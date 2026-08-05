@echo off
title StockSense - FastAPI AI/OCR Service
color 0A

echo.
echo  ==========================================
echo   StockSense - FastAPI AI/OCR Service
echo  ==========================================
echo.

REM ── Check Python ────────────────────────────────────────────────────────
python --version >nul 2>&1
IF ERRORLEVEL 1 (
    echo  [ERROR] Python is not installed or not in PATH.
    echo  Download Python 3.11 from: https://www.python.org/downloads/
    echo  IMPORTANT: Check "Add Python to PATH" during installation.
    pause
    exit /b 1
)
echo  [OK] Python found:
python --version

REM ── Delete broken venv if it exists ─────────────────────────────────────
IF EXIST venv (
    echo  [INFO] Removing old virtual environment...
    rmdir /s /q venv
)

REM ── Create fresh virtual environment ────────────────────────────────────
echo  [1/4] Creating virtual environment...
python -m venv venv
IF ERRORLEVEL 1 (
    echo  [ERROR] Failed to create virtual environment.
    pause
    exit /b 1
)

REM ── Activate venv ────────────────────────────────────────────────────────
call venv\Scripts\activate.bat
echo  [OK] Virtual environment activated.

REM ── Upgrade pip first ────────────────────────────────────────────────────
echo  [2/4] Upgrading pip...
python -m pip install --upgrade pip --quiet

REM ── Install packages one by one (more reliable) ──────────────────────────
echo  [3/4] Installing packages...
echo         Installing fastapi...
pip install "fastapi==0.104.1" --quiet
echo         Installing uvicorn...
pip install "uvicorn[standard]==0.24.0" --quiet
echo         Installing python-multipart...
pip install "python-multipart==0.0.6" --quiet
echo         Installing Pillow (pre-built wheel)...
pip install Pillow --quiet
echo         Installing pytesseract...
pip install pytesseract --quiet
echo         Installing pdfplumber...
pip install pdfplumber --quiet
echo         Installing numpy...
pip install numpy --quiet
echo         Installing pandas...
pip install pandas --quiet
echo         Installing scikit-learn...
pip install scikit-learn --quiet
echo         Installing joblib...
pip install joblib --quiet
echo         Installing requests...
pip install requests --quiet

REM ── Check Tesseract ──────────────────────────────────────────────────────
echo.
echo  [4/4] Checking Tesseract OCR...
tesseract --version >nul 2>&1
IF ERRORLEVEL 1 (
    echo  [WARNING] Tesseract NOT found.
    echo  -----------------------------------------------------------
    echo  For IMAGE invoice OCR, install Tesseract:
    echo  https://github.com/UB-Mannheim/tesseract/wiki
    echo  Download: tesseract-ocr-w64-setup-5.x.x.exe
    echo  Install to: C:\Program Files\Tesseract-OCR\
    echo  Check "Add to PATH" during install, then restart this script.
    echo  -----------------------------------------------------------
    echo  PDF invoices will still work without Tesseract.
    echo.
) ELSE (
    echo  [OK] Tesseract found.
)

REM ── Start FastAPI ────────────────────────────────────────────────────────
echo.
echo  ==========================================
echo   Starting server on http://localhost:8000
echo   API Docs: http://localhost:8000/docs
echo   Press Ctrl+C to stop
echo  ==========================================
echo.

python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload

pause
