import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'home_page.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../event/presentation/pages/event_page.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // 🔴 Khai báo mảng chứa các trang cố định
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // 🔴 KHỞI TẠO TRANG MỘT LẦN DUY NHẤT: Giữ chặt liên kết hàm callback không bị mất khi setState
    _pages = [
      HomePage(
        onAvatarPressed: () =>
            _onNavItemTapped(3), // Trỏ thẳng về tab Profile (Index = 3)
      ),
      const MapPage(),
      const EventPage(),
      const ProfilePage(),
    ];
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng IndexedStack thay vì mảng trơn để giữ nguyên trạng thái cuộn của các trang khi đổi tab
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ================= TOÀN BỘ UI THANH ĐÁY GIỮ NGUYÊN 100% =================
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                index: 0,
                activeColor: const Color(0xFF00CC00),
              ),
              _buildNavItem(
                icon: Icons.location_on_rounded,
                index: 1,
                activeColor: Colors.red,
              ),
              _buildNavItem(
                icon: Icons.local_fire_department_rounded,
                index: 2,
                activeColor: Colors.red,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                index: 3,
                activeColor: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required Color activeColor,
  }) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 230),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive
                  ? activeColor
                  : AppColors.textSecondary.withOpacity(0.4),
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}
