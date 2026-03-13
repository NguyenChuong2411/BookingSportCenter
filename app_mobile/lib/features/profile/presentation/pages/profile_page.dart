import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/user_profile.dart';
import '../widgets/profile_menu_item.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Mock user data - Replace with actual user data from authentication
  late final UserProfile _currentUser;

  @override
  void initState() {
    super.initState();
    // TODO: Get actual user from authentication service
    _currentUser = UserProfile(
      id: '123e4567-e89b-12d3-a456-426614174000',
      username: 'john.doe',
      email: 'john.doe@example.com',
      fullName: 'John Doe',
      phoneNumber: '+1234567890',
      avatarUrl: null, // No avatar URL - will show initials
      role: 'Customer',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                child: _currentUser.avatarUrl != null
                    ? Image.network(
                        _currentUser.avatarUrl!,
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
              _currentUser.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            // Email
            Text(
              _currentUser.email,
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
          _currentUser.initials,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
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
        borderRadius: BorderRadius.circular(12),
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
              // TODO: Navigate to My Booking page
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
              // TODO: Navigate to Edit Profile page
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
              // TODO: Navigate to Settings page
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
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            // TODO: Implement logout - redirect to login page (will be implemented later)
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
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Logout - Login page will be implemented later',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Log out',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Log out',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
