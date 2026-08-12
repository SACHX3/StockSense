package com.stocksense.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class SaleRequest {
    private String customerName;
    private String customerPhone;
    private String paymentMethod = "CASH";
    private String notes;
    private BigDecimal discountAmount = BigDecimal.ZERO;

    @NotEmpty(message = "Sale items required")
    private List<SaleItemRequest> items;

    @Data
    public static class SaleItemRequest {
        @NotNull private Long productId;
        @NotNull @Min(1) private Integer quantity;
        @NotNull private BigDecimal unitPrice;
        private BigDecimal discountPercent = BigDecimal.ZERO;
    }
}
