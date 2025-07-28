import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admin_login_page.dart';
import 'dart:convert'; // Added for json.encode
import 'admin_main_page.dart';
import 'admin_edit_page.dart'; // Added for AdminEditPage

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
                onEdit: (application) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AdminEditPage(
                        application: application,
                        onSaved: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
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

  bool _isSubmitting = false;
  String? _message;
  String? _error;

  Future<void> _submitForm() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
      _message = null;
    });

    // Android 에뮬레이터에서는 10.0.2.2가 PC의 localhost를 가리킴
    final url = Uri.parse('http://localhost:8080/api/applications/api');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': _nameController.text.trim(),
        'studentId': _studentIdController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'motivation': _motivationController.text.trim(),
      }),
    );

    setState(() {
      _isSubmitting = false;
      if (response.statusCode == 200) {
        _message = '지원이 성공적으로 제출되었습니다!';
        _formKey.currentState?.reset();
      } else {
        String errorMsg = '제출에 실패했습니다. 다시 시도해 주세요.';
        try {
          final data = json.decode(response.body);
          if (data['error'] != null) errorMsg = data['error'];
        } catch (_) {}
        print('지원서 제출 실패: statusCode =  [response.statusCode], body =  [response.body]');
        _error = errorMsg;
      }
    });
  }

  Future<String?> _checkDuplicate() async {
    final studentId = _studentIdController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final url = Uri.parse('http://localhost:8080/api/applications/exists?studentId=$studentId&email=$email&phoneNumber=$phone');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      String msg = '';
      if (data['studentId'] == true) msg += '이미 사용 중인 학번입니다.\n';
      if (data['email'] == true) msg += '이미 사용 중인 이메일입니다.\n';
      if (data['phoneNumber'] == true) msg += '이미 사용 중인 전화번호입니다.\n';
      return msg.isEmpty ? null : msg.trim();
    }
    return null;
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
            width: 380,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('KUHAS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('부원 모집 지원서 제출', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  if (_message != null)
                    Text(_message!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
                    decoration: const InputDecoration(labelText: '이름'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return '이름을 입력하세요.';
                      if (!RegExp(r'^[가-힣a-zA-Z\s]+$').hasMatch(value)) return '이름은 한글 또는 영문만 입력하세요.';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _studentIdController,
                    decoration: const InputDecoration(labelText: '학번'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return '학번을 입력하세요.';
                      if (!RegExp(r'^\d{10}$').hasMatch(value)) return '학번은 숫자 10자리로 입력하세요.';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: '전화번호'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return '전화번호를 입력하세요.';
                      if (!RegExp(r'^[0-9\-]+$').hasMatch(value)) return '전화번호는 숫자와 -만 입력하세요.';
                      if (value.length < 8 || value.length > 14) return '전화번호는 8~14자 이내로 입력하세요.';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: '이메일'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return '이메일을 입력하세요.';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return '이메일 형식이 올바르지 않습니다.';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _motivationController,
                    decoration: const InputDecoration(labelText: '지원동기'),
                    minLines: 4,
                    maxLines: 8,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return '지원동기를 입력하세요.';
                      if (value.length < 50) return '지원동기는 50자 이상 입력하세요.';
                      return null;
                    },
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
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/admin-login');
                    },
                    child: const Text('관리자 페이지'),
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
