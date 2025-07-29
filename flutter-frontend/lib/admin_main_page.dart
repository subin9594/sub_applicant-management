import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart'; // Import ApplicantFormPage from main.dart
import 'admin_application_detail_page.dart'; // Import AdminApplicationDetailPage
import 'admin_executive_detail_page.dart'; // Import AdminExecutiveDetailPage

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
  final String? grade; // Added for member applications

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
    this.grade, // Added for member applications
  });

  factory ApplicationForm.fromJson(Map<String, dynamic> json) {
    return ApplicationForm(
      id: json['id'],
      name: json['name'],
      studentId: json['studentId'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      grade: json['grade'],
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

  String get formattedCreatedAt {
    final year = createdAt.year.toString();
    final month = createdAt.month.toString().padLeft(2, '0');
    final day = createdAt.day.toString().padLeft(2, '0');
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final second = createdAt.second.toString().padLeft(2, '0');
    
    return '$year-$month-$day\n$hour:$minute:$second';
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
  final bool _showSidePanel = false;
  ApplicationCategory? _sidePanelCategory;
  String? _successMessage; // 성공 메시지 추가

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  // 외부에서 호출할 수 있는 새로고침 메서드
  void refresh() {
    _fetchApplications();
  }

  // 성공 메시지 표시 메서드
  void _showSuccessMessage(String message) {
    setState(() {
      _successMessage = message;
    });
    
    // 3초 후 자동으로 제거
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _successMessage = null;
        });
      }
    });
  }

  Future<void> _fetchApplications() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    if (_category == ApplicationCategory.member) {
      try {
        final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/applications/list'));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            _applications = data.map((json) => ApplicationForm.fromJson(json)).toList();
            _loading = false;
          });
        } else {
          setState(() {
            _error = '부원 지원서 목록을 불러오지 못했습니다.';
            _loading = false;
          });
        }
      } catch (e) {
        setState(() {
          _error = '부원 지원서 목록을 불러오지 못했습니다: $e';
          _loading = false;
        });
      }
    } else {
      try {
        final response = await http.get(Uri.parse('http://10.0.2.2:8080/api/executive-applications'));
        print('Executive applications response status: ${response.statusCode}'); // 디버깅용
        print('Executive applications response body: ${response.body}'); // 디버깅용
        
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          print('Parsed executive applications data: $data'); // 디버깅용
          
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
      } catch (e) {
        setState(() {
          _error = '운영진 지원서 목록을 불러오지 못했습니다: $e';
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

  Future<void> _changeExecutiveStatus(int id, String status) async {
    final url = Uri.parse('http://10.0.2.2:8080/api/executive-applications/$id/status?status=$status');
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
    // Sort applications by createdAt in ascending order
    final sortedApplications = List<ApplicationForm>.from(_applications);
    sortedApplications.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedApplications.length,
      itemBuilder: (context, index) {
        final app = sortedApplications[index];
        final sequenceNumber = index + 1;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AdminApplicationDetailPage(
                    application: {
                      'id': app.id,
                      'name': app.name,
                      'studentId': app.studentId,
                      'phoneNumber': app.phoneNumber,
                      'email': app.email,
                      'motivation': app.motivation,
                      'status': app.status,
                      'createdAt': app.createdAt.toIso8601String(),
                      'otherActivity': app.otherActivity,
                      'curriculumReason': app.curriculumReason,
                      'wish': app.wish,
                      'career': app.career,
                      'languageExp': app.languageExp,
                      'languageDetail': app.languageDetail,
                      'wishActivities': app.wishActivities,
                      'interviewDate': app.interviewDate,
                      'attendType': app.attendType,
                      'privacyAgreement': app.privacyAgreement,
                      'grade': app.grade,
                    },
                    onSaved: () {
                      Navigator.of(context).pop();
                      _fetchApplications();
                      // 성공 메시지 표시
                      _showSuccessMessage('부원 지원서가 성공적으로 수정되었습니다.');
                    },
                  ),
                ),
              );
            },
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
                            if (app.grade != null && app.grade!.isNotEmpty)
                              Text('학년: ${app.grade}', style: const TextStyle(color: Colors.grey)),
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMemberField('이메일', app.email),
                            _buildMemberField('전화번호', app.phoneNumber),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '순번: $sequenceNumber',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            app.formattedCreatedAt,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
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
    // Sort executive applications by createdAt in ascending order
    final sortedExecutiveApplications = List<Map<String, dynamic>>.from(_executiveApplications);
    sortedExecutiveApplications.sort((a, b) {
      final aDate = DateTime.parse(a['createdAt']);
      final bDate = DateTime.parse(b['createdAt']);
      return aDate.compareTo(bDate);
    });
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedExecutiveApplications.length,
      itemBuilder: (context, index) {
        final app = sortedExecutiveApplications[index];
        final sequenceNumber = index + 1;
        final createdAt = DateTime.parse(app['createdAt']);
        
        String formatCreatedAt(DateTime date) {
          final year = date.year.toString();
          final month = date.month.toString().padLeft(2, '0');
          final day = date.day.toString().padLeft(2, '0');
          final hour = date.hour.toString().padLeft(2, '0');
          final minute = date.minute.toString().padLeft(2, '0');
          final second = date.second.toString().padLeft(2, '0');
          
          return '$year-$month-$day\n$hour:$minute:$second';
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 20),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AdminExecutiveDetailPage(
                    application: app,
                    onSaved: () {
                      Navigator.of(context).pop();
                      _fetchApplications();
                      // 성공 메시지 표시
                      _showSuccessMessage('운영진 지원서가 성공적으로 수정되었습니다.');
                    },
                  ),
                ),
              );
            },
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
                            if (app['grade'] != null && app['grade'].toString().isNotEmpty)
                              Text('학년: ${app['grade']}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        child: Container(
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
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'PENDING',
                            child: Text('대기'),
                          ),
                          const PopupMenuItem(
                            value: 'ACCEPTED',
                            child: Text('합격'),
                          ),
                          const PopupMenuItem(
                            value: 'REJECTED',
                            child: Text('불합격'),
                          ),
                        ],
                        onSelected: (value) {
                          _changeExecutiveStatus(app['id'], value);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24, thickness: 1.2),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildExecutiveField('이메일', app['email']),
                            _buildExecutiveField('전화번호', app['phoneNumber']),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '순번: $sequenceNumber',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatCreatedAt(createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
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
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.black),
          tooltip: '홈으로',
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => ApplicantFormPage()),
              (route) => false,
            );
          },
        ),
        title: Text(
          _category == ApplicationCategory.member ? '부원 지원서 목록' : '운영진 지원서 목록',
          style: const TextStyle(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _category == ApplicationCategory.member ? 'member' : 'executive',
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              items: const [
                DropdownMenuItem(
                  value: 'member',
                  child: Text('부원 모집 지원서'),
                ),
                DropdownMenuItem(
                  value: 'executive',
                  child: Text('운영진 모집 지원서'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _category = value == 'executive' ? ApplicationCategory.executive : ApplicationCategory.member;
                });
                _fetchApplications(); // 카테고리 변경 시 데이터 새로고침
              },
            ),
          ),
        ],
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
          
          // 성공 메시지 표시
          if (_successMessage != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () {
                        setState(() {
                          _successMessage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
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