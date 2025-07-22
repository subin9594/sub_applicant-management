import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  final void Function(ApplicationForm) onEdit;
  const AdminMainPage({super.key, required this.onLogout, required this.onEdit});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  List<ApplicationForm> _applications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final url = Uri.parse('http://localhost:8080/api/applications');
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
  }

  Future<void> _changeStatus(int id, String status) async {
    final url = Uri.parse('http://localhost:8080/admin/approve/$id');
    final response = await http.post(url, body: {'status': status});
    if (response.statusCode == 302 || response.statusCode == 200) {
      _fetchApplications();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('상태 변경 실패')),
        );
        }
  }

  Future<void> _deleteApplication(int id) async {
    final url = Uri.parse('http://localhost:8080/admin/delete/$id');
    final response = await http.post(url);
    if (response.statusCode == 302 || response.statusCode == 200) {
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
            content: const Text('삭제하시겠습니까?\nENTER를 누르면 삭제 됩니다.\n취소하려면 ESC를 눌러주세요'),
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
      backgroundColor: const Color(0xfff7f8fa),
      appBar: AppBar(
        title: const Text('KUHAS 부원 모집 지원서 목록'),
        actions: [
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
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('순번')),
                      DataColumn(label: Text('지원 시각')),
                      DataColumn(label: Text('이름')),
                      DataColumn(label: Text('학번')),
                      DataColumn(label: Text('전화번호')),
                      DataColumn(label: Text('이메일')),
                      DataColumn(label: Text('지원동기')),
                      DataColumn(label: Text('상태')),
                      DataColumn(label: Text('처리')),
                    ],
                    rows: _applications.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final app = entry.value;
                      return DataRow(cells: [
                        DataCell(Text('${idx + 1}')),
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${app.createdAt.year}-${app.createdAt.month.toString().padLeft(2, '0')}-${app.createdAt.day.toString().padLeft(2, '0')}'),
                            Text('${app.createdAt.hour.toString().padLeft(2, '0')}:${app.createdAt.minute.toString().padLeft(2, '0')}:${app.createdAt.second.toString().padLeft(2, '0')}'),
                          ],
                        )),
                        DataCell(Text(app.name)),
                        DataCell(Text(app.studentId)),
                        DataCell(Text(app.phoneNumber)),
                        DataCell(Text(app.email)),
                        DataCell(SizedBox(width: 200, child: Text(app.motivation, maxLines: 5, overflow: TextOverflow.ellipsis))),
                        DataCell(Text(app.status, style: TextStyle(
                          color: app.status == 'PENDING' ? Color(0xfff59e42) : app.status == 'ACCEPTED' ? Color(0xff22c55e) : Color(0xffef4444),
                          fontWeight: FontWeight.bold,
                        ))),
                        DataCell(Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => _changeStatus(app.id, 'ACCEPTED'),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff22c55e)),
                              child: const Text('합격'),
                            ),
                            const SizedBox(width: 4),
                            ElevatedButton(
                              onPressed: () => _changeStatus(app.id, 'REJECTED'),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffef4444)),
                              child: const Text('불합격'),
                            ),
                            const SizedBox(width: 4),
                            ElevatedButton(
                              onPressed: () => widget.onEdit(app),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xfffde68a)),
                              child: const Text('수정', style: TextStyle(color: Colors.black)),
                            ),
                            const SizedBox(width: 4),
                            ElevatedButton(
                              onPressed: () async {
                                final ok = await _showDeleteDialog();
                                if (ok) _deleteApplication(app.id);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffef4444)),
                              child: const Text('삭제'),
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
    );
  }
} 