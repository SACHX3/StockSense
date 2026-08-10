package com.stocksense.repository;

import com.stocksense.entity.Invoice;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface InvoiceRepository extends JpaRepository<Invoice, Long> {
    Page<Invoice> findAllByOrderByCreatedAtDesc(Pageable pageable);
    List<Invoice> findByOcrStatus(Invoice.OcrStatus status);
    List<Invoice> findByIsAppliedFalseAndOcrStatus(Invoice.OcrStatus status);
}
