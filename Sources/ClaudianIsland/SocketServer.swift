import Foundation

final class SocketServer {
    private let socketPath = "/tmp/claudian-island.sock"
    private var serverFd: Int32 = -1
    private let viewModel = IslandViewModel.shared

    func start() {
        // Clean up stale socket
        try? FileManager.default.removeItem(atPath: socketPath)

        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.runLoop()
        }
    }

    private func runLoop() {
        serverFd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard serverFd >= 0 else {
            print("[Island] socket() failed: \(errno)")
            return
        }

        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        let pathBytes = Array(socketPath.utf8)
        withUnsafeMutableBytes(of: &addr.sun_path) { rawBuf in
            for (i, byte) in pathBytes.enumerated() {
                rawBuf[i] = byte
            }
        }

        let bindResult = withUnsafePointer(to: &addr) { ptr -> Int32 in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                bind(serverFd, $0, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }
        guard bindResult == 0 else {
            print("[Island] bind() failed: \(errno)")
            close(serverFd)
            return
        }

        guard listen(serverFd, 10) == 0 else {
            print("[Island] listen() failed: \(errno)")
            close(serverFd)
            return
        }

        print("[Island] Listening on \(socketPath)")

        while true {
            let clientFd = accept(serverFd, nil, nil)
            guard clientFd >= 0 else { continue }
            DispatchQueue.global().async { [weak self] in
                self?.handleClient(clientFd)
            }
        }
    }

    private func handleClient(_ fd: Int32) {
        var buffer = [UInt8](repeating: 0, count: 8192)
        let n = read(fd, &buffer, buffer.count - 1)
        guard n > 0 else { close(fd); return }

        let data = Data(bytes: buffer, count: n)
        let rawString = String(data: data, encoding: .utf8) ?? "<binary>"
        let ts = ISO8601DateFormatter().string(from: Date())
        print("[Island \(ts)] recv: \(rawString.trimmingCharacters(in: .whitespacesAndNewlines))")

        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let type_ = json["type"] as? String
        else {
            print("[Island] invalid JSON, closing")
            close(fd)
            return
        }

        switch type_ {
        case "stop":
            DispatchQueue.main.async { self.viewModel.scheduleStop() }
            close(fd)

        case "tool_activity":
            // Claude 正在调用工具 → 取消待弹的 ✓（还在干活）
            DispatchQueue.main.async { self.viewModel.cancelPendingStop() }
            close(fd)

        case "notification":
            let msg = json["message"] as? String ?? "通知"
            DispatchQueue.main.async { self.viewModel.transitionTo(.notification(message: msg)) }
            close(fd)

        case "question_pending":
            let id = json["id"] as? String ?? UUID().uuidString
            DispatchQueue.main.async { self.viewModel.transitionTo(.question(id: id)) }
            close(fd)

        case "dismiss_question":
            DispatchQueue.main.async {
                if case .question = self.viewModel.state {
                    self.viewModel.transitionTo(.idle)
                }
            }
            close(fd)

        case "permission_pending":
            let tool = json["tool"] as? String ?? "unknown"
            // 只做通知，不阻塞。用户点击后跳 Obsidian 处理审批。
            // tool_activity 或 stop 会自动清除这个状态。
            DispatchQueue.main.async {
                self.viewModel.transitionTo(.permission(tool: tool, id: ""))
            }
            close(fd)

        default:
            close(fd)
        }
    }
}
