"""OCR Router"""
import logging
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from services.ocr_service import ocr_service

logger = logging.getLogger(__name__)
router = APIRouter()


class OcrRequest(BaseModel):
    invoice_id: int
    file_path: str
    file_type: str = "IMAGE"


@router.post("/process")
async def process_invoice(request: OcrRequest):
    logger.info(f"OCR: id={request.invoice_id} file={request.file_path} type={request.file_type}")
    try:
        result = ocr_service.process_invoice(request.invoice_id, request.file_path, request.file_type)
        return result
    except Exception as e:
        logger.error(f"OCR error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/status")
async def ocr_status():
    return {
        "service": "OCR",
        "tesseract": ocr_service.tesseract_ok,
        "pdfplumber": ocr_service.pdfplumber_ok,
        "note": "If tesseract=false, only PDF invoices work. Install Tesseract for image support."
    }
