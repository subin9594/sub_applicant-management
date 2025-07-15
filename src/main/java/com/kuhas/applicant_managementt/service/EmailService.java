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

@Service
public class EmailService {

    private final JavaMailSender mailSender;

    @Autowired
    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    // 지원서 접수 확인 이메일 발송
    public void sendApplicationReceivedEmail(ApplicationForm applicationForm) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(applicationForm.getEmail());
        message.setSubject("[지원서 접수 확인] " + applicationForm.getName() + "님의 지원서가 접수되었습니다");
        message.setText(
                applicationForm.getName() + "님 안녕하세요!\n\n" +
                        "지원서가 성공적으로 접수되었습니다.\n\n" +
                        "지원 정보:\n" +
                        "- 이름: " + applicationForm.getName() + "\n" +
                        "- 학번: " + applicationForm.getStudentId() + "\n" +
                        "- 이메일: " + applicationForm.getEmail() + "\n" +
                        "- 전화번호: " + applicationForm.getPhoneNumber() + "\n\n" +
                        "현재 상태: " + applicationForm.getStatus().getDisplayName() + "\n\n" +
                        "결과는 이메일로 개별 안내드리겠습니다.\n" +
                        "감사합니다."
        );
        message.setFrom("subo3os2@korea.ac.kr");

        try {
            mailSender.send(message);
            System.out.println("지원서 접수 확인 이메일 발송 완료: " + applicationForm.getEmail());
        } catch (Exception e) {
            System.err.println("이메일 발송 실패: " + e.getMessage());
        }
    }

    // 합격/불합격 결과 이메일 발송 (HTML)
    public void sendResultEmail(ApplicationForm applicationForm, ApplicationForm.ApplicationStatus status) {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        try {
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, false, "UTF-8");
            helper.setTo(applicationForm.getEmail());
            helper.setFrom(new InternetAddress("subo3os2@korea.ac.kr", "KUHAS"));
            String subject;
            String htmlContent;
            String infoUrl = "https://www.notion.so/K-U-H-A-S-3ff94268d9c74280b9840d56833ea762";
            if (status == ApplicationForm.ApplicationStatus.ACCEPTED) {
                subject = "[합격 안내] " + applicationForm.getName() + "님 축하드립니다!";
                htmlContent =
                        "<div style='font-family:Arial,sans-serif;'>" +
                                "<h2 style='color:#222;'>KUHAS 부원 모집 지원 결과 안내</h2>" +
                                "<p>안녕하세요, <b>" + applicationForm.getName() + "</b>님.<br><br>" +
                                "축하드립니다! KUHAS 부원 모집에 <span style='color:green;font-weight:bold;'>합격</span>하셨습니다.<br>" +
                                "추후 일정은 개별 연락 드릴 예정이니 메일 및 연락을 확인해주세요.<br>" +
                                "감사합니다.<br></p>" +
                                "<p><a href='" + infoUrl + "' style='color:#0056b3;text-decoration:underline;font-weight:bold;'>🔗 KUHAS 관련 정보 보러가기</a></p>" +
                                "<span style='font-size:12px;color:#888;'>&copy; 2025 KUHAS. All rights reserved.</span>" +
                                "</div>";
            } else if (status == ApplicationForm.ApplicationStatus.REJECTED) {
                subject = "[불합격 안내] " + applicationForm.getName() + "님";
                htmlContent =
                        "<div style='font-family:Arial,sans-serif;'>" +
                                "<h2 style='color:#222;'>KUHAS 부원 모집 지원 결과 안내</h2>" +
                                "<p>안녕하세요, <b>" + applicationForm.getName() + "</b>님.<br><br>" +
                                "아쉽게도 KUHAS 부원 모집에 <span style='color:red;font-weight:bold;'>불합격</span>하셨습니다.<br>" +
                                "앞으로 더 좋은 기회가 있을 때 다시 지원해주시기 바랍니다.<br>" +
                                "지원해주셔서 감사합니다.<br></p>" +
                                "<p><a href='" + infoUrl + "' style='color:#0056b3;text-decoration:underline;font-weight:bold;'>🔗 KUHAS 관련 정보 보러가기</a></p>" +
                                "<span style='font-size:12px;color:#888;'>&copy; 2025 KUHAS. All rights reserved.</span>" +
                                "</div>";
            } else {
                subject = "[지원 결과 안내] " + applicationForm.getName() + "님";
                htmlContent = "결과 안내";
            }
            helper.setSubject(subject);
            helper.setText(htmlContent, true);
            mailSender.send(mimeMessage);
            System.out.println("결과 HTML 이메일 발송 완료: " + applicationForm.getEmail() + " - " + status.getDisplayName());
        } catch (MessagingException | java.io.UnsupportedEncodingException e) {
            System.err.println("HTML 이메일 발송 실패: " + e.getMessage());
        }
    }
}