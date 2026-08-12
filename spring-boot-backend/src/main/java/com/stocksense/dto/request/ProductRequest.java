package com.stocksense.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class ProductRequest {
    @NotBlank(message = "Product name is required")
    @Size(max = 200)
    private String name;

    @NotBlank(message = "SKU is required")
    @Size(max = 100)
    private String sku;

    private String barcode;
    private String description;

    @NotNull(message = "Category is required")
    private Long categoryId;

    private Long supplierId;

    private String unit = "pcs";

    @NotNull @DecimalMin("0.00")
    private BigDecimal buyingPrice;

    @NotNull @DecimalMin("0.01")
    private BigDecimal sellingPrice;

    @NotNull @Min(0)
    private Integer quantity;

    @Min(0)
    private Integer minStockLevel = 10;

    @Min(0)
    private Integer maxStockLevel = 1000;
}
