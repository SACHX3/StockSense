package com.stocksense.controller;

import com.stocksense.entity.User;
import com.stocksense.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
@RequiredArgsConstructor
public class AuthController {

    private final UserRepository userRepository;

    @GetMapping("/login")
    public String loginPage(Authentication authentication) {
        if (authentication != null && authentication.isAuthenticated()) {
            return "redirect:/dashboard";
        }
        return "auth/login";
    }

    @GetMapping("/profile")
    public String profile(Authentication authentication, Model model) {
        if (authentication != null) {
            userRepository.findByUsername(authentication.getName()).ifPresent(u -> model.addAttribute("user", u));
        }
        model.addAttribute("pageTitle", "My Profile");
        return "auth/profile";
    }
}
