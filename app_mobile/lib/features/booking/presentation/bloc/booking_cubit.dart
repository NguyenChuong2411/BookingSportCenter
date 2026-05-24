import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_state.dart';
import '../../data/models/time_slot_model.dart';
import 'package:booking_sport/core/services/booking_api_service.dart';

class BookingCubit extends Cubit<BookingState> {
  String? _selectedCourtId;
  String? _selectedCenterId;

  BookingCubit() : super(BookingLoading());

  /// Tải danh sách khung giờ có sẵn từ backend
  Future<void> loadBookingSlots({
    required String courtId,
    required DateTime date,
  }) async {
    emit(BookingLoading());
    try {
      _selectedCourtId = courtId;

      // Gọi API để lấy available slots
      final slotsData = await BookingApiService.getAvailableSlots(
        courtId,
        date,
      );

      // Convert API response to TimeSlot objects
      List<TimeSlot> slots = [];
      for (var slotData in slotsData) {
        final startTime = TimeOfDay(
          hour: int.parse(slotData['startTime'].toString().split(':')[0]),
          minute: int.parse(slotData['startTime'].toString().split(':')[1]),
        );

        final timeLabel =
            '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';

        final startDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          startTime.hour,
          startTime.minute,
        );

        final pricePerHour =
            (slotData['pricePerHour'] as num?)?.toDouble() ?? 0.0;

        slots.add(
          TimeSlot(
            courtId: courtId,
            courtName: slotData['courtName']?.toString(),
            timeLabel: timeLabel,
            startTime: startDateTime,
            pricePerHour: pricePerHour,
            status: slotData['isAvailable']
                ? SlotStatus.available
                : SlotStatus.reserved,
          ),
        );
      }

      emit(
        BookingLoaded(
          slots: slots,
          selectedSlots: const [],
          selectedDate: date,
        ),
      );
    } catch (e) {
      emit(BookingError("Lỗi tải danh sách khung giờ: $e"));
    }
  }

  /// Tải mock slots (nếu backend không sẵn có)
  void loadMockBookingSlots() async {
    emit(BookingLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final courts = [
        {'id': '078f789c-7824-42f7-b2f7-d9713958eb9e', 'name': 'BT Pitch B'},
      ];
      List<String> times = [
        "08:00",
        "08:30",
        "09:00",
        "09:30",
        "10:00",
        "10:30",
        "11:00",
        "11:30",
      ];
      List<TimeSlot> mockSlots = [];

      for (var court in courts) {
        final courtId = court['id'] as String;
        final courtName = court['name'] as String;
        for (var time in times) {
          SlotStatus status = SlotStatus.available;
          if (time == "8:00") {
            status = SlotStatus.unavailable;
          }
          if (courtName == "BT Pitch B" && time == "9:00") {
            status = SlotStatus.reserved;
          }

          mockSlots.add(
            TimeSlot(
              courtId: courtId,
              courtName: courtName,
              timeLabel: time,
              startTime: DateTime.now(),
              pricePerHour: 40.0,
              status: status,
            ),
          );
        }
      }
      final selectedDate = DateTime.now();

      try {
        final slotsData = await BookingApiService.getAvailableSlots(
          courts.first['id'] as String,
          selectedDate,
        );

        final reservedTimes = slotsData
            .where((slot) => slot['isAvailable'] == false)
            .map((slot) => _normalizeTimeLabel(slot['startTime'].toString()))
            .toSet();

        for (final slot in mockSlots) {
          if (reservedTimes.contains(_normalizeTimeLabel(slot.timeLabel))) {
            slot.status = SlotStatus.reserved;
          }
        }
      } catch (_) {
        // Ignore API errors and keep mock availability
      }

      emit(
        BookingLoaded(
          slots: mockSlots,
          selectedSlots: const [],
          selectedDate: selectedDate,
        ),
      );
    } catch (e) {
      emit(const BookingError("Không thể tải thông tin lịch sân"));
    }
  }

  String _normalizeTimeLabel(String value) {
    final parts = value.split(':');
    final hour = parts.isNotEmpty ? parts[0].padLeft(2, '0') : '00';
    final minute = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
    return '$hour:$minute';
  }

  void updateSelectedDate(DateTime newDate) {
    if (state is BookingLoaded) {
      final currentState = state as BookingLoaded;
      emit(
        currentState.copyWith(selectedDate: newDate, selectedSlots: const []),
      );
    }
  }

  void toggleSelectSlot(TimeSlot clickedSlot) {
    if (state is BookingLoaded) {
      final currentState = state as BookingLoaded;

      if (clickedSlot.status == SlotStatus.reserved ||
          clickedSlot.status == SlotStatus.unavailable) {
        return;
      }

      List<TimeSlot> updatedSlots = List.from(currentState.slots);
      List<TimeSlot> updatedSelectedSlots = List.from(
        currentState.selectedSlots,
      );

      final index = updatedSlots.indexWhere(
        (s) =>
            s.courtId == clickedSlot.courtId &&
            s.timeLabel == clickedSlot.timeLabel,
      );

      if (index != -1) {
        final slotInList = updatedSlots[index];

        if (slotInList.status == SlotStatus.picked) {
          slotInList.status = SlotStatus.available;
          updatedSelectedSlots.removeWhere(
            (s) =>
                s.courtId == clickedSlot.courtId &&
                s.timeLabel == clickedSlot.timeLabel,
          );
        } else {
          slotInList.status = SlotStatus.picked;
          updatedSelectedSlots.add(slotInList);
        }

        emit(
          currentState.copyWith(
            slots: updatedSlots,
            selectedSlots: updatedSelectedSlots,
          ),
        );
      }
    }
  }

  /// Tạo booking mới (GỬI TỚI BACKEND)
  /// TÍNH TIỀN SÂN: Court charged $20/30min - Khách trả tại sân (không thanh toán online)
  Future<bool> createBooking({
    required String courtId,
    required DateTime bookingDate,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    String? userName,
    String? userPhone,
    String? note,
  }) async {
    try {
      emit(BookingLoading());

      // Gọi API backend để tạo booking
      await BookingApiService.createBooking(
        courtId: courtId,
        bookingDate: bookingDate,
        startTime: startTime,
        endTime: endTime,
        note: note,
      );

      // Success - emit loaded state lại
      if (state is BookingLoaded) {
        emit(state);
      }
      return true;
    } catch (e) {
      emit(BookingError("Lỗi tạo booking: $e"));
      return false;
    }
  }

  /// Getter cho selected court ID
  String? get selectedCourtId => _selectedCourtId;

  /// Getter cho selected center ID
  String? get selectedCenterId => _selectedCenterId;

  /// Setter cho selected center ID
  void setSelectedCenter(String centerId) {
    _selectedCenterId = centerId;
  }
}
