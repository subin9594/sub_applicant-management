package com.kuhas.applicant_managementt.controller;

import com.kuhas.applicant_managementt.dto.ApplicationFormResponse;
import com.kuhas.applicant_managementt.service.ApplicationFormService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import java.util.List;
import com.kuhas.applicant_managementt.entity.ApplicationForm;

@Controller
public class HomeController {
    private final ApplicationFormService applicationFormService;
    private static final String ADMIN_PASSWORD = "admin1234";
    public HomeController(ApplicationFormService applicationFormService) {
        this.applicationFormService = applicationFormService;
    }

    @GetMapping("/")
    public String home() {
        return "home";
    }

    @GetMapping("/admin")
    public String adminPage(HttpSession session, Model model) {
        if (session.getAttribute("admin") != null) {
            List<ApplicationFormResponse> applications = applicationFormService.getAllApplications();
            model.addAttribute("applications", applications);
            return "admin";
        } else {
            return "admin_login";
        }
    }

    @PostMapping("/admin/login")
    public String adminLogin(@RequestParam String password, HttpSession session, Model model) {
        if (ADMIN_PASSWORD.equals(password)) {
            session.setAttribute("admin", true);
            return "redirect:/admin";
        } else {
            model.addAttribute("error", "비밀번호가 올바르지 않습니다.");
            return "admin_login";
        }
    }

    @GetMapping("/admin/logout")
    public String adminLogout(HttpSession session) {
        session.removeAttribute("admin");
        return "redirect:/admin";
    }

    @PostMapping("/admin/approve/{id}")
    public String approveApplication(@PathVariable Long id, @RequestParam String status, HttpSession session, Model model) {
        if (session.getAttribute("admin") == null) {
            return "redirect:/admin";
        }
        // 지원서 상태 변경
        ApplicationForm.ApplicationStatus newStatus = com.kuhas.applicant_managementt.entity.ApplicationForm.ApplicationStatus.valueOf(status);
        applicationFormService.updateApplicationStatus(id, newStatus);
        return "redirect:/admin";
    }
}