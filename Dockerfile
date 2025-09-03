# -----------------------------
# 1. Frontend build (React + Vite)
# -----------------------------
    FROM node:18-alpine AS frontend-builder

    WORKDIR /app/frontend
    
    # Install dependencies (include dev for vite)
    COPY frontend/package*.json ./
    RUN npm install
    
    # Copy all frontend files and build
    COPY frontend/ .
    RUN npm run build
    
    
    # -----------------------------
    # 2. Backend build (FastAPI + Python)
    # -----------------------------
    FROM python:3.11-slim AS backend
    
    WORKDIR /app
    
    # Install system deps
    RUN apt-get update && apt-get install -y --no-install-recommends build-essential && \
        rm -rf /var/lib/apt/lists/*
    
    # Copy and install Python deps
    COPY requirements.txt .
    RUN pip install --no-cache-dir -r requirements.txt
    
    # Copy backend + frontend dist
    COPY . .
    COPY --from=frontend-builder /app/frontend/dist ./frontend/dist
    
    # Railway sets $PORT automatically
    CMD ["sh", "-c", "uvicorn run:app --host 0.0.0.0 --port ${PORT}"]
    