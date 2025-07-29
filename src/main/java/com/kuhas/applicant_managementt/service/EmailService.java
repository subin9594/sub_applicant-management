package com.kuhas.applicant_managementt.service;

import com.kuhas.applicant_managementt.entity.ApplicationForm;
import com.kuhas.applicant_managementt.entity.ExecutiveApplication;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import java.io.UnsupportedEncodingException;

@Service
public class EmailService {

    private final JavaMailSender mailSender;

    @Autowired
    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    // 지원서 접수 확인 이메일 발송 (HTML + 이미지)
    public void sendApplicationReceivedEmail(ApplicationForm applicationForm) {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        try {
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");
            helper.setTo(applicationForm.getEmail());
            helper.setFrom(new InternetAddress("koreauniv.kuhas@gmail.com", "KUHAS"));
            helper.setSubject("[KUHAS 부원 모집 지원서 접수 확인] " + applicationForm.getName() + "님의 지원서가 접수되었습니다");

            String infoUrl = "https://www.notion.so/K-U-H-A-S-3ff94268d9c74280b9840d56833ea762";
            String motivationHtml = insertLineBreaks(applicationForm.getMotivation(), 30, true);
            String motivationPlain = insertLineBreaks(applicationForm.getMotivation(), 30, false);

            String htmlContent =
                "<html><body style='font-family:Arial,sans-serif; color:#222;'>" +
                "<div style='max-width:600px; margin:0 auto; background:#fff; border:1px solid #ccc; padding:20px;'>" +
                // 제목
                "<h2 style='text-align:center; margin-bottom:16px;'>KUHAS 지원서 접수 안내</h2>" +
                // 안내문
                "<div style='text-align:center; font-size:1.1em; margin-bottom:24px;'><b>지원이 정상적으로 접수되었습니다!</b></div>" +
                // 정보 표
                "<table style='margin:0 auto 24px auto; text-align:left;'>" +
                "<tr><td><b>이름</b></td><td style='padding-left:16px;'>" + applicationForm.getName() + "</td></tr>" +
                "<tr><td><b>학번</b></td><td style='padding-left:16px;'>" + applicationForm.getStudentId() + "</td></tr>" +
                "<tr><td><b>전화번호</b></td><td style='padding-left:16px;'>" + applicationForm.getPhoneNumber() + "</td></tr>" +
                "<tr><td><b>이메일</b></td><td style='padding-left:16px;'>" + applicationForm.getEmail() + "</td></tr>" +
                // 추가 항목들
                "<tr><td><b>기타 활동</b></td><td style='padding-left:16px;'>" + nullToDash(applicationForm.getOtherActivity()) + "</td></tr>" +
                "<tr><td><b>커리큘럼 이수 가능 이유</b></td><td style='padding-left:16px;'>" + nullToDash(applicationForm.getCurriculumReason()) + "</td></tr>" +
                "<tr><td><b>KUHAS에서 얻고 싶은 것</b></td><td style='padding-left:16px;'>" + nullToDash(applicationForm.getWish()) + "</td></tr>" +
                "<tr><td><b>진로</b></td><td style='padding-left:16px;'>" + nullToDash(applicationForm.getCareer()) + "</td></tr>" +
                "<tr><td><b>프로그래밍 언어 경험</b></td><td style='padding-left:16px;'>" + nullToDash(applicationForm.getLanguageExp()) + "</td></tr>" +
                "<tr><td><b>경험한 언어</b></td><td style='padding-left:16px;'>" + nullToDash(applicationForm.getLanguageDetail()) + "</td></tr>" +
                "<tr><td><b>희망 활동</b></td><td style='padding-left:16px;'>" + nullToDash(applicationForm.getWishActivities()) + "</td></tr>" +
                "<tr><td><b>대면 면접 희망 날짜</b></td><td style='padding-left:16px;'>" + nullToDash(applicationForm.getInterviewDate()) + "</td></tr>" +
                "<tr><td><b>개강총회 참석</b></td><td style='padding-left:16px;'>" + nullToDash(applicationForm.getAttendType()) + "</td></tr>" +
                "</table>" +
                // 지원동기
                "<div style='text-align:center; margin-top:16px;'>" +
                "<b>지원동기</b>" +
                "<div style='display:inline-block; background:#f7f7f7; border-radius:8px; padding:12px; margin-top:4px; text-align:left; max-width:400px;'>" + motivationHtml + "</div>" +
                "</div>" +
                // 상태
                "<div style='text-align:center; margin-top:16px; font-size:1.1em;'><b>현재 상태: " + applicationForm.getStatus().getDisplayName() + "</b></div>" +
                "</div>" +
                // 하단
                "<div style='text-align:center; margin-top:32px;'><a href='" + infoUrl + "' style='color:#3b82f6; text-decoration:underline;'>KUHAS Notion 바로가기</a></div>" +
                "<div style='text-align:center; color:#888; font-size:13px; margin-top:8px;'>© 2025 KUHAS. All rights reserved.</div>" +
                "</body></html>";

            String plainText =
                "[KUHAS 지원서 접수 확인]\n" +
                applicationForm.getName() + "님, 안녕하세요.\n" +
                "지원서가 접수되었습니다.\n\n" +
                "이름: " + applicationForm.getName() + "\n" +
                "학번: " + applicationForm.getStudentId() + "\n" +
                "이메일: " + applicationForm.getEmail() + "\n" +
                "전화번호: " + applicationForm.getPhoneNumber() + "\n" +
                // 추가 항목들
                "기타 활동: " + nullToDash(applicationForm.getOtherActivity()) + "\n" +
                "커리큘럼 이수 가능 이유: " + nullToDash(applicationForm.getCurriculumReason()) + "\n" +
                "KUHAS에서 얻고 싶은 것: " + nullToDash(applicationForm.getWish()) + "\n" +
                "진로: " + nullToDash(applicationForm.getCareer()) + "\n" +
                "프로그래밍 언어 경험: " + nullToDash(applicationForm.getLanguageExp()) + "\n" +
                "경험한 언어: " + nullToDash(applicationForm.getLanguageDetail()) + "\n" +
                "희망 활동: " + nullToDash(applicationForm.getWishActivities()) + "\n" +
                "대면 면접 희망 날짜: " + nullToDash(applicationForm.getInterviewDate()) + "\n" +
                "개강총회 참석: " + nullToDash(applicationForm.getAttendType()) + "\n" +
                "지원동기: " + motivationPlain + "\n" +
                "현재 상태: " + applicationForm.getStatus().getDisplayName() + "\n\n" +
                "결과는 이메일로 안내드릴 예정입니다. 감사합니다.\n" +
                "KUHAS Notion 바로가기: " + infoUrl + "\n" +
                "© 2025 KUHAS. All rights reserved.";

            helper.setText(plainText, htmlContent);
            mailSender.send(mimeMessage);
            System.out.println("이메일 발송 완료: " + applicationForm.getEmail());
        } catch (MessagingException | UnsupportedEncodingException e) {
            System.err.println("이메일 발송 실패: " + e.getMessage());
        }
    }

    // 합격/불합격 결과 이메일 발송 (HTML)
    public void sendResultEmail(ApplicationForm applicationForm, ApplicationForm.ApplicationStatus status) {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        try {
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");
            helper.setTo(applicationForm.getEmail());
            helper.setFrom(new InternetAddress("koreauniv.kuhas@gmail.com", "KUHAS"));

            String motivationHtml = insertLineBreaks(applicationForm.getMotivation(), 30, true);
            String motivationPlain = insertLineBreaks(applicationForm.getMotivation(), 30, false);
            String infoUrl = "https://www.notion.so/K-U-H-A-S-3ff94268d9c74280b9840d56833ea762";

            String subject, htmlContent, plainText;
            String statusDisplay = (status == ApplicationForm.ApplicationStatus.ACCEPTED) ? "합격" : (status == ApplicationForm.ApplicationStatus.REJECTED) ? "불합격" : status.name();
            String statusColor = (status == ApplicationForm.ApplicationStatus.ACCEPTED) ? "#22c55e" : (status == ApplicationForm.ApplicationStatus.REJECTED) ? "#ef4444" : "#222";

            subject = (status == ApplicationForm.ApplicationStatus.ACCEPTED)
                ? "[KUHAS 부원 모집 합격 안내] " + applicationForm.getName() + "님"
                : "[KUHAS 부원 모집 불합격 안내] " + applicationForm.getName() + "님";

            htmlContent =
                "<html><body style='font-family:Arial,sans-serif; color:#222;'>" +
                "<div style='max-width:600px; margin:0 auto; background:#fff; border:1px solid #ccc; padding:20px;'>" +
                // 제목
                "<h2 style='text-align:center; margin-bottom:16px; color:" + statusColor + ";'>KUHAS " + statusDisplay + " 안내</h2>" +
                // 안내문
                "<div style='text-align:center; font-size:1.1em; margin-bottom:24px;'><b>" + (status == ApplicationForm.ApplicationStatus.ACCEPTED ? "합격을 진심으로 축하합니다!" : "아쉽게도 이번에는 불합격하셨습니다.") + "</b></div>" +
                // 정보 표
                "<table style='margin:0 auto 24px auto; text-align:left;'>" +
                "<tr><td><b>이름</b></td><td style='padding-left:16px;'>" + applicationForm.getName() + "</td></tr>" +
                "<tr><td><b>학번</b></td><td style='padding-left:16px;'>" + applicationForm.getStudentId() + "</td></tr>" +
                "<tr><td><b>전화번호</b></td><td style='padding-left:16px;'>" + applicationForm.getPhoneNumber() + "</td></tr>" +
                "<tr><td><b>이메일</b></td><td style='padding-left:16px;'>" + applicationForm.getEmail() + "</td></tr>" +
                "<tr><td><b>상태</b></td><td style='padding-left:16px; color:" + statusColor + ";'>" + statusDisplay + "</td></tr>" +
                "</table>" +
                // 지원동기
                "<div style='text-align:center; margin-top:16px;'>" +
                "<b>지원동기</b>" +
                "<div style='display:inline-block; background:#f7f7f7; border-radius:8px; padding:12px; margin-top:4px; text-align:left; max-width:400px;'>" + motivationHtml + "</div>" +
                "</div>" +
                "</div>" +
                // 하단
                "<div style='text-align:center; margin-top:32px;'><a href='" + infoUrl + "' style='color:#3b82f6; text-decoration:underline;'>KUHAS Notion 바로가기</a></div>" +
                "<div style='text-align:center; color:#888; font-size:13px; margin-top:8px;'>© 2025 KUHAS. All rights reserved.</div>" +
                "</body></html>";

            plainText =
                "[KUHAS 부원 모집 결과 안내]\n" +
                applicationForm.getName() + "님, " + statusDisplay + "입니다.\n" +
                "이름: " + applicationForm.getName() + "\n" +
                "학번: " + applicationForm.getStudentId() + "\n" +
                "이메일: " + applicationForm.getEmail() + "\n" +
                "전화번호: " + applicationForm.getPhoneNumber() + "\n" +
                "지원동기: " + motivationPlain + "\n" +
                "현재 상태: " + statusDisplay + "\n\n" +
                "KUHAS Notion 바로가기: " + infoUrl + "\n" +
                "© 2025 KUHAS. All rights reserved.";

            helper.setSubject(subject);
            helper.setText(plainText, htmlContent);
            mailSender.send(mimeMessage);
            System.out.println("합격/불합격 이메일 발송 완료: " + applicationForm.getEmail());
        } catch (MessagingException | UnsupportedEncodingException e) {
            System.err.println("결과 이메일 발송 실패: " + e.getMessage());
        }
    }

    // 지원서 수정 안내 메일 발송 (수정 전/후 모두 전달)
    public void sendApplicationModifiedEmail(ApplicationForm before, String name, String studentId, String phoneNumber, String email, String motivation, String status) {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        try {
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");
            helper.setTo(email);
            helper.setFrom(new InternetAddress("koreauniv.kuhas@gmail.com", "KUHAS"));
            helper.setSubject("[KUHAS 부원 모집 지원] 지원서 수정 안내");

            String infoUrl = "https://www.notion.so/K-U-H-A-S-3ff94268d9c74280b9840d56833ea762";
            String motivationHtml = insertLineBreaks(motivation, 30, true);
            String motivationPlain = insertLineBreaks(motivation, 30, false);

            String htmlContent =
                "<html><body style='font-family:Arial,sans-serif; color:#222;'>" +
                "<div style='max-width:600px; margin:0 auto; background:#fff; border:1px solid #ccc; padding:20px;'>" +
                // 제목
                "<h2 style='text-align:center; margin-bottom:16px;'>KUHAS 지원서 수정 안내</h2>" +
                // 안내문
                "<div style='text-align:center; font-size:1.1em; margin-bottom:24px;'><b>지원서 정보가 성공적으로 수정되었습니다.</b></div>" +
                // 정보 표
                "<table style='margin:0 auto 24px auto; text-align:left;'>" +
                "<tr><td><b>이름</b></td><td style='padding-left:16px;'>" + highlightIfChanged(before.getName(), name) + "</td></tr>" +
                "<tr><td><b>학번</b></td><td style='padding-left:16px;'>" + highlightIfChanged(before.getStudentId(), studentId) + "</td></tr>" +
                "<tr><td><b>전화번호</b></td><td style='padding-left:16px;'>" + highlightIfChanged(before.getPhoneNumber(), phoneNumber) + "</td></tr>" +
                "<tr><td><b>이메일</b></td><td style='padding-left:16px;'>" + highlightIfChanged(before.getEmail(), email) + "</td></tr>" +
                "<tr><td><b>상태</b></td><td style='padding-left:16px;'>" + highlightIfChanged(before.getStatus().name(), status) + "</td></tr>" +
                "</table>" +
                // 지원동기
                "<div style='text-align:center; margin-top:16px;'>" +
                "<b>지원동기</b>" +
                "<div style='display:inline-block; background:#f7f7f7; border-radius:8px; padding:12px; margin-top:4px; text-align:left; max-width:400px;'>" + motivationHtml + "</div>" +
                "</div>" +
                "</div>" +
                // 하단
                "<div style='text-align:center; margin-top:32px;'><a href='" + infoUrl + "' style='color:#3b82f6; text-decoration:underline;'>KUHAS Notion 바로가기</a></div>" +
                "<div style='text-align:center; color:#888; font-size:13px; margin-top:8px;'>© 2025 KUHAS. All rights reserved.</div>" +
                "</body></html>";

            String plainText =
                "[KUHAS 지원서 수정 안내]\n" +
                name + "님, 안녕하세요.\n" +
                "지원서 정보가 수정되었습니다.\n\n" +
                "수정된 정보:\n" +
                "이름: " + name + "\n" +
                "학번: " + studentId + "\n" +
                "이메일: " + email + "\n" +
                "전화번호: " + phoneNumber + "\n" +
                "지원동기: " + motivationPlain + "\n" +
                "현재 상태: " + status + "\n\n" +
                "결과는 이메일로 안내드릴 예정입니다. 감사합니다.\n" +
                "KUHAS Notion 바로가기: " + infoUrl + "\n" +
                "© 2025 KUHAS. All rights reserved.";

            helper.setText(plainText, htmlContent);
            mailSender.send(mimeMessage);
            System.out.println("지원서 수정 안내 메일 발송 완료: " + email);
        } catch (MessagingException | UnsupportedEncodingException e) {
            System.err.println("지원서 수정 안내 메일 발송 실패: " + e.getMessage());
        }
    }
    
    // 운영진 모집 지원서 접수 확인 이메일 발송
    public void sendExecutiveApplicationReceivedEmail(ExecutiveApplication execApp) {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        try {
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");
            helper.setTo(execApp.getEmail());
            helper.setFrom(new InternetAddress("koreauniv.kuhas@gmail.com", "KUHAS"));
            helper.setSubject("[KUHAS 운영진 모집 지원서 접수 확인] " + execApp.getName() + "님의 지원서가 접수되었습니다");

            String infoUrl = "https://www.notion.so/K-U-H-A-S-3ff94268d9c74280b9840d56833ea762";

            String htmlContent =
                "<html><body style='font-family:Arial,sans-serif; color:#222;'>" +
                "<div style='max-width:600px; margin:0 auto; background:#fff; border:1px solid #ccc; padding:20px;'>" +
                "<h2 style='text-align:center; margin-bottom:16px;'>KUHAS 운영진 지원서 접수 안내</h2>" +
                "<div style='text-align:center; font-size:1.1em; margin-bottom:24px;'><b>지원이 정상적으로 접수되었습니다!</b></div>" +
                "<table style='margin:0 auto 24px auto; text-align:left;'>" +
                "<tr><td><b>이름</b></td><td style='padding-left:16px;'>" + execApp.getName() + "</td></tr>" +
                "<tr><td><b>학번</b></td><td style='padding-left:16px;'>" + execApp.getStudentId() + "</td></tr>" +
                "<tr><td><b>학년</b></td><td style='padding-left:16px;'>" + execApp.getGrade() + "</td></tr>" +
                "<tr><td><b>이메일</b></td><td style='padding-left:16px;'>" + execApp.getEmail() + "</td></tr>" +
                "<tr><td><b>전화번호</b></td><td style='padding-left:16px;'>" + execApp.getPhoneNumber() + "</td></tr>" +
                "<tr><td><b>휴학 계획</b></td><td style='padding-left:16px;'>" + nullToDash(execApp.getLeavePlan()) + "</td></tr>" +
                "<tr><td><b>활동 기간</b></td><td style='padding-left:16px;'>" + nullToDash(execApp.getPeriod()) + "</td></tr>" +
                "<tr><td><b>지원 동기</b></td><td style='padding-left:16px;'>" + nullToDash(execApp.getMotivation()) + "</td></tr>" +
                "<tr><td><b>활동 목표</b></td><td style='padding-left:16px;'>" + nullToDash(execApp.getGoal()) + "</td></tr>" +
                "<tr><td><b>위기 극복 경험</b></td><td style='padding-left:16px;'>" + nullToDash(execApp.getCrisis()) + "</td></tr>" +
                "<tr><td><b>회의 참석</b></td><td style='padding-left:16px;'>" + nullToDash(execApp.getMeeting()) + "</td></tr>" +
                "<tr><td><b>각오 한 마디</b></td><td style='padding-left:16px;'>" + nullToDash(execApp.getResolution()) + "</td></tr>" +
                "<tr><td><b>개인정보 동의</b></td><td style='padding-left:16px;'>" + nullToDash(execApp.getPrivacy()) + "</td></tr>" +
                "</table>" +
                "</div>" +
                "<div style='text-align:center; margin-top:32px;'><a href='" + infoUrl + "' style='color:#3b82f6; text-decoration:underline;'>KUHAS Notion 바로가기</a></div>" +
                "<div style='text-align:center; color:#888; font-size:13px; margin-top:8px;'>© 2025 KUHAS. All rights reserved.</div>" +
                "</body></html>";

            String plainText =
                "[KUHAS 운영진 지원서 접수 확인]\n" +
                execApp.getName() + "님, 안녕하세요.\n" +
                "지원서가 접수되었습니다.\n\n" +
                "이름: " + execApp.getName() + "\n" +
                "학번: " + execApp.getStudentId() + "\n" +
                "학년: " + execApp.getGrade() + "\n" +
                "이메일: " + execApp.getEmail() + "\n" +
                "전화번호: " + execApp.getPhoneNumber() + "\n" +
                "휴학 계획: " + nullToDash(execApp.getLeavePlan()) + "\n" +
                "활동 기간: " + nullToDash(execApp.getPeriod()) + "\n" +
                "지원 동기: " + nullToDash(execApp.getMotivation()) + "\n" +
                "활동 목표: " + nullToDash(execApp.getGoal()) + "\n" +
                "위기 극복 경험: " + nullToDash(execApp.getCrisis()) + "\n" +
                "회의 참석: " + nullToDash(execApp.getMeeting()) + "\n" +
                "각오 한 마디: " + nullToDash(execApp.getResolution()) + "\n" +
                "개인정보 동의: " + nullToDash(execApp.getPrivacy()) + "\n" +
                "\n결과는 이메일로 안내드릴 예정입니다. 감사합니다.\n" +
                "KUHAS Notion 바로가기: " + infoUrl + "\n" +
                "© 2025 KUHAS. All rights reserved.";

            helper.setText(plainText, htmlContent);
            mailSender.send(mimeMessage);
            System.out.println("운영진 지원서 이메일 발송 완료: " + execApp.getEmail());
        } catch (MessagingException | UnsupportedEncodingException e) {
            System.err.println("운영진 지원서 이메일 발송 실패: " + e.getMessage());
        }
    }

    private String highlightIfChanged(String oldVal, String newVal) {
        if (oldVal == null) oldVal = "";
        if (newVal == null) newVal = "";
        if (!oldVal.equals(newVal)) {
            return "<span style=\"color:#2563eb; font-weight:bold;\">" + escapeHtml(newVal) + "</span>";
        } else {
            return escapeHtml(newVal);
        }
    }
    private String escapeHtml(String s) {
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }

    // 줄바꿈 함수 추가
    private String insertLineBreaks(String text, int maxLen, boolean html) {
        if (text == null) return "";
        StringBuilder sb = new StringBuilder();
        int count = 0;
        for (int i = 0; i < text.length(); i++) {
            sb.append(text.charAt(i));
            count++;
            if (count >= maxLen && (i + 1 < text.length())) {
                sb.append(html ? "<br>" : "\n");
                count = 0;
            }
        }
        return sb.toString();
    }

    private String nullToDash(String s) {
        return (s == null || s.trim().isEmpty()) ? "-" : s;
    }
}