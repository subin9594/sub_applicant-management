package com.kuhas.applicant_managementt.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin")
public class AdminController {
    @PreAuthorize("hasRole('ADMIN')")
    @GetMapping("/application-status")
    public ResponseEntity<String> getApplicationStatus() {
        // 실제 지원상황 데이터 반환 로직을 구현하세요.
        return ResponseEntity.ok("지원상황 데이터 (예시)");
    }
}