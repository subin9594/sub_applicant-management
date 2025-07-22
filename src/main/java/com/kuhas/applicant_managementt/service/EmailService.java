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
    
            // 이미지 로딩 (classpath 위치 정확히 확인 필요!)
//            Resource logoResource = new ClassPathResource("/static/logo.png"); // 앞에 / 필요할 수 있음
//            if (logoResource.exists()) {
//                helper.addInline("logoImage", logoResource); // CID: logoImage
//            }
    
            String infoUrl = "https://www.notion.so/K-U-H-A-S-3ff94268d9c74280b9840d56833ea762";
            String motivationHtml = insertLineBreaks(applicationForm.getMotivation(), 30, true);
            String motivationPlain = insertLineBreaks(applicationForm.getMotivation(), 30, false);
    
            String htmlContent =
                "<html><body style='font-family:Arial,sans-serif; color:#222;'>" +
                "<div style='max-width:600px; margin:0 auto; background:#fff; border:1px solid #ccc; padding:20px;'>" +
//                "<div style='text-align:center;'>" +
//                "<img src='cid:logoImage' alt='KUHAS' style='max-width:180px; height:auto; margin-bottom:20px;'/>" +
//                "</div>" +
                "<h2>KUHAS 부원 모집 지원서 접수 확인</h2>" +
                "<p><b>" + applicationForm.getName() + "</b>님, 안녕하세요.<br>" +
                "지원서가 성공적으로 접수되었습니다.</p>" +
                "<p><b>지원 정보:</b><br>" +
                "이름: " + applicationForm.getName() + "<br>" +
                "학번: " + applicationForm.getStudentId() + "<br>" +
                "이메일: " + applicationForm.getEmail() + "<br>" +
                "전화번호: " + applicationForm.getPhoneNumber() + "<br>" +
                "지원동기: " + motivationHtml + "<br>" +
                "현재 상태: " + applicationForm.getStatus().getDisplayName() + "</p>" +
                "<p>결과는 이메일로 개별 안내드리겠습니다.<br>감사합니다.</p>" +
                "<p><a href='" + infoUrl + "' style='color:#0066cc;'>🔗 KUHAS Notion 바로가기</a></p>" +
                "</div></body></html>";
    
            String plainText =
                "[KUHAS 지원서 접수 확인]\n" +
                applicationForm.getName() + "님, 안녕하세요.\n" +
                "지원서가 접수되었습니다.\n\n" +
                "이름: " + applicationForm.getName() + "\n" +
                "학번: " + applicationForm.getStudentId() + "\n" +
                "이메일: " + applicationForm.getEmail() + "\n" +
                "전화번호: " + applicationForm.getPhoneNumber() + "\n" +
                "지원동기: " + motivationPlain + "\n" +
                "현재 상태: " + applicationForm.getStatus().getDisplayName() + "\n\n" +
                "결과는 이메일로 안내드릴 예정입니다.\n감사합니다.\n" +
                "KUHAS Notion 보러가기: " + infoUrl;
    
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
    
            // 이미지
//            Resource logoResource = new ClassPathResource("/static/logo.png");
//            if (logoResource.exists()) {
//                helper.addInline("logoImage", logoResource);
//            }
    
            String motivationHtml = insertLineBreaks(applicationForm.getMotivation(), 30, true);
            String motivationPlain = insertLineBreaks(applicationForm.getMotivation(), 30, false);
            String infoUrl = "https://www.notion.so/K-U-H-A-S-3ff94268d9c74280b9840d56833ea762";
    
            String subject, htmlContent, plainText;
    
            if (status == ApplicationForm.ApplicationStatus.ACCEPTED) {
                subject = "[KUHAS 부원 모집 합격 안내] " + applicationForm.getName() + "님 축하드립니다!";
                htmlContent =
                    "<html><body style='font-family:Arial,sans-serif; color:#222;'><div style='max-width:600px; margin:0 auto; background:#fff; border:1px solid #ccc; padding:20px;'>" +
//                "<div style='text-align:center;'><img src='cid:logoImage' alt='KUHAS' style='max-width:180px; height:auto; margin-bottom:20px;'/></div>" +
                    "<h2>KUHAS 부원 모집 합격을 축하드립니다!</h2>" +
                    "<p>" + applicationForm.getName() + "님, KUHAS 부원 모집에 <b style='color:green;'>합격</b>하셨습니다!<br>" +
                    "추후 일정은 개별 안내드릴 예정입니다.<br>감사합니다.</p>" +
                    "<p><a href='" + infoUrl + "' style='color:#0066cc;'>🔗 KUHAS Notion 바로가기</a></p>" +
                    "</div></body></html>";
    
                plainText =
                    "[KUHAS 부원 모집 합격 안내]\n" +
                    applicationForm.getName() + "님, KUHAS 부원 모집에 합격하셨습니다!\n" +
                    "지원동기: " + motivationPlain + "\n" +
                    "추후 일정은 개별 연락 드릴 예정입니다.\n감사합니다.";
            } else {
                subject = "[KUHAS 부원 모집 불합격 안내] " + applicationForm.getName() + "님";
                htmlContent =
                    "<html><body style='font-family:Arial,sans-serif; color:#222;'><div style='max-width:600px; margin:0 auto; background:#fff; border:1px solid #ccc; padding:20px;'>" +
//                "<div style='text-align:center;'><img src='cid:logoImage' alt='KUHAS' style='max-width:180px; height:auto; margin-bottom:20px;'/></div>" +
                    "<h2>KUHAS 부원 모집 결과 안내</h2>" +
                    "<p>" + applicationForm.getName() + "님, 아쉽게도 이번에는 <b style='color:red;'>불합격</b>하셨습니다.<br>" +
                    "지원해주셔서 진심으로 감사합니다.<br>다음 기회에 다시 만나길 바랍니다.</p>" +
                    "<p><a href='" + infoUrl + "' style='color:#0066cc;'>🔗 KUHAS Notion 바로가기</a></p>" +
                    "</div></body></html>";
    
                plainText =
                    "[KUHAS 부원 모집 불합격 안내]\n" +
                    applicationForm.getName() + "님, 아쉽게도 이번에는 불합격하셨습니다.\n" +
                    "지원동기: " + motivationPlain + "\n" +
                    "지원해주셔서 감사합니다. 다음 기회에 다시 만나길 바랍니다.";
            }
    
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
    
            // 이미지
//            Resource logoResource = new ClassPathResource("/static/logo.png");
//            if (logoResource.exists()) {
//                helper.addInline("logoImage", logoResource);
//            }
    
            String infoUrl = "https://www.notion.so/K-U-H-A-S-3ff94268d9c74280b9840d56833ea762";
            String motivationHtml = insertLineBreaks(motivation, 30, true);
            String motivationPlain = insertLineBreaks(motivation, 30, false);
    
            String htmlContent =
                "<html><body style='font-family:Arial,sans-serif; color:#222;'>" +
                "<div style='max-width:600px; margin:0 auto; background:#fff; border:1px solid #ccc; padding:20px;'>" +
//                "<div style='text-align:center;'>" +
//                "<img src='cid:logoImage' alt='KUHAS' style='max-width:180px; height:auto; margin-bottom:20px;'/>" +
//                "</div>" +
                "<h2>KUHAS 지원서 수정 안내</h2>" +
                "<p><b>" + highlightIfChanged(before.getName(), name) + "</b>님, 안녕하세요.<br>" +
                "지원서 정보가 성공적으로 수정되었습니다.</p>" +
                "<p><b>수정된 정보:</b><br>" +
                "이름: " + highlightIfChanged(before.getName(), name) + "<br>" +
                "학번: " + highlightIfChanged(before.getStudentId(), studentId) + "<br>" +
                "이메일: " + highlightIfChanged(before.getEmail(), email) + "<br>" +
                "전화번호: " + highlightIfChanged(before.getPhoneNumber(), phoneNumber) + "<br>" +
                "지원동기: " + motivationHtml + "<br>" +
                "현재 상태: " + highlightIfChanged(before.getStatus().name(), status) + "</p>" +
                "<p>결과는 이메일로 개별 안내드리겠습니다.<br>감사합니다.</p>" +
                "<p><a href='" + infoUrl + "' style='color:#0066cc;'>🔗 KUHAS Notion 바로가기</a></p>" +
                "</div></body></html>";
    
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
                "결과는 이메일로 안내드릴 예정입니다.\n감사합니다.\n" +
                "KUHAS Notion 보러가기: " + infoUrl;
    
            helper.setText(plainText, htmlContent);
            mailSender.send(mimeMessage);
            System.out.println("지원서 수정 안내 메일 발송 완료: " + email);
        } catch (MessagingException | UnsupportedEncodingException e) {
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