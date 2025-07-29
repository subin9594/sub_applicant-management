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
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseBody;

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

    @GetMapping("/admin/edit/{id}")
    public String editApplicationForm(@PathVariable Long id, HttpSession session, Model model) {
        if (session.getAttribute("admin") == null) {
            return "redirect:/admin";
        }
        ApplicationFormResponse application = applicationFormService.getApplicationById(id);
        model.addAttribute("application", application);
        model.addAttribute("id", id); // 항상 id 추가
        return "admin_edit";
    }

    @PostMapping("/admin/edit/{id}")
    public String editApplicationSubmit(@PathVariable Long id,
                                        @RequestParam String name,
                                        @RequestParam String studentId,
                                        @RequestParam String phoneNumber,
                                        @RequestParam String email,
                                        @RequestParam String motivation,
                                        @RequestParam String status,
                                        HttpSession session,
                                        Model model) {
        if (session.getAttribute("admin") == null) {
            return "redirect:/admin";
        }
            try {
                applicationFormService.updateApplicationByAdmin(id, name, studentId, phoneNumber, email, motivation, status);
                return "redirect:/admin";
            } catch (IllegalArgumentException e) {
                model.addAttribute("error", e.getMessage());
                model.addAttribute("name", name);
                model.addAttribute("studentId", studentId);
                model.addAttribute("phoneNumber", phoneNumber);
                model.addAttribute("email", email);
                model.addAttribute("motivation", motivation);
                model.addAttribute("status", status);
                model.addAttribute("id", id); // 항상 id 추가
                return "admin_edit";
            }
    }
    @PostMapping("/admin/delete/{id}")
    public String deleteApplication(@PathVariable Long id, HttpSession session) {
        if (session.getAttribute("admin") == null) {
            return "redirect:/admin";
        }
        applicationFormService.deleteApplication(id);
        return "redirect:/admin";
    }
}