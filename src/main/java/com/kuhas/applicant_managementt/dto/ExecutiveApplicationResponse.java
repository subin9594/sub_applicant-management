package com.kuhas.applicant_managementt.dto;

import com.kuhas.applicant_managementt.entity.ExecutiveApplication;
import java.time.LocalDateTime;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;

@JsonInclude(JsonInclude.Include.NON_NULL)  // null 값을 제외
public class ExecutiveApplicationResponse {

    private Long id;

    @JsonProperty("name")
    private String name;

    @JsonProperty("studentId")
    private String studentId;

    private String grade;

    @JsonProperty("email")
    private String email;

    @JsonProperty("phoneNumber")
    private String phoneNumber;

    private String leavePlan;
    private String period;
    private String motivation;
    private String goal;
    private String crisis;
    private String meeting;
    private String resolution;
    private String privacy;
    private String status;
    private String statusDisplayName;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")  // LocalDateTime 포맷 설정
    private LocalDateTime createdAt;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")  // LocalDateTime 포맷 설정
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
        this.status = entity.getStatus().name();
        this.statusDisplayName = entity.getStatus().getDisplayName();
        this.createdAt = entity.getCreatedAt();
        this.updatedAt = entity.getUpdatedAt();
    }

    // Getters and setters for all fields...
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }
    public String getGrade() { return grade; }
    public void setGrade(String grade) { this.grade = grade; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getLeavePlan() { return leavePlan; }
    public void setLeavePlan(String leavePlan) { this.leavePlan = leavePlan; }
    public String getPeriod() { return period; }
    public void setPeriod(String period) { this.period = period; }
    public String getMotivation() { return motivation; }
    public void setMotivation(String motivation) { this.motivation = motivation; }
    public String getGoal() { return goal; }
    public void setGoal(String goal) { this.goal = goal; }
    public String getCrisis() { return crisis; }
    public void setCrisis(String crisis) { this.crisis = crisis; }
    public String getMeeting() { return meeting; }
    public void setMeeting(String meeting) { this.meeting = meeting; }
    public String getResolution() { return resolution; }
    public void setResolution(String resolution) { this.resolution = resolution; }
    public String getPrivacy() { return privacy; }
    public void setPrivacy(String privacy) { this.privacy = privacy; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getStatusDisplayName() { return statusDisplayName; }
    public void setStatusDisplayName(String statusDisplayName) { this.statusDisplayName = statusDisplayName; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}