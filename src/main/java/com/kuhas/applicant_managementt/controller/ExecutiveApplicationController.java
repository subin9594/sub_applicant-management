package com.kuhas.applicant_managementt.controller;

import com.kuhas.applicant_managementt.dto.ExecutiveApplicationRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/executive-applications")
public class ExecutiveApplicationController {
    private final List<ExecutiveApplicationRequest> applications = new ArrayList<>(); // 임시 메모리 저장

    @PostMapping
    public ResponseEntity<?> submitExecutiveApplication(@RequestBody ExecutiveApplicationRequest request) {
        applications.add(request);
        return ResponseEntity.ok().body("{\"message\":\"운영진 지원서가 성공적으로 제출되었습니다!\"}");
    }

    @GetMapping
    public List<ExecutiveApplicationRequest> getAll() {
        return applications;
    }
} 