package com.kuhas.applicant_managementt.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class ExecutiveApplicationRequest {
    @NotBlank(message = "이름은 필수입니다")
    @Size(max = 100, message = "이름은 100자 이하여야 합니다")
    private String name;

    @NotBlank(message = "학번은 필수입니다")
    @Size(max = 20, message = "학번은 20자 이하여야 합니다")
    private String studentId;

    @NotBlank(message = "학년은 필수입니다")
    @Size(max = 20, message = "학년은 20자 이하여야 합니다")
    private String grade;

    @NotBlank(message = "이메일은 필수입니다")
    @Email(message = "올바른 이메일 형식이 아닙니다")
    private String email;

    @NotBlank(message = "전화번호는 필수입니다")
    @Size(max = 20, message = "전화번호는 20자 이하여야 합니다")
    private String phoneNumber;

    private String leavePlan;
    private String period;
    private String motivation;
    private String goal;
    private String crisis;
    private String meeting;
    private String resolution;
    private String privacy;

    public ExecutiveApplicationRequest() {}

    // Getter/Setter
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
} 