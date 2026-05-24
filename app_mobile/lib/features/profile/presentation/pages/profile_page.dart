import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_api_service.dart';
import '../../data/models/user_profile_model.dart';
import '../../domain/entities/user_profile.dart';
import '../widgets/profile_menu_item.dart';
import 'edit_profile_page.dart';
import 'my_booking_page.dart';
import '../../../auth/presentation/pages/start_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await AuthApiService.getProfile();
      final profile = UserProfileModel.fromJson(data);
      if (mounted) {
        setState(() {
          _currentUser = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? _buildErrorState()
                : SingleChildScrollView(
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
        // ← THÊM PADDING TẠI ĐÂY
        padding: const EdgeInsets.only(top: 20), // Padding trái/phải
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
                child: _currentUser?.avatarUrl != null
                    ? Image.network(
                        _currentUser!.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildInitials();
                        },
                      )
                    : _buildInitials(),
              ),
            ),
            const SizedBox(height: 16),
            // Full name
            Text(
              _currentUser?.fullName ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            // Email
            Text(
              _currentUser?.email ?? '',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitials() {
    return Container(
      color: AppColors.primaryBlue.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          _currentUser?.initials ?? '?',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage ?? 'Failed to load profile',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadProfile, child: const Text('Retry')),
          ],
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyBookingPage()),
              );
            },
          ),
          Divider(height: 1, color: Colors.grey[200]),
          ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Edit profile',
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(profile: _currentUser),
                ),
              );
              if (result == true) {
                _loadProfile();
              }
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
        height:
            54, // Tăng nhẹ lên 54 cho đồng bộ chiều cao với bộ nút của StartPage
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

                      // 2. ĐIỀU HƯỚNG BẢO MẬT: Xóa sạch toàn bộ Stack và quay về StartPage đầu tiên
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StartPage(),
                        ),
                        (route) =>
                            false, // Ép không cho người dùng bấm Back để quay lại màn hình Profile nữa
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
            // Custom lại UI: Nút Đăng xuất dùng nền xám/đỏ nhạt, chữ đỏ để phân biệt với các nút hành động chính
            backgroundColor: Colors.grey.shade100,
            foregroundColor: Colors.redAccent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                27,
              ), // Bo tròn đối xứng hoàn hảo dạng Capsule giống StartPage
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                size: 20,
              ), // Thêm cái icon logout nhìn cho sinh động chuyên nghiệp
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
