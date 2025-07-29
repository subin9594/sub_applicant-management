package com.kuhas.applicant_managementt.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "executive_applications")
public class ExecutiveApplication {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;
    @Column(nullable = false)
    private String studentId;
    @Column(nullable = false)
    private String grade;
    @Column(nullable = false)
    private String email;
    @Column(nullable = false)
    private String phoneNumber;
    @Column(columnDefinition = "TEXT")
    private String leavePlan;
    @Column
    private String period;
    @Column(columnDefinition = "TEXT")
    private String motivation;
    @Column(columnDefinition = "TEXT")
    private String goal;
    @Column(columnDefinition = "TEXT")
    private String crisis;
    @Column
    private String meeting;
    @Column(columnDefinition = "TEXT")
    private String resolution;
    @Column
    private String privacy;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ApplicationStatus status = ApplicationStatus.PENDING;
    
    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();
    @Column
    private LocalDateTime updatedAt;

    // ApplicationStatus enum 정의
    public enum ApplicationStatus {
        PENDING("대기"),
        ACCEPTED("합격"),
        REJECTED("불합격");

        private final String displayName;

        ApplicationStatus(String displayName) {
            this.displayName = displayName;
        }

        public String getDisplayName() {
            return displayName;
        }
    }

    // Getters and setters for all fields
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
    public ApplicationStatus getStatus() { return status; }
    public void setStatus(ApplicationStatus status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
} 