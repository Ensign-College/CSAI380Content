"""Minimal web app for CSAI 380 — the image you build, push, and deploy in 1.4."""
import http.server
import os

PORT = int(os.environ.get("PORT", "8080"))
STUDENT = os.environ.get("STUDENT_NAME", "<your-name>")


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        body = f"Hello from {STUDENT}'s container! Path: {self.path}\n".encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


if __name__ == "__main__":
    print(f"Listening on :{PORT}")
    http.server.HTTPServer(("", PORT), Handler).serve_forever()
