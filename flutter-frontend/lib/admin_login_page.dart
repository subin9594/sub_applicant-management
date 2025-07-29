import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminLoginPage extends StatefulWidget {
  final void Function() onLoginSuccess;
  const AdminLoginPage({super.key, required this.onLoginSuccess});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
  
    final url = Uri.parse('http://10.0.2.2:8080/admin/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'password': _passwordController.text.trim()}),
    );
    
    setState(() {
      _isSubmitting = false;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          widget.onLoginSuccess();
        } else {
          _error = '알 수 없는 오류가 발생했습니다.';
        }
      } else if (response.statusCode == 401) {
        final data = json.decode(response.body);
        _error = data['error'] ?? '비밀번호가 올바르지 않습니다.';
      } else {
        _error = '서버 오류가 발생했습니다.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
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
            width: 360,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('KUHAS 관리자 로그인', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '비밀번호'),
                    validator: (value) => (value == null || value.isEmpty) ? '비밀번호를 입력하세요.' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _login();
                              }
                            },
                      child: _isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('로그인'),
                    ),
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
        ),
      ),
    );
  }
} 