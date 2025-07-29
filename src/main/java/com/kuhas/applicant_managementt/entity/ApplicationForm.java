package com.kuhas.applicant_managementt.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.LocalDateTime;

@Entity
@Table(name = "application_forms")
public class ApplicationForm {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "이름은 필수입니다")
    @Size(max = 100, message = "이름은 100자 이하여야 합니다")
    @Column(nullable = false)
    private String name;

    @NotBlank(message = "학번은 필수입니다")
    @Size(max = 20, message = "학번은 20자 이하여야 합니다")
    @Column(nullable = false, unique = true)
    private String studentId;

    @NotBlank(message = "전화번호는 필수입니다")
    @Size(max = 20, message = "전화번호는 20자 이하여야 합니다")
    @Column(nullable = false)
    private String phoneNumber;

    @NotBlank(message = "이메일은 필수입니다")
    @Email(message = "올바른 이메일 형식이 아닙니다")
    @Column(nullable = false)
    private String email;

    @Column
    private String grade;

    @NotBlank(message = "지원동기는 필수입니다")
    @Size(max = 2000, message = "지원동기는 2000자 이하여야 합니다")
    @Column(nullable = false, columnDefinition = "TEXT")
    private String motivation;

    @Column
    private String otherActivity;
    @Column
    private String curriculumReason;
    @Column
    private String wish;
    @Column
    private String career;
    @Column
    private String languageExp;
    @Column
    private String languageDetail;
    @Column
    private String wishActivities;
    @Column
    private String interviewDate;
    @Column
    private String attendType;
    @Column
    private String privacyAgreement;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ApplicationStatus status = ApplicationStatus.PENDING;

    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column
    private LocalDateTime updatedAt;

    // 생성자
    public ApplicationForm() {}

    public ApplicationForm(String name, String studentId, String phoneNumber, String email, String motivation) {
        this.name = name;
        this.studentId = studentId;
        this.phoneNumber = phoneNumber;
        this.email = email;
        this.motivation = motivation;
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

    public ApplicationStatus getStatus() {
        return status;
    }

    public void setStatus(ApplicationStatus status) {
        this.status = status;
        this.updatedAt = LocalDateTime.now();
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

    // 상태 열거형
    public enum ApplicationStatus {
        PENDING("대기중"),
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
}