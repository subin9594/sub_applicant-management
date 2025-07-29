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
    private String grade;
    private String motivation;
    private String status;
    private String statusDisplayName;
    private String otherActivity;
    private String curriculumReason;
    private String wish;
    private String career;
    private String languageExp;
    private String languageDetail;
    private String wishActivities;
    private String interviewDate;
    private String attendType;
    private String privacyAgreement;

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
        this.grade = applicationForm.getGrade();
        this.motivation = applicationForm.getMotivation();
        this.status = applicationForm.getStatus().name();
        this.statusDisplayName = applicationForm.getStatus().getDisplayName();
        this.otherActivity = applicationForm.getOtherActivity();
        this.curriculumReason = applicationForm.getCurriculumReason();
        this.wish = applicationForm.getWish();
        this.career = applicationForm.getCareer();
        this.languageExp = applicationForm.getLanguageExp();
        this.languageDetail = applicationForm.getLanguageDetail();
        this.wishActivities = applicationForm.getWishActivities();
        this.interviewDate = applicationForm.getInterviewDate();
        this.attendType = applicationForm.getAttendType();
        this.privacyAgreement = applicationForm.getPrivacyAgreement();
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

    public String getGrade() {
        return grade;
    }

    public void setGrade(String grade) {
        this.grade = grade;
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

    public String getOtherActivity() {
        return otherActivity;
    }

    public void setOtherActivity(String otherActivity) {
        this.otherActivity = otherActivity;
    }

    public String getCurriculumReason() {
        return curriculumReason;
    }

    public void setCurriculumReason(String curriculumReason) {
        this.curriculumReason = curriculumReason;
    }

    public String getWish() {
        return wish;
    }

    public void setWish(String wish) {
        this.wish = wish;
    }

    public String getCareer() {
        return career;
    }

    public void setCareer(String career) {
        this.career = career;
    }

    public String getLanguageExp() {
        return languageExp;
    }

    public void setLanguageExp(String languageExp) {
        this.languageExp = languageExp;
    }

    public String getLanguageDetail() {
        return languageDetail;
    }

    public void setLanguageDetail(String languageDetail) {
        this.languageDetail = languageDetail;
    }

    public String getWishActivities() {
        return wishActivities;
    }

    public void setWishActivities(String wishActivities) {
        this.wishActivities = wishActivities;
    }

    public String getInterviewDate() {
        return interviewDate;
    }

    public void setInterviewDate(String interviewDate) {
        this.interviewDate = interviewDate;
    }

    public String getAttendType() {
        return attendType;
    }

    public void setAttendType(String attendType) {
        this.attendType = attendType;
    }

    public String getPrivacyAgreement() {
        return privacyAgreement;
    }

    public void setPrivacyAgreement(String privacyAgreement) {
        this.privacyAgreement = privacyAgreement;
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