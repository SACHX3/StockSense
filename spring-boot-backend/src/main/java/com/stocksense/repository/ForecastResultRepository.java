package com.stocksense.repository;

import com.stocksense.entity.ForecastResult;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;

public interface ForecastResultRepository extends JpaRepository<ForecastResult, Long> {
    List<ForecastResult> findByProductIdAndForecastDateAfterOrderByForecastDateAsc(Long productId, LocalDate date);
    List<ForecastResult> findTop30ByProductIdOrderByForecastDateDesc(Long productId);
    void deleteByProductId(Long productId);
}
