import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admin_edit_page.dart';
import 'admin_main_page.dart';

class AdminApplicationDetailPage extends StatefulWidget {
  final ApplicationForm application;
  final VoidCallback onSaved;

  const AdminApplicationDetailPage({
    super.key,
    required this.application,
    required this.onSaved,
  });

  @override
  State<AdminApplicationDetailPage> createState() => _AdminApplicationDetailPageState();
}

class _AdminApplicationDetailPageState extends State<AdminApplicationDetailPage> {
  Future<void> _deleteApplication() async {
    final url = Uri.parse('http://10.0.2.2:8080/api/applications/${widget.application.id}');
    final response = await http.delete(url);
    
    if (response.statusCode == 200 || response.statusCode == 204) {
      widget.onSaved();
      Navigator.of(context).pop(); // 상세 페이지에서 목록으로 돌아가기
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('삭제에 실패했습니다.')),
      );
    }
  }

  Future<bool> _showDeleteDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('지원서 삭제'),
        content: const Text('정말로 이 지원서를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildField(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    return Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('${app.name} 지원서 상세'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
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
                      widget.onSaved();
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
              if (ok) _deleteApplication();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Submission date at top left
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    '제출일시: ${app.formattedCreatedAt}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                _buildField('이메일', app.email),
                _buildField('전화번호', app.phoneNumber),
                _buildField('지원 동기', app.motivation),
                _buildField('기타 활동', app.otherActivity),
                _buildField('커리큘럼 이수 가능 이유', app.curriculumReason),
                _buildField('KUHAS에서 얻고 싶은 것', app.wish),
                _buildField('진로', app.career),
                _buildField('프로그래밍 언어 경험', app.languageExp),
                _buildField('경험한 언어', app.languageDetail),
                _buildField('희망 활동', app.wishActivities),
                _buildField('면접 희망 날짜', app.interviewDate),
                _buildField('개강총회 참석', app.attendType),
                _buildField('개인정보 동의', app.privacyAgreement),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 