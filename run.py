import os
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import uvicorn

app = FastAPI()

# ✅ Health check for Railway
@app.get("/health")
def health():
    return {"status": "ok"}

# ✅ Serve frontend (React build)
frontend_dir = os.path.join(os.path.dirname(__file__), "frontend", "dist")
if os.path.exists(frontend_dir):
    app.mount("/static", StaticFiles(directory=os.path.join(frontend_dir, "assets")), name="static")

    @app.get("/")
    async def serve_index():
        return FileResponse(os.path.join(frontend_dir, "index.html"))
else:
    @app.get("/")
    async def root():
        return {"message": "Frontend not built yet"}

# ✅ Example API route
@app.get("/query")
def query(q: str):
    return {"answer": f"You asked: {q}"}

# ✅ Local run support
if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))  # Railway gives $PORT, else fallback
    uvicorn.run("run:app", host="0.0.0.0", port=port, reload=False)
