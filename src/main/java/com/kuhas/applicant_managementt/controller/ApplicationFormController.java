package com.kuhas.applicant_managementt.controller;

import com.kuhas.applicant_managementt.dto.ApplicationFormRequest;
import com.kuhas.applicant_managementt.dto.ApplicationFormResponse;
import com.kuhas.applicant_managementt.entity.ApplicationForm;
import com.kuhas.applicant_managementt.service.ApplicationFormService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;
import java.util.Map;
import java.util.HashMap;

@Controller
@RequestMapping("/api/applications")
public class ApplicationFormController {

    private final ApplicationFormService applicationFormService;

    @Autowired
    public ApplicationFormController(ApplicationFormService applicationFormService) {
        this.applicationFormService = applicationFormService;
    }

    // 지원서 제출
    @PostMapping
    public String submitApplication(@ModelAttribute ApplicationFormRequest request, org.springframework.ui.Model model) {
        try {
            applicationFormService.submitApplication(request);
            model.addAttribute("message", "지원서가 성공적으로 제출되었습니다!");
            return "home";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "home";
        }
    }

    // Flutter 등 외부 API용 JSON 지원서 제출
    @PostMapping("/api")
    @ResponseBody
    public ResponseEntity<?> submitApplicationApi(@RequestBody ApplicationFormRequest request) {
        try {
            applicationFormService.submitApplication(request);
            return ResponseEntity.ok().body("{\"message\":\"지원이 성공적으로 제출되었습니다!\"}");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    // 지원서 제출 폼 및 안내 화면 (GET)
    @GetMapping
    public String showApplicationForm() {
        return "home";
    }

    // 모든 지원서 조회
    @GetMapping("/list")
    @ResponseBody
    public ResponseEntity<List<ApplicationFormResponse>> getAllApplications() {
        List<ApplicationFormResponse> applications = applicationFormService.getAllApplications();
        return ResponseEntity.ok(applications);
    }

    // ID로 지원서 조회
    @GetMapping("/{id}")
    @ResponseBody
    public ResponseEntity<ApplicationFormResponse> getApplicationById(@PathVariable Long id) {
        try {
            ApplicationFormResponse response = applicationFormService.getApplicationById(id);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // 학번으로 지원서 조회
    @GetMapping("/student/{studentId}")
    @ResponseBody
    public ResponseEntity<ApplicationFormResponse> getApplicationByStudentId(@PathVariable String studentId) {
        try {
            ApplicationFormResponse response = applicationFormService.getApplicationByStudentId(studentId);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // 상태별 지원서 조회
    @GetMapping("/status/{status}")
    @ResponseBody
    public ResponseEntity<List<ApplicationFormResponse>> getApplicationsByStatus(@PathVariable String status) {
        try {
            ApplicationForm.ApplicationStatus applicationStatus = ApplicationForm.ApplicationStatus.valueOf(status.toUpperCase());
            List<ApplicationFormResponse> applications = applicationFormService.getApplicationsByStatus(applicationStatus);
            return ResponseEntity.ok(applications);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // 키워드로 지원서 검색
    @GetMapping("/search")
    @ResponseBody
    public ResponseEntity<List<ApplicationFormResponse>> searchApplications(@RequestParam String keyword) {
        List<ApplicationFormResponse> applications = applicationFormService.searchApplications(keyword);
        return ResponseEntity.ok(applications);
    }

    // 지원서 상태 변경
    @PutMapping("/{id}/status")
    @ResponseBody
    public ResponseEntity<ApplicationFormResponse> updateApplicationStatus(
            @PathVariable Long id,
            @RequestParam String status) {
        try {
            ApplicationForm.ApplicationStatus applicationStatus = ApplicationForm.ApplicationStatus.valueOf(status.toUpperCase());
            ApplicationFormResponse response = applicationFormService.updateApplicationStatus(id, applicationStatus);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    // 지원서 수정 (JSON)
    @PutMapping("/{id}")
    @ResponseBody
    public ResponseEntity<?> updateApplication(@PathVariable Long id, @RequestBody ApplicationFormRequest request) {
        try {
            applicationFormService.updateApplicationByAdmin(
                id,
                request.getName(),
                request.getStudentId(),
                request.getPhoneNumber(),
                request.getEmail(),
                request.getMotivation(),
                request.getStatus() != null ? request.getStatus() : "PENDING"
            );
            return ResponseEntity.ok().body("{\"message\":\"수정이 완료되었습니다.\"}");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    // 지원서 삭제
    @DeleteMapping("/{id}")
    @ResponseBody
    public ResponseEntity<Void> deleteApplication(@PathVariable Long id) {
        try {
            applicationFormService.deleteApplication(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // 통계 정보 조회
    @GetMapping("/statistics")
    @ResponseBody
    public ResponseEntity<ApplicationFormService.ApplicationStatistics> getStatistics() {
        ApplicationFormService.ApplicationStatistics statistics = applicationFormService.getStatistics();
        return ResponseEntity.ok(statistics);
    }

    // 중복 체크 API
    @GetMapping("/exists")
    @ResponseBody
    public Map<String, Boolean> checkDuplicate(
        @RequestParam(required = false) String studentId,
        @RequestParam(required = false) String email,
        @RequestParam(required = false) String phoneNumber
    ) {
        Map<String, Boolean> result = new HashMap<>();
        if (studentId != null) {
            result.put("studentId", applicationFormService.isStudentIdExists(studentId));
        }
        if (email != null) {
            result.put("email", applicationFormService.isEmailExists(email));
        }
        if (phoneNumber != null) {
            result.put("phoneNumber", applicationFormService.isPhoneNumberExists(phoneNumber));
        }
        return result;
    }
}