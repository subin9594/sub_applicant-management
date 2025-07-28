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
    

    
            String infoUrl = "https://www.notion.so/K-U-H-A-S-3ff94268d9c74280b9840d56833ea762";
            String motivationHtml = insertLineBreaks(applicationForm.getMotivation(), 30, true);
            String motivationPlain = insertLineBreaks(applicationForm.getMotivation(), 30, false);
    
            String htmlContent =
                "<div style='max-width:500px;margin:0 auto;text-align:center;font-family:Segoe UI,Arial,sans-serif;'>" +
                "<h2 style='margin-bottom:16px;'>KUHAS 지원서 접수 안내</h2>" +
                "<div style='font-size:1.1em;margin-bottom:24px;'><b>지원이 정상적으로 접수되었습니다!</b></div>" +
                "<table style='margin:0 auto 24px auto;text-align:left;'>" +
                "<tr><td><b>이름</b></td><td style='padding-left:16px;'>" + applicationForm.getName() + "</td></tr>" +
                "<tr><td><b>학번</b></td><td style='padding-left:16px;'>" + applicationForm.getStudentId() + "</td></tr>" +
                "<tr><td><b>전화번호</b></td><td style='padding-left:16px;'>" + applicationForm.getPhoneNumber() + "</td></tr>" +
                "<tr><td><b>이메일</b></td><td style='padding-left:16px;'>" + applicationForm.getEmail() + "</td></tr>" +
                "<tr><td><b>상태</b></td><td style='padding-left:16px;'>" + applicationForm.getStatus().getDisplayName() + "</td></tr>" +
                "</table>" +
                "<div style='background:#f7f7f7;padding:16px 12px;border-radius:8px;margin-bottom:24px;'><b>지원동기</b><br/>" + motivationHtml + "</div>" +
                "<div style='font-size:0.95em;color:#888;'>KUHAS 드림</div>" +
                "</div>";
    
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
    
            String notionHtml = "<div style='margin-top:16px;'><a href='https://alabaster-puffin-eac.notion.site/K-U-H-A-S-3ff94268d9c74280b9840d56833ea762' style='color:#2563eb;text-decoration:underline;font-size:1em;'>🔗 KUHAS Notion 바로가기</a></div>";
            String copyrightHtml = "<div style='margin-top:24px;font-size:0.85em;color:#aaa;'>© 2025 KUHAS. All rights reserved.</div>";
            String logoImg = "<img src='https://www.notion.so/image/attachment%3A2ab80972-1341-4f51-b8f1-0049436d22e8%3AKUHAS_Final-01.png?table=block&id=2073f113-03ef-8028-bef0-e572d69f5daa&spaceId=7fe0042d-a3bc-4118-9663-78a8594018e8&width=2000&userId=a51981cf-088e-4e6a-9d83-6fbdd902b57e&cache=v2' style='max-width:120px;margin-bottom:18px;' alt='KUHAS Logo'/>";
            htmlContent = logoImg + htmlContent;
            htmlContent = htmlContent + notionHtml + copyrightHtml;
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
    
            if (status == ApplicationForm.ApplicationStatus.ACCEPTED) {
                subject = "[KUHAS 부원 모집 합격 안내] " + applicationForm.getName() + "님";
                htmlContent =
                    "<div style='max-width:500px;margin:0 auto;text-align:center;font-family:Segoe UI,Arial,sans-serif;'>" +
                    "<h2 style='margin-bottom:16px;color:#22c55e;'>KUHAS 합격을 축하드립니다!</h2>" +
                    "<div style='font-size:1.1em;margin-bottom:24px;'><b>합격을 진심으로 축하합니다!</b></div>" +
                    "<table style='margin:0 auto 24px auto;text-align:left;'>" +
                    "<tr><td><b>이름</b></td><td style='padding-left:16px;'>" + applicationForm.getName() + "</td></tr>" +
                    "<tr><td><b>학번</b></td><td style='padding-left:16px;'>" + applicationForm.getStudentId() + "</td></tr>" +
                    "<tr><td><b>전화번호</b></td><td style='padding-left:16px;'>" + applicationForm.getPhoneNumber() + "</td></tr>" +
                    "<tr><td><b>이메일</b></td><td style='padding-left:16px;'>" + applicationForm.getEmail() + "</td></tr>" +
                    "<tr><td><b>상태</b></td><td style='padding-left:16px;color:#22c55e;'>합격</td></tr>" +
                    "</table>" +
                    "<div style='background:#f7f7f7;padding:16px 12px;border-radius:8px;margin-bottom:24px;'><b>지원동기</b><br/>" + motivationHtml + "</div>" +
                    "KUHAS 드림" +
                    "</div>";
                plainText =
                    "[KUHAS 부원 모집 합격 안내]\n" +
                    applicationForm.getName() + "님, KUHAS 부원 모집에 합격하셨습니다!\n" +
                    "지원동기: " + motivationPlain + "\n" +
                    "추후 일정은 개별 연락 드릴 예정입니다.\n감사합니다.";
            } else {
                subject = "[KUHAS 부원 모집 합불 안내] " + applicationForm.getName() + "님";
                htmlContent =
                    "<div style='max-width:500px;margin:0 auto;text-align:center;font-family:Segoe UI,Arial,sans-serif;'>" +
                    "<h2 style='margin-bottom:16px;color:#ef4444;'>KUHAS 불합격 안내</h2>" +
                    "<div style='font-size:1.1em;margin-bottom:24px;'><b>아쉽게도 이번에는 불합격하셨습니다.</b></div>" +
                    "<table style='margin:0 auto 24px auto;text-align:left;'>" +
                    "<tr><td><b>이름</b></td><td style='padding-left:16px;'>" + applicationForm.getName() + "</td></tr>" +
                    "<tr><td><b>학번</b></td><td style='padding-left:16px;'>" + applicationForm.getStudentId() + "</td></tr>" +
                    "<tr><td><b>전화번호</b></td><td style='padding-left:16px;'>" + applicationForm.getPhoneNumber() + "</td></tr>" +
                    "<tr><td><b>이메일</b></td><td style='padding-left:16px;'>" + applicationForm.getEmail() + "</td></tr>" +
                    "<tr><td><b>상태</b></td><td style='padding-left:16px;color:#ef4444;'>불합격</td></tr>" +
                    "</table>" +
                    "<div style='background:#f7f7f7;padding:16px 12px;border-radius:8px;margin-bottom:24px;'><b>지원동기</b><br/>" + motivationHtml + "</div>" +
                    "KUHAS 드림" +
                    "</div>";
                plainText =
                    "[KUHAS 부원 모집 합불 안내]\n" +
                    applicationForm.getName() + "님, 아쉽게도 이번에는 불합격하셨습니다.\n" +
                    "지원동기: " + motivationPlain + "\n" +
                    "지원해주셔서 감사합니다. 다음 기회에 다시 만나길 바랍니다.";
            }
    
            String notionHtml = "<div style='margin-top:16px;'><a href='https://alabaster-puffin-eac.notion.site/K-U-H-A-S-3ff94268d9c74280b9840d56833ea762' style='color:#2563eb;text-decoration:underline;font-size:1em;'>🔗 KUHAS Notion 바로가기</a></div>";
            String copyrightHtml = "<div style='margin-top:24px;font-size:0.85em;color:#aaa;'>© 2025 KUHAS. All rights reserved.</div>";
            String logoImg = "<img src='https://www.notion.so/image/attachment%3A2ab80972-1341-4f51-b8f1-0049436d22e8%3AKUHAS_Final-01.png?table=block&id=2073f113-03ef-8028-bef0-e572d69f5daa&spaceId=7fe0042d-a3bc-4118-9663-78a8594018e8&width=2000&userId=a51981cf-088e-4e6a-9d83-6fbdd902b57e&cache=v2' style='max-width:120px;margin-bottom:18px;' alt='KUHAS Logo'/>";
            htmlContent = logoImg + htmlContent;
            htmlContent = htmlContent + notionHtml + copyrightHtml;
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
                "<div style='max-width:500px;margin:0 auto;text-align:center;font-family:Segoe UI,Arial,sans-serif;'>" +
                "<h2 style='margin-bottom:16px;'>KUHAS 지원서 수정 안내</h2>" +
                "<div style='font-size:1.1em;margin-bottom:24px;'><b>지원서 정보가 성공적으로 수정되었습니다.</b></div>" +
                "<table style='margin:0 auto 24px auto;text-align:left;'>" +
                "<tr><td><b>이름</b></td><td style='padding-left:16px;'>" + highlightIfChanged(before.getName(), name) + "</td></tr>" +
                "<tr><td><b>학번</b></td><td style='padding-left:16px;'>" + highlightIfChanged(before.getStudentId(), studentId) + "</td></tr>" +
                "<tr><td><b>전화번호</b></td><td style='padding-left:16px;'>" + highlightIfChanged(before.getPhoneNumber(), phoneNumber) + "</td></tr>" +
                "<tr><td><b>이메일</b></td><td style='padding-left:16px;'>" + highlightIfChanged(before.getEmail(), email) + "</td></tr>" +
                "<tr><td><b>상태</b></td><td style='padding-left:16px;'>" + highlightIfChanged(before.getStatus().name(), status) + "</td></tr>" +
                "</table>" +
                "<div style='background:#f7f7f7;padding:16px 12px;border-radius:8px;margin-bottom:24px;'><b>지원동기</b><br/>" + motivationHtml + "</div>" +
                "<div style='font-size:0.95em;color:#888;'>KUHAS 드림</div>" +
                "</div>";
    
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
    
            String notionHtml = "<div style='margin-top:16px;'><a href='https://alabaster-puffin-eac.notion.site/K-U-H-A-S-3ff94268d9c74280b9840d56833ea762' style='color:#2563eb;text-decoration:underline;font-size:1em;'>🔗 KUHAS Notion 바로가기</a></div>";
            String copyrightHtml = "<div style='margin-top:24px;font-size:0.85em;color:#aaa;'>© 2025 KUHAS. All rights reserved.</div>";
            String logoImg = "<img src='https://www.notion.so/image/attachment%3A2ab80972-1341-4f51-b8f1-0049436d22e8%3AKUHAS_Final-01.png?table=block&id=2073f113-03ef-8028-bef0-e572d69f5daa&spaceId=7fe0042d-a3bc-4118-9663-78a8594018e8&width=2000&userId=a51981cf-088e-4e6a-9d83-6fbdd902b57e&cache=v2' style='max-width:120px;margin-bottom:18px;' alt='KUHAS Logo'/>";
            htmlContent = logoImg + htmlContent;
            htmlContent = htmlContent + notionHtml + copyrightHtml;
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