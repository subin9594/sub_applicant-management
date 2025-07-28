import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'admin_edit_page.dart';

enum ApplicationCategory { member, executive }

class ApplicationForm {
  final int id;
  final String name;
  final String studentId;
  final String phoneNumber;
  final String email;
  final String motivation;
  final String status;
  final DateTime createdAt;

  ApplicationForm({
    required this.id,
    required this.name,
    required this.studentId,
    required this.phoneNumber,
    required this.email,
    required this.motivation,
    required this.status,
    required this.createdAt,
  });

  factory ApplicationForm.fromJson(Map<String, dynamic> json) {
    return ApplicationForm(
      id: json['id'],
      name: json['name'],
      studentId: json['studentId'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      motivation: json['motivation'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class AdminMainPage extends StatefulWidget {
  final VoidCallback onLogout;
  const AdminMainPage({super.key, required this.onLogout});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  ApplicationCategory _category = ApplicationCategory.member;
  List<ApplicationForm> _applications = [];
  List<Map<String, dynamic>> _executiveApplications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  // 외부에서 호출할 수 있는 새로고침 메서드
  void refresh() {
    _fetchApplications();
  }

  void _fetchApplications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    if (_category == ApplicationCategory.member) {
      final url = Uri.parse('http://10.0.2.2:8080/api/applications/list');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _applications = data.map((e) => ApplicationForm.fromJson(e)).toList();
        _loading = false;
      });
    } else {
      setState(() {
        _error = '목록을 불러오지 못했습니다.';
        _loading = false;
      });
      }
    } else {
      final url = Uri.parse('http://10.0.2.2:8080/api/executive-applications');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _executiveApplications = List<Map<String, dynamic>>.from(data);
          _loading = false;
        });
      } else {
        setState(() {
          _error = '운영진 지원서 목록을 불러오지 못했습니다.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _changeStatus(int id, String status) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/applications/$id/status?status=$status');
    final response = await http.put(url);
    if (response.statusCode == 200) {
      _fetchApplications();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('상태 변경 실패')),
        );
        }
  }

  Future<void> _deleteApplication(int id) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/applications/$id');
    final response = await http.delete(url);
    if (response.statusCode == 204) {
      _fetchApplications();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제 실패')),
        );
        }
  }

  Future<bool> _showDeleteDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('삭제 확인'),
            content: const Text('삭제하시겠습니까?'),
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

  String _wrapMotivation(String text) {
    if (text.length <= 16) return text;
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i += 16) {
      buffer.write(text.substring(i, i + 16 > text.length ? text.length : i + 16));
      if (i + 16 < text.length) buffer.write('\n');
    }
    return buffer.toString();
  }

  void _showCategoryDialog() {
    ApplicationCategory? selected = _category;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => AlertDialog(
        title: const Text('지원서 카테고리 선택'),
        content: StatefulBuilder(
          builder: (context, setState) => DropdownButton<ApplicationCategory>(
            value: selected,
            items: [
              DropdownMenuItem(value: ApplicationCategory.member, child: Text('부원 모집 지원서')),
              DropdownMenuItem(value: ApplicationCategory.executive, child: Text('운영진 모집 지원서')),
            ],
            onChanged: (v) => setState(() => selected = v),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (selected != null && selected != _category) {
                setState(() => _category = selected!);
                _fetchApplications();
              }
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
      appBar: AppBar(
        title: Text(_category == ApplicationCategory.member ? 'KUHAS 부원 모집 지원서 목록' : 'KUHAS 운영진 모집 지원서 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment),
            tooltip: '지원서 카테고리 선택',
            onPressed: _showCategoryDialog,
          ),
          TextButton(
            onPressed: widget.onLogout,
            child: const Text('로그아웃', style: TextStyle(color: Colors.black)),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : (_category == ApplicationCategory.member
                  ? (_applications.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('지원서가 없습니다', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _applications.length,
                          itemBuilder: (context, index) {
                            final app = _applications[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 헤더 (순번, 이름, 학번, 상태)
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '#${index + 1}',
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                                              Text(
                                                app.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                app.studentId,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: app.status == 'PENDING' 
                                                ? Colors.orange.shade100
                                                : app.status == 'ACCEPTED'
                                                    ? Colors.green.shade100
                                                    : Colors.red.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            app.status == 'PENDING' ? '대기중'
                                                : app.status == 'ACCEPTED' ? '합격'
                                                : '불합격',
                                            style: TextStyle(
                                              color: app.status == 'PENDING'
                                                  ? Colors.orange.shade700
                                                  : app.status == 'ACCEPTED'
                                                      ? Colors.green.shade700
                                                      : Colors.red.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                          ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // 연락처 정보
                                    Row(
                                      children: [
                                        Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                                        const SizedBox(width: 8),
                                        Text(app.phoneNumber),
                                        const SizedBox(width: 16),
                                        Icon(Icons.email, size: 16, color: Colors.grey.shade600),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            app.email,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // 지원 시각
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${app.createdAt.year}-${app.createdAt.month.toString().padLeft(2, '0')}-${app.createdAt.day.toString().padLeft(2, '0')} ${app.createdAt.hour.toString().padLeft(2, '0')}:${app.createdAt.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // 지원동기
                                    const Text(
                                      '지원동기',
                                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: Text(
                                        app.motivation,
                                        style: const TextStyle(fontSize: 14, height: 1.4),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // 액션 버튼들
                                    Row(
                          children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                              onPressed: () => _changeStatus(app.id, 'ACCEPTED'),
                                            icon: const Icon(Icons.check, size: 16),
                                            label: const Text('합격'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                            ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                              onPressed: () => _changeStatus(app.id, 'REJECTED'),
                                            icon: const Icon(Icons.close, size: 16),
                                            label: const Text('불합격'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                            ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => AdminEditPage(
                                                    application: app,
                                                    onSaved: () {
                                                      Navigator.of(context).pop();
                                                      // 수정 완료 후 목록 새로고침
                                                      _fetchApplications();
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.edit, size: 16),
                                            label: const Text('수정'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.blue,
                                            ),
                                          ),
                            ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                              onPressed: () async {
                                final ok = await _showDeleteDialog();
                                if (ok) _deleteApplication(app.id);
                              },
                                            icon: const Icon(Icons.delete, size: 16),
                                            label: const Text('삭제'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ))
                  : (_executiveApplications.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('운영진 지원서가 없습니다', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _executiveApplications.length,
                          itemBuilder: (context, index) {
                            final app = _executiveApplications[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('이름: ${app['name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('학번: ${app['studentId'] ?? ''}'),
                                    Text('학년: ${app['grade'] ?? ''}'),
                                    Text('이메일: ${app['email'] ?? ''}'),
                                    Text('전화번호: ${app['phoneNumber'] ?? ''}'),
                                    Text('휴학 계획: ${app['leavePlan'] ?? ''}'),
                                    Text('운영진 활동 기간: ${app['period'] ?? ''}'),
                                    const SizedBox(height: 8),
                                    Text('지원 동기: ${app['motivation'] ?? ''}'),
                                    const SizedBox(height: 8),
                                    Text('운영진으로 얻고자 하는 것: ${app['goal'] ?? ''}'),
                                    const SizedBox(height: 8),
                                    Text('위기 극복 경험: ${app['crisis'] ?? ''}'),
                                    const SizedBox(height: 8),
                                    Text('회의 참석: ${app['meeting'] ?? ''}'),
                                    const SizedBox(height: 8),
                                    Text('각오 한 마디: ${app['resolution'] ?? ''}'),
                                    const SizedBox(height: 8),
                                    Text('개인정보 동의: ${app['privacy'] ?? ''}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ))
                ),
    );
  }
} 