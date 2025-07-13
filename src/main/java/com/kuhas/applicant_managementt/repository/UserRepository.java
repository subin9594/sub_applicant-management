package com.kuhas.applicant_managementt.repository;

import com.kuhas.applicant_managementt.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface UserRepository extends JpaRepository<User, Long> {
    List<User> findByApprovalStatus(User.ApprovalStatus approvalStatus);
    java.util.Optional<User> findByEmail(String email);
}