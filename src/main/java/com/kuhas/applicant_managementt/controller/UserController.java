package com.kuhas.applicant_managementt.controller;

import com.kuhas.applicant_managementt.dto.UserSignUpRequest;
import com.kuhas.applicant_managementt.dto.UserResponse;
import com.kuhas.applicant_managementt.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/user")
public class UserController {
    private final UserService userService;
    public UserController(UserService userService) { this.userService = userService; }

    @PostMapping("/signup")
    public UserResponse signUp(@RequestBody UserSignUpRequest request) {
        return userService.signUp(request);
    }

    @GetMapping("/pending")
    public List<UserResponse> getPendingUsers() {
        return userService.getPendingUsers();
    }

    @PostMapping("/approve/{userId}")
    public UserResponse approveUser(@PathVariable Long userId, @RequestParam boolean approve) {
        return userService.approveUser(userId, approve);
    }

    @GetMapping("/role")
    public ResponseEntity<String> getUserRole(Authentication authentication) {
        String role = authentication.getAuthorities().stream()
                .findFirst()
                .map(GrantedAuthority::getAuthority)
                .orElse("APPLICANT");
        return ResponseEntity.ok(role);
    }
}