import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_page.dart';
import 'sign_up_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Đồng bộ màu nền xanh đậm (1B15FF) cho toàn bộ màn hình phía sau
      backgroundColor: const Color(0xff1B15FF),
      body: Column(
        children: [
          // ================= 1. KHOẢNG TRỐNG NỀN XANH PHÍA TRÊN =================
          const SizedBox(height: 100),

          // ================= 2. KHỐI TRẮNG BO TRÒN CHỨA NỘI DUNG CHÍNH =================
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white, // Khối chữ nhật màu trắng tinh khôi
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    250,
                  ), // Bo tròn góc trên bên trái cực sâu tạo đường cong bán nguyệt
                  topRight: Radius.circular(
                    250,
                  ), // Bo tròn góc trên bên phải đồng bộ
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Khoảng trống lớn phía trên để đẩy Logo xuống một khoảng hợp lý so với đỉnh vòm
                    const Spacer(flex: 1),

                    // 1. CỤM TRUNG TÂM: BÂY GIỜ CHỈ CÒN ĐỘC NHẤT LOGO SVG
                    SvgPicture.asset(
                      'assets/icons/logo.svg',
                      width: 300,
                      fit: BoxFit.contain,
                    ),

                    // Khoảng trống lớn ở giữa để ép Slogan và bộ nút nằm im sát đáy màn hình
                    const Spacer(flex: 3),

                    // 2. KHỐI ĐÁY: GỒM SLOGAN NẰM TRÊN BỘ ĐÔI NÚT BẤM
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ĐƯA CÂU SLOGAN XUỐNG ĐÂY (NẰM NGAY TRÊN NÚT SIGN IN)
                        const Text(
                          "Spot On - Your Field, Your Time.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xff1B15FF),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ), // Khoảng cách từ Slogan xuống nút Sign in
                        // NÚT SIGN IN
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1B15FF),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                            child: const Text(
                              "Sign in",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // NÚT SIGN UP
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xff1B15FF),
                                width: 1.2,
                              ),
                              foregroundColor: const Color(0xff1B15FF),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
                              ),
                            ),
                            child: const Text(
                              "Sign up",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
