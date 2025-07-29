import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admin_login_page.dart';
import 'dart:convert'; // Added for json.encode
import 'admin_main_page.dart';
// Added for AdminEditPage
import 'package:lottie/lottie.dart';
import 'executive_form_page.dart'; // Added for ExecutiveFormPage

void main() {
  runApp(const ApplicantFormApp());
}

class ApplicantFormApp extends StatelessWidget {
  const ApplicantFormApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KUHAS 부원 모집 지원서',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => ApplicantFormPage(),
        '/admin-login': (context) => AdminLoginPage(onLoginSuccess: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AdminMainPage(
                onLogout: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => ApplicantFormPage()),
                    (route) => false,
                  );
                },
              ),
            ),
          );
        }),
      },
    );
  }
}

enum AdminPageView { none, login, main, edit }

class ApplicantFormPage extends StatefulWidget {
  final VoidCallback? onAdminTap;
  const ApplicantFormPage({super.key, this.onAdminTap});

  @override
  State<ApplicantFormPage> createState() => _ApplicantFormPageState();
}

class _ApplicantFormPageState extends State<ApplicantFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _motivationController = TextEditingController();
  // Add controllers and state for new fields
  final _otherActivityController = TextEditingController();
  final _curriculumReasonController = TextEditingController();
  final _wishController = TextEditingController();
  final _careerController = TextEditingController();
  final _languageController = TextEditingController();
  String? _languageExp; // 'O' or 'X'
  String? _gradeDropdownValue;

  // Add state for wishActivities, interviewDate, attendType
  final List<String> _wishActivities = [];
  String? _selectedInterviewDate;
  String? _selectedAttendType;
  String? _privacyValue;

  bool _isSubmitting = false;
  String? _message;
  String? _error;
  bool _showSuccess = false;
  bool _hasSubmitted = false;
  bool _showNameError = false;
  bool _showStudentIdError = false;
  bool _showGradeError = false;
  bool _showPhoneError = false;
  bool _showEmailError = false;
  bool _showMotivationError = false;
  bool _showOtherActivityError = false;
  bool _showCurriculumReasonError = false;
  bool _showWishError = false;
  bool _showCareerError = false;
  bool _showPrivacyError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _motivationController.dispose();
    _otherActivityController.dispose();
    _curriculumReasonController.dispose();
    _wishController.dispose();
    _careerController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
      _message = null;
      _hasSubmitted = true;
      _showNameError = _nameController.text.trim().isEmpty;
      _showStudentIdError = _studentIdController.text.trim().isEmpty;
      _showGradeError = _gradeDropdownValue == null || _gradeDropdownValue!.trim().isEmpty;
      _showPhoneError = _phoneController.text.trim().isEmpty;
      _showEmailError = _emailController.text.trim().isEmpty;
      _showMotivationError = _motivationController.text.trim().isEmpty;
      _showOtherActivityError = _otherActivityController.text.trim().isEmpty;
      _showCurriculumReasonError = _curriculumReasonController.text.trim().isEmpty;
      _showWishError = _wishController.text.trim().isEmpty;
      _showCareerError = _careerController.text.trim().isEmpty;
      _showPrivacyError = _privacyValue == null || _privacyValue!.trim().isEmpty;
    });

    if (!_formKey.currentState!.validate() || _showNameError || _showStudentIdError || _showGradeError || _showPhoneError || _showEmailError || _showMotivationError || _showOtherActivityError || _showCurriculumReasonError || _showWishError || _showCareerError || _showPrivacyError) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    // Android 에뮬레이터에서는 10.0.2.2가 PC의 localhost를 가리킴
    final url = Uri.parse('http://10.0.2.2:8080/api/applications');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _nameController.text.trim(),
          'studentId': _studentIdController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'motivation': _motivationController.text.trim(),
          'otherActivity': _otherActivityController.text.trim(),
          'curriculumReason': _curriculumReasonController.text.trim(),
          'wish': _wishController.text.trim(),
          'career': _careerController.text.trim(),
          'languageExp': _languageExp,
          'languageDetail': _languageController.text.trim(),
          'wishActivities': _wishActivities.join(','),
          'interviewDate': _selectedInterviewDate,
          'attendType': _selectedAttendType,
          'privacyAgreement': _privacyValue,
          'grade': _gradeDropdownValue,
        }),
      );

      setState(() {
        _isSubmitting = false;
        if (response.statusCode == 200) {
          _showSuccess = true;
          _message = '지원서가 성공적으로 제출되었습니다!';
        } else {
          String errorMsg = '제출에 실패했습니다. 다시 시도해 주세요. (서버 오류: \n  {response.statusCode}\n  {response.body})';
          try {
            final data = json.decode(response.body);
            if (data['error'] != null) errorMsg = data['error'];
          } catch (_) {}
          print('지원서 제출 실패: statusCode =  [response.statusCode], body =  [response.body]');
          _error = errorMsg;
        }
      });
      if (response.statusCode == 200) {
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          setState(() {
            _showSuccess = false;
            // 폼 초기화
            _nameController.clear();
            _studentIdController.clear();
            _phoneController.clear();
            _emailController.clear();
            _motivationController.clear();
            _otherActivityController.clear();
            _curriculumReasonController.clear();
            _wishController.clear();
            _careerController.clear();
            _languageController.clear();
            _gradeDropdownValue = null;
            _languageExp = null;
            _wishActivities.clear();
            _selectedInterviewDate = null;
            _selectedAttendType = null;
            _privacyValue = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = '제출 중 오류가 발생했습니다.\n  {e.toString()}';
        _isSubmitting = false;
      });
    }
  }

  Future<String?> _checkDuplicate() async {
    final studentId = _studentIdController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final url = Uri.parse('http://10.0.2.2:8080/api/applications/exists?studentId=$studentId&email=$email&phoneNumber=$phone');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      List<String> duplicates = [];
      if (data['studentId'] == true) duplicates.add('학번');
      if (data['email'] == true) duplicates.add('이메일');
      if (data['phoneNumber'] == true) duplicates.add('전화번호');
      
      if (duplicates.isNotEmpty) {
        return '이미 사용 중인 ${duplicates.join(', ')}입니다.';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
      appBar: AppBar(
        title: const Text('KUHAS'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: 'member',
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              items: const [
                DropdownMenuItem(
                  value: 'member',
                  child: Text('부원 모집 지원서'),
                ),
                DropdownMenuItem(
                  value: 'executive',
                  child: Text('운영진 모집 지원서'),
                ),
              ],
              onChanged: (value) {
                if (value == 'executive') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ExecutiveFormPage()),
                  );
                }
                // 부원 모집 지원서는 현재 페이지이므로 아무 동작 안 함
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('메뉴', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            // 지원서 양식 선택 메뉴는 Drawer에서 제거
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('관리자 로그인'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/admin-login');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.08 * 255).toInt()),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            width: 380,
            child: _showSuccess && _message != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/success.json', width: 120, repeat: false),
                      const SizedBox(height: 16),
                      Text(
                        _message!,
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('KUHAS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('부원 모집 지원서 제출', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              softWrap: true,
                              maxLines: null,
                            ),
                          ),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: '이름',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return '이름을 입력하세요.';
                            if (!RegExp(r'^[가-힣a-zA-Z\s]+$').hasMatch(value.trim())) return '이름은 한글 또는 영문만 입력하세요.';
                            if (value.length > 100) return '이름은 100자 이하여야 합니다.';
                            return null;
                          },
                        ),
                        if (_showNameError)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text('이름을 입력하세요.', style: TextStyle(color: Colors.red)),
                          ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _studentIdController,
                          decoration: const InputDecoration(
                            labelText: '학번',
                            hintText: 'ex) 20XX270XXX',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return '학번을 입력하세요.';
                            if (!RegExp(r'^\d{10}$').hasMatch(value)) return '학번은 숫자 10자리로 입력하세요.';
                            return null;
                          },
                        ),
                        if (_showStudentIdError)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text('학번을 입력하세요.', style: TextStyle(color: Colors.red)),
                          ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _gradeDropdownValue,
                          items: [
                            '1학년', '2학년', '3학년', '4학년'
                          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => _gradeDropdownValue = v),
                          decoration: const InputDecoration(labelText: '학년'),
                          validator: (v) => v == null ? '학년을 선택하세요.' : null,
                        ),
                        if (_showGradeError)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text('학년을 선택하세요.', style: TextStyle(color: Colors.red)),
                          ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: '전화번호',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return '전화번호를 입력하세요.';
                            if (!RegExp(r'^[0-9\-]+$').hasMatch(value)) return '전화번호는 숫자와 -만 입력하세요.';
                            if (value.length < 8 || value.length > 13) return '전화번호는 8~13자 이내로 입력하세요.';
                            return null;
                          },
                        ),
                        if (_showPhoneError)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text('전화번호를 입력하세요.', style: TextStyle(color: Colors.red)),
                          ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: '이메일',
                            hintText: 'ex) xxx@gmail.com 또는 xxx@korea.ac.kr',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return '이메일을 입력하세요.';
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return '이메일 형식이 올바르지 않습니다.';
                            return null;
                          },
                        ),
                        if (_showEmailError)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text('이메일을 입력하세요.', style: TextStyle(color: Colors.red)),
                          ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _motivationController,
                          decoration: const InputDecoration(
                            labelText: '지원동기',
                            hintText: 'KUHAS 지원 동기를 작성해주세요. (100자 이상)',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          minLines: 4,
                          maxLines: 8,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return '지원동기를 입력하세요.';
                            if (value.length < 100) return '지원동기는 100자 이상 입력하세요.';
                            return null;
                          },
                        ),
                        if (_showMotivationError)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text('지원동기를 입력하세요.', style: TextStyle(color: Colors.red)),
                          ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _otherActivityController,
                          decoration: const InputDecoration(
                            labelText: '기타 활동',
                            hintText: '쿠하스 이외의 소모임, 동아리 지원한 것과 진행하고 있는 활동을 작성해주세요.',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          minLines: 3,
                          maxLines: 6,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return '기타 활동을 입력하세요.';
                            return null;
                          },
                        ),
                        if (_showOtherActivityError)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text('기타 활동을 입력하세요.', style: TextStyle(color: Colors.red)),
                          ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _curriculumReasonController,
                          decoration: const InputDecoration(
                            labelText: '커리큘럼 이수 가능 이유',
                            hintText: '쿠하스 커리큘럼 진행 및 강의를 동시에 수강 시 개인차에 따라 어려움이 있을 수 있습니다. 커리큘럼을 성실히 이수할 수 있다면 그 이유는 무엇인가요?',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          minLines: 3,
                          maxLines: 6,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return '커리큘럼 이수 가능 이유를 입력하세요.';
                            return null;
                          },
                        ),
                        if (_showCurriculumReasonError)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text('커리큘럼 이수 가능 이유를 입력하세요.', style: TextStyle(color: Colors.red)),
                          ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _wishController,
                          decoration: const InputDecoration(
                            labelText: 'KUHAS에서 얻고 싶은 것',
                            hintText: '쿠하스에 들어와서 얻고 싶거나 하고 싶은 것을 작성해주세요.',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          minLines: 3,
                          maxLines: 6,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'KUHAS에서 얻고 싶은 것을 입력하세요.';
                            return null;
                          },
                        ),
                        if (_showWishError)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text('KUHAS에서 얻고 싶은 것을 입력하세요.', style: TextStyle(color: Colors.red)),
                          ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _careerController,
                          decoration: const InputDecoration(
                            labelText: '진로',
                            hintText: '본인이 생각하고 있는 진로를 작성해주세요.',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          minLines: 2,
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return '진로를 입력하세요.';
                            return null;
                          },
                        ),
                        if (_showCareerError)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text('진로를 입력하세요.', style: TextStyle(color: Colors.red)),
                          ),
                        const SizedBox(height: 16),
                        const Text('프로그래밍 언어 경험 여부', style: TextStyle(fontWeight: FontWeight.bold)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'O',
                                  groupValue: _languageExp,
                                  onChanged: (v) => setState(() => _languageExp = v),
                                ),
                                const Text('O'),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _languageController,
                                    enabled: _languageExp == 'O',
                                    decoration: const InputDecoration(
                                      hintText: '경험한 언어를 작성해주세요',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: UnderlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'X',
                                  groupValue: _languageExp,
                                  onChanged: (v) => setState(() => _languageExp = v),
                                ),
                                const Text('X'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('희망 활동 (중복 선택 가능)', style: TextStyle(fontWeight: FontWeight.bold)),
                        CheckboxListTile(
                          title: const Text('활동 1'),
                          value: _wishActivities.contains('활동 1'),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _wishActivities.add('활동 1');
                              } else {
                                _wishActivities.remove('활동 1');
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('활동 2'),
                          value: _wishActivities.contains('활동 2'),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _wishActivities.add('활동 2');
                              } else {
                                _wishActivities.remove('활동 2');
                              }
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('활동 3'),
                          value: _wishActivities.contains('활동 3'),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _wishActivities.add('활동 3');
                              } else {
                                _wishActivities.remove('활동 3');
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('대면 면접 희망 날짜', style: TextStyle(fontWeight: FontWeight.bold)),
                        RadioListTile<String>(
                          title: const Text('9월 1일(화)'),
                          value: '9월 1일(화)',
                          groupValue: _selectedInterviewDate,
                          onChanged: (v) => setState(() => _selectedInterviewDate = v),
                        ),
                        RadioListTile<String>(
                          title: const Text('9월 2일(수)'),
                          value: '9월 2일(수)',
                          groupValue: _selectedInterviewDate,
                          onChanged: (v) => setState(() => _selectedInterviewDate = v),
                        ),
                        RadioListTile<String>(
                          title: const Text('9월 3일(목)'),
                          value: '9월 3일(목)',
                          groupValue: _selectedInterviewDate,
                          onChanged: (v) => setState(() => _selectedInterviewDate = v),
                        ),
                        RadioListTile<String>(
                          title: const Text('9월 4일(금)'),
                          value: '9월 4일(금)',
                          groupValue: _selectedInterviewDate,
                          onChanged: (v) => setState(() => _selectedInterviewDate = v),
                        ),
                        const SizedBox(height: 16),
                        const Text('개강총회 참석 여부', style: TextStyle(fontWeight: FontWeight.bold)),
                        RadioListTile<String>(
                          title: const Text('개강총회만 참석'),
                          value: '개강총회만 참석',
                          groupValue: _selectedAttendType,
                          onChanged: (v) => setState(() => _selectedAttendType = v),
                        ),
                        RadioListTile<String>(
                          title: const Text('뒷풀이만 참석'),
                          value: '뒷풀이만 참석',
                          groupValue: _selectedAttendType,
                          onChanged: (v) => setState(() => _selectedAttendType = v),
                        ),
                        RadioListTile<String>(
                          title: const Text('둘 다 참석'),
                          value: '둘 다 참석',
                          groupValue: _selectedAttendType,
                          onChanged: (v) => setState(() => _selectedAttendType = v),
                        ),
                        const SizedBox(height: 16),
                        const Text('제출 시 개인정보 제공에 동의하는 것으로 간주합니다. 개인정보 동의를 하지 않으실 경우 해당 설문을 제출하지 않으시면 됩니다.', style: TextStyle(fontSize: 13)),
                        RadioListTile<String>(
                          title: const Text('예'),
                          value: '예',
                          groupValue: _privacyValue,
                          onChanged: (v) => setState(() => _privacyValue = v),
                        ),
                        if (_showPrivacyError)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text('제출 시 개인정보 제공에 동의하는 것으로 간주합니다. 개인정보 동의를 하지 않으실 경우 해당 설문을 제출하지 않으시면 됩니다.', style: TextStyle(color: Colors.red)),
                          ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () async {
                                    if (_formKey.currentState?.validate() ?? false) {
                                      final duplicateMsg = await _checkDuplicate();
                                      if (duplicateMsg != null) {
                                        setState(() {
                                          _error = duplicateMsg;
                                        });
                                        return;
                                      }
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('제출 확인'),
                                          content: const Text('지원서를 제출하시겠습니까?\n확인을 누르면 제출이 됩니다.\n수정을 원하시면 취소를 눌러주세요.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(ctx).pop(),
                                              child: const Text('취소'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                                _submitForm();
                                              },
                                              child: const Text('확인'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('지원서 제출'),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
