# 지원서 관리 시스템 (Applicant Management System)

Spring Boot를 사용한 지원서 제출 및 관리 시스템입니다.

## 주요 기능

- 지원서 제출 및 관리
- 지원서 상태 관리 (대기중, 합격, 불합격)
- 이메일 알림 기능
- 지원서 검색 및 필터링
- 통계 정보 제공

## 기술 스택

- **Backend**: Spring Boot 3.2.0
- **Database**: H2 (인메모리)
- **ORM**: Spring Data JPA
- **Email**: Spring Mail
- **Validation**: Bean Validation

## 프로젝트 구조

```
src/main/java/com/example/applicantmanagement/
├── ApplicantManagementApplication.java    # 메인 애플리케이션
├── controller/
│   └── ApplicationFormController.java     # REST API 컨트롤러
├── service/
│   ├── ApplicationFormService.java        # 비즈니스 로직
│   └── EmailService.java                  # 이메일 서비스
├── repository/
│   └── ApplicationFormRepository.java     # 데이터 접근 계층
├── entity/
│   └── ApplicationForm.java              # 엔티티 클래스
└── dto/
    ├── ApplicationFormRequest.java        # 요청 DTO
    └── ApplicationFormResponse.java       # 응답 DTO
```

## API 엔드포인트

### 지원서 관리
- `POST /api/applications` - 지원서 제출
- `GET /api/applications` - 모든 지원서 조회
- `GET /api/applications/{id}` - ID로 지원서 조회
- `GET /api/applications/student/{studentId}` - 학번으로 지원서 조회
- `GET /api/applications/status/{status}` - 상태별 지원서 조회
- `GET /api/applications/search?keyword={keyword}` - 키워드로 검색
- `PUT /api/applications/{id}/status?status={status}` - 지원서 상태 변경
- `DELETE /api/applications/{id}` - 지원서 삭제
- `GET /api/applications/statistics` - 통계 정보 조회

## 실행 방법

### 1. 프로젝트 빌드
```bash
mvn clean install
```

### 2. 애플리케이션 실행
```bash
mvn spring-boot:run
```

### 3. 접속
- 애플리케이션: http://localhost:8080
- H2 콘솔: http://localhost:8080/h2-console

## 설정

### 이메일 설정
`src/main/resources/application.yml` 파일에서 이메일 설정을 수정하세요:

```yaml
spring:
  mail:
    host: smtp.gmail.com
    port: 587
    username: your-email@gmail.com
    password: your-app-password
```

### 데이터베이스 설정
현재 H2 인메모리 데이터베이스를 사용하고 있습니다. 다른 데이터베이스를 사용하려면 `application.yml`을 수정하세요.

## 지원서 상태

- `PENDING` - 대기중
- `ACCEPTED` - 합격
- `REJECTED` - 불합격

## 예시 요청

### 지원서 제출
```bash
curl -X POST http://localhost:8080/api/applications \
  -H "Content-Type: application/json" \
  -d '{
    "name": "홍길동",
    "studentId": "2024001",
    "phoneNumber": "010-1234-5678",
    "email": "hong@example.com",
    "motivation": "저는 이 분야에 관심이 많아서 지원하게 되었습니다."
  }'
```

### 지원서 상태 변경
```bash
curl -X PUT "http://localhost:8080/api/applications/1/status?status=ACCEPTED"
```

## 개발 환경

- Java 17
- Maven 3.6+
- Spring Boot 3.2.0

## 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다. 