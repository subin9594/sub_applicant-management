package com.kuhas.applicant_managementt.dto;

import com.kuhas.applicant_managementt.entity.User;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class UserSignUpRequest {
    private String name;
    private String studentId;
    private String email;
    private User.Role role;
    private String password;
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

}