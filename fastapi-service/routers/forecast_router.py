"""
Forecast Router - AI demand forecasting endpoints
POST /api/forecast/predict  -> predict demand for a product
POST /api/forecast/retrain  -> retrain model with latest data
"""
import logging
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from services.forecast_service import generate_forecast, retrain_model

logger = logging.getLogger(__name__)
router = APIRouter()


class ForecastRequest(BaseModel):
    product_id: int
    forecast_days: int = 30
    sales_history: Optional[List[dict]] = []


class RetrainRequest(BaseModel):
    sales_history: Optional[dict] = {}


@router.post("/predict")
async def predict_demand(request: ForecastRequest):
    """Generate demand forecast for a product"""
    try:
        result = generate_forecast(request.product_id, request.forecast_days, request.sales_history)
        return result
    except Exception as e:
        logger.error(f"Forecast error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/retrain")
async def retrain(request: RetrainRequest):
    """Retrain the forecasting model"""
    try:
        result = retrain_model()
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/status")
async def forecast_status():
    """Check forecasting service status"""
    try:
        import sklearn
        import numpy
        import pandas
        return {
            "service": "Forecasting",
            "available": True,
            "libraries": {
                "scikit-learn": sklearn.__version__,
                "numpy": numpy.__version__,
                "pandas": pandas.__version__
            }
        }
    except Exception as e:
        return {"service": "Forecasting", "available": False, "error": str(e)}
