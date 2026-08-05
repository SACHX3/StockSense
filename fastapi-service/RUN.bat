@echo off
title StockSense FastAPI
color 0A

echo.
echo ============================================
echo  StockSense - FastAPI AI/OCR Service
echo ============================================
echo.

:: ── Step 1: Check Python ──────────────────────
python --version >nul 2>&1
IF ERRORLEVEL 1 (
    echo [ERROR] Python not found.
    echo Install Python 3.11 from https://python.org
    echo CHECK "Add Python to PATH" during install!
    pause
    exit /b 1
)
echo [OK] Python: & python --version

:: ── Step 2: Delete broken venv ────────────────
IF EXIST venv (
    echo [INFO] Deleting old broken venv...
    rmdir /s /q venv
    echo [OK] Old venv deleted.
)

:: ── Step 3: Install to system Python ──────────
echo.
echo [INSTALLING] This takes 2-3 minutes first time...
echo.
python -m pip install --upgrade pip --quiet --no-warn-script-location
python -m pip install fastapi==0.104.1 --quiet --no-warn-script-location
python -m pip install "uvicorn[standard]==0.24.0" --quiet --no-warn-script-location
python -m pip install python-multipart==0.0.6 --quiet --no-warn-script-location
python -m pip install Pillow --quiet --no-warn-script-location
python -m pip install pytesseract --quiet --no-warn-script-location
python -m pip install pdfplumber --quiet --no-warn-script-location
python -m pip install pandas --quiet --no-warn-script-location
python -m pip install scikit-learn --quiet --no-warn-script-location
python -m pip install joblib --quiet --no-warn-script-location
echo [OK] All packages installed.

:: ── Step 4: Tesseract check ───────────────────
echo.
tesseract --version >nul 2>&1
IF ERRORLEVEL 1 (
    echo [WARNING] Tesseract not installed.
    echo           PDF invoices work fine WITHOUT Tesseract.
    echo           For IMAGE OCR install from:
    echo           https://github.com/UB-Mannheim/tesseract/wiki
) ELSE (
    echo [OK] Tesseract found.
)

:: ── Step 5: Start server ──────────────────────
echo.
echo ============================================
echo  Server: http://localhost:8000
echo  Docs:   http://localhost:8000/docs
echo  Press Ctrl+C to stop
echo ============================================
echo.
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload

pause
