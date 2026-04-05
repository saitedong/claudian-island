#!/usr/bin/env python3
"""
PermissionRequest hook for ClaudianIsland.
- Reads Claude Code's hook JSON from stdin
- Sends permission_request to the island socket
- Waits for allow/deny response
- Prints Claude Code hook decision to stdout
"""
import sys
import json
import socket
import uuid

SOCKET_PATH = "/tmp/claudian-island.sock"

def main():
    # Read hook input
    try:
        hook_input = json.load(sys.stdin)
    except Exception:
        hook_input = {}

    tool_name = hook_input.get("tool_name", hook_input.get("tool", "unknown"))
    request_id = str(uuid.uuid4())

    payload = json.dumps({
        "type": "permission_request",
        "tool": tool_name,
        "id": request_id
    }) + "\n"

    # Connect to island socket
    try:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.connect(SOCKET_PATH)
        sock.sendall(payload.encode("utf-8"))

        # Wait for response (blocks until user taps allow/deny)
        sock.settimeout(60)
        response_data = b""
        while True:
            chunk = sock.recv(256)
            if not chunk:
                break
            response_data += chunk

        sock.close()

        response = json.loads(response_data.decode("utf-8").strip())
        decision = response.get("decision", "ask")
    except Exception:
        # If app not running or timeout, fall through to ask
        decision = "ask"

    # Output Claude Code hook decision
    print(json.dumps({"decision": decision}))

if __name__ == "__main__":
    main()
