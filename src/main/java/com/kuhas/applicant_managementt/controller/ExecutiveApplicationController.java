package com.kuhas.applicant_managementt.controller;

import com.kuhas.applicant_managementt.dto.ExecutiveApplicationRequest;
import com.kuhas.applicant_managementt.dto.ExecutiveApplicationResponse;
import com.kuhas.applicant_managementt.service.ExecutiveApplicationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/executive-applications")
public class ExecutiveApplicationController {
    private final ExecutiveApplicationService service;

    @Autowired
    public ExecutiveApplicationController(ExecutiveApplicationService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<?> submitExecutiveApplication(@RequestBody ExecutiveApplicationRequest request) {
        ExecutiveApplicationResponse response = service.submitApplication(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public List<ExecutiveApplicationResponse> getAll() {
        return service.getAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ExecutiveApplicationResponse> getById(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(service.getById(id));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }
} 