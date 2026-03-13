import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/event.dart';
import '../widgets/event_card.dart';
import 'event_detail_page.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  // Mock event data - Replace with actual data from backend API
  late final List<Event> _events;

  @override
  void initState() {
    super.initState();
    _events = [
      Event(
        id: '1',
        title: 'Năm Mới Sân Mới - Hoạt Động Xuyên Tết',
        description:
            'Chào đón năm mới với sân bóng đá mới hoàn toàn. Nhiều ưu đãi hấp dẫn trong suốt dịp Tết Nguyên Đán.',
        imageUrl: 'https://example.com/event1.jpg', // Will use placeholder
        courtId: 'court1',
        courtName: 'City Football Pitch',
        eventType: 'promotion',
        startDate: DateTime(2026, 1, 20),
        endDate: DateTime(2026, 2, 28),
        discount: 'TẾT SALE',
        originalPrice: 200000,
        discountedPrice: 150000,
        location: '123 Luy Ban Bich, Tan Phu, HCM',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Event(
        id: '2',
        title: 'Săn Trung Tâm - Deal Siêu Hot Cuối Tuần',
        description:
            'Giảm giá 60% cho tất cả các sân vào cuối tuần. Không giới hạn số lượng đặt sân. First come, first served!',
        imageUrl: 'https://example.com/event2.jpg',
        courtId: 'court2',
        courtName: 'Central Sports Complex',
        eventType: 'special_offer',
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 3, 31),
        discount: '60% OFF',
        originalPrice: 300000,
        discountedPrice: 120000,
        location: 'Trung Tam Quan 3, TP.HCM',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Event(
        id: '3',
        title: 'Giải Đấu Bóng Đá Mini - Mùa Xuân 2026',
        description:
            'Tham gia giải đấu bóng đá mini với tổng giá trị giải thưởng lên đến 50 triệu đồng. Đăng ký ngay!',
        imageUrl: 'https://example.com/event3.jpg',
        courtId: 'court3',
        courtName: 'Thanh Phat Football Pitch',
        eventType: 'tournament',
        startDate: DateTime(2026, 4, 15),
        endDate: DateTime(2026, 5, 15),
        discount: null,
        originalPrice: null,
        discountedPrice: null,
        location: 'Central Thanh Xuan District',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Event(
        id: '4',
        title: 'Free 1 Giờ Thuê Sân - Khách Hàng Mới',
        description:
            'Miễn phí 1 giờ thuê sân cho tất cả khách hàng mới đăng ký. Áp dụng cho tất cả các ngày trong tuần.',
        imageUrl: 'https://example.com/event4.jpg',
        courtId: 'court1',
        courtName: 'City Football Pitch',
        eventType: 'promotion',
        startDate: DateTime(2026, 3, 1),
        endDate: DateTime(2026, 6, 30),
        discount: 'FREE 1H',
        originalPrice: 200000,
        discountedPrice: 0,
        location: '123 Luy Ban Bich, Tan Phu, HCM',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildEventList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleAddEvent,
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Event',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
        'Event',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEventList() {
    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No events available',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return EventCard(
          event: event,
          onTap: () => _navigateToEventDetail(event),
          onBookNow: () => _handleBookNow(event),
        );
      },
    );
  }

  void _navigateToEventDetail(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventDetailPage(event: event)),
    );
  }

  void _handleBookNow(Event event) {
    // TODO: Implement booking flow
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking: ${event.title}'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _handleAddEvent() {
    // TODO: Navigate to add event page (admin only)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Event'),
        content: const Text(
          'This feature is available for court owners and administrators only.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
