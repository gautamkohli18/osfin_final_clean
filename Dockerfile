# -----------------------------
# 1. Frontend build (React + Vite)
# -----------------------------
    FROM node:18-alpine AS frontend-builder

    WORKDIR /app/frontend
    
    COPY frontend/package*.json ./
    RUN npm install
    
    COPY frontend/ .
    RUN npm run build
    
    
    # -----------------------------
    # 2. Backend build (FastAPI + Python)
    # -----------------------------
    FROM python:3.11-slim AS backend
    
    WORKDIR /app
    
    RUN apt-get update && apt-get install -y --no-install-recommends build-essential && \
        rm -rf /var/lib/apt/lists/*
    
    COPY requirements.txt .
    RUN pip install --no-cache-dir -r requirements.txt
    
    COPY . .
    
    # Copy built frontend
    COPY --from=frontend-builder /app/frontend/dist ./frontend/dist
    
    EXPOSE 8000
    CMD exec uvicorn run:app --host 0.0.0.0 --port ${PORT:-8000}
    
