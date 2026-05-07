import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'complaints_type.dart';

class AddComplaintPage extends StatefulWidget {
  @override
  _AddComplaintPageState createState() => _AddComplaintPageState();
}

class _AddComplaintPageState extends State<AddComplaintPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // متغيرات الاختيار
  int? _selectedAuthorityId;
  int? _selectedDepartmentId;

  // حالات التحميل والبيانات
  bool _isLoading = false;
  bool _isFetching = true;
  String? _userToken;

  List<dynamic> _authorities = []; // قائمة الجهات
  List<dynamic> _filteredDepartments = []; // الأقسام التابعة للجهة المختارة

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // 1. تحميل التوكن والبيانات الأساسية
  Future<void> _loadInitialData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userToken = prefs.getString('token');
    _usernameController.text = prefs.getString('username') ?? "";
    await _fetchAuthorities();
  }

  // 2. جلب الجهات (Authorities) من السيرفر
  Future<void> _fetchAuthorities() async {
    const String authUrl = "http://192.168.10.235:8000/api/authorities";
    try {
      final response = await http.get(
        Uri.parse(authUrl),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $_userToken", // إرسال التوكن المطلوب
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            _authorities = responseData['data'];
            _isFetching = false;
          });
        }
      } else {
        throw Exception("فشل جلب البيانات من السيرفر");
      }
    } catch (e) {
      setState(() => _isFetching = false);
      _showSnackBar("خطأ في الاتصال: $e");
    }
  }

  // 3. إرسال الشكوى
  Future<void> _submitComplaint() async {
    if (_usernameController.text.isEmpty ||
        _titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedAuthorityId == null ||
        _selectedDepartmentId == null) {
      _showSnackBar("يرجى ملء جميع الحقول واختيار الجهة والقسم");
      return;
    }

    setState(() => _isLoading = true);

    const String apiUrl = "http://192.168.10.235:8000/api/complaints";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $_userToken",
        },
        body: jsonEncode({
          "full_name": _usernameController.text,
          "title": _titleController.text,
          "description": _descriptionController.text,
          "authority_id": _selectedAuthorityId,
          "department_id": _selectedDepartmentId,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || responseData['success'] == true) {
        _showSnackBar(
          "تم تقديم الشكوى بنجاح برقم: ${responseData['data']['complain_number']}",
        );
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => 
            ), // اسم الكلاس في ملف complaints_type.dart
          );
        });
      } else {
        throw Exception(responseData['message'] ?? "فشل إرسال الشكوى");
      }
    } catch (e) {
      _showSnackBar("حدث خطأ: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F7FA),
      appBar: AppBar(
        title: Text("تقديم شكوى جديدة", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF00796B),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isFetching
          ? Center(child: CircularProgressIndicator(color: Color(0xFF00796B)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _inputField(
                    _usernameController,
                    "اسم المستخدم",
                    Icons.person_outline,
                  ),
                  _inputField(_titleController, "عنوان الشكوى", Icons.title),
                  _inputField(
                    _descriptionController,
                    "تفاصيل الشكوى",
                    Icons.description,
                    maxLines: 4,
                  ),

                  // القائمة المنسدلة للجهة (Authority)
                  _buildDropdown(
                    hint: "اختر الجهة المعنية",
                    value: _selectedAuthorityId,
                    items: _authorities,
                    onChanged: (val) {
                      setState(() {
                        _selectedAuthorityId = val;
                        _selectedDepartmentId =
                            null; // إعادة تعيين القسم عند تغيير الجهة
                        // فلترة الأقسام بناءً على الجهة المختارة
                        var selectedAuth = _authorities.firstWhere(
                          (a) => a['id'] == val,
                        );
                        _filteredDepartments = selectedAuth['departments'];
                      });
                    },
                  ),

                  // القائمة المنسدلة للقسم (Department)
                  _buildDropdown(
                    hint: "اختر القسم الموجه إليه الشكوى",
                    value: _selectedDepartmentId,
                    items: _filteredDepartments,
                    enabled: _selectedAuthorityId != null,
                    onChanged: (val) {
                      setState(() => _selectedDepartmentId = val);
                    },
                  ),

                  SizedBox(height: 30),
                  _buildSubmitButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required int? value,
    required List<dynamic> items,
    required Function(int?) onChanged,
    bool enabled = true,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          disabledHint: Text(hint),
          items: items.map((item) {
            return DropdownMenuItem<int>(
              value: item['id'],
              child: Text(item['name'], textAlign: TextAlign.right),
            );
          }).toList(),
          onChanged: enabled ? (val) => onChanged(val) : null,
        ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: Icon(icon, color: Color(0xFF00796B)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitComplaint,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF00796B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                "إرسال الشكوى",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }
}
