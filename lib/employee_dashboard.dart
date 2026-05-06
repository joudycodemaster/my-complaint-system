import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نظام إدارة الشكاوى الذكي',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Cairo', // تأكد من إضافة الخط في pubspec.yaml
      ),
      home: const EmployeeDashboard(),
    );
  }
}

// --- 1. لوحة تحكم الموظف (Dashboard) ---
class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'لوحة تحكم الموظف',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 1. كرت الشكاوى الجديدة
              _buildDashboardItem(
                context,
                title: 'الشكاوى الجديدة',
                icon: Icons.notifications_active_outlined,
                color: Colors.blueAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ComplaintsListScreen(
                        filterTitle: 'الشكاوى الجديدة',
                      ),
                    ),
                  );
                },
              ),Navigator.push(
                     context,
  MaterialPageRoute(
    builder: (context) => const ResolvedComplaintDetailsScreen(
      complaintData: {
        'id': 1,
        'type': 'مشكلة إنترنت',
        'user_name': 'أحمد',
      },
    ),
  ),
);

              // 2. كرت قيد المعالجة
              _buildDashboardItem(
                context,
                title: 'قيد المعالجة',
                icon: Icons.pending_actions_outlined,
                color: Colors.orangeAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ComplaintsListScreen(
                        filterTitle: 'قيد المعالجة',
                      ),
                    ),
                  );
                },
              ),

              // 3. كرت الشكاوى المغلقة
              _buildDashboardItem(
                context,
                title: 'الشكاوى المغلقة',
                icon: Icons.check_circle_outline,
                color: Colors.greenAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ResolvedComplaintDetailsScreen(
                            complaintData: {
                              'id': '10890',
                              'type': 'مشكلة في التكييف',
                              'user_name': 'خالد محمد',
                              'status': 'تم الحل',
                              'date': '2023-10-25',
                            },
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFD),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 15),
                Icon(icon, color: color.withOpacity(0.7), size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- 2. صفحة عرض الشكاوى (المربوطة بـ Laravel) ---
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
    final url = Uri.parse('http:///192.168.1.8:8000/api/complaints');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          complaints = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("خطأ في الاتصال بالباك إند: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(
            widget.filterTitle,
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  final item = complaints[index];
                  return _buildComplaintCard(item);
                },
              ),
      ),
    );
  }

  Widget _buildComplaintCard(Map item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['status'] ?? "قيد المعالجة",
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "#${item['id'] ?? '10582'}",
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              "نوع الشكوى: ${item['type'] ?? 'تحديث نظام البصمة'}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "بواسطة: ${item['user_name'] ?? 'سارة علي'}",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "الرد على الشكوى",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 3. صفحة تفاصيل الشكوى المغلقة (تجريبية) ---
class ResolvedComplaintDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> complaintData;
  const ResolvedComplaintDetailsScreen({
    super.key,
    required this.complaintData,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "تفاصيل الشكوى المغلقة",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                Text(
                  "رقم الشكوى: ${complaintData['id']}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "النوع: ${complaintData['type']}",
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  "الحالة: ${complaintData['status']}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "التاريخ: ${complaintData['date']}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("رجوع للوحة التحكم"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
