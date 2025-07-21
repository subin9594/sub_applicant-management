package com.kuhas.applicant_managementt.service;

import com.kuhas.applicant_managementt.entity.ApplicationForm;
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
            helper.setFrom(new InternetAddress("subo3os2@korea.ac.kr", "KUHAS"));
            String subject = "[KUHAS 부원 모집 지원서 접수 확인] " + applicationForm.getName() + "님의 지원서가 접수되었습니다";
            String infoUrl = "https://www.notion.so/K-U-H-A-S-3ff94268d9c74280b9840d56833ea762";
            // 이미지 첨부 (CID, classpath)
            Resource logoResource = new ClassPathResource("static/logo.png");
            if (logoResource.exists()) {
                helper.addInline("logoImage", logoResource);
            }
            String motivationHtml = insertLineBreaks(applicationForm.getMotivation(), 30, true);
            String motivationPlain = insertLineBreaks(applicationForm.getMotivation(), 30, false);
            String htmlContent =
                "<table width='100%' cellpadding='0' cellspacing='0' border='0' style='background:#f7f8fa;'><tr><td align='center'>" +
                "<table width='480' cellpadding='0' cellspacing='0' border='0' style='background:#fff; border-radius:12px; box-shadow:0 2px 8px #0001; margin:40px 0;'>" +
                "<tr><td align='center' style='text-align:center; padding:32px 24px; font-family:Arial, Helvetica, sans-serif; color:#222;'>" +
                "<img src='cid:logoImage' width='180' alt='KUHAS' style='display:block; margin:0 auto 24px auto; max-width:100%; height:auto;'>" +
                "<h2 style='margin:0 0 16px 0; font-size:24px; font-weight:bold;'>KUHAS 부원 모집 지원서 접수 확인</h2>" +
                "<p style='font-size:16px; margin:0 0 12px 0;'>안녕하세요, <b>" + applicationForm.getName() + "</b>님.<br>지원서가 성공적으로 접수되었습니다.<br><br>" +
                "<b>지원 정보:</b><br>" +
                "- 이름: " + applicationForm.getName() + "<br>" +
                "- 학번: " + applicationForm.getStudentId() + "<br>" +
                "- 이메일: " + applicationForm.getEmail() + "<br>" +
                "- 전화번호: " + applicationForm.getPhoneNumber() + "<br>" +
                "- 지원동기: " + motivationHtml + "<br><br>" +
                "<br>현재 상태: " + applicationForm.getStatus().getDisplayName() + "<br><br>" +
                "결과는 이메일로 개별 안내드리겠습니다.<br>감사합니다.</p>" +
                "<p style='margin-top:24px;'><a href='" + infoUrl + "' style='color:#0056b3;text-decoration:underline;font-weight:bold;'>🔗 KUHAS Notion 보러가기</a></p>" +
                "<div style='margin-top:32px; color:#888; font-size:13px;'>&copy; 2025 KUHAS. All rights reserved.</div>" +
                "</td></tr></table></td></tr></table>";
            String plainText =
                "KUHAS 부원 모집 지원서 접수 확인\n" +
                "안녕하세요, " + applicationForm.getName() + "님.\n" +
                "지원서가 성공적으로 접수되었습니다.\n" +
                "이름: " + applicationForm.getName() + "\n" +
                "학번: " + applicationForm.getStudentId() + "\n" +
                "이메일: " + applicationForm.getEmail() + "\n" +
                "전화번호: " + applicationForm.getPhoneNumber() + "\n" +
                "지원동기: " + motivationPlain + "\n\n" +
                "현재 상태: " + applicationForm.getStatus().getDisplayName() + "\n" +
                "결과는 이메일로 개별 안내드리겠습니다.\n감사합니다.";
            helper.setSubject(subject);
            helper.setText(plainText, htmlContent);
            mailSender.send(mimeMessage);
            System.out.println("지원서 접수 확인 HTML 이메일 발송 완료: " + applicationForm.getEmail());
        } catch (MessagingException | java.io.UnsupportedEncodingException e) {
            System.err.println("지원서 접수 확인 HTML 이메일 발송 실패: " + e.getMessage());
        }
    }

    // 합격/불합격 결과 이메일 발송 (HTML)
    public void sendResultEmail(ApplicationForm applicationForm, ApplicationForm.ApplicationStatus status) {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        try {
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");
            helper.setTo(applicationForm.getEmail());
            helper.setFrom(new InternetAddress("subo3os2@korea.ac.kr", "KUHAS"));
            String subject;
            String htmlContent;
            String plainText;
            String infoUrl = "https://www.notion.so/K-U-H-A-S-3ff94268d9c74280b9840d56833ea762";
            // 이미지 첨부 (CID)
            Resource logoResource = new ClassPathResource("static/logo.png");
            if (logoResource.exists()) {
                helper.addInline("logoImage", logoResource);
            }
            String motivationHtml = insertLineBreaks(applicationForm.getMotivation(), 30, true);
            String motivationPlain = insertLineBreaks(applicationForm.getMotivation(), 30, false);
            if (status == ApplicationForm.ApplicationStatus.ACCEPTED) {
                subject = "[KUHAS 부원 모집 합격 안내] " + applicationForm.getName() + "님 축하드립니다!";
                htmlContent =
                    "<table width='100%' cellpadding='0' cellspacing='0' border='0' style='background:#f7f8fa;'><tr><td align='center'>" +
                    "<table width='480' cellpadding='0' cellspacing='0' border='0' style='background:#fff; border-radius:12px; box-shadow:0 2px 8px #0001; margin:40px 0;'>" +
                    "<tr><td align='center' style='text-align:center; padding:32px 24px; font-family:Arial, Helvetica, sans-serif; color:#222;'>" +
                    "<img src='cid:logoImage' width='180' alt='KUHAS' style='display:block; margin:0 auto 24px auto; max-width:100%; height:auto;'>" +
                    "<h2 style='margin:0 0 16px 0; font-size:24px; font-weight:bold;'>KUHAS 부원 모집 지원 결과 안내</h2>" +
                    "<p style='font-size:16px; margin:0 0 12px 0;'>안녕하세요, <b>" + applicationForm.getName() + "</b>님.<br>" +
                    "축하드립니다! KUHAS 부원 모집에 <span style='color:green;font-weight:bold;'>합격</span>하셨습니다.<br>" +
                    "추후 일정은 개별 연락 드릴 예정이니 메일 및 연락을 확인해주세요.<br><br>감사합니다.</p>" +
                    "<p style='margin-top:24px;'><a href='" + infoUrl + "' style='color:#0056b3;text-decoration:underline;font-weight:bold;'>🔗 KUHAS Notion 보러가기</a></p>" +
                    "<div style='margin-top:32px; color:#888; font-size:13px;'>&copy; 2025 KUHAS. All rights reserved.</div>" +
                    "</td></tr></table></td></tr></table>";
                plainText =
                    "KUHAS 부원 모집 합격 안내\n" +
                    "안녕하세요, " + applicationForm.getName() + "님.\n" +
                    "축하드립니다! KUHAS 부원 모집에 합격하셨습니다.\n" +
                    "지원동기: " + motivationPlain + "\n" +
                    "추후 일정은 개별 연락 드릴 예정이니 메일 및 연락을 확인해주세요.\n감사합니다.";
            } else {
                subject = "[KUHAS 부원 모집 합불 안내] " + applicationForm.getName() + "님";
                htmlContent =
                    "<table width='100%' cellpadding='0' cellspacing='0' border='0' style='background:#f7f8fa;'><tr><td align='center'>" +
                    "<table width='480' cellpadding='0' cellspacing='0' border='0' style='background:#fff; border-radius:12px; box-shadow:0 2px 8px #0001; margin:40px 0;'>" +
                    "<tr><td align='center' style='text-align:center; padding:32px 24px; font-family:Arial, Helvetica, sans-serif; color:#222;'>" +
                    "<img src='cid:logoImage' width='180' alt='KUHAS' style='display:block; margin:0 auto 24px auto; max-width:100%; height:auto;'>" +
                    "<h2 style='margin:0 0 16px 0; font-size:24px; font-weight:bold;'>KUHAS 부원 모집 지원 결과 안내</h2>" +
                    "<p style='font-size:16px; margin:0 0 12px 0;'>안녕하세요, <b>" + applicationForm.getName() + "</b>님.<br>" +
                    "아쉽게도 KUHAS 부원 모집에 <span style='color:red;font-weight:bold;'>불합격</span>하셨습니다.<br>" +
                    "지원동기: " + motivationHtml + "<br>" +
                    "앞으로 더 좋은 기회가 있을 때 다시 지원해주시기 바랍니다.<br><br>지원해주셔서 감사합니다.</p>" +
                    "<p style='margin-top:24px;'><a href='" + infoUrl + "' style='color:#0056b3;text-decoration:underline;font-weight:bold;'>🔗 KUHAS Notion 보러가기</a></p>" +
                    "<div style='margin-top:32px; color:#888; font-size:13px;'>&copy; 2025 KUHAS. All rights reserved.</div>" +
                    "</td></tr></table></td></tr></table>";
                plainText =
                    "KUHAS 부원 모집 합불 안내\n" +
                    "안녕하세요, " + applicationForm.getName() + "님.\n" +
                    "아쉽게도 KUHAS 부원 모집에 불합격하셨습니다.\n" +
                    "지원동기: " + motivationPlain + "\n" +
                    "앞으로 더 좋은 기회가 있을 때 다시 지원해주시기 바랍니다.\n지원해주셔서 감사합니다.";
            }
            helper.setSubject(subject);
            helper.setText(plainText, htmlContent);
            mailSender.send(mimeMessage);
            System.out.println("결과 HTML 이메일 발송 완료: " + applicationForm.getEmail() + " - " + status.getDisplayName());
        } catch (MessagingException | java.io.UnsupportedEncodingException e) {
            System.err.println("HTML 이메일 발송 실패: " + e.getMessage());
        }
    }
    // 지원서 수정 안내 메일 발송 (수정 전/후 모두 전달)
    public void sendApplicationModifiedEmail(ApplicationForm before, String name, String studentId, String phoneNumber, String email, String motivation, String status) {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        try {
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");
            helper.setTo(email);
            helper.setFrom(new InternetAddress("subo3os2@korea.ac.kr", "KUHAS"));
            String subject = "[KUHAS 부원 모집 지원] 지원서 수정 안내";
            String infoUrl = "https://www.notion.so/K-U-H-A-S-3ff94268d9c74280b9840d56833ea762";
            Resource logoResource = new org.springframework.core.io.ClassPathResource("static/logo.png");
            if (logoResource.exists()) {
                helper.addInline("logoImage", logoResource);
            }
            String motivationHtml = insertLineBreaks(motivation, 30, true);
            String motivationPlain = insertLineBreaks(motivation, 30, false);
            String htmlContent =
                "<table width='100%' cellpadding='0' cellspacing='0' border='0' style='background:#f7f8fa;'><tr><td align='center'>" +
                "<table width='480' cellpadding='0' cellspacing='0' border='0' style='background:#fff; border-radius:12px; box-shadow:0 2px 8px #0001; margin:40px 0;'>" +
                "<tr><td align='center' style='text-align:center; padding:32px 24px; font-family:Arial, Helvetica, sans-serif; color:#222;'>" +
                "<img src='cid:logoImage' width='180' alt='KUHAS' style='display:block; margin:0 auto 24px auto; max-width:100%; height:auto;'>" +
                "<h2 style='margin:0 0 16px 0; font-size:24px; font-weight:bold;'>KUHAS 지원서 수정 안내</h2>" +
                "<p style='font-size:16px; margin:0 0 12px 0;'>안녕하세요, <b>" + highlightIfChanged(before.getName(), name) + "</b>님.<br>지원서 정보가 성공적으로 수정되었습니다.<br><br>" +
                "<b>수정된 지원서 정보:</b><br>" +
                "- 이름: " + highlightIfChanged(before.getName(), name) + "<br>" +
                "- 학번: " + highlightIfChanged(before.getStudentId(), studentId) + "<br>" +
                "- 이메일: " + highlightIfChanged(before.getEmail(), email) + "<br>" +
                "- 전화번호: " + highlightIfChanged(before.getPhoneNumber(), phoneNumber) + "<br>" +
                "- 지원동기: " + motivationHtml + "<br>" +
                "- <br>현재 상태: " + highlightIfChanged(before.getStatus().name(), status) + "<br><br>" +
                "결과는 이메일로 개별 안내드리겠습니다.<br>감사합니다.</p>" +
                "<p style='margin-top:24px;'><a href='" + infoUrl + "' style='color:#0056b3;text-decoration:underline;font-weight:bold;'>🔗 KUHAS Notion 보러가기</a></p>" +
                "<div style='margin-top:32px; color:#888; font-size:13px;'>&copy; 2025 KUHAS. All rights reserved.</div>" +
                "</td></tr></table></td></tr></table>";
            String plainText =
                "KUHAS 지원서 수정 안내\n" +
                "안녕하세요, " + name + "님.\n" +
                "지원서 정보가 성공적으로 수정되었습니다.\n" +
                "수정된 지원서 정보:\n" +
                "- 이름: " + name + "\n" +
                "- 학번: " + studentId + "\n" +
                "- 이메일: " + email + "\n" +
                "- 전화번호: " + phoneNumber + "\n" +
                "- 지원동기: " + motivationPlain + "\n" +
                "- 현재 상태: " + status + "\n" +
                "결과는 이메일로 개별 안내드리겠습니다.\n감사합니다.";
            helper.setSubject(subject);
            helper.setText(plainText, htmlContent);
            mailSender.send(mimeMessage);
            System.out.println("지원서 수정 안내 메일 발송 완료: " + email);
        } catch (MessagingException | java.io.UnsupportedEncodingException e) {
            System.err.println("지원서 수정 안내 메일 발송 실패: " + e.getMessage());
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
}