@echo off
title StockSense FastAPI Service
color 0B

echo.
echo  ==========================================
echo   StockSense - FastAPI AI/OCR Service  
echo   SIMPLE INSTALLER (no venv)
echo  ==========================================
echo.

REM Check Python
python --version >nul 2>&1
IF ERRORLEVEL 1 (
    echo [ERROR] Python not found! 
    echo Download from: https://www.python.org/downloads/
    echo MUST check "Add Python to PATH" during install
    pause
    exit /b 1
)
echo [OK] Using system Python:
python --version
echo.

echo [STEP 1] Upgrading pip...
python -m pip install --upgrade pip

echo.
echo [STEP 2] Installing all packages...
python -m pip install fastapi "uvicorn[standard]" python-multipart Pillow pytesseract pdfplumber numpy pandas scikit-learn joblib requests

echo.
echo [STEP 3] Checking Tesseract...
tesseract --version >nul 2>&1
IF ERRORLEVEL 1 (
    echo [WARNING] Tesseract not found - IMAGE OCR will not work
    echo [INFO]    PDF invoices work fine without Tesseract
    echo [INFO]    Install from: https://github.com/UB-Mannheim/tesseract/wiki
) ELSE (
    echo [OK] Tesseract is installed
)

echo.
echo  ==========================================
echo   Server starting at http://localhost:8000
echo   Open this URL to confirm it is running
echo   Press Ctrl+C to stop
echo  ==========================================
echo.

python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload

pause
