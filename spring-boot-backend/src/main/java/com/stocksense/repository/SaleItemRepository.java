package com.stocksense.repository;

import com.stocksense.entity.SaleItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDateTime;
import java.util.List;

public interface SaleItemRepository extends JpaRepository<SaleItem, Long> {

    @Query("SELECT si.product.id, si.product.name, SUM(si.quantity) as totalQty, SUM(si.totalPrice) as totalRevenue, si.product.imagePath FROM SaleItem si WHERE si.sale.createdAt BETWEEN :start AND :end GROUP BY si.product.id, si.product.name, si.product.imagePath ORDER BY totalQty DESC")
    List<Object[]> findTopSellingProducts(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    @Query("SELECT si.product.id, SUM(si.quantity) as totalQty FROM SaleItem si WHERE si.sale.createdAt >= :start GROUP BY si.product.id ORDER BY totalQty DESC")
    List<Object[]> findProductSalesHistory(@Param("start") LocalDateTime start);

    @Query("SELECT si.product.id, si.product.name, SUM(si.quantity) as totalQty FROM SaleItem si WHERE si.sale.createdAt BETWEEN :start AND :end GROUP BY si.product.id, si.product.name ORDER BY totalQty ASC")
    List<Object[]> findSlowMovingProducts(@Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    // Day-by-day sold quantity for ONE product - this is the real time series the AI
    // forecasting service (fastapi-service) needs to train on. Native SQL, matching the
    // pattern already used in SaleRepository for date grouping (Hibernate 6 compatible).
    @Query(value =
        "SELECT DATE(s.created_at) as sale_date, SUM(si.quantity) as qty " +
        "FROM sales_items si JOIN sales s ON si.sale_id = s.id " +
        "WHERE si.product_id = :productId AND s.created_at >= :start " +
        "GROUP BY DATE(s.created_at) ORDER BY sale_date ASC",
        nativeQuery = true)
    List<Object[]> findDailySalesForProduct(@Param("productId") Long productId, @Param("start") LocalDateTime start);
}
