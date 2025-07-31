import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'admin_edit_page.dart';

class AdminApplicationDetailPage extends StatefulWidget {
  final Map<String, dynamic> application;
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
  Map<String, dynamic> _application = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _application = Map<String, dynamic>.from(widget.application);
  }

  Future<void> _refreshApplication() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/applications/${_application['id']}'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _application = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('지원서 정보를 불러오는데 실패했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteApplication() async {
    final url = Uri.parse('http://10.0.2.2:8080/api/applications/${_application['id']}');
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
                    application: _application,
                    onSaved: () async {
                      // 수정 완료 후 상세 페이지 새로고침
                      await _refreshApplication();
                      // 메인 리스트도 새로고침
                      widget.onSaved();
                      // 성공 메시지
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('부원 지원서가 성공적으로 수정되었습니다.'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _buildInfoCard('기본 정보', [
                    _buildInfoRow('이름', _application['name'] ?? ''),
                    _buildInfoRow('학번', _application['studentId'] ?? ''),
                    _buildInfoRow('학년', _application['grade'] ?? ''),
                    _buildInfoRow('이메일', _application['email'] ?? ''),
                    _buildInfoRow('전화번호', _application['phoneNumber'] ?? ''),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoCard('지원 정보', [
                    _buildInfoRow('지원동기', _application['motivation'] ?? '', isLongText: true),
                    _buildInfoRow('기타 활동', _application['otherActivity'] ?? ''),
                    _buildInfoRow('커리큘럼 이유', _application['curriculumReason'] ?? ''),
                    _buildInfoRow('희망사항', _application['wish'] ?? ''),
                    _buildInfoRow('진로계획', _application['career'] ?? ''),
                    _buildInfoRow('언어 경험', _application['languageExp'] ?? ''),
                    if (_application['languageExp'] == '있음')
                      _buildInfoRow('언어 상세', _application['languageDetail'] ?? ''),
                    _buildInfoRow('희망 활동', _application['wishActivities'] ?? ''),
                    _buildInfoRow('면접 일정', _application['interviewDate'] ?? ''),
                    _buildInfoRow('개강총회 참석 유형', _application['attendType'] ?? ''),
                    _buildInfoRow('개인정보 동의', _application['privacyAgreement'] ?? ''),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoCard('상태 정보', [
                    _buildInfoRow('상태', _getStatusText(_application['status'] ?? 'PENDING')),
                    _buildInfoRow('등록일', _formatDate(_application['createdAt'])),
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