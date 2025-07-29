package com.kuhas.applicant_managementt.controller;

import com.kuhas.applicant_managementt.service.ExecutiveApplicationService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import com.kuhas.applicant_managementt.dto.ApplicationFormResponse;
import com.kuhas.applicant_managementt.service.ApplicationFormService;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import org.springframework.stereotype.Controller;

@Controller
@RequestMapping("/admin")
public class AdminController {
    private final ApplicationFormService applicationFormService;
    private final ExecutiveApplicationService executiveApplicationService;

    public AdminController(ApplicationFormService applicationFormService, ExecutiveApplicationService executiveApplicationService) {
        this.applicationFormService = applicationFormService;
        this.executiveApplicationService = executiveApplicationService;
    }

    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/application-status")
    public ResponseEntity<String> getApplicationStatus() {
        // 실제 지원상황 데이터 반환 로직을 구현하세요.
        return ResponseEntity.ok("지원상황 데이터 (예시)");
    }

    @GetMapping
    public String adminPage(HttpSession session, Model model) {
        if (session.getAttribute("admin") != null) {
            List<ApplicationFormResponse> applications = applicationFormService.getAllApplications();
            model.addAttribute("applications", applications);
            model.addAttribute("executiveApplications", executiveApplicationService.getAll());
            return "admin";
        } else {
            return "admin_login";
        }
    }

    @PostMapping("/login")
    public String login(@RequestParam("username") String username, @RequestParam("password") String password, HttpSession session) {
        if ("admin".equals(username) && "admin".equals(password)) {
            session.setAttribute("admin", "true");
            return "redirect:/api/admin/admin";
        }
        return "admin_login";
    }
}