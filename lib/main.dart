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
        fontFamily: 'Cairo', // تأكدي من إضافة الخط في pubspec.yaml
      ),
      home: const EmployeeDashboard(),
    );
  }
}

// --- لوحة تحكم الموظف ---
class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'لوحة تحكم الموظف',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // عند الضغط هنا سينتقل لصفحة الشكاوى
              _buildCard(context, 'الشكاوى الجديدة', Colors.blue),
              _buildCard(context, 'قيد المعالجة', Colors.orange),
              _buildCard(context, 'الشكاوى المغلقة', Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, Color accentColor) {
    return InkWell(
      onTap: () {
        // الانتقال لصفحة الشكاوى مع تمرير العنوان
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComplaintsListScreen(filterTitle: title),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 100,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(15),
          border: Border(right: BorderSide(color: accentColor, width: 5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// --- صفحة عرض الشكاوى (تم دمجها وتعديلها لتناسب الـ IP الجديد) ---
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
    // تم تحديث الـ IP ليتوافق مع جهازك (تأكدي من تشغيل السيرفر بنفس الـ IP)
    final url = Uri.parse('http://192.168.1.104:8000/api/complaints');
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
      debugPrint("Error fetching complaints: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.filterTitle),
          backgroundColor: Colors.teal,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : complaints.isEmpty
            ? const Center(child: Text("لا توجد شكاوى حالياً"))
            : ListView.builder(
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  final item = complaints[index];
                  return ComplaintCard(
                    id: item['id'].toString(),
                    type: item['type'] ?? 'غير محدد',
                    status: item['status'] ?? 'جديدة',
                    userName: item['user_name'] ?? 'مستخدم غير معروف',
                  );
                },
              ),
      ),
    );
  }
}

// كود الكارد (البطاقة)
class ComplaintCard extends StatelessWidget {
  final String id, type, status, userName;

  const ComplaintCard({
    super.key,
    required this.id,
    required this.type,
    required this.status,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "#$id",
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "نوع الشكوى: $type",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "بواسطة: $userName",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // الربط مع الشات لاحقاً
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "الرد على الشكوى",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
