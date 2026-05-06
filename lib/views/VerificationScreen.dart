import 'package:flutter/material.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // تعريف المتحكمات لكل خانة من الرمز
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA), // لون الخلفية الفاتح كما في الصورة
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // أيقونة المغلف الملونة
              const Center(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Icon(Icons.mail, size: 120, color: Color(0xFFFFC107)), // لون المغلف الأصفر
                    Positioned(
                      top: 10,
                      child: Icon(Icons.arrow_downward, size: 45, color: Color(0xFF2196F3)), // السهم الأزرق
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "التحقق من الحساب",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF00796B)),
              ),
              const SizedBox(height: 15),
              const Text(
                "يرجى إدخال الرمز المكون من 6 أرقام المرسل إلى هاتفك",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              
              // حقول إدخال الرمز الستة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) => _otpTextField(index)),
              ),
              
              const SizedBox(height: 40),
              
              // زر تأكيد الرمز
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    String code = _controllers.map((e) => e.text).join();
                    print("الرمز المدخل: $code");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "تأكيد الرمز",
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              const SizedBox(height: 25),
              
              // خيار إعادة الإرسال
              TextButton(
                onPressed: () {},
                child: const Text(
                  "لم يصلك الرمز؟ إعادة إرسال",
                  style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت مخصصة لكل خانة رقم
  Widget _otpTextField(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
          hintText: "0",
          hintStyle: TextStyle(color: Colors.grey),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus(); // الانتقال التلقائي للخانة التالية
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus(); // العودة للخلف عند المسح
          }
        },
      ),
    );
  }
}