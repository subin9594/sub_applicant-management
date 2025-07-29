package com.kuhas.applicant_managementt.controller;

import com.kuhas.applicant_managementt.dto.ExecutiveApplicationRequest;
import com.kuhas.applicant_managementt.dto.ExecutiveApplicationResponse;
import com.kuhas.applicant_managementt.entity.ExecutiveApplication;
import com.kuhas.applicant_managementt.service.ExecutiveApplicationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
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

    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE, produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> submitExecutiveApplication(@RequestBody ExecutiveApplicationRequest request) {
        ExecutiveApplicationResponse response = service.submitApplication(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
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

    @PutMapping("/{id}")
    public ResponseEntity<?> updateExecutiveApplication(@PathVariable Long id, @RequestBody ExecutiveApplicationRequest request) {
        try {
            service.updateApplication(id, request);
            return ResponseEntity.ok().body("{\"message\":\"수정이 완료되었습니다.\"}");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteExecutiveApplication(@PathVariable Long id) {
        try {
            service.deleteApplication(id);
            return ResponseEntity.ok().body("{\"message\":\"삭제가 완료되었습니다.\"}");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<?> updateApplicationStatus(@PathVariable Long id, @RequestParam String status) {
        try {
            ExecutiveApplication.ApplicationStatus newStatus = ExecutiveApplication.ApplicationStatus.valueOf(status.toUpperCase());
            ExecutiveApplicationResponse response = service.updateApplicationStatus(id, newStatus);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("{\"error\":\"" + e.getMessage() + "\"}");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("{\"error\":\"잘못된 상태값입니다.\"}");
        }
    }
} 