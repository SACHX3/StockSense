package com.stocksense.controller;

import com.stocksense.dto.request.SupplierRequest;
import com.stocksense.dto.response.ApiResponse;
import com.stocksense.entity.Supplier;
import com.stocksense.service.SupplierService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/suppliers")
@RequiredArgsConstructor
public class SupplierController {

    private final SupplierService supplierService;

    @GetMapping
    public String list(Model model, @RequestParam(required = false) String keyword) {
        List<Supplier> suppliers = keyword != null && !keyword.isEmpty()
                ? supplierService.search(keyword)
                : supplierService.findAll();
        model.addAttribute("suppliers", suppliers);
        model.addAttribute("keyword", keyword);
        model.addAttribute("pageTitle", "Suppliers");
        return "suppliers/list";
    }

    @GetMapping("/create")
    public String createForm(Model model) {
        model.addAttribute("supplier", new SupplierRequest());
        model.addAttribute("pageTitle", "Add Supplier");
        return "suppliers/form";
    }

    @PostMapping("/create")
    public String create(@Valid @ModelAttribute SupplierRequest request,
                         RedirectAttributes redirectAttributes) {
        try {
            supplierService.create(request);
            redirectAttributes.addFlashAttribute("successMsg", "Supplier created successfully!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMsg", e.getMessage());
            return "redirect:/suppliers/create";
        }
        return "redirect:/suppliers";
    }

    @GetMapping("/edit/{id}")
    public String editForm(@PathVariable Long id, Model model) {
        Supplier supplier = supplierService.findById(id);
        SupplierRequest req = new SupplierRequest();
        req.setName(supplier.getName());
        req.setContactPerson(supplier.getContactPerson());
        req.setEmail(supplier.getEmail());
        req.setPhone(supplier.getPhone());
        req.setAddress(supplier.getAddress());
        req.setCity(supplier.getCity());
        req.setCountry(supplier.getCountry());
        req.setTaxNumber(supplier.getTaxNumber());
        req.setPaymentTerms(supplier.getPaymentTerms());
        req.setNotes(supplier.getNotes());
        model.addAttribute("supplier", req);
        model.addAttribute("supplierId", id);
        model.addAttribute("pageTitle", "Edit Supplier");
        return "suppliers/form";
    }

    @PostMapping("/edit/{id}")
    public String update(@PathVariable Long id,
                         @Valid @ModelAttribute SupplierRequest request,
                         RedirectAttributes redirectAttributes) {
        try {
            supplierService.update(id, request);
            redirectAttributes.addFlashAttribute("successMsg", "Supplier updated successfully!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/suppliers";
    }

    @GetMapping("/view/{id}")
    public String view(@PathVariable Long id, Model model) {
        model.addAttribute("supplier", supplierService.findById(id));
        model.addAttribute("pageTitle", "Supplier Details");
        return "suppliers/view";
    }

    @PostMapping("/delete/{id}")
    public String delete(@PathVariable Long id, RedirectAttributes redirectAttributes) {
        try {
            supplierService.delete(id);
            redirectAttributes.addFlashAttribute("successMsg", "Supplier deleted successfully!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMsg", e.getMessage());
        }
        return "redirect:/suppliers";
    }

    @GetMapping("/api/all")
    @ResponseBody
    public ResponseEntity<ApiResponse<List<Supplier>>> getAllApi() {
        return ResponseEntity.ok(ApiResponse.success("OK", supplierService.findAllActive()));
    }
}
