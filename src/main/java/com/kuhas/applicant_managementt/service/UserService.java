package com.kuhas.applicant_managementt.service;

import com.kuhas.applicant_managementt.dto.UserSignUpRequest;
import com.kuhas.applicant_managementt.dto.UserResponse;
import com.kuhas.applicant_managementt.entity.User;
import com.kuhas.applicant_managementt.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional
    public UserResponse signUp(UserSignUpRequest request) {
        User user = new User();
        user.setName(request.getName());
        user.setStudentId(request.getStudentId());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(request.getRole());
        user.setApprovalStatus(User.ApprovalStatus.PENDING);
        userRepository.save(user);
        return toResponse(user);
    }

    @Transactional(readOnly = true)
    public List<UserResponse> getPendingUsers() {
        return userRepository.findByApprovalStatus(User.ApprovalStatus.PENDING)
                .stream().map(this::toResponse).collect(Collectors.toList());
    }

    @Transactional
    public UserResponse approveUser(Long userId, boolean approve) {
        User user = userRepository.findById(userId).orElseThrow();
        user.setApprovalStatus(approve ? User.ApprovalStatus.APPROVED : User.ApprovalStatus.REJECTED);
        return toResponse(user);
    }

    private UserResponse toResponse(User user) {
        UserResponse res = new UserResponse();
        res.setId(user.getId());
        res.setName(user.getName());
        res.setStudentId(user.getStudentId());
        res.setEmail(user.getEmail());
        res.setRole(user.getRole());
        res.setApprovalStatus(user.getApprovalStatus());
        return res;
    }
}