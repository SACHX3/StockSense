package com.stocksense.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Entity
@Table(name = "sales_items")
@Data
@NoArgsConstructor
public class SaleItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sale_id", nullable = false)
    @JsonIgnore
    private Sale sale;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "product_id", nullable = false)
    @JsonIgnore
    private Product product;

    @Column(nullable = false)
    private Integer quantity;

    @Column(name = "unit_price", precision = 12, scale = 2)
    private BigDecimal unitPrice;

    @Column(name = "discount_percent", precision = 5, scale = 2)
    private BigDecimal discountPercent = BigDecimal.ZERO;

    @Column(name = "total_price", precision = 12, scale = 2)
    private BigDecimal totalPrice;

    // ── Transient getters for JSON serialization (no DB columns) ──────────
    // These read from the product entity but are NOT mapped to columns

    @Transient
    public Long getProductId() {
        return product != null ? product.getId() : null;
    }

    @Transient
    public String getProductName() {
        return product != null ? product.getName() : null;
    }

    @Transient
    public String getProductSku() {
        return product != null ? product.getSku() : null;
    }
}
