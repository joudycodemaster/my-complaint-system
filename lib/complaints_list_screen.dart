import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ComplaintsListScreen extends StatefulWidget {
  @override
  _ComplaintsListScreenState createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  // مصفوفة لتخزين الشكاوى القادمة من اللارفيل
  List complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  // دالة جلب البيانات من الباك إند
  Future<void> fetchComplaints() async {
    // استبدل الـ IP بـ IP جهازك أو رابط السيرفر
    final url = Uri.parse('http://10.0.2.2:8000/api/complaints');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          complaints = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching complaints: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لدعم اللغة العربية
      child: Scaffold(
        appBar: AppBar(title: Text("الشكاوى"), backgroundColor: Colors.teal),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  final item = complaints[index];
                  return ComplaintCard(
                    id: item['id'].toString(),
                    type: item['type'],
                    status: item['status'],
                    userName: item['user_name'],
                  );
                },
              ),
      ),
    );
  }
}

// كود الكارد (البطاقة) المنفصلة
class ComplaintCard extends StatelessWidget {
  final String id, type, status, userName;

  ComplaintCard({
    required this.id,
    required this.type,
    required this.status,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
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
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: Colors.cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "#$id",
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              "نوع الشكوى: $type",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "بواسطة: $userName",
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // سيتم فتح الشات المخصص لكل شكوى هنا
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
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
