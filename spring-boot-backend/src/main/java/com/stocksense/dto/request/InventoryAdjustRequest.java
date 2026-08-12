package com.stocksense.dto.request;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class InventoryAdjustRequest {
    @NotNull private Long productId;
    @NotBlank private String movementType;
    // For STOCK_IN/STOCK_OUT/RETURN/DAMAGED/INVOICE_UPDATE this is a delta (must move stock),
    // but for ADJUSTMENT (see InventoryService) it's the new absolute quantity, and writing
    // stock down to exactly 0 is a legitimate operation - so the floor is 0, not 1.
    @NotNull @Min(0) private Integer quantity;
    private String referenceNo;
    private String notes;
}
