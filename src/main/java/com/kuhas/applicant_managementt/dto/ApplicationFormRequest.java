package com.kuhas.applicant_managementt.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class ApplicationFormRequest {

    @NotBlank(message = "이름은 필수입니다")
    @Size(max = 100, message = "이름은 100자 이하여야 합니다")
    private String name;

    @NotBlank(message = "학번은 필수입니다")
    @Size(max = 20, message = "학번은 20자 이하여야 합니다")
    private String studentId;

    @NotBlank(message = "전화번호는 필수입니다")
    @Size(max = 20, message = "전화번호는 20자 이하여야 합니다")
    private String phoneNumber;

    @NotBlank(message = "이메일은 필수입니다")
    @Email(message = "올바른 이메일 형식이 아닙니다")
    private String email;

    @NotBlank(message = "지원동기는 필수입니다")
    @Size(max = 2000, message = "지원동기는 2000자 이하여야 합니다")
    private String motivation;

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
    private String grade;

    @Size(max = 20, message = "상태는 20자 이하여야 합니다")
    private String status;

    // 생성자
    public ApplicationFormRequest() {}

    public ApplicationFormRequest(String name, String studentId, String phoneNumber, String email, String motivation) {
        this.name = name;
        this.studentId = studentId;
        this.phoneNumber = phoneNumber;
        this.email = email;
        this.motivation = motivation;
    }

    // Getter와 Setter
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

    public String getOtherActivity() { return otherActivity; }
    public void setOtherActivity(String otherActivity) { this.otherActivity = otherActivity; }
    public String getCurriculumReason() { return curriculumReason; }
    public void setCurriculumReason(String curriculumReason) { this.curriculumReason = curriculumReason; }
    public String getWish() { return wish; }
    public void setWish(String wish) { this.wish = wish; }
    public String getCareer() { return career; }
    public void setCareer(String career) { this.career = career; }
    public String getLanguageExp() { return languageExp; }
    public void setLanguageExp(String languageExp) { this.languageExp = languageExp; }
    public String getLanguageDetail() { return languageDetail; }
    public void setLanguageDetail(String languageDetail) { this.languageDetail = languageDetail; }
    public String getWishActivities() { return wishActivities; }
    public void setWishActivities(String wishActivities) { this.wishActivities = wishActivities; }
    public String getInterviewDate() { return interviewDate; }
    public void setInterviewDate(String interviewDate) { this.interviewDate = interviewDate; }
    public String getAttendType() { return attendType; }
    public void setAttendType(String attendType) { this.attendType = attendType; }
    public String getPrivacyAgreement() { return privacyAgreement; }
    public void setPrivacyAgreement(String privacyAgreement) { this.privacyAgreement = privacyAgreement; }
    public String getGrade() { return grade; }
    public void setGrade(String grade) { this.grade = grade; }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }
}