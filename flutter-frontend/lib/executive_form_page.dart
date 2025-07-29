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

  Future<void> _submitForm() async {
    setState(() => _error = null);
    // 추가 검증: grade, period, meeting, privacy
    if (_gradeDropdownValue == null || _gradeDropdownValue!.trim().isEmpty) {
      setState(() => _error = '학년을 선택하세요.');
      return;
    }
    if (_periodValue == null || _periodValue!.trim().isEmpty || (_periodValue == '기타' && _periodEtcController.text.trim().isEmpty)) {
      setState(() => _error = '운영진 활동 기간을 선택하거나 기타 항목을 입력하세요.');
      return;
    }
    if (_meetingValue == null || _meetingValue!.trim().isEmpty) {
      setState(() => _error = '회의 참석 가능 여부를 선택하세요.');
      return;
    }
    if (_privacyValue == null || _privacyValue!.trim().isEmpty) {
      setState(() => _error = '개인정보 제공 동의를 선택하세요.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    try {
    final url = Uri.parse('http://10.0.2.2:8080/api/executive-applications');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
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
      });
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _showSuccess = false;
        });
        Navigator.of(context).pop();
      }
    } else {
        setState(() => _error = '제출에 실패했습니다. 다시 시도해 주세요. (서버 오류: \n${response.statusCode}\n${response.body})');
      }
    } catch (e) {
      setState(() => _error = '제출 중 오류가 발생했습니다.\n${e.toString()}');
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
                          validator: (v) => v == null || v.trim().isEmpty ? '학년을 선택하세요.' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: '이메일',
                            hintText: 'ex) xxx@gmail.com 또는 xxx@korea.ac.kr',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
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
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return '전화번호를 입력하세요.';
                            if (!RegExp(r'^[0-9\-]+$').hasMatch(v.trim())) return '전화번호는 숫자와 -만 입력하세요.';
                            if (v.length < 8 || v.length > 14) return '전화번호는 8~14자 이내로 입력하세요.';
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
                                      ),
                                    ),
                                ],
                              ),
                              value: '기타',
                              groupValue: _periodValue,
                              onChanged: (v) => setState(() => _periodValue = v),
                            ),
                          ],
                        ),
                        if (_periodValue == null || _periodValue!.trim().isEmpty || (_periodValue == '기타' && _periodEtcController.text.trim().isEmpty))
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text('운영진 활동 기간을 선택하거나 기타 항목을 입력하세요.', style: TextStyle(color: Colors.red)),
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
                            if (v.trim().length < 50) return '50자 이상 입력하세요.';
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
                            if (v == null || v.trim().isEmpty) return '입력하세요.';
                            if (v.trim().length < 50) return '50자 이상 입력하세요.';
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
                            if (v == null || v.trim().isEmpty) return null; // 공란 허용
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
                        RadioListTile<String>(
                          title: const Text('불가능'),
                          value: '불가능',
                          groupValue: _meetingValue,
                          onChanged: (v) => setState(() => _meetingValue = v),
                        ),
                        if (_meetingValue == null || _meetingValue!.trim().isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text('회의 참석 가능 여부를 선택하세요.', style: TextStyle(color: Colors.red)),
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
                          validator: (v) => (v == null || v.trim().isEmpty) ? '입력하세요.' : null,
                        ),
                        const SizedBox(height: 16),
                        const Text('제출 시 개인정보 제공에 동의하는 것으로 간주합니다. 개인정보 동의를 하지 않으실 경우 해당 설문을 제출하지 않으시면 됩니다.', style: TextStyle(fontSize: 13)),
                        RadioListTile<String>(
                          title: const Text('예'),
                          value: '예',
                          groupValue: _privacyValue,
                          onChanged: (v) => setState(() => _privacyValue = v),
                        ),
                        if (_privacyValue == null || _privacyValue!.trim().isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 8),
                            child: Text('개인정보 제공 동의를 선택하세요.', style: TextStyle(color: Colors.red)),
                          ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text('제출'),
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