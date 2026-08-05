"""
StockSense Inventory - FastAPI AI & OCR Service
Start: python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import ocr_router, forecast_router

app = FastAPI(
    title="StockSense Inventory AI Service",
    description="OCR Invoice Processing + AI Demand Forecasting",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ocr_router.router,      prefix="/api/ocr",      tags=["OCR"])
app.include_router(forecast_router.router, prefix="/api/forecast",  tags=["Forecast"])

@app.get("/")
def root():
    return {"status": "running", "service": "StockSense Inventory AI Service", "version": "1.0.0"}

@app.get("/health")
def health():
    return {"status": "healthy"}
