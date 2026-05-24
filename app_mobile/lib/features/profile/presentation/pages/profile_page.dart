import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/profile_menu_item.dart';
import '../../../auth/presentation/pages/start_page.dart';
import '../../../../core/utils/user_session.dart'; // 🔴 IMPORT KHO DỮ LIỆU

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ĐÃ XÓA MOCK DATA VÀ INIT STATE VÌ GIỜ MÌNH DÙNG DỮ LIỆU THẬT TỪ USERSESSION

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  _buildUserInfo(),
                  const SizedBox(height: 32),
                  _buildMenuItems(),
                  const SizedBox(height: 32),
                  _buildLogoutButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 48, bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0000FF), Color(0xFF0000CC)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(45),
          bottomRight: Radius.circular(45),
        ),
      ),
      child: const Text(
        'Profile',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textWhite,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Transform.translate(
      offset: const Offset(0, -60),
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                // Hiện tại chưa có link ảnh từ Backend nên mình dùng luôn Avatar chữ cái
                child: _buildInitials(),
              ),
            ),
            const SizedBox(height: 16),

            // 🔴 LẤY TÊN THẬT TỪ HỆ THỐNG
            Text(
              UserSession.fullName ?? "Người dùng",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // 🔴 LẤY EMAIL THẬT TỪ HỆ THỐNG
            Text(
              UserSession.email ?? "Chưa cập nhật email",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tạo Avatar chữ cái động
  Widget _buildInitials() {
    // Lấy chữ cái đầu tiên của tên, nếu lỗi thì để chữ "U"
    final String initial =
        (UserSession.fullName != null && UserSession.fullName!.isNotEmpty)
        ? UserSession.fullName![0].toUpperCase()
        : "U";

    return Container(
      color: const Color(0xFF0000FF).withValues(alpha: 0.1), // Nền xanh nhạt
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0000FF), // Chữ xanh đậm
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileMenuItem(
            icon: Icons.calendar_today,
            title: 'My Booking',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('My Booking - Coming soon')),
              );
            },
          ),
          Divider(height: 1, color: Colors.grey[200]),
          ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Edit profile',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile - Coming soon')),
              );
            },
          ),
          Divider(height: 1, color: Colors.grey[200]),
          ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'Setting',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings - Coming soon')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Log out'),
                content: const Text('Are you sure you want to log out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      // 1. Tắt hộp thoại Alert Dialog
                      Navigator.pop(context);

                      // 2. 🔴 XÓA SẠCH DỮ LIỆU PHIÊN ĐĂNG NHẬP
                      UserSession.clearSession();

                      // 3. ĐIỀU HƯỚNG BẢO MẬT: Xóa sạch toàn bộ Stack và quay về StartPage
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StartPage(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Log out',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            foregroundColor: Colors.redAccent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                'Log out',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
