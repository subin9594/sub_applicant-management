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
  // 추가 필드
  final String? otherActivity;
  final String? curriculumReason;
  final String? wish;
  final String? career;
  final String? languageExp;
  final String? languageDetail;
  final String? wishActivities;
  final String? interviewDate;
  final String? attendType;
  final String? privacyAgreement;

  ApplicationForm({
    required this.id,
    required this.name,
    required this.studentId,
    required this.phoneNumber,
    required this.email,
    required this.motivation,
    required this.status,
    required this.createdAt,
    this.otherActivity,
    this.curriculumReason,
    this.wish,
    this.career,
    this.languageExp,
    this.languageDetail,
    this.wishActivities,
    this.interviewDate,
    this.attendType,
    this.privacyAgreement,
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
      otherActivity: json['otherActivity'],
      curriculumReason: json['curriculumReason'],
      wish: json['wish'],
      career: json['career'],
      languageExp: json['languageExp'],
      languageDetail: json['languageDetail'],
      wishActivities: json['wishActivities'],
      interviewDate: json['interviewDate'],
      attendType: json['attendType'],
      privacyAgreement: json['privacyAgreement'],
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
  bool _showSidePanel = false;
  ApplicationCategory? _sidePanelCategory;

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

  // 표 기반 UI 완전 제거
  // _buildCustomTable 및 관련 Table, TableRow, Row 등 표 관련 코드 삭제

  Widget _buildMemberList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _applications.length,
      itemBuilder: (context, index) {
        final app = _applications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(app.name.isNotEmpty ? app.name[0] : '?'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(app.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text('학번: ${app.studentId}', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (app.status == 'PENDING')
                            ? Colors.orange.shade100
                            : app.status == 'ACCEPTED'
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        app.status == 'PENDING'
                            ? '대기'
                            : app.status == 'ACCEPTED'
                                ? '합격'
                                : '불합격',
                        style: TextStyle(
                          color: (app.status == 'PENDING')
                              ? Colors.orange
                              : app.status == 'ACCEPTED'
                                  ? Colors.green
                                  : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1.2),
                _buildMemberField('이메일', app.email),
                _buildMemberField('전화번호', app.phoneNumber),
                _buildMemberField('지원 동기', app.motivation),
                _buildMemberField('기타 활동', app.otherActivity),
                _buildMemberField('커리큘럼 이수 가능 이유', app.curriculumReason),
                _buildMemberField('KUHAS에서 얻고 싶은 것', app.wish),
                _buildMemberField('진로', app.career),
                _buildMemberField('프로그래밍 언어 경험', app.languageExp),
                _buildMemberField('경험한 언어', app.languageDetail),
                _buildMemberField('희망 활동', app.wishActivities),
                _buildMemberField('면접 희망 날짜', app.interviewDate),
                _buildMemberField('개강총회 참석', app.attendType),
                _buildMemberField('개인정보 동의', app.privacyAgreement),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: '수정',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AdminEditPage(
                              application: app,
                              onSaved: () {
                                Navigator.of(context).pop();
                                _fetchApplications();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: '삭제',
                      onPressed: () async {
                        final ok = await _showDeleteDialog();
                        if (ok) _deleteApplication(app.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemberField(String label, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
          Expanded(
            child: Text(value.toString(), style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _executiveApplications.length,
      itemBuilder: (context, index) {
        final app = _executiveApplications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(app['name'] != null && app['name'].isNotEmpty ? app['name'][0] : '?'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(app['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text('학번: ${app['studentId'] ?? ''}', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (app['status'] == 'PENDING')
                            ? Colors.orange.shade100
                            : app['status'] == 'ACCEPTED'
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        app['status'] == 'PENDING'
                            ? '대기'
                            : app['status'] == 'ACCEPTED'
                                ? '합격'
                                : '불합격',
                        style: TextStyle(
                          color: (app['status'] == 'PENDING')
                              ? Colors.orange
                              : app['status'] == 'ACCEPTED'
                                  ? Colors.green
                                  : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 1.2),
                _buildExecutiveField('이메일', app['email']),
                _buildExecutiveField('전화번호', app['phoneNumber']),
                _buildExecutiveField('학년', app['grade']),
                _buildExecutiveField('휴학 계획', app['leavePlan']),
                _buildExecutiveField('운영진 활동 기간', app['period']),
                _buildExecutiveField('지원 동기', app['motivation']),
                _buildExecutiveField('운영진으로 얻고자 하는 것', app['goal']),
                _buildExecutiveField('위기 극복 경험', app['crisis']),
                _buildExecutiveField('회의 참석', app['meeting']),
                _buildExecutiveField('각오 한 마디', app['resolution']),
                _buildExecutiveField('개인정보 동의', app['privacy']),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: '삭제',
                      onPressed: () async {
                        final ok = await _showDeleteDialog();
                        if (ok) _deleteApplication(app['id']);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExecutiveField(String label, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
          Expanded(
            child: Text(value.toString(), style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sidePanelWidth = MediaQuery.of(context).size.width * 0.4;
    return Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
      appBar: AppBar(
        title: Text(_category == ApplicationCategory.member ? 'KUHAS 부원 모집 지원서 목록' : 'KUHAS 운영진 모집 지원서 목록'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('메뉴', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('지원서 양식 선택'),
              onTap: () {
                Navigator.of(context).pop();
                ApplicationCategory? selected = _category;
                showDialog(
                  context: context,
                  barrierColor: Colors.black.withOpacity(0.7),
                  builder: (context) => AlertDialog(
                    title: const Text('지원서 양식 선택'),
                    content: StatefulBuilder(
                      builder: (context, setState) => DropdownButton<ApplicationCategory>(
                        value: selected,
                        items: [
                          DropdownMenuItem(value: ApplicationCategory.executive, child: Text('KUHAS 운영진 모집 지원서')),
                          DropdownMenuItem(value: ApplicationCategory.member, child: Text('KUHAS 부원 모집 지원서 목록')),
                        ],
                        onChanged: (v) => setState(() => selected = v),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() => _category = selected!);
                        },
                        child: const Text('확인'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('로그아웃'),
              onTap: () {
                Navigator.of(context).pop();
                widget.onLogout();
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : (_category == ApplicationCategory.member
                      ? (_applications.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text('지원서가 없습니다.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                                ],
                              ),
                            )
                          : _buildMemberList())
                      : (_executiveApplications.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text('운영진 지원서가 없습니다.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                                ],
                              ),
                            )
                          : _buildExecutiveList())),
          // 사이드 패널 + 오버레이
          // if (_showSidePanel) ...[
          //   GestureDetector(
          //     onTap: () => setState(() => _showSidePanel = false),
          //     child: Container(
          //       color: Colors.black.withOpacity(0.7),
          //       width: double.infinity,
          //       height: double.infinity,
          //     ),
          //   ),
          //   Align(
          //     alignment: Alignment.centerRight,
          //     child: Container(
          //       width: sidePanelWidth,
          //       height: double.infinity,
          //       color: Colors.white,
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Row(
          //             children: [
          //               IconButton(
          //                 icon: const Icon(Icons.arrow_back),
          //                 onPressed: () => setState(() => _showSidePanel = false),
          //               ),
          //               const Text('관리자 메뉴', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          //             ],
          //           ),
          //           const Divider(),
          //           Padding(
          //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //             child: ElevatedButton.icon(
          //               onPressed: widget.onLogout,
          //               icon: const Icon(Icons.logout),
          //               label: const Text('로그아웃'),
          //               style: ElevatedButton.styleFrom(
          //                 backgroundColor: Colors.red,
          //                 foregroundColor: Colors.white,
          //               ),
          //             ),
          //           ),
          //           const Divider(),
          //           Padding(
          //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 const Text('지원서 양식 선택', style: TextStyle(fontWeight: FontWeight.bold)),
          //                 const SizedBox(height: 8),
          //                 DropdownButton<ApplicationCategory>(
          //                   value: _sidePanelCategory,
          //                   items: const [
          //                     DropdownMenuItem(value: ApplicationCategory.member, child: Text('부원 모집 지원서')),
          //                     DropdownMenuItem(value: ApplicationCategory.executive, child: Text('운영진 모집 지원서')),
          //                   ],
          //                   onChanged: (v) {
          //                     setState(() {
          //                       _sidePanelCategory = v;
          //                       if (v != null && v != _category) {
          //                         _category = v;
          //                         _fetchApplications();
          //                       }
          //                     });
          //                   },
          //                 ),
          //               ],
          //             ),
          //           ),
          //           // 추가 관리자 기능/설정은 여기에
          //         ],
          //       ),
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }
} 