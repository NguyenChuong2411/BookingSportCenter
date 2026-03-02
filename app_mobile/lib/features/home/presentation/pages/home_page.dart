import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/court.dart';
import '../../domain/entities/user.dart';
import '../widgets/booking_card.dart';
import '../widgets/court_card.dart';
import '../widgets/date_selector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _selectedDate;

  // Mock user data
  final User _user = User(
    id: '1',
    name: 'Minh Sang',
    email: 'minhsang@example.com',
  );

  // Mock bookings data
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

  // Mock available courts data
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

  // Generate dates for the next 14 days
  List<DateTime> _generateDates() {
    final now = DateTime.now();
    return List.generate(14, (index) => now.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with gradient
          _buildHeader(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Your Bookings Section
                  _buildYourBookingsSection(),

                  const SizedBox(height: 24),

                  // Available Courts Section
                  _buildAvailableCourtsSection(),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0000FF), Color(0xFF0000CC)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.hello,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.textSecondary,
                  size: 24,
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all bookings
                },
                child: const Text(
                  AppStrings.seeAll,
                  style: TextStyle(
                    fontSize: 12,
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
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _bookings.length,
            itemBuilder: (context, index) {
              return BookingCard(
                booking: _bookings[index],
                onTap: () {
                  // Handle booking tap
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableCourtsSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen.withValues(alpha: 0.9),
            const Color(0xFF00DD00),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.availableCourtNearYou,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.selectTheDaysAvailable,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textWhite,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            // Date Selector
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

            // Available Courts List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _availableCourts.length,
              itemBuilder: (context, index) {
                return CourtCard(
                  court: _availableCourts[index],
                  onBookNow: () {
                    // Handle book now action
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Booking ${_availableCourts[index].name}',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, true),
              _buildNavItem(Icons.location_on_outlined, false),
              _buildNavItem(Icons.favorite_border, false),
              _buildNavItem(Icons.person_outline, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryGreen : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isActive ? AppColors.textWhite : AppColors.textSecondary,
        size: 24,
      ),
    );
  }
}
