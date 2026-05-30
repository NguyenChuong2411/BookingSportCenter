import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/court.dart';
import '../../domain/entities/user.dart';
import '../../../../core/services/auth_api_service.dart';
import '../../../../core/services/booking_api_service.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../../../profile/presentation/pages/my_booking_page.dart';
import '../widgets/booking_card.dart';
import '../widgets/court_card.dart';
import '../widgets/date_selector.dart';
import 'package:booking_sport/features/booking/presentation/pages/select_slots_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onAvatarPressed;

  const HomePage({super.key, this.onAvatarPressed});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _selectedDate;

  User? _user;
  bool _isLoadingUser = true;
  bool _isLoadingCourts = true;
  bool _isLoadingBookings = true;
  String? _courtsErrorMessage;
  String? _bookingsErrorMessage;
  List<Court> _availableCourts = [];
  List<Booking> _bookings = [];
  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadAvailableCourts();
    _loadBookings();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoadingUser = true;
    });

    try {
      final data = await AuthApiService.getProfile();
      final profile = UserProfileModel.fromJson(data);
      if (mounted) {
        setState(() {
          _user = User(
            id: profile.id,
            name: profile.fullName,
            email: profile.email,
            profileImage: profile.avatarUrl,
          );
          _isLoadingUser = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  Future<void> _loadAvailableCourts() async {
    setState(() {
      _isLoadingCourts = true;
      _courtsErrorMessage = null;
    });

    try {
      final data = await BookingApiService.getAvailableCenters();
      final courts = data.map(_mapCenterToCourt).toList();
      if (mounted) {
        setState(() {
          _availableCourts = courts;
          _isLoadingCourts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _courtsErrorMessage = e.toString();
          _isLoadingCourts = false;
        });
      }
    }
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoadingBookings = true;
      _bookingsErrorMessage = null;
    });

    try {
      final data = await BookingApiService.getMyBookings();
      final bookingItems = data.map(_BookingItem.fromJson).toList();
      final courtNames = await _loadCourtNames(bookingItems);

      final bookings = bookingItems.map((item) {
        final courtName = courtNames[item.courtId] ?? item.courtIdShort;
        return Booking(
          id: item.id,
          courtName: courtName,
          location: '',
          date: item.bookingDate,
          time: item.timeRange,
          rating: 0,
          sportType: '',
        );
      }).toList();

      if (mounted) {
        setState(() {
          _bookings = bookings;
          _isLoadingBookings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _bookingsErrorMessage = e.toString();
          _isLoadingBookings = false;
        });
      }
    }
  }

  Future<Map<String, String>> _loadCourtNames(
    List<_BookingItem> bookings,
  ) async {
    final uniqueCourtIds = bookings.map((b) => b.courtId).toSet();
    if (uniqueCourtIds.isEmpty) return {};

    final results = await Future.wait(
      uniqueCourtIds.map((courtId) async {
        try {
          final data = await BookingApiService.getCourtDetails(courtId);
          final name = data['name'] as String?;
          return MapEntry(courtId, name);
        } catch (_) {
          return MapEntry(courtId, null);
        }
      }),
    );

    final names = <String, String>{};
    for (final entry in results) {
      if (entry.value != null && entry.value!.isNotEmpty) {
        names[entry.key] = entry.value!;
      }
    }
    return names;
  }

  Court _mapCenterToCourt(Map<String, dynamic> json) {
    final ratingValue = json['rating'] as num? ?? 0;
    final reviewCountValue = json['reviewCount'] as num? ?? 0;

    return Court(
      id: json['id'] as String,
      name: (json['name'] ?? '') as String,
      location: (json['location'] ?? '') as String,
      address: (json['address'] ?? '') as String,
      rating: ratingValue.toDouble(),
      reviewCount: reviewCountValue.toInt(),
      sportType: (json['sportType'] ?? 'Football') as String,
      imageUrl: (json['imageUrl'] ?? '') as String,
      availableDates: _generateDates(),
    );
  }

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
    final displayName = _isLoadingUser
        ? "Loading..."
        : (_user?.name ?? "Guest");
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
                displayName,
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyBookingPage(),
                    ),
                  );
                },
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
        if (_isLoadingBookings)
          const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_bookingsErrorMessage != null)
          SizedBox(
            height: 150,
            child: Center(
              child: Text(
                _bookingsErrorMessage ?? 'Failed to load bookings',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          )
        else if (_bookings.isEmpty)
          const SizedBox(
            height: 150,
            child: Center(child: Text('No bookings found')),
          )
        else
          SizedBox(
            height: 150,
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
    if (_isLoadingCourts) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_courtsErrorMessage != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Text(
                _courtsErrorMessage ?? 'Failed to load centers',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadAvailableCourts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_availableCourts.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: Text('No centers available')),
        ),
      );
    }

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
                    builder: (context) => SelectSlotsPage(centerId: court.id),
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

class _BookingItem {
  final String id;
  final String courtId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;

  _BookingItem({
    required this.id,
    required this.courtId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
  });

  String get courtIdShort {
    if (courtId.length <= 8) return courtId;
    return '${courtId.substring(0, 8)}...';
  }

  String get timeRange => '${_formatTime(startTime)} - ${_formatTime(endTime)}';

  static String _formatTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return value;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  factory _BookingItem.fromJson(Map<String, dynamic> json) {
    final bookingDateValue = json['bookingDate']?.toString() ?? '';
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(bookingDateValue);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return _BookingItem(
      id: json['id']?.toString() ?? '',
      courtId: json['courtId']?.toString() ?? '',
      bookingDate: parsedDate,
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
    );
  }
}
