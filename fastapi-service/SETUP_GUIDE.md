# StockSense FastAPI Service - Setup Guide

## What This Service Does
- **OCR Invoice Processing**: Reads text from invoice images/PDFs using Tesseract
- **AI Demand Forecasting**: Predicts future product demand using Random Forest ML

---

## Step 1: Install Tesseract OCR (REQUIRED for Image OCR)

### Windows:
1. Download installer from: https://github.com/UB-Mannheim/tesseract/wiki
2. Download: `tesseract-ocr-w64-setup-5.x.x.exe`
3. Install to: `C:\Program Files\Tesseract-OCR\`
4. **IMPORTANT**: During install, check "Add to PATH"
5. Verify: Open CMD and type `tesseract --version`

### Mac:
```bash
brew install tesseract
```

### Linux (Ubuntu):
```bash
sudo apt-get install tesseract-ocr
```

---

## Step 2: Install Python Dependencies

Open CMD/Terminal in the `fastapi-service` folder:

```bash
pip install -r requirements.txt
```

This installs:
- `fastapi` + `uvicorn` - web server
- `pytesseract` + `Pillow` - image OCR
- `pdfplumber` - PDF text extraction
- `scikit-learn` + `pandas` + `numpy` - AI forecasting

---

## Step 3: Start the Service

### Windows:
```
Double-click: start.bat
```
Or in CMD:
```bash
cd fastapi-service
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Mac/Linux:
```bash
cd fastapi-service
chmod +x start.sh
./start.sh
```

---

## Step 4: Verify it's Running

Open browser: http://localhost:8000

You should see:
```json
{"status": "running", "service": "StockSense Inventory AI Service", "version": "1.0.0"}
```

Check OCR status: http://localhost:8000/api/ocr/status
Check Forecast status: http://localhost:8000/api/forecast/status

---

## Step 5: Test OCR with Sample Invoice

### Option A - Via the Web App:
1. Spring Boot must be running at http://localhost:8080
2. Login → OCR Invoices → Upload Invoice
3. Upload the `sample_invoice.png` or `sample_invoice.pdf`
4. Click "Process OCR"

### Option B - Direct API Test:
```bash
curl -X POST http://localhost:8000/api/ocr/process \
  -H "Content-Type: application/json" \
  -d '{"invoice_id": 1, "file_path": "uploads/invoices/your_file.png", "file_type": "IMAGE"}'
```

---

## Both Services Must Run Together

| Service | URL | How to Start |
|---------|-----|--------------|
| Spring Boot (Backend) | http://localhost:8080 | Run from IntelliJ/Eclipse |
| FastAPI (AI/OCR) | http://localhost:8000 | Run `start.bat` in fastapi-service folder |

---

## Troubleshooting

### "Connection refused: connect" in Spring Boot logs
→ FastAPI service is not running. Start it with `start.bat`.

### "Tesseract not found" error
→ Install Tesseract from the link above. PDF invoices still work without it.

### OCR extracted wrong text
→ Use a clearer, higher-resolution invoice image. PDF usually gives better results.

### "scikit-learn not found"
→ Run: `pip install scikit-learn pandas numpy`
