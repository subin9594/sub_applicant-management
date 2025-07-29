import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminExecutiveEditPage extends StatefulWidget {
  final Map<String, dynamic> application;
  final VoidCallback onSaved;
  const AdminExecutiveEditPage({super.key, required this.application, required this.onSaved});

  @override
  State<AdminExecutiveEditPage> createState() => _AdminExecutiveEditPageState();
}

class _AdminExecutiveEditPageState extends State<AdminExecutiveEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _studentIdController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _leavePlanController;
  late TextEditingController _periodEtcController;
  late TextEditingController _motivationController;
  late TextEditingController _goalController;
  late TextEditingController _crisisController;
  late TextEditingController _resolutionController;
  String _status = 'PENDING';
  String? _gradeDropdownValue;
  String? _periodValue;
  String? _meetingValue;
  String? _privacyValue;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    
    // 디버깅용: 전달받은 application 데이터 확인
    print('Executive application data: ${widget.application}');
    print('Executive application ID: ${widget.application['id']}');
    
    _nameController = TextEditingController(text: widget.application['name'] ?? '');
    _studentIdController = TextEditingController(text: widget.application['studentId'] ?? '');
    _phoneController = TextEditingController(text: widget.application['phoneNumber'] ?? '');
    _emailController = TextEditingController(text: widget.application['email'] ?? '');
    _leavePlanController = TextEditingController(text: widget.application['leavePlan'] ?? '');
    _periodEtcController = TextEditingController(text: widget.application['period'] ?? '');
    _motivationController = TextEditingController(text: widget.application['motivation'] ?? '');
    _goalController = TextEditingController(text: widget.application['goal'] ?? '');
    _crisisController = TextEditingController(text: widget.application['crisis'] ?? '');
    _resolutionController = TextEditingController(text: widget.application['resolution'] ?? '');
    _status = widget.application['status'] ?? 'PENDING';
    _gradeDropdownValue = widget.application['grade'];
    _periodValue = widget.application['period'];
    _meetingValue = widget.application['meeting'];
    _privacyValue = widget.application['privacy'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _leavePlanController.dispose();
    _periodEtcController.dispose();
    _motivationController.dispose();
    _goalController.dispose();
    _crisisController.dispose();
    _resolutionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    
    // ID 확인
    final id = widget.application['id'];
    if (id == null) {
      setState(() {
        _isSubmitting = false;
        _error = '지원서 ID를 찾을 수 없습니다.';
      });
      return;
    }
    
    final url = Uri.parse('http://10.0.2.2:8080/api/executive-applications/$id');
    print('Saving executive application with ID: $id'); // 디버깅용
    
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _nameController.text.trim(),
          'studentId': _studentIdController.text.trim(),
          'grade': _gradeDropdownValue,
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
          'status': _status,
        }),
      );
      
      print('Response status: ${response.statusCode}'); // 디버깅용
      print('Response body: ${response.body}'); // 디버깅용
      
      if (response.statusCode == 200) {
        // 성공 시 콜백 호출
        widget.onSaved();
        
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          
          // 안전한 네비게이션 처리
          Navigator.of(context).pop(); // 편집 페이지 닫기
          
          // 추가 지연 후 상세 페이지도 닫기
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            Navigator.of(context).pop(); // 상세 페이지 닫기 (목록으로 돌아가기)
          }
        }
      } else {
        setState(() {
          _isSubmitting = false;
          _error = '저장에 실패했습니다. (상태 코드: ${response.statusCode})';
        });
      }
    } catch (e) {
      print('Error saving executive application: $e'); // 디버깅용
      setState(() {
        _isSubmitting = false;
        _error = '저장 중 오류가 발생했습니다: $e';
      });
    }
  }

  Future<bool> _showSaveDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('수정 확인'),
            content: const Text('수정하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('취소'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('확인'),
              ),
            ],
          ),
        ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('운영진 지원서 수정')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '이름'),
                validator: (value) {
                  if (value == null || value.isEmpty) return '이름을 입력하세요.';
                  if (!RegExp(r'^[가-힣a-zA-Z\s]+$').hasMatch(value)) return '이름은 한글 또는 영문만 입력하세요.';
                  return null;
                },
              ),
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(labelText: '학번'),
                validator: (value) {
                  if (value == null || value.isEmpty) return '학번을 입력하세요.';
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) return '학번은 숫자 10자리로 입력하세요.';
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _gradeDropdownValue,
                items: [
                  '1학년', '2학년', '3학년', '4학년'
                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _gradeDropdownValue = v),
                decoration: const InputDecoration(labelText: '학년'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: '이메일'),
                validator: (value) {
                  if (value == null || value.isEmpty) return '이메일을 입력하세요.';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return '이메일 형식이 올바르지 않습니다.';
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: '전화번호'),
                validator: (value) {
                  if (value == null || value.isEmpty) return '전화번호를 입력하세요.';
                  if (!RegExp(r'^[0-9\-]+$').hasMatch(value)) return '전화번호는 숫자와 -만 입력하세요.';
                  if (value.length < 8 || value.length > 13) return '전화번호는 8~13자 이내로 입력하세요.';
                  return null;
                },
              ),
              TextFormField(
                controller: _leavePlanController,
                decoration: const InputDecoration(labelText: '휴학 계획'),
                minLines: 2,
                maxLines: 4,
              ),
              const Text('운영진 활동 기간', style: TextStyle(fontWeight: FontWeight.bold)),
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
              TextFormField(
                controller: _motivationController,
                decoration: const InputDecoration(labelText: '지원 동기'),
                minLines: 3,
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) return '지원 동기를 입력하세요.';
                  if (value.trim().length < 100) return '100자 이상 입력하세요.';
                  if (value.trim().length > 350) return '300자 내외로 입력하세요.';
                  return null;
                },
              ),
              TextFormField(
                controller: _goalController,
                decoration: const InputDecoration(labelText: '운영진으로 얻고자 하는 것'),
                minLines: 3,
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) return '운영진으로 얻고자 하는 것을 입력하세요.';
                  if (value.trim().length < 100) return '100자 이상 입력하세요.';
                  if (value.trim().length > 350) return '300자 내외로 입력하세요.';
                  return null;
                },
              ),
              TextFormField(
                controller: _crisisController,
                decoration: const InputDecoration(labelText: '위기 극복 경험'),
                minLines: 3,
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) return '위기 극복 경험을 입력하세요.';
                  if (value.trim().length > 350) return '300자 내외로 입력하세요.';
                  return null;
                },
              ),
              const Text('회의 참석', style: TextStyle(fontWeight: FontWeight.bold)),
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
              TextFormField(
                controller: _resolutionController,
                decoration: const InputDecoration(labelText: '각오 한 마디'),
                minLines: 2,
                maxLines: 4,
                validator: (value) => (value == null || value.isEmpty) ? '입력하세요.' : null,
              ),
              const Text('개인정보 제공 동의', style: TextStyle(fontWeight: FontWeight.bold)),
              RadioListTile<String>(
                title: const Text('예'),
                value: '예',
                groupValue: _privacyValue,
                onChanged: (v) => setState(() => _privacyValue = v),
              ),
              DropdownButtonFormField<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(value: 'PENDING', child: Text('대기')),
                  DropdownMenuItem(value: 'ACCEPTED', child: Text('합격')),
                  DropdownMenuItem(value: 'REJECTED', child: Text('불합격')),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'PENDING'),
                decoration: const InputDecoration(labelText: '상태'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final ok = await _showSaveDialog();
                                if (ok) {
                                  // 다이얼로그가 완전히 닫힌 후 저장 실행
                                  await Future.delayed(const Duration(milliseconds: 100));
                                  if (mounted) {
                                    await _save(); // await 추가
                                  }
                                }
                              }
                            },
                      child: _isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('저장'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      child: const Text('취소'),
                    ),
                  ),
                ],
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 