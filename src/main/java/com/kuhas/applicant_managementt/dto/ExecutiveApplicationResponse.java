package com.kuhas.applicant_managementt.dto;

import com.kuhas.applicant_managementt.entity.ExecutiveApplication;
import java.time.LocalDateTime;

public class ExecutiveApplicationResponse {
    private Long id;
    private String name;
    private String studentId;
    private String grade;
    private String email;
    private String phoneNumber;
    private String leavePlan;
    private String period;
    private String motivation;
    private String goal;
    private String crisis;
    private String meeting;
    private String resolution;
    private String privacy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public ExecutiveApplicationResponse() {}
    public ExecutiveApplicationResponse(ExecutiveApplication entity) {
        this.id = entity.getId();
        this.name = entity.getName();
        this.studentId = entity.getStudentId();
        this.grade = entity.getGrade();
        this.email = entity.getEmail();
        this.phoneNumber = entity.getPhoneNumber();
        this.leavePlan = entity.getLeavePlan();
        this.period = entity.getPeriod();
        this.motivation = entity.getMotivation();
        this.goal = entity.getGoal();
        this.crisis = entity.getCrisis();
        this.meeting = entity.getMeeting();
        this.resolution = entity.getResolution();
        this.privacy = entity.getPrivacy();
        this.createdAt = entity.getCreatedAt();
        this.updatedAt = entity.getUpdatedAt();
    }
    // Getters and setters for all fields
} 