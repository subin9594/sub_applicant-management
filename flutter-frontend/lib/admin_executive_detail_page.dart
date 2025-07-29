import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'admin_executive_edit_page.dart';

class AdminExecutiveDetailPage extends StatefulWidget {
  final Map<String, dynamic> application;
  final VoidCallback onSaved;

  const AdminExecutiveDetailPage({
    super.key,
    required this.application,
    required this.onSaved,
  });

  @override
  State<AdminExecutiveDetailPage> createState() => _AdminExecutiveDetailPageState();
}

class _AdminExecutiveDetailPageState extends State<AdminExecutiveDetailPage> {
  Future<void> _deleteApplication() async {
    final url = Uri.parse('http://10.0.2.2:8080/api/executive-applications/${widget.application['id']}');
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

  Widget _buildField(String label, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return const SizedBox.shrink();
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
            value.toString(),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
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
    
    return Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('${app['name']} 운영진 지원서'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            tooltip: '수정',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AdminExecutiveEditPage(
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
                    '제출일시: ${formatCreatedAt(createdAt)}',
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
                _buildField('이메일', app['email']),
                _buildField('전화번호', app['phoneNumber']),
                _buildField('학년', app['grade']),
                _buildField('휴학 계획', app['leavePlan']),
                _buildField('운영진 활동 기간', app['period']),
                _buildField('지원 동기', app['motivation']),
                _buildField('운영진 활동 목표', app['goal']),
                _buildField('위기 극복 경험', app['crisis']),
                _buildField('회의 참석', app['meeting']),
                _buildField('각오 한 마디', app['resolution']),
                _buildField('개인정보 동의', app['privacy']),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 