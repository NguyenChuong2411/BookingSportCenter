import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/booking_api_service.dart';

class MyBookingPage extends StatefulWidget {
  const MyBookingPage({super.key});

  @override
  State<MyBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<_BookingItem> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await BookingApiService.getMyBookings();
      var bookings = data
          .map(_BookingItem.fromJson)
          .where((booking) => booking.status.toLowerCase() == 'completed')
          .toList();
      final courtNames = await _loadCourtNames(bookings);
      bookings = bookings
          .map(
            (booking) =>
                booking.copyWith(courtName: courtNames[booking.courtId]),
          )
          .toList();
      if (mounted) {
        setState(() {
          _bookings = bookings;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Booking'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textWhite,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _buildErrorState()
            : _bookings.isEmpty
            ? const Center(child: Text('No bookings found'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildBookingCard(_bookings[index]);
                },
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
              _errorMessage ?? 'Failed to load bookings',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBookings,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(_BookingItem booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Court: ${booking.courtName ?? booking.courtIdShort}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${booking.bookingDate} • ${booking.timeRange}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Total: ${booking.totalPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingItem {
  final String id;
  final String courtId;
  final String? courtName;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String status;
  final double totalPrice;

  _BookingItem({
    required this.id,
    required this.courtId,
    this.courtName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalPrice,
  });

  _BookingItem copyWith({String? courtName}) {
    return _BookingItem(
      id: id,
      courtId: courtId,
      courtName: courtName ?? this.courtName,
      bookingDate: bookingDate,
      startTime: startTime,
      endTime: endTime,
      status: status,
      totalPrice: totalPrice,
    );
  }

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
    return _BookingItem(
      id: json['id'] as String,
      courtId: json['courtId'] as String,
      courtName: json['courtName'] as String?,
      bookingDate: (json['bookingDate'] as String).split('T')[0],
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: json['status'] as String? ?? 'Pending',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
    );
  }
}
