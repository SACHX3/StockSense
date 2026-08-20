package com.stocksense.controller;

import com.stocksense.dto.response.ApiResponse;
import com.stocksense.dto.response.DashboardStats;
import com.stocksense.service.DashboardService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.ArrayList;

@Controller
@RequiredArgsConstructor
@Slf4j
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping({"/", "/dashboard"})
    public String dashboard(Model model) {
        try {
            DashboardStats stats = dashboardService.getDashboardStats();
            model.addAttribute("stats", stats);
        } catch (Exception e) {
            log.error("Dashboard load error: {}", e.getMessage(), e);
            // Provide safe empty stats so page still renders
            DashboardStats emptyStats = new DashboardStats();
            emptyStats.setTodayRevenue(BigDecimal.ZERO);
            emptyStats.setMonthlyRevenue(BigDecimal.ZERO);
            emptyStats.setMonthlyRevenueChart(new ArrayList<>());
            emptyStats.setDailySalesChart(new ArrayList<>());
            emptyStats.setTopSellingProducts(new ArrayList<>());
            emptyStats.setLowStockItems(new ArrayList<>());
            model.addAttribute("stats", emptyStats);
            model.addAttribute("errorMsg", "Dashboard data partially unavailable: " + e.getMessage());
        }
        model.addAttribute("pageTitle", "Dashboard");
        return "dashboard/index";
    }

    @GetMapping("/api/dashboard/stats")
    @ResponseBody
    public ResponseEntity<ApiResponse<DashboardStats>> getStats() {
        try {
            return ResponseEntity.ok(ApiResponse.success("OK", dashboardService.getDashboardStats()));
        } catch (Exception e) {
            log.error("Dashboard API error: {}", e.getMessage());
            return ResponseEntity.internalServerError()
                    .body(ApiResponse.error("Failed to load stats: " + e.getMessage()));
        }
    }
}
