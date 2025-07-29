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
import java.util.Map;
import org.springframework.web.bind.annotation.RequestBody;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;


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
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> loginRequest, HttpSession session) {
        String password = loginRequest.get("password");
        if ("admin1234".equals(password)) {
            session.setAttribute("admin", true);
            return ResponseEntity.ok(Map.of("success", true)); // 로그인 성공 시 JSON 응답
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of("error", "비밀번호가 틀렸습니다.")); // 비밀번호 오류 시 JSON 응답
    }
    
}