import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'admin_main_page.dart';

class AdminEditPage extends StatefulWidget {
  final ApplicationForm application;
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
  String _status = 'PENDING';
  bool _isSubmitting = false;
  String? _error;
  String? _studentIdError;
  String? _emailError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.application.name);
    _studentIdController = TextEditingController(text: widget.application.studentId);
    _phoneController = TextEditingController(text: widget.application.phoneNumber);
    _emailController = TextEditingController(text: widget.application.email);
    _motivationController = TextEditingController(text: widget.application.motivation);
    _status = widget.application.status;
  }

  Future<void> _checkStudentId() async {
    final studentId = _studentIdController.text.trim();
    if (studentId.isEmpty) return;
    final url = Uri.parse('http://10.0.2.2:8080/api/applications/student/$studentId');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data['id'] != widget.application.id) {
        setState(() { _studentIdError = '이미 사용 중인 학번입니다.'; });
        return;
      }
    }
    setState(() { _studentIdError = null; });
  }

  Future<void> _checkEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    final url = Uri.parse('http://10.0.2.2:8080/api/applications?email=$email');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data is List && data.isNotEmpty && data[0]['id'] != widget.application.id) {
        setState(() { _emailError = '이미 사용 중인 이메일입니다.'; });
        return;
      }
    }
    setState(() { _emailError = null; });
  }

  Future<void> _checkPhone() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    final url = Uri.parse('http://10.0.2.2:8080/api/applications?phoneNumber=$phone');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data is List && data.isNotEmpty && data[0]['id'] != widget.application.id) {
        setState(() { _phoneError = '이미 사용 중인 전화번호입니다.'; });
        return;
      }
    }
    setState(() { _phoneError = null; });
  }

  Future<void> _save() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final url = Uri.parse('http://10.0.2.2:8080/api/applications/${widget.application.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': _nameController.text.trim(),
        'studentId': _studentIdController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'motivation': _motivationController.text.trim(),
        'status': _status,
      }),
    );
    setState(() {
      _isSubmitting = false;
      if (response.statusCode == 200) {
        widget.onSaved();
      } else {
        _error = '저장에 실패했습니다.';
      }
    });
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
      appBar: AppBar(title: const Text('지원서 수정')),
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
                decoration: InputDecoration(labelText: '학번', errorText: _studentIdError),
                onChanged: (_) => _checkStudentId(),
                validator: (value) {
                  if (value == null || value.isEmpty) return '학번을 입력하세요.';
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) return '학번은 숫자 10자리로 입력하세요.';
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: '전화번호', errorText: _phoneError),
                onChanged: (_) => _checkPhone(),
                validator: (value) {
                  if (value == null || value.isEmpty) return '전화번호를 입력하세요.';
                  if (!RegExp(r'^[0-9\-]+$').hasMatch(value)) return '전화번호는 숫자와 -만 입력하세요.';
                  if (value.length < 8 || value.length > 14) return '전화번호는 8~14자 이내로 입력하세요.';
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: '이메일', errorText: _emailError),
                onChanged: (_) => _checkEmail(),
                validator: (value) {
                  if (value == null || value.isEmpty) return '이메일을 입력하세요.';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return '이메일 형식이 올바르지 않습니다.';
                  return null;
                },
              ),
              TextFormField(
                controller: _motivationController,
                decoration: const InputDecoration(labelText: '지원동기'),
                minLines: 3,
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) return '지원동기를 입력하세요.';
                  if (value.length < 50) return '지원동기는 50자 이상 입력하세요.';
                  return null;
                },
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
                                if (_studentIdError != null || _emailError != null || _phoneError != null) return;
                                final ok = await _showSaveDialog();
                                if (ok) _save();
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