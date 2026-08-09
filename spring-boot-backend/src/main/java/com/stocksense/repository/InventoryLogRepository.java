package com.stocksense.repository;

import com.stocksense.entity.InventoryLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import java.time.LocalDateTime;
import java.util.List;

public interface InventoryLogRepository extends JpaRepository<InventoryLog, Long> {
    Page<InventoryLog> findByProductIdOrderByCreatedAtDesc(Long productId, Pageable pageable);

    @Query("SELECT il FROM InventoryLog il ORDER BY il.createdAt DESC")
    Page<InventoryLog> findAllOrderByCreatedAtDesc(Pageable pageable);

    List<InventoryLog> findByCreatedAtBetween(LocalDateTime start, LocalDateTime end);
}
