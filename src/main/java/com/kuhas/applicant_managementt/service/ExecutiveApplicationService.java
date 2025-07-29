package com.kuhas.applicant_managementt.service;

import com.kuhas.applicant_managementt.dto.ExecutiveApplicationRequest;
import com.kuhas.applicant_managementt.dto.ExecutiveApplicationResponse;
import com.kuhas.applicant_managementt.entity.ExecutiveApplication;
import com.kuhas.applicant_managementt.repository.ExecutiveApplicationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
public class ExecutiveApplicationService {
    private final ExecutiveApplicationRepository repository;

    @Autowired
    public ExecutiveApplicationService(ExecutiveApplicationRepository repository) {
        this.repository = repository;
    }

    public ExecutiveApplicationResponse submitApplication(ExecutiveApplicationRequest request) {
        ExecutiveApplication entity = new ExecutiveApplication();
        entity.setName(request.getName());
        entity.setStudentId(request.getStudentId());
        entity.setGrade(request.getGrade());
        entity.setEmail(request.getEmail());
        entity.setPhoneNumber(request.getPhoneNumber());
        entity.setLeavePlan(request.getLeavePlan());
        entity.setPeriod(request.getPeriod());
        entity.setMotivation(request.getMotivation());
        entity.setGoal(request.getGoal());
        entity.setCrisis(request.getCrisis());
        entity.setMeeting(request.getMeeting());
        entity.setResolution(request.getResolution());
        entity.setPrivacy(request.getPrivacy());
        ExecutiveApplication saved = repository.save(entity);
        return new ExecutiveApplicationResponse(saved);
    }

    @Transactional(readOnly = true)
    public List<ExecutiveApplicationResponse> getAll() {
        return repository.findAll().stream().map(ExecutiveApplicationResponse::new).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public ExecutiveApplicationResponse getById(Long id) {
        ExecutiveApplication entity = repository.findById(id).orElseThrow(() -> new IllegalArgumentException("Not found: " + id));
        return new ExecutiveApplicationResponse(entity);
    }
} 