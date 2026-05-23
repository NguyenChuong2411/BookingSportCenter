import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/court.dart';
import '../../domain/entities/user.dart';
import '../widgets/booking_card.dart';
import '../widgets/court_card.dart';
import '../widgets/date_selector.dart';
import 'package:booking_sport/features/booking/presentation/pages/select_slots_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onAvatarPressed;

  const HomePage({super.key, this.onAvatarPressed});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _selectedDate;

  final User _user = User(
    id: '1',
    name: 'Minh Sang',
    email: 'minhsang@example.com',
  );

  final List<Booking> _bookings = [
    Booking(
      id: '1',
      courtName: 'Fusing\nMeadows',
      location: 'Location 1',
      date: DateTime(2026, 10, 21),
      time: '14:00 - 16:00',
      rating: 4.5,
      sportType: 'Football',
    ),
    Booking(
      id: '2',
      courtName: 'Gran\nSlam Grass',
      location: 'Location 2',
      date: DateTime(2026, 10, 21),
      time: '14:00',
      rating: 4.0,
      sportType: 'Tennis',
    ),
  ];

  final List<Court> _availableCourts = [
    Court(
      id: '1',
      name: 'Thanh Phat Football Pitch',
      location: 'Tan Phu',
      address: '123 Luy Ban Bich, Tan Phu, HCMC',
      rating: 4.0,
      reviewCount: 120,
      sportType: 'Football',
      imageUrl: '',
      availableDates: [],
    ),
    Court(
      id: '2',
      name: 'Thanh Phat Football Pitch',
      location: 'Tan Phu',
      address: '123 Luy Ban Bich, Tan Phu, HCMC',
      rating: 4.0,
      reviewCount: 120,
      sportType: 'Football',
      imageUrl: '',
      availableDates: [],
    ),
    Court(
      id: '3',
      name: 'Thanh Phat Football Pitch',
      location: 'Tan Phu',
      address: '123 Luy Ban Bich, Tan Phu, HCMC',
      rating: 4.0,
      reviewCount: 120,
      sportType: 'Football',
      imageUrl: '',
      availableDates: [],
    ),
    Court(
      id: '4',
      name: 'Thanh Phat Football Pitch',
      location: 'Tan Phu',
      address: '123 Luy Ban Bich, Tan Phu, HCMC',
      rating: 4.0,
      reviewCount: 120,
      sportType: 'Football',
      imageUrl: '',
      availableDates: [],
    ),
  ];

  List<DateTime> _generateDates() {
    final now = DateTime.now();
    return List.generate(14, (index) => now.add(Duration(days: index)));
  }

  // Hàm bổ trợ đổi số tháng sang chữ tiếng Anh
  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  // Hàm quét mảng 14 ngày để trả về chuỗi tên tháng (Xử lý được cả trường hợp giao giữa 2 tháng)
  String _getAvailableMonthsString() {
    final dates = _generateDates();
    if (dates.isEmpty) return '';

    final firstMonth = dates.first.month;
    final lastMonth = dates.last.month;

    if (firstMonth == lastMonth) {
      return _getMonthName(firstMonth); // Ví dụ: "May"
    } else {
      return '${_getMonthName(firstMonth)} - ${_getMonthName(lastMonth)}'; // Ví dụ: "May - June"
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          SliverToBoxAdapter(child: _buildYourBookingsSection()),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          _buildAvailableCourtsHeader(),

          _buildAvailableCourtsList(),

          const SliverFillRemaining(hasScrollBody: false, child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔴 BỌC AVATAR BẰNG INKWELL ĐỂ TẠO HIỆU ỨNG GỢN SÓNG VÀ CHUYỂN TRANG
              InkWell(
                onTap: () {
                  // 🔴 KÍCH HOẠT HÀM ĐỔI TAB CỦA CHA TRUYỀN XUỐNG
                  if (widget.onAvatarPressed != null) {
                    widget.onAvatarPressed!();
                  }
                },
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.textSecondary,
                    size: 30,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                AppStrings.hello,
                style: TextStyle(fontSize: 24, color: AppColors.textWhite),
              ),

              const SizedBox(height: 4),

              Text(
                _user.name,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYourBookingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.yourBookings,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  AppStrings.seeAll,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _bookings.length,
            itemBuilder: (context, index) {
              return BookingCard(booking: _bookings[index], onTap: () {});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableCourtsHeader() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryGreen.withValues(alpha: 0.9),
              const Color(0xFF00DD00),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(45),
            topRight: Radius.circular(45),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.availableCourtNearYou,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
              ),

              const SizedBox(height: 8),

              // 🔴 CẬP NHẬT: Thay chuỗi tĩnh bằng chuỗi động kết hợp tên tháng thời gian thực
              Text(
                "${AppStrings.selectTheDaysAvailable} in ${_getAvailableMonthsString()}"
                    .toUpperCase(),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textWhite,
                ),
              ),

              const SizedBox(height: 16),

              DateSelector(
                dates: _generateDates(),
                selectedDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableCourtsList() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryGreen.withValues(alpha: 0.9),
              const Color(0xFF00DD00),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: _availableCourts.map((court) {
            return CourtCard(
              court: court,
              onBookNow: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SelectSlotsPage(),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
