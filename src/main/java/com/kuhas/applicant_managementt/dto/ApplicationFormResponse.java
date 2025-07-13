package com.kuhas.applicant_managementt.dto;

import com.kuhas.applicant_managementt.entity.ApplicationForm;
import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDateTime;

public class ApplicationFormResponse {

    private Long id;
    private String name;
    private String studentId;
    private String phoneNumber;
    private String email;
    private String motivation;
    private String status;
    private String statusDisplayName;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;

    // 생성자
    public ApplicationFormResponse() {}

    public ApplicationFormResponse(ApplicationForm applicationForm) {
        this.id = applicationForm.getId();
        this.name = applicationForm.getName();
        this.studentId = applicationForm.getStudentId();
        this.phoneNumber = applicationForm.getPhoneNumber();
        this.email = applicationForm.getEmail();
        this.motivation = applicationForm.getMotivation();
        this.status = applicationForm.getStatus().name();
        this.statusDisplayName = applicationForm.getStatus().getDisplayName();
        this.createdAt = applicationForm.getCreatedAt();
        this.updatedAt = applicationForm.getUpdatedAt();
    }

    // Getter와 Setter
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getStudentId() {
        return studentId;
    }

    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getMotivation() {
        return motivation;
    }

    public void setMotivation(String motivation) {
        this.motivation = motivation;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatusDisplayName() {
        return statusDisplayName;
    }

    public void setStatusDisplayName(String statusDisplayName) {
        this.statusDisplayName = statusDisplayName;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}