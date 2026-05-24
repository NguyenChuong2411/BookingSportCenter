import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_api_service.dart';
import '../../../../core/services/booking_api_service.dart';
import '../../../home/presentation/pages/main_scaffold.dart';
import 'sign_up_page.dart';
import 'start_page.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Thư viện xử lý đọc logo SVG độc quyền

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController(
    text: "minhsang@uit.edu.vn",
  );
  final TextEditingController _passwordController = TextEditingController(
    text: "123456",
  );
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password are required")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthApiService.login(
        email: email,
        password: password,
      );

      final token = response['token']?.toString();
      if (token == null || token.isEmpty) {
        throw Exception("Token not returned from server");
      }

      BookingApiService.setJwtToken(token);
      AuthApiService.setJwtToken(token);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScaffold()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER GRADIENT THIẾT KẾ PHÁ CÁCH THEO MOCKUP ĐÚNG TỶ LỆ PIXEL
            Stack(
              clipBehavior:
                  Clip.none, // Cho phép hộp logo phình rộng vượt khung
              children: [
                // Khối nền xanh dương chủ đạo phía sau
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

                // Khối chữ nhật trắng to nằm lọt lòng sát đáy nền xanh dương, bo 2 góc trên
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

                // Hộp vuông trắng bo tròn 4 góc đặt lệch trái đè lên khối chữ nhật, chứa logo SpotOn
                Positioned(
                  bottom: 25,
                  left: 36,
                  child: Container(
                    width: 105,
                    height: 105,
                    padding: const EdgeInsets.all(
                      12,
                    ), // Tạo khoảng đệm cho logo SVG sắc nét
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

            // PHẦN THÂN GIAO DIỆN NHẬP LIỆU (FORM TEXTFIELD)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Sign in to continue booking your favorite pitch",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // 2. Ô NHẬP EMAIL ADDRESS
                  _buildInputFieldLabel("Email Address"),
                  _buildTextField(
                    controller: _emailController,
                    hintText: "Enter your email",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),

                  // 3. Ô NHẬP PASSWORD
                  _buildInputFieldLabel("Password"),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: "Enter your password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onSuffixIconTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),

                  // Nút bấm Quên mật khẩu
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Color(0xFF0000FF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. BỘ NÚT ĐĂNG NHẬP (SIGN IN)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0000FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Khối chuyển hướng sang trang Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Color(0xFF0000FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            color: Colors.black.withOpacity(0.2),
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
