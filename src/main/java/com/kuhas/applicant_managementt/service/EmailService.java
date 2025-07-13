package com.kuhas.applicant_managementt.service;

import com.kuhas.applicant_managementt.entity.ApplicationForm;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
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

        try {
            mailSender.send(message);
            System.out.println("지원서 접수 확인 이메일 발송 완료: " + applicationForm.getEmail());
        } catch (Exception e) {
            System.err.println("이메일 발송 실패: " + e.getMessage());
        }
    }

    // 합격/불합격 결과 이메일 발송
    public void sendResultEmail(ApplicationForm applicationForm, ApplicationForm.ApplicationStatus status) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(applicationForm.getEmail());

        if (status == ApplicationForm.ApplicationStatus.ACCEPTED) {
            message.setSubject("[합격 안내] " + applicationForm.getName() + "님 축하드립니다!");
            message.setText(
                    applicationForm.getName() + "님 안녕하세요!\n\n" +
                            "축하드립니다! 지원하신 모집에 합격하셨습니다.\n\n" +
                            "지원 정보:\n" +
                            "- 이름: " + applicationForm.getName() + "\n" +
                            "- 학번: " + applicationForm.getStudentId() + "\n" +
                            "- 이메일: " + applicationForm.getEmail() + "\n\n" +
                            "합격 관련 세부사항은 추후 별도 안내드리겠습니다.\n" +
                            "감사합니다."
            );
        } else if (status == ApplicationForm.ApplicationStatus.REJECTED) {
            message.setSubject("[불합격 안내] " + applicationForm.getName() + "님");
            message.setText(
                    applicationForm.getName() + "님 안녕하세요.\n\n" +
                            "지원해주신 모집에 대해 안타깝게도 불합격 통보를 드립니다.\n\n" +
                            "지원 정보:\n" +
                            "- 이름: " + applicationForm.getName() + "\n" +
                            "- 학번: " + applicationForm.getStudentId() + "\n" +
                            "- 이메일: " + applicationForm.getEmail() + "\n\n" +
                            "앞으로 더 좋은 기회가 있을 때 다시 지원해주시기 바랍니다.\n" +
                            "지원해주셔서 감사합니다."
            );
        }

        try {
            mailSender.send(message);
            System.out.println("결과 이메일 발송 완료: " + applicationForm.getEmail() + " - " + status.getDisplayName());
        } catch (Exception e) {
            System.err.println("이메일 발송 실패: " + e.getMessage());
        }
    }
}