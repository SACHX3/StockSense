package com.stocksense.service;

import com.stocksense.dto.response.DashboardStats;
import com.stocksense.entity.Product;
import com.stocksense.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class DashboardService {

    private final ProductRepository   productRepository;
    private final SupplierRepository  supplierRepository;
    private final UserRepository      userRepository;
    private final SaleRepository      saleRepository;
    private final SaleService         saleService;
    private final SaleItemRepository  saleItemRepository;
    private final ProductService      productService;

    public DashboardStats getDashboardStats() {
        DashboardStats stats = new DashboardStats();

        try { stats.setTotalProducts(productService.countActive()); }
        catch (Exception e) { log.warn("countActive err: {}", e.getMessage()); }

        try { stats.setTotalSuppliers(supplierRepository.findByIsActiveTrue().size()); }
        catch (Exception e) { log.warn("suppliers err: {}", e.getMessage()); }

        try { stats.setLowStockProducts(productService.countLowStock()); }
        catch (Exception e) { log.warn("lowStock err: {}", e.getMessage()); }

        try { stats.setTotalUsers(userRepository.count()); }
        catch (Exception e) { log.warn("users err: {}", e.getMessage()); }

        try { stats.setTodayRevenue(nullSafe(saleService.getTodayRevenue())); }
        catch (Exception e) { stats.setTodayRevenue(BigDecimal.ZERO); }

        try { stats.setMonthlyRevenue(nullSafe(saleService.getMonthlyRevenue())); }
        catch (Exception e) { stats.setMonthlyRevenue(BigDecimal.ZERO); }

        try { stats.setTodaySalesCount(saleService.getTodaySalesCount()); }
        catch (Exception e) { log.warn("todaySalesCount err: {}", e.getMessage()); }

        try { stats.setDailySalesChart(buildDailyChart()); }
        catch (Exception e) { stats.setDailySalesChart(new ArrayList<>()); log.error("dailyChart err: {}", e.getMessage(), e); }

        try { stats.setMonthlyRevenueChart(buildMonthlyChart()); }
        catch (Exception e) { stats.setMonthlyRevenueChart(new ArrayList<>()); log.error("monthlyChart err: {}", e.getMessage(), e); }

        try { stats.setTopSellingProducts(buildTopProducts()); }
        catch (Exception e) { stats.setTopSellingProducts(new ArrayList<>()); log.warn("topProducts err: {}", e.getMessage()); }

        try { stats.setLowStockItems(buildLowStockList()); }
        catch (Exception e) { stats.setLowStockItems(new ArrayList<>()); log.warn("lowStockItems err: {}", e.getMessage()); }

        return stats;
    }

    // ── Daily chart: last 30 days ──────────────────────────────────
    private List<DashboardStats.DailySales> buildDailyChart() {
        LocalDate today = LocalDate.now();
        LocalDate from  = today.minusDays(29);
        LocalDateTime start = from.atStartOfDay();
        LocalDateTime end   = today.atTime(23, 59, 59);

        List<Object[]> rows = saleRepository.getDailyRevenue(start, end);

        // DB returns DATE(created_at) as String "YYYY-MM-DD" or java.sql.Date
        Map<String, BigDecimal> revMap = new HashMap<>();
        Map<String, Long>       cntMap = new HashMap<>();
        for (Object[] row : rows) {
            try {
                // row[0] = DATE() result - convert to LocalDate string "YYYY-MM-DD"
                String dateKey = row[0].toString().substring(0, 10); // "YYYY-MM-DD"
                BigDecimal rev = row[1] != null ? new BigDecimal(row[1].toString()) : BigDecimal.ZERO;
                long       cnt = row[2] != null ? ((Number) row[2]).longValue() : 0L;
                revMap.put(dateKey, rev);
                cntMap.put(dateKey, cnt);
            } catch (Exception e) { log.warn("Daily row parse: {}", e.getMessage()); }
        }

        // Fill all 30 days, 0 for days with no sales
        List<DashboardStats.DailySales> chart = new ArrayList<>();
        DateTimeFormatter labelFmt = DateTimeFormatter.ofPattern("dd MMM");

        for (int i = 29; i >= 0; i--) {
            LocalDate  date    = today.minusDays(i);
            String     dateKey = date.toString(); // "YYYY-MM-DD"

            DashboardStats.DailySales ds = new DashboardStats.DailySales();
            ds.setDay(date.getDayOfMonth());
            ds.setLabel(date.format(labelFmt));    // "01 Jun", "31 May" etc.
            ds.setRevenue(revMap.getOrDefault(dateKey, BigDecimal.ZERO));
            ds.setCount(cntMap.getOrDefault(dateKey, 0L));
            chart.add(ds);
        }
        log.info("Daily chart: 30 days ({} to {}), {} days with sales",
                from, today, revMap.size());
        return chart;
    }

    // ── Monthly chart: last 12 months ───────────────────────────────
    private List<DashboardStats.MonthlyRevenue> buildMonthlyChart() {
        LocalDateTime start = LocalDateTime.now().minusMonths(11)
                .withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0);
        List<Object[]> rows = saleRepository.getMonthlyRevenue(start);

        Map<String, BigDecimal> revMap = new LinkedHashMap<>();
        Map<String, Long>       cntMap = new LinkedHashMap<>();
        for (Object[] row : rows) {
            try {
                int        yr  = ((Number) row[0]).intValue();
                int        mo  = ((Number) row[1]).intValue();
                BigDecimal rev = row[2] != null ? new BigDecimal(row[2].toString()) : BigDecimal.ZERO;
                long       cnt = row[3] != null ? ((Number) row[3]).longValue() : 0L;
                String     key = yr + "-" + mo;
                revMap.put(key, rev);
                cntMap.put(key, cnt);
            } catch (Exception e) { log.warn("Monthly parse: {}", e.getMessage()); }
        }

        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MMM yyyy");
        List<DashboardStats.MonthlyRevenue> chart = new ArrayList<>();
        for (int i = 11; i >= 0; i--) {
            YearMonth ym  = YearMonth.now().minusMonths(i);
            String    key = ym.getYear() + "-" + ym.getMonthValue();
            DashboardStats.MonthlyRevenue mr = new DashboardStats.MonthlyRevenue();
            mr.setMonth(ym.format(fmt));
            mr.setRevenue(revMap.getOrDefault(key, BigDecimal.ZERO));
            mr.setCount(cntMap.getOrDefault(key, 0L));
            chart.add(mr);
        }
        return chart;
    }

    // ── Top selling products ─────────────────────────────────────────
    private List<DashboardStats.TopProduct> buildTopProducts() {
        LocalDateTime start = LocalDateTime.now().minusMonths(3);
        LocalDateTime end   = LocalDateTime.now();
        List<Object[]> rows = saleItemRepository.findTopSellingProducts(start, end);
        List<DashboardStats.TopProduct> list = new ArrayList<>();
        for (int i = 0; i < Math.min(rows.size(), 5); i++) {
            try {
                Object[] row = rows.get(i);
                DashboardStats.TopProduct tp = new DashboardStats.TopProduct();
                tp.setProductId(row[0] != null ? ((Number) row[0]).longValue() : null);
                tp.setProductName(row[1] != null ? row[1].toString() : "Unknown");
                tp.setQuantity(row[2] != null ? ((Number) row[2]).longValue() : 0L);
                tp.setRevenue(row[3] != null ? new BigDecimal(row[3].toString()) : BigDecimal.ZERO);
                tp.setImagePath(row[4] != null ? row[4].toString() : null);
                list.add(tp);
            } catch (Exception e) { log.warn("TopProduct parse: {}", e.getMessage()); }
        }
        return list;
    }

    // ── Low stock list ───────────────────────────────────────────────
    private List<DashboardStats.LowStockProduct> buildLowStockList() {
        List<DashboardStats.LowStockProduct> list = new ArrayList<>();
        for (Product p : productRepository.findLowStockProducts()) {
            DashboardStats.LowStockProduct ls = new DashboardStats.LowStockProduct();
            ls.setId(p.getId());
            ls.setName(p.getName());
            ls.setSku(p.getSku());
            ls.setUnit(p.getUnit());
            ls.setImagePath(p.getImagePath());
            ls.setQuantity(p.getQuantity());
            ls.setMinStockLevel(p.getMinStockLevel());
            list.add(ls);
        }
        return list;
    }

    private BigDecimal nullSafe(BigDecimal v) {
        return v != null ? v : BigDecimal.ZERO;
    }
}
