import os
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

app = FastAPI()

# ✅ Health check for Railway
@app.get("/health")
def health():
    return {"status": "ok"}

# ✅ Serve frontend
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
