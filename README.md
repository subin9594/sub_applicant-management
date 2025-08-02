# KUHAS 지원서 관리 시스템

Spring Boot 백엔드와 Flutter 프론트엔드를 사용한 KUHAS 지원서 제출 및 관리 시스템입니다.

## 주요 기능

### 지원서 제출
- **부원 모집 지원서**: 일반 회원 지원서 제출
- **운영진 모집 지원서**: 운영진 지원서 제출
- **실시간 폼 검증**: 모든 필수 항목 검증 및 중복 체크
- **제출 성공 애니메이션**: Lottie 애니메이션으로 제출 완료 표시
- **이메일 알림**: 제출 완료 시 자동 이메일 발송
- **자동 스크롤**: 검증 실패 시 첫 번째 오류 항목으로 자동 스크롤
- **통합 에러 메시지**: 제출 시 모든 미충족 항목의 에러 메시지를 한 번에 표시

### 관리자 기능
- **관리자 로그인**: 안전한 관리자 인증
- **지원서 목록 조회**: 부원/운영진 지원서 분류 조회
- **지원서 상세 보기**: 개별 지원서 상세 정보 확인
- **지원서 상태 관리**: 합격/불합격 상태 변경
- **지원서 삭제**: 불필요한 지원서 삭제 (삭제 후 목록 페이지로 자동 이동)
- **순번 및 제출일시**: 지원서 순서와 제출 시간 표시
- **요약 카드 목록**: 앱 친화적인 카드 형태 목록
- **상세 페이지**: 카드 클릭 시 전체 정보 확인
- **지원서 수정**: 상세 페이지에서 지원서 내용 수정 가능

### 사용자 인터페이스
- **반응형 디자인**: 모바일 친화적 UI/UX
- **툴바 메뉴**: 지원서 양식 선택 및 관리자 로그인 접근
- **카드 기반 목록**: 앱 친화적인 지원서 목록 표시
- **직관적 네비게이션**: 홈 버튼 및 드로어 메뉴
- **홈 버튼**: 모든 페이지에서 지원서 작성 페이지로 이동

## 기술 스택

### Backend
- **Framework**: Spring Boot 3.2.0
- **Database**: H2 (인메모리)
- **ORM**: Spring Data JPA
- **Email**: Spring Mail
- **Validation**: Bean Validation
- **Security**: Spring Security

### Frontend
- **Framework**: Flutter 3.x
- **HTTP Client**: http package
- **Animation**: Lottie
- **UI Components**: Material Design 3

## 프로젝트 구조

```
sub_applicant-management/
├── src/main/java/com/kuhas/applicant_managementt/
│   ├── ApplicantManagementApplication.java
│   ├── controller/
│   │   ├── AdminController.java
│   │   ├── ApplicationFormController.java
│   │   ├── ExecutiveApplicationController.java
│   │   └── HomeController.java
│   ├── service/
│   │   ├── ApplicationFormService.java
│   │   ├── ExecutiveApplicationService.java
│   │   └── EmailService.java
│   ├── entity/
│   │   ├── ApplicationForm.java
│   │   └── ExecutiveApplication.java
│   ├── dto/
│   │   ├── ApplicationFormRequest.java
│   │   ├── ApplicationFormResponse.java
│   │   ├── ExecutiveApplicationRequest.java
│   │   └── ExecutiveApplicationResponse.java
│   ├── repository/
│   │   ├── ApplicationFormRepository.java
│   │   └── ExecutiveApplicationRepository.java
│   ├── config/
│   │   └── SecurityConfig.java
│   └── exception/
│       └── GlobalExceptionHandler.java
├── src/main/resources/
│   ├── application.yml
│   ├── templates/
│   │   ├── home.html
│   │   ├── admin.html
│   │   ├── admin_login.html
│   │   └── admin_edit.html
│   └── static/
│       ├── favicon.ico
│       └── logo.png
└── flutter-frontend/
    ├── lib/
    │   ├── main.dart                           # 부원 지원서 페이지
    │   ├── executive_form_page.dart            # 운영진 지원서 페이지
    │   ├── admin_login_page.dart               # 관리자 로그인
    │   ├── admin_main_page.dart                # 관리자 메인 페이지 (지원서 목록)
    │   ├── admin_application_detail_page.dart  # 부원 지원서 상세 페이지
    │   ├── admin_executive_detail_page.dart    # 운영진 지원서 상세 페이지
    │   └── admin_edit_page.dart                # 지원서 편집
    └── assets/
        └── success.json                        # 제출 성공 애니메이션
```

## 주요 기능 상세

### 폼 검증 시스템
- **실시간 검증**: 입력 시 즉시 오류 메시지 표시
- **필수 항목 검증**: 모든 필수 필드 입력 확인
- **형식 검증**: 이메일, 전화번호, 학번 형식 검증
- **중복 검증**: 학번, 이메일, 전화번호 중복 체크
- **길이 제한**: 텍스트 필드 길이 제한 및 검증
- **개별 오류 메시지**: 각 필드별 개별 오류 메시지 표시
- **자동 스크롤**: 검증 실패 시 첫 번째 오류 항목으로 자동 스크롤 (0.5초 애니메이션)
- **통합 에러 표시**: 제출 버튼 클릭 시 모든 미충족 항목의 에러 메시지를 동시에 표시

### 지원서 양식

#### 부원 모집 지원서
- **이름**: 필수 입력, 한글/영문만 허용, 100자 이하
- **학번**: 필수 입력, 정확히 10자리 숫자
- **학년**: 필수 선택 (1-4학년)
- **전화번호**: 필수 입력, 숫자/하이픈만 허용, 8~13자
- **이메일**: 필수 입력, 이메일 형식 검증
- **지원 동기**: 필수 입력, 100자 이상
- **기타 활동**: 필수 입력
- **커리큘럼 이수 가능 이유**: 필수 입력
- **KUHAS에서 얻고 싶은 것**: 필수 입력
- **진로**: 필수 입력
- **프로그래밍 언어 경험 여부**: 필수 선택 (O/X)
- **경험한 언어**: 언어 경험이 'O'인 경우 필수 입력
- **희망 활동**: 필수 다중 선택 (활동 1, 2, 3)
- **대면 면접 희망 날짜**: 필수 선택 (9월 1-4일)
- **개강총회 참석 여부**: 필수 선택 (개강총회만/뒷풀이만/둘 다)
- **개인정보 동의**: 필수 선택

#### 운영진 모집 지원서
- **이름**: 필수 입력, 한글/영문만 허용, 100자 이하
- **학번**: 필수 입력, 정확히 10자리 숫자
- **학년**: 필수 선택 (1-4학년)
- **전화번호**: 필수 입력, 숫자/하이픈만 허용, 8~13자
- **이메일**: 필수 입력, 이메일 형식 검증
- **휴학 계획**: 필수 입력 (없다면 '없음' 입력), 300자 내외
- **운영진 활동 기간**: 필수 선택 (6개월/1년/1년 이상/기타)
- **지원 동기**: 필수 입력, 100자 이상, 300자 내외
- **운영진 활동 목표**: 필수 입력, 100자 이상, 300자 내외
- **위기 극복 경험**: 필수 입력 (없다면 '없음' 입력), 300자 내외
- **회의 참석 가능 여부**: 필수 선택
- **개인정보 동의**: 필수 선택

### 검증 방식
- **실시간 검증**: 입력 중에 validator가 즉시 형식 오류 표시
- **제출 시 검증**: 제출 버튼 누를 때 빈 필드 오류 메시지 표시
- **개별 오류 메시지**: 각 필드별로 개별 오류 메시지 표시
- **서버 검증**: 중복 체크 및 서버 오류 메시지 표시
- **자동 스크롤**: 검증 실패 시 첫 번째 오류 항목으로 자동 스크롤
- **통합 에러 표시**: 모든 미충족 항목의 에러 메시지를 동시에 표시

### 관리자 기능

#### 지원서 목록 관리
- **요약 카드 목록**: 이름, 학번, 학년, 이메일, 전화번호, 상태만 표시
- **순번 표시**: 제출 순서대로 1, 2, 3... 순번 표시
- **제출일시 표시**: YYYY-MM-DD (줄바꿈) HH:mm:ss 형식으로 표시
- **정렬**: 제출일시 순으로 오름차순 정렬
- **상태 표시**: 대기/합격/불합격 상태를 색상으로 구분
- **카드 클릭**: 상세 페이지로 이동

#### 지원서 상세 보기
- **전체 정보 표시**: 모든 제출 항목의 상세 내용 확인
- **제출일시 표시**: 상세 페이지 상단에 제출일시 표시
- **편집 기능**: 상세 페이지에서 지원서 수정 가능
- **삭제 기능**: 상세 페이지에서 지원서 삭제 가능 (삭제 후 목록 페이지로 자동 이동)
- **상태 관리**: 합격/불합격 상태 변경
- **성공 메시지**: 삭제 완료 시 스낵바로 성공 메시지 표시

#### 네비게이션
- **홈 버튼**: 모든 관리자 페이지에서 지원서 작성 페이지로 이동
- **뒤로가기**: 상세 페이지에서 목록으로 돌아가기
- **지원서 양식 선택**: 드롭다운으로 부원/운영진 지원서 전환
- **자동 리프레시**: 삭제 후 목록 자동 새로고침

### 지원서 수정 기능
- **일관된 양식**: 수정 페이지의 선택 항목들이 제출 페이지와 동일한 옵션 제공
- **데이터 반영**: 기존 제출 데이터가 수정 페이지에 정확히 반영
- **선택 항목 동기화**: 프로그래밍 언어 경험, 희망 활동, 면접 날짜 등의 선택 항목들이 제출 페이지와 일치
- **웹/앱 동기화**: 웹 버전과 Flutter 앱 버전의 수정 페이지가 동일한 기능 제공

### 지원서 목록 UI/UX
- **카드 디자인**: 둥근 모서리와 그림자가 있는 카드 형태
- **아바타**: 지원자 이름 첫 글자로 원형 아바타 표시
- **색상 구분**: 상태별로 다른 색상 사용 (대기: 주황, 합격: 초록, 불합격: 빨강)
- **정보 배치**: 왼쪽에 기본 정보, 오른쪽에 순번과 제출일시
- **터치 반응**: 카드 클릭 시 상세 페이지로 자연스러운 이동

## API 엔드포인트

### 부원 지원서
- `POST /api/applications` - 부원 지원서 제출
- `GET /api/applications` - 부원 지원서 목록 조회
- `GET /api/applications/{id}` - 부원 지원서 상세 조회
- `PUT /api/applications/{id}` - 부원 지원서 수정
- `DELETE /api/applications/{id}` - 부원 지원서 삭제
- `GET /api/applications/exists` - 중복 체크

### 운영진 지원서
- `POST /api/executive-applications` - 운영진 지원서 제출
- `GET /api/executive-applications` - 운영진 지원서 목록 조회
- `GET /api/executive-applications/{id}` - 운영진 지원서 상세 조회
- `PUT /api/executive-applications/{id}` - 운영진 지원서 수정
- `DELETE /api/executive-applications/{id}` - 운영진 지원서 삭제

### 관리자
- `POST /api/admin/login` - 관리자 로그인
- `GET /api/admin/applications` - 관리자용 지원서 목록

### 웹 페이지
- `GET /` - 부원 지원서 제출 페이지
- `GET /admin` - 관리자 메인 페이지
- `GET /admin/login` - 관리자 로그인 페이지
- `GET /admin/edit/{id}` - 지원서 수정 페이지

## 실행 방법

### 1. Backend 실행
```bash
# 프로젝트 루트 디렉토리에서
./gradlew bootRun
```

### 2. Frontend 실행
```bash
# flutter-frontend 디렉토리에서
flutter pub get
flutter run
```

### 3. 접속
- **Flutter 앱**: 에뮬레이터 또는 실제 기기에서 실행
- **웹 페이지**: http://localhost:8080
- **Backend API**: http://localhost:8080
- **H2 콘솔**: http://localhost:8080/h2-console

## 설정

### 이메일 설정
`src/main/resources/application.yml`에서 이메일 설정을 수정하세요:

```yaml
spring:
  mail:
    host: smtp.gmail.com
    port: 587
    username: your-email@gmail.com
    password: your-app-password
```

### Flutter 설정
`flutter-frontend/pubspec.yaml`에서 필요한 패키지들이 자동으로 설치됩니다.

## 개발 환경

### Backend
- Java 17
- Gradle 7.x
- Spring Boot 3.2.0

### Frontend
- Flutter 3.x
- Dart 3.x
- Android Studio / VS Code

## 주요 특징

### 사용자 경험 (UX)
- **직관적 인터페이스**: 명확한 라벨과 힌트 텍스트
- **실시간 피드백**: 즉시 오류 메시지 표시
- **성공 애니메이션**: 제출 완료 시 시각적 피드백
- **반응형 디자인**: 다양한 화면 크기에 대응
- **카드 기반 목록**: 앱 친화적인 지원서 목록
- **순번 및 제출일시**: 지원서 관리 효율성 증대
- **자동 스크롤**: 검증 실패 시 첫 번째 오류 항목으로 자동 이동
- **통합 에러 표시**: 모든 미충족 항목의 에러 메시지를 동시에 표시
- **자동 네비게이션**: 삭제 후 목록 페이지로 자동 이동

### 보안
- **입력 검증**: 클라이언트/서버 양쪽 검증
- **중복 방지**: 학번, 이메일, 전화번호 중복 체크
- **관리자 인증**: 안전한 로그인 시스템

### 성능
- **빠른 응답**: 최적화된 API 응답
- **효율적 UI**: 카드 기반 목록으로 빠른 로딩
- **메모리 효율성**: 적절한 리소스 관리
- **정렬 최적화**: 제출일시 기준 정렬로 관리 편의성 향상
- **자동 스크롤**: 사용자 경험 향상을 위한 스마트 네비게이션

## 최근 업데이트

### v1.2.0 (최신)
- **자동 스크롤 기능**: 검증 실패 시 첫 번째 오류 항목으로 자동 스크롤
- **통합 에러 메시지**: 제출 시 모든 미충족 항목의 에러 메시지를 동시에 표시
- **네비게이션 개선**: 삭제 후 목록 페이지로 자동 이동
- **수정 페이지 동기화**: 제출 페이지와 수정 페이지의 선택 항목 일치
- **성공 메시지**: 삭제 완료 시 스낵바로 성공 메시지 표시

### v1.1.0
- **필수 항목 검증**: 프로그래밍 언어 경험, 희망 활동, 면접 날짜, 참석 여부, 개인정보 동의 필수화
- **에러 메시지 개선**: 각 필드별 개별 에러 메시지 표시
- **웹 버전 지원**: HTML/JavaScript 기반 웹 버전 추가

### v1.0.0
- **기본 지원서 시스템**: 부원/운영진 지원서 제출 및 관리
- **관리자 기능**: 로그인, 목록 조회, 상세 보기, 수정, 삭제
- **Flutter 앱**: 모바일 친화적 UI/UX

## 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다. 