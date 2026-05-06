import 'package:flutter/material.dart';

class ResolvedComplaintDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> complaintData;

  const ResolvedComplaintDetailsScreen({
    super.key,
    required this.complaintData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              '#${complaintData['id']}',
              style: const TextStyle(
                color: Color(0xFF00A38C),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.end, // للبدء من اليمين (العربية)
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'تم الحل',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'نوع الشكوى: ${complaintData['type']}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 10),
            Text(
              'بواسطة: ${complaintData['user_name']}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.right,
            ),
            const Divider(height: 40),
            // هنا يمكنك إضافة وصف الشكوى أو الرد الذي تم
          ],
        ),
      ),
    );
  }
}
