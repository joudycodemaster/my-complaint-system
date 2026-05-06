import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ComplaintsByStatusScreen extends StatefulWidget {
  final String status;
  final String title;

  const ComplaintsByStatusScreen({
    super.key,
    required this.status,
    required this.title,
  });

  @override
  State<ComplaintsByStatusScreen> createState() =>
      _ComplaintsByStatusScreenState();
}

class _ComplaintsByStatusScreenState extends State<ComplaintsByStatusScreen> {
  List complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/complaints');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      List data = json.decode(response.body);

      setState(() {
        // ✅ الفلترة
        complaints = data.where((item) {
          return item['status'] == widget.status;
        }).toList();

        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : complaints.isEmpty
            ? const Center(child: Text("لا يوجد شكاوى"))
            : ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  final item = complaints[index];
                  return _complaintCard(item);
                },
              ),
      ),
    );
  }

  // 🎨 تصميم الكارد مثل الصورة
  Widget _complaintCard(Map item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الحالة + الرقم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['status'] ?? '',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "#${item['id']}",
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // نوع الشكوى
          Text(
            "نوع الشكوى: ${item['type']}",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          // اسم المستخدم
          Text(
            "بواسطة: ${item['user_name']}",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
