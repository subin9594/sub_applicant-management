import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminEditPage extends StatefulWidget {
  final Map<String, dynamic> application;
  final VoidCallback onSaved;
  const AdminEditPage({super.key, required this.application, required this.onSaved});

  @override
  State<AdminEditPage> createState() => _AdminEditPageState();
}

class _AdminEditPageState extends State<AdminEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _studentIdController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _motivationController;
  late TextEditingController _otherActivityController;
  late TextEditingController _curriculumReasonController;
  late TextEditingController _wishController;
  late TextEditingController _careerController;
  late TextEditingController _languageExpController;
  late TextEditingController _languageDetailController;
  late TextEditingController _wishActivitiesController;
  late TextEditingController _interviewDateController;
  String _status = 'PENDING';
  String? _gradeDropdownValue;
  String? _attendTypeValue;
  String? _privacyAgreementValue;
  String? _languageExpValue;
  List<String> _wishActivitiesValues = [];
  List<String> _interviewDateValues = [];
  bool _showLanguageDetail = false;
  bool _isSubmitting = false;
  String? _error;
  bool _hasSubmitted = false;
  bool _showGradeError = false;
  bool _showPrivacyError = false;
  bool _showNameError = false;
  bool _showStudentIdError = false;
  bool _showPhoneError = false;
  bool _showEmailError = false;
  bool _showMotivationError = false;

  @override
  void initState() {
    super.initState();
    
    // 기존 데이터로 컨트롤러 초기화
    _nameController = TextEditingController(text: widget.application['name'] ?? '');
    _studentIdController = TextEditingController(text: widget.application['studentId'] ?? '');
    _phoneController = TextEditingController(text: widget.application['phoneNumber'] ?? '');
    _emailController = TextEditingController(text: widget.application['email'] ?? '');
    _motivationController = TextEditingController(text: widget.application['motivation'] ?? '');
    _otherActivityController = TextEditingController(text: widget.application['otherActivity'] ?? '');
    _curriculumReasonController = TextEditingController(text: widget.application['curriculumReason'] ?? '');
    _wishController = TextEditingController(text: widget.application['wish'] ?? '');
    _careerController = TextEditingController(text: widget.application['career'] ?? '');
    _languageExpController = TextEditingController(text: widget.application['languageExp'] ?? '');
    _languageDetailController = TextEditingController(text: widget.application['languageDetail'] ?? '');
    _wishActivitiesController = TextEditingController(text: widget.application['wishActivities'] ?? '');
    _interviewDateController = TextEditingController(text: widget.application['interviewDate'] ?? '');
    
    _status = widget.application['status'] ?? 'PENDING';
    _gradeDropdownValue = widget.application['grade'];
    _attendTypeValue = widget.application['attendType'];
    _privacyAgreementValue = widget.application['privacyAgreement'];
    _languageExpValue = widget.application['languageExp'];
    
    // 언어 경험에 따라 언어 상세 표시 여부 설정
    _showLanguageDetail = _languageExpValue == 'O';
    
    // 기존 데이터를 새로운 선택지에 맞게 변환
    if (_languageExpValue == '있음') {
      _languageExpValue = 'O';
    } else if (_languageExpValue == '없음') {
      _languageExpValue = 'X';
    }
    
    // 희망 활동 파싱 (쉼표로 구분된 문자열을 리스트로 변환)
    if (widget.application['wishActivities'] != null && widget.application['wishActivities'].toString().isNotEmpty) {
      _wishActivitiesValues = widget.application['wishActivities'].toString().split(',').map((e) => e.trim()).toList();
    }
    
    // 면접 일정 파싱 (쉼표로 구분된 문자열을 리스트로 변환)
    if (widget.application['interviewDate'] != null && widget.application['interviewDate'].toString().isNotEmpty) {
      _interviewDateValues = widget.application['interviewDate'].toString().split(',').map((e) => e.trim()).toList();
    }
    
    // attendType 값이 유효하지 않은 경우 null로 설정
    if (_attendTypeValue != null && _attendTypeValue != '개강총회만 참석' && _attendTypeValue != '뒷풀이만 참석' && _attendTypeValue != '둘 다 참석') {
      _attendTypeValue = null;
    }
    
    // privacyAgreement 값이 유효하지 않은 경우 null로 설정
    if (_privacyAgreementValue != null && _privacyAgreementValue != '예') {
      _privacyAgreementValue = null;
    }
  }

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
    _languageExpController.dispose();
    _languageDetailController.dispose();
    _wishActivitiesController.dispose();
    _interviewDateController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
      _hasSubmitted = true;
      _showGradeError = _gradeDropdownValue == null || _gradeDropdownValue!.trim().isEmpty;
      _showPrivacyError = _privacyAgreementValue == null || _privacyAgreementValue!.trim().isEmpty;
      _showNameError = _nameController.text.trim().isEmpty;
      _showStudentIdError = _studentIdController.text.trim().isEmpty;
      _showPhoneError = _phoneController.text.trim().isEmpty;
      _showEmailError = _emailController.text.trim().isEmpty;
      _showMotivationError = _motivationController.text.trim().isEmpty;
    });
    
    if (!_formKey.currentState!.validate() || _showGradeError || _showPrivacyError || _showNameError || _showStudentIdError || _showPhoneError || _showEmailError || _showMotivationError) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }
    
    try {
      final url = Uri.parse('http://10.0.2.2:8080/api/applications/${widget.application['id']}');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': _nameController.text.trim(),
          'studentId': _studentIdController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'grade': _gradeDropdownValue,
          'motivation': _motivationController.text.trim(),
          'otherActivity': _otherActivityController.text.trim(),
          'curriculumReason': _curriculumReasonController.text.trim(),
          'wish': _wishController.text.trim(),
          'career': _careerController.text.trim(),
          'languageExp': _languageExpValue,
          'languageDetail': _languageDetailController.text.trim(),
          'wishActivities': _wishActivitiesValues.join(', '),
          'interviewDate': _interviewDateValues.isNotEmpty ? _interviewDateValues.first : '',
          'attendType': _attendTypeValue,
          'privacyAgreement': _privacyAgreementValue,
          'status': _status,
        }),
      );
      
      if (response.statusCode == 200) {
        setState(() {
          _isSubmitting = false;
        });
        
        // 성공 메시지 표시 후 네비게이션
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_nameController.text.trim()}의 부원 지원서가 성공적으로 수정되었습니다.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          
          // 잠시 대기 후 콜백 호출 (네비게이션 제거)
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {
            widget.onSaved();
            // Navigator.of(context).pop(); // 이 줄 제거
          }
        }
      } else {
        String errorMsg = '수정에 실패했습니다. 다시 시도해 주세요.';
        try {
          final data = json.decode(response.body);
          if (data['error'] != null) errorMsg = data['error'];
        } catch (_) {}
        setState(() {
          _error = errorMsg;
          _isSubmitting = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = '수정 중 오류가 발생했습니다.\n${e.toString()}';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
      appBar: AppBar(
        title: const Text('KUHAS'),
        backgroundColor: Colors.white,
        elevation: 0,
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
        child: Form(
          key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                  const Text('KUHAS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('부원 모집 지원서 수정', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  if (_error != null && _hasSubmitted)
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
                      labelText: '이름:',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return '이름을 입력하세요.';
                      if (!RegExp(r'^[가-힣a-zA-Z\s]+$').hasMatch(v.trim())) return '이름은 한글 또는 영문만 입력하세요.';
                      if (v.length > 100) return '이름은 100자 이하여야 합니다.';
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
                      labelText: '학번:',
                      hintText: 'ex) 20XX270XXX',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return '학번을 입력하세요.';
                      if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) return '학번은 숫자 10자리로 입력하세요.';
                      return null;
                    },
                  ),
                  if (_showStudentIdError)
                    const Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 8),
                      child: Text('학번을 입력하세요.', style: TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: '전화번호:',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return '전화번호를 입력하세요.';
                      if (!RegExp(r'^[0-9\-]+$').hasMatch(v.trim())) return '전화번호는 숫자와 -만 입력하세요.';
                      if (v.length < 8 || v.length > 14) return '전화번호는 8~14자 이내로 입력하세요.';
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
                      labelText: '이메일:',
                      hintText: 'ex) xxx@gmail.com 또는 xxx@korea.ac.kr',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return '이메일을 입력하세요.';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) return '이메일 형식이 올바르지 않습니다.';
                  return null;
                },
              ),
                  if (_showEmailError)
                    const Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 8),
                      child: Text('이메일을 입력하세요.', style: TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gradeDropdownValue,
                items: [
                  '1학년', '2학년', '3학년', '4학년'
                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _gradeDropdownValue = v),
                    decoration: const InputDecoration(labelText: '학년:'),
                    validator: (v) => v == null ? '학년을 선택하세요.' : null,
                  ),
                  if (_showGradeError)
                    const Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 8),
                      child: Text('학년을 선택하세요.', style: TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 16),
              TextFormField(
                controller: _motivationController,
                    decoration: const InputDecoration(
                      labelText: '지원동기:',
                      hintText: 'KUHAS에 지원하게 된 동기를 작성해주세요.(300자 내외)',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                minLines: 3,
                maxLines: 8,
                    style: const TextStyle(
                      decoration: TextDecoration.none,
                      decorationThickness: 0,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return '지원동기를 입력하세요.';
                      if (v.trim().length < 50) return '50자 이상 입력하세요.';
                      if (v.trim().length > 2000) return '2000자 이하로 입력하세요.';
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
                      labelText: '기타 활동:',
                      hintText: '현재 참여하고 있는 동아리, 학회, 봉사활동 등이 있다면 작성해주세요. (없다면 \'없음\'이라고 작성해주세요.)',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                minLines: 2,
                maxLines: 4,
                    style: const TextStyle(
                      decoration: TextDecoration.none,
                      decorationThickness: 0,
                    ),
                    validator: (v) {
                      if (v != null && v.trim().length > 1000) return '1000자 이하로 입력하세요.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _curriculumReasonController,
                    decoration: const InputDecoration(
                      labelText: '커리큘럼 이수 가능 이유:',
                      hintText: 'KUHAS의 커리큘럼 중 관심 있는 분야와 그 이유를 작성해주세요.',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    minLines: 2,
                    maxLines: 4,
                    style: const TextStyle(
                      decoration: TextDecoration.none,
                      decorationThickness: 0,
                    ),
                    validator: (v) {
                      if (v != null && v.trim().length > 1000) return '1000자 이하로 입력하세요.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _wishController,
                    decoration: const InputDecoration(
                      labelText: 'KUHAS에서 얻고 싶은 것:',
                      hintText: 'KUHAS에서 하고 싶은 활동이나 배우고 싶은 것들을 작성해주세요.',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    minLines: 2,
                    maxLines: 4,
                    style: const TextStyle(
                      decoration: TextDecoration.none,
                      decorationThickness: 0,
                    ),
                    validator: (v) {
                      if (v != null && v.trim().length > 1000) return '1000자 이하로 입력하세요.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
              TextFormField(
                controller: _careerController,
                    decoration: const InputDecoration(
                      labelText: '진로계획:',
                      hintText: '졸업 후 진로계획이나 목표를 작성해주세요.',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                minLines: 2,
                maxLines: 4,
                    style: const TextStyle(
                      decoration: TextDecoration.none,
                      decorationThickness: 0,
                    ),
                    validator: (v) {
                      if (v != null && v.trim().length > 1000) return '1000자 이하로 입력하세요.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '프로그래밍 언어 경험 여부:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  RadioListTile<String>(
                    title: const Text('O'),
                    value: 'O',
                    groupValue: _languageExpValue,
                    onChanged: (v) {
                      setState(() {
                        _languageExpValue = v;
                        _showLanguageDetail = v == 'O';
                        if (v != 'O') {
                          _languageDetailController.clear();
                        }
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('X'),
                    value: 'X',
                    groupValue: _languageExpValue,
                    onChanged: (v) {
                      setState(() {
                        _languageExpValue = v;
                        _showLanguageDetail = v == 'O';
                        if (v != 'O') {
                          _languageDetailController.clear();
                        }
                      });
                    },
                  ),
                  if (_showLanguageDetail) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _languageDetailController,
                      decoration: const InputDecoration(
                        labelText: '언어 상세:',
                        hintText: '언어 경험에 대한 추가 설명이나 구체적인 경험을 작성해주세요.',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      minLines: 2,
                      maxLines: 4,
                      style: const TextStyle(
                        decoration: TextDecoration.none,
                        decorationThickness: 0,
                      ),
                      validator: (v) {
                        if (v != null && v.trim().length > 1000) return '1000자 이하로 입력하세요.';
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    '희망 활동:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  CheckboxListTile(
                    title: const Text('활동 1'),
                    value: _wishActivitiesValues.contains('활동 1'),
                    onChanged: (v) {
                      setState(() {
                        if (v != null && v) {
                          if (!_wishActivitiesValues.contains('활동 1')) {
                            _wishActivitiesValues.add('활동 1');
                          }
                        } else {
                          _wishActivitiesValues.remove('활동 1');
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    title: const Text('활동 2'),
                    value: _wishActivitiesValues.contains('활동 2'),
                    onChanged: (v) {
                      setState(() {
                        if (v != null && v) {
                          if (!_wishActivitiesValues.contains('활동 2')) {
                            _wishActivitiesValues.add('활동 2');
                          }
                        } else {
                          _wishActivitiesValues.remove('활동 2');
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    title: const Text('활동 3'),
                    value: _wishActivitiesValues.contains('활동 3'),
                    onChanged: (v) {
                      setState(() {
                        if (v != null && v) {
                          if (!_wishActivitiesValues.contains('활동 3')) {
                            _wishActivitiesValues.add('활동 3');
                          }
                        } else {
                          _wishActivitiesValues.remove('활동 3');
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '대면 면접 희망 날짜:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  RadioListTile<String>(
                    title: const Text('9월 1일(화)'),
                    value: '9월 1일(화)',
                    groupValue: _interviewDateValues.isNotEmpty ? _interviewDateValues.first : null,
                    onChanged: (v) {
                      setState(() {
                        _interviewDateValues.clear();
                        if (v != null) {
                          _interviewDateValues.add(v);
                        }
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('9월 2일(수)'),
                    value: '9월 2일(수)',
                    groupValue: _interviewDateValues.isNotEmpty ? _interviewDateValues.first : null,
                    onChanged: (v) {
                      setState(() {
                        _interviewDateValues.clear();
                        if (v != null) {
                          _interviewDateValues.add(v);
                        }
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('9월 3일(목)'),
                    value: '9월 3일(목)',
                    groupValue: _interviewDateValues.isNotEmpty ? _interviewDateValues.first : null,
                    onChanged: (v) {
                      setState(() {
                        _interviewDateValues.clear();
                        if (v != null) {
                          _interviewDateValues.add(v);
                        }
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('9월 4일(금)'),
                    value: '9월 4일(금)',
                    groupValue: _interviewDateValues.isNotEmpty ? _interviewDateValues.first : null,
                    onChanged: (v) {
                      setState(() {
                        _interviewDateValues.clear();
                        if (v != null) {
                          _interviewDateValues.add(v);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '개강총회 참석 유형:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  RadioListTile<String>(
                    title: const Text('개강총회만 참석'),
                    value: '개강총회만 참석',
                    groupValue: _attendTypeValue,
                    onChanged: (v) => setState(() => _attendTypeValue = v),
                  ),
              RadioListTile<String>(
                    title: const Text('뒷풀이만 참석'),
                    value: '뒷풀이만 참석',
                groupValue: _attendTypeValue,
                onChanged: (v) => setState(() => _attendTypeValue = v),
              ),
              RadioListTile<String>(
                    title: const Text('둘 다 참석'),
                    value: '둘 다 참석',
                groupValue: _attendTypeValue,
                onChanged: (v) => setState(() => _attendTypeValue = v),
              ),
                  const SizedBox(height: 16),
                  const Text(
                    '개인정보 동의:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
              RadioListTile<String>(
                title: const Text('예'),
                value: '예',
                groupValue: _privacyAgreementValue,
                onChanged: (v) => setState(() => _privacyAgreementValue = v),
              ),
                  if (_showPrivacyError)
                    const Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 8),
                      child: Text('개인정보 제공 동의 여부를 선택하세요.', style: TextStyle(color: Colors.red)),
                    ),
                  const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                    items: [
                      'PENDING', 'ACCEPTED', 'REJECTED'
                    ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _status = v!),
                decoration: const InputDecoration(labelText: '상태'),
              ),
              const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                _submitForm();
                              }
                            },
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('부원 지원서 수정'),
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