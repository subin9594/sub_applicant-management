package com.kuhas.applicant_managementt.dto;

import com.kuhas.applicant_managementt.entity.User;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserResponse {
    private Long id;
    private String name;
    private String studentId;
    private String email;
    private User.Role role;
    private User.ApprovalStatus approvalStatus;
}