import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking_sport/core/services/booking_api_service.dart';
import 'package:booking_sport/core/utils/formatters.dart';
import '../bloc/booking_cubit.dart';
import '../bloc/booking_state.dart';
import '../pages/reservation_details_page.dart';

class BookingBottomBar extends StatelessWidget {
  final BookingLoaded state;

  const BookingBottomBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final hours = state.totalMinutes ~/ 60;
    final minutes = state.totalMinutes % 60;
    final durationText =
        "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
    final priceText = formatVnd(state.totalPrice);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff1B15FF), Color(0xff100D98)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 85,
                        child: Text(
                          "Total time",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            durationText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const SizedBox(
                        width: 85,
                        child: Text(
                          "Price",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            priceText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: state.selectedSlots.isNotEmpty ? 64 : 0,
              width: state.selectedSlots.isNotEmpty ? 120 : 0,
              child: state.selectedSlots.isNotEmpty
                  ? Column(
                      children: [
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 120,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () async {
                              final selectedSlots = state.selectedSlots;
                              if (selectedSlots.isEmpty) {
                                return;
                              }

                              final courtId = selectedSlots.first.courtId;

                              final sortedSlots = List.of(selectedSlots)
                                ..sort(
                                  (a, b) => _timeLabelToMinutes(
                                    a.timeLabel,
                                  ).compareTo(_timeLabelToMinutes(b.timeLabel)),
                                );

                              final startTime = _parseTimeLabel(
                                sortedSlots.first.timeLabel,
                              );

                              final totalMinutes = selectedSlots.length * 30;
                              final endTime = _addMinutes(
                                startTime,
                                totalMinutes,
                              );

                              final bookingDate = state.selectedDate;

                              try {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Creating booking..."),
                                  ),
                                );

                                final bookingResponse =
                                    await BookingApiService.createBooking(
                                      courtId: courtId,
                                      bookingDate: bookingDate,
                                      startTime: startTime,
                                      endTime: endTime,
                                    );

                                final bookingId = bookingResponse['id']
                                    ?.toString();
                                if (bookingId == null || bookingId.isEmpty) {
                                  throw Exception(
                                    "Booking ID not returned from server",
                                  );
                                }

                                final totalPriceValue =
                                    bookingResponse['totalPrice'];
                                final depositValue =
                                    bookingResponse['depositAmount'];
                                final courtPrice = totalPriceValue is num
                                    ? totalPriceValue.toDouble()
                                    : null;
                                final depositAmount = depositValue is num
                                    ? depositValue.toDouble()
                                    : null;

                                if (context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).clearSnackBars();
                                  final completed = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ReservationDetailsPage(
                                            bookingId: bookingId,
                                            bookedSlots: selectedSlots,
                                            bookingDate: bookingDate,
                                            startTime: startTime,
                                            endTime: endTime,
                                            courtPrice: courtPrice,
                                            depositAmount: depositAmount,
                                          ),
                                    ),
                                  );

                                  if (completed == true) {
                                    await context
                                        .read<BookingCubit>()
                                        .loadBookingSlots(
                                          courtId: courtId,
                                          date: bookingDate,
                                        );
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).clearSnackBars();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Error: $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              "Book now",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  TimeOfDay _parseTimeLabel(String timeLabel) {
    final parts = timeLabel.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  int _timeLabelToMinutes(String timeLabel) {
    final parts = timeLabel.split(':');
    return (int.parse(parts[0]) * 60) + int.parse(parts[1]);
  }

  TimeOfDay _addMinutes(TimeOfDay time, int minutesToAdd) {
    final totalMinutes = (time.hour * 60) + time.minute + minutesToAdd;
    final endHour = totalMinutes ~/ 60;
    final endMinute = totalMinutes % 60;
    return TimeOfDay(hour: endHour, minute: endMinute);
  }
}
