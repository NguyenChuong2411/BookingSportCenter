import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/pages/main_scaffold.dart';
import 'login_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Để dùng kIsWeb
import '../../../../core/utils/user_session.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // 5 Controllers cho 5 trường thông tin Backend yêu cầu
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false; // Biến tạo hiệu ứng xoay loading

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ======================================================================
  // HÀM XỬ LÝ ĐĂNG KÝ VÀ TỰ ĐỘNG ĐĂNG NHẬP
  // ======================================================================
  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    // 1. Validate sơ bộ
    if (username.isEmpty ||
        fullName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Bật xoay vòng loading
    });

    // 2. Chuyển đổi link API Web/Mobile cho Đăng ký
    final String registerUrl = kIsWeb
        ? 'http://localhost:5236/api/Auth/register'
        : 'http://10.0.2.2:5236/api/Auth/register';

    try {
      // CÚ ĐẤM 1: GỌI API ĐĂNG KÝ
      final registerResponse = await http.post(
        Uri.parse(registerUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'fullName': fullName,
          'email': email,
          'phoneNumber': phone,
          'password': password,
        }),
      );

      if (!mounted) return;

      if (registerResponse.statusCode == 200) {
        // CÚ ĐẤM 2: ÂM THẦM GỌI TIẾP API ĐĂNG NHẬP
        final String loginUrl = kIsWeb
            ? 'http://localhost:5236/api/Auth/login'
            : 'http://10.0.2.2:5236/api/Auth/login';

        final loginResponse = await http.post(
          Uri.parse(loginUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'email': email, 'password': password}),
        );

        if (!mounted) return;

        if (loginResponse.statusCode == 200) {
          final loginData = jsonDecode(loginResponse.body);
          UserSession.saveSession(loginData['user']);
          // Thành công cả 2 bước!
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Đăng ký thành công! Đang vào trang chủ...'),
              backgroundColor: Colors.green,
            ),
          );

          // Chuyển hướng thẳng sang MainScaffold
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScaffold()),
          );
        } else {
          // Đăng ký OK nhưng lỗi lúc auto-login -> Đá về trang Đăng nhập
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đăng ký thành công! Vui lòng đăng nhập lại.'),
              backgroundColor: Colors.blue,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      } else {
        // Lỗi từ Backend (Trùng Email, trùng Username...)
        final errorData = jsonDecode(registerResponse.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: ${errorData['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Không thể kết nối đến máy chủ!'),
          backgroundColor: Colors.orange,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Tắt loading
        });
      }
    }
  }
  // ======================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER GRADIENT TƯƠNG TỰ TRANG LOGIN
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF0000FF), Color(0xFF0000CC)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 25,
                  left: 36,
                  child: Container(
                    width: 105,
                    height: 105,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/logo.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),

            // PHẦN FORM NHẬP LIỆU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Sign up to start booking with SpotOn",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // 1. Username
                  _buildInputFieldLabel("Username"),
                  _buildTextField(
                    controller: _usernameController,
                    hintText: "Enter username",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  // 2. Full Name
                  _buildInputFieldLabel("Full Name"),
                  _buildTextField(
                    controller: _fullNameController,
                    hintText: "Enter your full name",
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 16),

                  // 3. Email
                  _buildInputFieldLabel("Email Address"),
                  _buildTextField(
                    controller: _emailController,
                    hintText: "Enter your email",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),

                  // 4. Phone Number
                  _buildInputFieldLabel("Phone Number"),
                  _buildTextField(
                    controller: _phoneController,
                    hintText: "Enter phone number",
                    icon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 16),

                  // 5. Password
                  _buildInputFieldLabel("Password"),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: "Create a password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onSuffixIconTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  const SizedBox(height: 32),

                  // NÚT SIGN UP
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0000FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ĐÃ CÓ TÀI KHOẢN -> QUAY LẠI ĐĂNG NHẬP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            color: Color(0xFF0000FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ), // Đệm thêm dưới cùng cho đỡ sát viền
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CÁC WIDGET DÙNG CHUNG (Tương tự LoginPage)
  Widget _buildInputFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onSuffixIconTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black26),
          prefixIcon: Icon(icon, color: const Color(0xFF0000FF), size: 20),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: onSuffixIconTap,
                )
              : null,
        ),
      ),
    );
  }
}
