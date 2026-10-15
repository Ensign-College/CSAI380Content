# GKE nodes are amd64 — on Apple Silicon build with: docker build --platform linux/amd64 ...
FROM python:3.12-slim
WORKDIR /app
COPY app/ .
EXPOSE 8080
CMD ["python", "server.py"]
