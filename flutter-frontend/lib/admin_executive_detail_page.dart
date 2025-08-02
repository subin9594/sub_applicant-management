import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
        Uri.parse('http://10.0.2.2:8080/api/executive-applications/${_application['id']}'),
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
    final url = Uri.parse('http://10.0.2.2:8080/api/executive-applications/${_application['id']}');
    final response = await http.delete(url);
    
    if (response.statusCode == 200 || response.statusCode == 204) {
      // 삭제 후 지원서 목록으로 돌아가고 성공 메시지 표시
      widget.onSaved(); // 지원서 목록 새로고침
      // 상세 페이지만 닫고 목록 페이지로 돌아가기
      Navigator.of(context).pop();
      // 성공 메시지는 메인 페이지에서 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_application['name']}의 운영진 지원서가 성공적으로 삭제되었습니다.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    final app = _application;
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
                    onSaved: () async {
                      // 수정 완료 후 상세 페이지 새로고침
                      await _refreshApplication();
                      // 메인 리스트도 새로고침
                      widget.onSaved();
                      // 성공 메시지
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('운영진 지원서가 성공적으로 수정되었습니다.'),
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
                    _buildInfoRow('이름', app['name'] ?? ''),
                    _buildInfoRow('학번', app['studentId'] ?? ''),
                    _buildInfoRow('학년', app['grade'] ?? ''),
                    _buildInfoRow('이메일', app['email'] ?? ''),
                    _buildInfoRow('전화번호', app['phoneNumber'] ?? ''),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoCard('지원 정보', [
                    _buildInfoRow('휴학 계획', app['leavePlan'] ?? ''),
                    _buildInfoRow('운영진 활동 기간', app['period'] ?? ''),
                    _buildInfoRow('지원 동기', app['motivation'] ?? '', isLongText: true),
                    _buildInfoRow('운영진 활동 목표', app['goal'] ?? '', isLongText: true),
                    _buildInfoRow('위기 극복 경험', app['crisis'] ?? '', isLongText: true),
                    _buildInfoRow('회의 참석', app['meeting'] ?? ''),
                    _buildInfoRow('각오 한 마디', app['resolution'] ?? ''),
                    _buildInfoRow('개인정보 동의', app['privacy'] ?? ''),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoCard('상태 정보', [
                    _buildInfoRow('상태', _getStatusText(app['status'] ?? 'PENDING')),
                    _buildInfoRow('등록일', _formatDate(app['createdAt'])),
                  ]),
                ],
              ),
            ),
    );
  }
} 