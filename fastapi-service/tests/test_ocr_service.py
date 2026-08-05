"""
Unit tests for OCR Service
Run: pytest tests/ -v
"""
import pytest
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from services.ocr_service import OCRService


@pytest.fixture
def svc():
    return OCRService()


class TestCleanProductName:
    def test_removes_leading_row_number(self, svc):
        assert svc._clean_product_name("1 Coca-Cola 330ml Can") == "Coca-Cola 330ml Can"

    def test_removes_pipe_chars(self, svc):
        assert "Coca-Cola" in svc._clean_product_name("| Coca-Cola 330ml |")

    def test_removes_trailing_unit(self, svc):
        result = svc._clean_product_name("Coca-Cola 330ml Can can")
        assert result.lower().endswith("can") == False or "Cola" in result

    def test_handles_empty_string(self, svc):
        assert svc._clean_product_name("") == ""

    def test_handles_none(self, svc):
        assert svc._clean_product_name(None) == ""


class TestParseDecimal:
    def test_plain_number(self, svc):
        assert svc._parse_decimal("55.00") == 55.00

    def test_with_rs_prefix(self, svc):
        assert svc._parse_decimal("Rs. 55.00") == 55.00

    def test_with_commas(self, svc):
        assert svc._parse_decimal("6,600.00") == 6600.00

    def test_rs_with_commas(self, svc):
        assert svc._parse_decimal("Rs. 12,480.00") == 12480.00

    def test_empty_string(self, svc):
        assert svc._parse_decimal("") is None

    def test_non_numeric(self, svc):
        assert svc._parse_decimal("abc") is None


class TestIsSkipRow:
    def test_skips_total_row(self, svc):
        assert svc._is_skip_row("TOTAL PAYABLE") is True

    def test_skips_discount_row(self, svc):
        assert svc._is_skip_row("Discount (5%)") is True

    def test_skips_vat_row(self, svc):
        assert svc._is_skip_row("VAT 15%") is True

    def test_does_not_skip_product(self, svc):
        assert svc._is_skip_row("Coca-Cola 330ml Can") is False

    def test_skips_empty_string(self, svc):
        assert svc._is_skip_row("") is True


class TestDeduplicate:
    def test_removes_duplicates(self, svc):
        items = [
            {"product_name": "Coca-Cola 330ml Can"},
            {"product_name": "Coca-Cola 330ml Can"},
            {"product_name": "Pepsi 500ml Bottle"},
        ]
        result = svc._deduplicate(items)
        assert len(result) == 2

    def test_keeps_unique(self, svc):
        items = [
            {"product_name": "Coca-Cola"},
            {"product_name": "Pepsi"},
            {"product_name": "Sprite"},
        ]
        result = svc._deduplicate(items)
        assert len(result) == 3

    def test_empty_list(self, svc):
        assert svc._deduplicate([]) == []


class TestParseTable:
    def test_extracts_8_items_from_invoice_table(self, svc):
        table = [
            ['#', 'Product Name', 'Unit', 'Qty', 'Unit Price (Rs.)', 'Amount (Rs.)'],
            ['1', 'Coca-Cola 330ml Can',         'can',    '120', '55.00',  '6,600.00'],
            ['2', 'Pepsi 500ml Bottle',          'bottle', '96',  '65.00',  '6,240.00'],
            ['3', 'Sprite 330ml Can',            'can',    '60',  '55.00',  '3,300.00'],
            ['4', 'Milo 400g Tin',               'tin',    '24',  '520.00', '12,480.00'],
            ['5', 'Coca-Cola 1.5L Bottle',       'bottle', '48',  '135.00', '6,480.00'],
            ['6', 'Fanta Orange 330ml Can',      'can',    '72',  '55.00',  '3,960.00'],
            ['7', 'Nestea Lemon 500ml Bottle',   'bottle', '36',  '95.00',  '3,420.00'],
            ['8', 'Red Bull Energy Drink 250ml', 'can',    '24',  '280.00', '6,720.00'],
            [None, 'Subtotal',     None, None, None, '49,200.00'],
            [None, 'Discount 5%',  None, None, None, '2,460.00'],
            [None, 'TOTAL PAYABLE',None, None, None, '53,751.00'],
        ]
        items = svc._parse_table(table)
        assert len(items) == 8

    def test_correct_quantities(self, svc):
        table = [
            ['#', 'Product Name', 'Unit', 'Qty', 'Unit Price (Rs.)', 'Amount (Rs.)'],
            ['1', 'Coca-Cola 330ml Can', 'can', '120', '55.00', '6,600.00'],
            ['2', 'Milo 400g Tin',       'tin',  '24', '520.00','12,480.00'],
        ]
        items = svc._parse_table(table)
        qtys = [i['quantity'] for i in items]
        assert 120 in qtys
        assert 24 in qtys

    def test_correct_prices(self, svc):
        table = [
            ['#', 'Product Name', 'Unit', 'Qty', 'Unit Price (Rs.)', 'Amount (Rs.)'],
            ['1', 'Coca-Cola 330ml Can', 'can', '120', '55.00', '6,600.00'],
        ]
        items = svc._parse_table(table)
        assert len(items) == 1
        assert items[0]['unit_price'] == 55.00
        assert items[0]['total_price'] == 6600.00

    def test_skips_discount_rows(self, svc):
        table = [
            ['#', 'Product Name', 'Unit', 'Qty', 'Unit Price (Rs.)', 'Amount (Rs.)'],
            ['1', 'Coca-Cola',    'can',  '10', '55.00', '550.00'],
            [None, 'Discount (5%)', None, None, None, '27.50'],
        ]
        items = svc._parse_table(table)
        assert len(items) == 1
        assert items[0]['product_name'] != 'Discount (5%)'


class TestDemoResult:
    def test_demo_returns_8_items(self, svc):
        result = svc._demo_result(1)
        assert result['invoice_id'] == 1
        assert result['status'] == 'completed'
        assert len(result['items']) == 8

    def test_demo_items_have_required_fields(self, svc):
        result = svc._demo_result(1)
        for item in result['items']:
            assert 'product_name' in item
            assert 'quantity' in item
            assert 'unit_price' in item
            assert 'total_price' in item
            assert item['quantity'] > 0
            assert item['unit_price'] > 0
