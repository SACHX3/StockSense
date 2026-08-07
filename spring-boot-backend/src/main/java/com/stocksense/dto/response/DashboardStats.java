package com.stocksense.dto.response;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;

@Data
public class DashboardStats {
    private long totalProducts;
    private long totalSuppliers;
    private long lowStockProducts;
    private long totalUsers;
    private BigDecimal todayRevenue;
    private BigDecimal monthlyRevenue;
    private long todaySalesCount;
    private long monthlySalesCount;
    private List<MonthlyRevenue> monthlyRevenueChart;
    private List<TopProduct> topSellingProducts;
    private List<TopProduct> slowMovingProducts;
    private List<LowStockProduct> lowStockItems;

    @Data
    public static class MonthlyRevenue {
        private String month;
        private BigDecimal revenue;
        private long count;
    }

    private List<DailySales> dailySalesChart;

    @Data
    public static class DailySales {
        private int day;
        private String label;
        private BigDecimal revenue;
        private long count;
    }

    @Data
    public static class TopProduct {
        private Long productId;
        private String productName;
        private String imagePath;
        private long quantity;
        private BigDecimal revenue;
    }

    @Data
    public static class LowStockProduct {
        private Long id;
        private String name;
        private String sku;
        private String unit;
        private String imagePath;
        private int quantity;
        private int minStockLevel;
    }
}
