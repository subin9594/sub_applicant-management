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
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    
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

  Future<void> _save() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    
    final id = widget.application['id'];
    if (id == null) {
      setState(() {
        _isSubmitting = false;
        _error = '지원서 ID를 찾을 수 없습니다.';
      });
      return;
    }
    
    final url = Uri.parse('http://10.0.2.2:8080/api/applications/$id');
    print('Saving application with ID: $id');
    
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
          'motivation': _motivationController.text.trim(),
          'otherActivity': _otherActivityController.text.trim(),
          'curriculumReason': _curriculumReasonController.text.trim(),
          'wish': _wishController.text.trim(),
          'career': _careerController.text.trim(),
          'languageExp': _languageExpController.text.trim(),
          'languageDetail': _languageDetailController.text.trim(),
          'wishActivities': _wishActivitiesController.text.trim(),
          'interviewDate': _interviewDateController.text.trim(),
          'attendType': _attendTypeValue,
          'privacyAgreement': _privacyAgreementValue,
          'status': _status,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        widget.onSaved();
        
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          
          Navigator.of(context).pop(); // 편집 페이지 닫기
          
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            Navigator.of(context).pop(); // 상세 페이지 닫기
          }
        }
      } else {
        setState(() {
          _isSubmitting = false;
          _error = '저장에 실패했습니다. (상태 코드: ${response.statusCode})';
        });
      }
    } catch (e) {
      print('Error saving application: $e');
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
      appBar: AppBar(title: const Text('부원 지원서 수정')),
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
                controller: _motivationController,
                decoration: const InputDecoration(labelText: '지원 동기'),
                minLines: 3,
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) return '지원 동기를 입력하세요.';
                  if (value.trim().length < 50) return '50자 이상 입력하세요.';
                  return null;
                },
              ),
              TextFormField(
                controller: _otherActivityController,
                decoration: const InputDecoration(labelText: '기타 활동'),
                minLines: 2,
                maxLines: 4,
              ),
              TextFormField(
                controller: _curriculumReasonController,
                decoration: const InputDecoration(labelText: '커리큘럼 이수 가능 이유'),
                minLines: 2,
                maxLines: 4,
              ),
              TextFormField(
                controller: _wishController,
                decoration: const InputDecoration(labelText: 'KUHAS에서 얻고 싶은 것'),
                minLines: 2,
                maxLines: 4,
              ),
              TextFormField(
                controller: _careerController,
                decoration: const InputDecoration(labelText: '진로'),
                minLines: 2,
                maxLines: 4,
              ),
              TextFormField(
                controller: _languageExpController,
                decoration: const InputDecoration(labelText: '프로그래밍 언어 경험'),
                minLines: 2,
                maxLines: 4,
              ),
              TextFormField(
                controller: _languageDetailController,
                decoration: const InputDecoration(labelText: '경험한 언어'),
                minLines: 2,
                maxLines: 4,
              ),
              TextFormField(
                controller: _wishActivitiesController,
                decoration: const InputDecoration(labelText: '희망 활동'),
                minLines: 2,
                maxLines: 4,
              ),
              TextFormField(
                controller: _interviewDateController,
                decoration: const InputDecoration(labelText: '면접 희망 날짜'),
              ),
              const Text('개강총회 참석', style: TextStyle(fontWeight: FontWeight.bold)),
              RadioListTile<String>(
                title: const Text('참석'),
                value: '참석',
                groupValue: _attendTypeValue,
                onChanged: (v) => setState(() => _attendTypeValue = v),
              ),
              RadioListTile<String>(
                title: const Text('불참석'),
                value: '불참석',
                groupValue: _attendTypeValue,
                onChanged: (v) => setState(() => _attendTypeValue = v),
              ),
              const Text('개인정보 제공 동의', style: TextStyle(fontWeight: FontWeight.bold)),
              RadioListTile<String>(
                title: const Text('예'),
                value: '예',
                groupValue: _privacyAgreementValue,
                onChanged: (v) => setState(() => _privacyAgreementValue = v),
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
                                  await Future.delayed(const Duration(milliseconds: 100));
                                  if (mounted) {
                                    await _save();
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