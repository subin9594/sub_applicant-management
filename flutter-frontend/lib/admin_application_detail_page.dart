import 'package:flutter/material.dart';
import 'admin_edit_page.dart';

class AdminApplicationDetailPage extends StatelessWidget {
  final Map<String, dynamic> application;
  final VoidCallback onSaved;

  const AdminApplicationDetailPage({
    super.key,
    required this.application,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('부원 지원서 상세'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AdminEditPage(
                    application: application,
                    onSaved: () {
                      Navigator.of(context).pop(); // Pop edit page
                      onSaved(); // Refresh main list
                      // Success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('부원 지원서가 성공적으로 수정되었습니다.'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildInfoCard('기본 정보', [
              _buildInfoRow('이름', application['name'] ?? ''),
              _buildInfoRow('학번', application['studentId'] ?? ''),
              _buildInfoRow('학년', application['grade'] ?? ''),
              _buildInfoRow('이메일', application['email'] ?? ''),
              _buildInfoRow('전화번호', application['phoneNumber'] ?? ''),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('지원 정보', [
              _buildInfoRow('지원동기', application['motivation'] ?? '', isLongText: true),
              _buildInfoRow('기타 활동', application['otherActivity'] ?? ''),
              _buildInfoRow('커리큘럼 이유', application['curriculumReason'] ?? ''),
              _buildInfoRow('희망사항', application['wish'] ?? ''),
              _buildInfoRow('진로계획', application['career'] ?? ''),
              _buildInfoRow('언어 경험', application['languageExp'] ?? ''),
              _buildInfoRow('언어 상세', application['languageDetail'] ?? ''),
              _buildInfoRow('희망 활동', application['wishActivities'] ?? ''),
              _buildInfoRow('면접 희망일', application['interviewDate'] ?? ''),
              _buildInfoRow('참석 유형', application['attendType'] ?? ''),
              _buildInfoRow('개인정보 동의', application['privacyAgreement'] ?? ''),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('상태 정보', [
              _buildInfoRow('상태', _getStatusText(application['status'] ?? 'PENDING')),
              _buildInfoRow('등록일', _formatDate(application['createdAt'])),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLongText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              fontSize: isLongText ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return '대기';
      case 'ACCEPTED':
        return '합격';
      case 'REJECTED':
        return '불합격';
      default:
        return status;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      if (date is String) {
        return date;
      }
      return date.toString();
    } catch (e) {
      return '-';
    }
  }
} 