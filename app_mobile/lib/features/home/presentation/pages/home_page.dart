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
import '../../../../core/utils/user_session.dart'; // Đã import UserSession
import '../../data/datasources/center_service.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onAvatarPressed;

  const HomePage({super.key, this.onAvatarPressed});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _selectedDate;

  // Cục mock data này ông có thể xóa đi cũng được, vì giờ mình xài UserSession rồi
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

  List<Court> _availableCourts = [];
  bool _isLoadingCourts = true; // Cờ hiệu để xoay vòng loading
  final CenterService _centerService = CenterService();

  @override
  void initState() {
    super.initState();
    _loadCourtsFromApi();
  }

  Future<void> _loadCourtsFromApi() async {
    setState(() => _isLoadingCourts = true);

    // Gọi xuống Backend C# lấy data
    final courts = await _centerService.fetchAvailableCenters();

    setState(() {
      _availableCourts = courts;
      _isLoadingCourts = false;
    });
  }

  List<DateTime> _generateDates() {
    final now = DateTime.now();
    return List.generate(14, (index) => now.add(Duration(days: index)));
  }

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

  String _getAvailableMonthsString() {
    final dates = _generateDates();
    if (dates.isEmpty) return '';

    final firstMonth = dates.first.month;
    final lastMonth = dates.last.month;

    if (firstMonth == lastMonth) {
      return _getMonthName(firstMonth);
    } else {
      return '${_getMonthName(firstMonth)} - ${_getMonthName(lastMonth)}';
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
              InkWell(
                onTap: () {
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
                  // 🔴 ĐÃ ĐỔI TỪ ICON SANG AVATAR CHỮ CÁI ĐỘNG
                  child: Center(
                    child: Text(
                      UserSession.fullName != null &&
                              UserSession.fullName!.isNotEmpty
                          ? UserSession.fullName![0].toUpperCase()
                          : "U", // Fallback chữ U (User) nếu chưa có data
                      style: const TextStyle(
                        color: Color(0xFF0000FF), // Màu xanh SpotOn
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                AppStrings.hello,
                style: TextStyle(fontSize: 24, color: AppColors.textWhite),
              ),

              const SizedBox(height: 4),

              // 🔴 ĐÃ ĐỔI TỪ MOCK DATA SANG DỮ LIỆU THẬT CỦA USER
              Text(
                UserSession.fullName ?? "User",
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
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: _isLoadingCourts
            // 🔴 TRẠNG THÁI 1: ĐANG TẢI (Hiện vòng xoay)
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppColors.textWhite),
                ),
              )
            // 🔴 TRẠNG THÁI 2: TẢI XONG (Kiểm tra xem có rỗng không)
            : _availableCourts.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    "No courts available at the moment.",
                    style: TextStyle(color: AppColors.textWhite, fontSize: 16),
                  ),
                ),
              )
            // 🔴 TRẠNG THÁI 3: CÓ DATA (Đổ list ra màn hình)
            : Column(
                children: _availableCourts.map((court) {
                  return CourtCard(
                    court: court,
                    onBookNow: () {
                      // Chuyền nguyên object 'court' sang trang chọn giờ
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectSlotsPage(
                            selectedCenter:
                                court, // Nhớ thêm thuộc tính này bên SelectSlotsPage nhé!
                          ),
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
