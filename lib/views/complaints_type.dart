import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// --- صفحة عرض الشكاوى المحدثة ---
class ComplaintsListScreen extends StatefulWidget {
  final String filterTitle;
  const ComplaintsListScreen({super.key, required this.filterTitle});

  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  List complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    // استخدمي 10.0.2.2 للمحاكي أو IP جهازك الفعلي
    final url = Uri.parse('http://10.0.2.2:8000/api/complaints');
    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          // "Authorization": "Bearer YOUR_TOKEN" // أضيفي التوكن إذا كان الموظف مسجل دخول
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          // تعديل هام: الوصول للمصفوفة داخل مفتاح 'data'
          complaints = responseData['data'] ?? [];

          // يمكنك هنا إضافة منطق الفلترة بناءً على widget.filterTitle
          // مثلاً: إذا كان العنوان "قيد المعالجة" نعرض فقط status == 'Processing'

          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error fetching complaints: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.filterTitle,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.teal,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.teal))
            : complaints.isEmpty
            ? const Center(child: Text("لا توجد شكاوى حالياً"))
            : ListView.builder(
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  final item = complaints[index];
                  return ComplaintCard(
                    // تعديل الأسماء لتطابق قاعدة البيانات (full_name و title)
                    id: item['complain_number'] ?? item['id'].toString(),
                    title: item['title'] ?? 'بدون عنوان',
                    status: item['status'] ?? 'قيد الانتظار',
                    fullName: item['full_name'] ?? 'مستخدم غير معروف',
                  );
                },
              ),
      ),
    );
  }
}

// كود الكارد (البطاقة) المعدل
class ComplaintCard extends StatelessWidget {
  final String id, title, status, fullName;

  const ComplaintCard({
    super.key,
    required this.id,
    required this.title,
    required this.status,
    required this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "#$id",
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(fullName, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
            const Divider(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // منطق الرد
                },
                icon: const Icon(Icons.reply, color: Colors.white),
                label: const Text(
                  "فتح التفاصيل والرد",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'closed':
        color = Colors.green;
        break;
      default:
        color = Colors.cyan;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
