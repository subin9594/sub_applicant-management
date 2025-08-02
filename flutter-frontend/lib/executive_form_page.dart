import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';

class ExecutiveFormPage extends StatefulWidget {
  const ExecutiveFormPage({super.key});

  @override
  State<ExecutiveFormPage> createState() => _ExecutiveFormPageState();
}

class _ExecutiveFormPageState extends State<ExecutiveFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _gradeController = TextEditingController();
  String? _gradeDropdownValue;
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _leavePlanController = TextEditingController();
  String? _periodValue;
  final _periodEtcController = TextEditingController();
  final _motivationController = TextEditingController();
  final _goalController = TextEditingController();
  final _crisisController = TextEditingController();
  String? _meetingValue;
  final _resolutionController = TextEditingController();
  String? _privacyValue;
  String? _error;
  bool _showSuccess = false;
  bool _hasSubmitted = false;
  bool _isSubmitting = false;
  bool _showGradeError = false;
  bool _showPeriodError = false;
  bool _showMeetingError = false;
  bool _showPrivacyError = false;
  bool _showCrisisError = false;
  bool _showLeavePlanError = false;
  bool _showNameError = false;
  bool _showStudentIdError = false;
  bool _showPhoneError = false;
  bool _showEmailError = false;
  bool _showMotivationError = false;
  bool _showGoalError = false;


  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _gradeController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _leavePlanController.dispose();
    _periodEtcController.dispose();
    _motivationController.dispose();
    _goalController.dispose();
    _crisisController.dispose();
    _resolutionController.dispose();
    super.dispose();
  }

  void _scrollToFirstError() {
    // 검증 실패 시 상단으로 스크롤
    _scrollToTop();
  }

  void _scrollToTop() {
    // 스크롤을 맨 위로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final scrollController = PrimaryScrollController.of(context);
        if (scrollController != null) {
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  Future<String?> _checkDuplicate() async {
    final studentId = _studentIdController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final url = Uri.parse('http://10.0.2.2:8080/api/executive-applications/exists?studentId=$studentId&email=$email&phoneNumber=$phone');
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

  Future<void> _submitForm() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
      _hasSubmitted = true;
      _showGradeError = _gradeDropdownValue == null || _gradeDropdownValue!.trim().isEmpty;
      _showPeriodError = _periodValue == null || _periodValue!.trim().isEmpty || (_periodValue == '기타' && _periodEtcController.text.trim().isEmpty);
      _showMeetingError = _meetingValue == null || _meetingValue!.trim().isEmpty;
      _showPrivacyError = _privacyValue == null || _privacyValue!.trim().isEmpty;
      _showCrisisError = _crisisController.text.trim().isEmpty;
      _showLeavePlanError = _leavePlanController.text.trim().isEmpty;
      _showNameError = _nameController.text.trim().isEmpty;
      _showStudentIdError = _studentIdController.text.trim().isEmpty;
      _showPhoneError = _phoneController.text.trim().isEmpty;
      _showEmailError = _emailController.text.trim().isEmpty;
      _showMotivationError = _motivationController.text.trim().isEmpty;
      _showGoalError = _goalController.text.trim().isEmpty;
    });
    if (!_formKey.currentState!.validate() || _showGradeError || _showPeriodError || _showMeetingError || _showPrivacyError || _showCrisisError || _showLeavePlanError || _showNameError || _showStudentIdError || _showPhoneError || _showEmailError || _showMotivationError || _showGoalError) {
      setState(() {
        _isSubmitting = false;
      });
      return;
    }
    try {
    final url = Uri.parse('http://10.0.2.2:8080/api/executive-applications');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'name': _nameController.text.trim(),
        'studentId': _studentIdController.text.trim(),
        'grade': _gradeDropdownValue == '기타' ? _gradeController.text.trim() : _gradeDropdownValue,
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'leavePlan': _leavePlanController.text.trim(),
        'period': _periodValue == '기타' ? _periodEtcController.text.trim() : _periodValue,
        'motivation': _motivationController.text.trim(),
        'goal': _goalController.text.trim(),
        'crisis': _crisisController.text.trim(),
        'meeting': _meetingValue,
        'resolution': _resolutionController.text.trim(),
        'privacy': _privacyValue,
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        _showSuccess = true;
        _isSubmitting = false;
      });
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _showSuccess = false;
        });
        Navigator.of(context).pop();
      }
    } else {
      String errorMsg = '제출에 실패했습니다. 다시 시도해 주세요. (서버 오류: \n${response.statusCode}\n${response.body})';
      try {
        final data = json.decode(response.body);
        if (data['error'] != null) errorMsg = data['error'];
      } catch (_) {}
      print('운영진 지원서 제출 실패: statusCode = ${response.statusCode}, body = ${response.body}');
      setState(() {
        _error = errorMsg;
        _isSubmitting = false;
      });
    }
    } catch (e) {
      setState(() {
        _error = '제출 중 오류가 발생했습니다.\n${e.toString()}';
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
            child: _showSuccess
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('assets/success.json', width: 120, repeat: false),
                      const SizedBox(height: 16),
                      const Text(
                        '운영진 지원서가 성공적으로 제출되었습니다!',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('KUHAS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('운영진 모집 지원서 제출', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                            labelText: '이름',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return '이름을 입력하세요.';
                            if (!RegExp(r'^[가-힣a-zA-Z\s]+$').hasMatch(v.trim())) return '이름은 한글 또는 영문만 입력하세요.';
                            if (v.length > 100) return '이름은 100자 이하여야 합니다.';
                            return null;
                          },
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
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return '학번을 입력하세요.';
                            if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) return '학번은 숫자 10자리로 입력하세요.';
                            return null;
                          },
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

                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: '이메일',
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

                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: '전화번호',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return '전화번호를 입력하세요.';
                            if (!RegExp(r'^[0-9\-]+$').hasMatch(v.trim())) return '전화번호는 숫자와 -만 입력하세요.';
                            if (v.length < 8 || v.length > 13) return '전화번호는 8~13자 이내로 입력하세요.';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _leavePlanController,
                          decoration: const InputDecoration(
                            labelText: '휴학 계획',
                            hintText: '추후에 휴학 하실 계획이 있으신가요? 있다면 구체적으로 작성해주시기 바랍니다.',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          minLines: 2,
                          maxLines: 4,
                          style: const TextStyle(
                            decoration: TextDecoration.none,
                            decorationThickness: 0,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return '휴학 계획을 입력하세요. (없다면 \'없음\'이라고 작성해주세요.)';
                            if (v.trim().length > 350) return '300자 내외로 입력하세요.';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),
                        const Text('운영진 활동 기간', style: TextStyle(fontWeight: FontWeight.bold)),
                        Column(
                          children: [
                            RadioListTile<String>(
                              title: const Text('6개월'),
                              value: '6개월',
                              groupValue: _periodValue,
                              onChanged: (v) => setState(() => _periodValue = v),
                            ),
                            RadioListTile<String>(
                              title: const Text('1년'),
                              value: '1년',
                              groupValue: _periodValue,
                              onChanged: (v) => setState(() => _periodValue = v),
                            ),
                            RadioListTile<String>(
                              title: const Text('1년 이상'),
                              value: '1년 이상',
                              groupValue: _periodValue,
                              onChanged: (v) => setState(() => _periodValue = v),
                            ),
                            RadioListTile<String>(
                              title: Row(
                                children: [
                                  const Text('기타:'),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _periodEtcController,
                                      enabled: _periodValue == '기타',
                                      decoration: const InputDecoration(
                                        hintText: '직접 입력',
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: UnderlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (_periodValue == '기타' && (value == null || value.trim().isEmpty)) {
                                          return '기타 항목을 입력하세요.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              value: '기타',
                              groupValue: _periodValue,
                              onChanged: (v) => setState(() => _periodValue = v),
                            ),
                            if (_periodValue == null && _hasSubmitted)
                              const Padding(
                                padding: EdgeInsets.only(top: 4, bottom: 8),
                                child: Text('운영진 활동 기간을 선택하거나 기타 항목을 입력하세요.', style: TextStyle(color: Colors.red)),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _motivationController,
                          decoration: const InputDecoration(
                            labelText: '지원 동기',
                            hintText: 'KUHAS 운영진에 지원하게 된 동기를 작성해주세요.(300자 내외)',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          minLines: 3,
                          maxLines: 8,
                          style: const TextStyle(
                            decoration: TextDecoration.none,
                            decorationThickness: 0,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return '지원 동기를 입력하세요.';
                            if (v.trim().length < 100) return '100자 이상 입력하세요.';
                            if (v.trim().length > 350) return '300자 내외로 입력하세요.';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _goalController,
                          decoration: const InputDecoration(
                            labelText: 'KUHAS 운영진 활동 목표',
                            hintText: 'KUHAS 운영진으로 활동하면서 얻고자 하는 것을 적어주세요.(300자 내외)',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          minLines: 3,
                          maxLines: 8,
                          style: const TextStyle(
                            decoration: TextDecoration.none,
                            decorationThickness: 0,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return '운영진 활동 목표를 입력하세요.';
                            if (v.trim().length < 100) return '100자 이상 입력하세요.';
                            if (v.trim().length > 350) return '300자 내외로 입력하세요.';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _crisisController,
                          decoration: const InputDecoration(
                            labelText: '위기 극복 경험',
                            hintText: '살아오면서 위기를 극복한 경험이 있다면 구체적으로 서술해주세요. 없으시다면 \'없음\'이라고 작성해주세요.',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          minLines: 3,
                          maxLines: 8,
                          style: const TextStyle(
                            decoration: TextDecoration.none,
                            decorationThickness: 0,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return '위기 극복 경험을 입력하세요. (없다면 \'없음\'이라고 작성해주세요.)';
                            if (v.trim().length > 350) return '300자 내외로 입력하세요.';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),
                        const Text(
                          '학기 중 대면 회의 참석 여부 (방학 중에는 온라인으로 진행)\n회의 참석은 필수이며, 매주 목요일 오후 10시(시간 변동 가능)입니다.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        RadioListTile<String>(
                          title: const Text('가능'),
                          value: '가능',
                          groupValue: _meetingValue,
                          onChanged: (v) => setState(() => _meetingValue = v),
                        ),
                        if (_meetingValue == null && _hasSubmitted)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text('회의 참석 가능 여부를 선택하세요.', style: TextStyle(color: Colors.red)),
                          ),
                        RadioListTile<String>(
                          title: const Text('불가능'),
                          value: '불가능',
                          groupValue: _meetingValue,
                          onChanged: (v) => setState(() => _meetingValue = v),
                        ),

                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _resolutionController,
                          decoration: const InputDecoration(
                            labelText: '각오 한 마디',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          minLines: 2,
                          maxLines: 4,
                          style: const TextStyle(
                            decoration: TextDecoration.none,
                            decorationThickness: 0,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? '각오 한 마디를 입력하세요.' : null,
                        ),
                        const SizedBox(height: 16),
                        const Text('제출 시 개인정보 제공에 동의하는 것으로 간주합니다. 개인정보 동의를 하지 않으실 경우 해당 설문을 제출하지 않으시면 됩니다.', style: TextStyle(fontSize: 13)),
                        RadioListTile<String>(
                          title: const Text('예'),
                          value: '예',
                          groupValue: _privacyValue,
                          onChanged: (v) => setState(() => _privacyValue = v),
                        ),
                        if (_privacyValue == null && _hasSubmitted)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text('개인정보 제공 동의를 선택하세요.', style: TextStyle(color: Colors.red)),
                          ),

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () async {
                                    setState(() {
                                      _hasSubmitted = true;
                                    });
                                    if (!_formKey.currentState!.validate()) {
                                      // 첫 번째 에러가 있는 항목으로 스크롤
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _scrollToFirstError();
                                      });
                                      return;
                                    }
                                    
                                    // 중복 확인
                                    final duplicateMsg = await _checkDuplicate();
                                    if (duplicateMsg != null) {
                                      setState(() {
                                        _error = duplicateMsg;
                                      });
                                      // 중복 확인 실패 시 상단으로 스크롤
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _scrollToTop();
                                      });
                                      return;
                                    }
                                    
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('제출 확인'),
                                        content: const Text('운영진 지원서를 제출하시겠습니까?\n확인을 누르면 제출이 됩니다.\n수정을 원하시면 취소를 눌러주세요.'),
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
                                  },
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('운영진 지원서 제출'),
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