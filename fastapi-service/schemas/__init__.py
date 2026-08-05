"""
Pydantic schemas for request/response validation
"""
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import date


class SalesDataPoint(BaseModel):
    date: str
    quantity: int
    product_id: Optional[int] = None


class ForecastRequest(BaseModel):
    product_id: int
    forecast_days: int = 30
    sales_history: Optional[List[Dict[str, Any]]] = None


class ForecastPrediction(BaseModel):
    date: str
    predicted_demand: int
    confidence_lower: int
    confidence_upper: int


class ForecastResponse(BaseModel):
    product_id: int
    forecast_days: int
    model: str
    predictions: List[ForecastPrediction]
    mae: Optional[float] = None
    rmse: Optional[float] = None
    message: str = "Forecast generated successfully"


class RetrainRequest(BaseModel):
    sales_history: Optional[Dict[str, Any]] = None


class RetrainResponse(BaseModel):
    status: str
    message: str
    model_version: Optional[str] = None
    training_records: Optional[int] = None


class OCRRequest(BaseModel):
    invoice_id: int
    file_path: str
    file_type: str  # IMAGE or PDF


class OCRItemResult(BaseModel):
    product_name: str
    quantity: Optional[int] = None
    unit_price: Optional[float] = None
    total_price: Optional[float] = None
    confidence: float = 0.0


class OCRResponse(BaseModel):
    invoice_id: int
    status: str
    raw_text: Optional[str] = None
    items: List[OCRItemResult] = []
    total_amount: Optional[float] = None
    invoice_date: Optional[str] = None
    message: str = "OCR processing complete"
