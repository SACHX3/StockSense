package com.stocksense.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "forecast_results")
@Data
@NoArgsConstructor
public class ForecastResult {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @Column(name = "forecast_date")
    private LocalDate forecastDate;

    @Column(name = "predicted_demand")
    private Integer predictedDemand;

    @Column(name = "confidence_lower")
    private Integer confidenceLower;

    @Column(name = "confidence_upper")
    private Integer confidenceUpper;

    @Column(name = "model_version", length = 50)
    private String modelVersion;

    @Column(precision = 10, scale = 4)
    private BigDecimal mae;

    @Column(precision = 10, scale = 4)
    private BigDecimal rmse;

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();
}
