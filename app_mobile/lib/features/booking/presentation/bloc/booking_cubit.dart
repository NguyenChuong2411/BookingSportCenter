import 'package:flutter_bloc/flutter_bloc.dart';
import 'booking_state.dart';
import '../../data/models/time_slot_model.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit() : super(BookingLoading());

  void loadBookingSlots() async {
    emit(BookingLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      List<String> courts = [
        "Court 1",
        "Court 2",
        "Court 3",
        "Court 4",
        "Court 5",
        "Court 6",
      ];
      List<String> times = [
        "8:00",
        "8:30",
        "9:00",
        "9:30",
        "10:00",
        "10:30",
        "11:00",
        "11:30",
      ];
      List<TimeSlot> mockSlots = [];

      for (var court in courts) {
        for (var time in times) {
          SlotStatus status = SlotStatus.available;
          if (time == "8:00") status = SlotStatus.unavailable;
          if (court == "Court 2" && time == "9:00")
            status = SlotStatus.reserved;

          mockSlots.add(
            TimeSlot(
              courtName: court,
              timeLabel: time,
              startTime: DateTime.now(),
              status: status,
            ),
          );
        }
      }
      // ĐÃ FIX DÒNG 54: Truyền đủ selectedSlots và selectedDate mặc định là ngày hôm nay
      emit(
        BookingLoaded(
          slots: mockSlots,
          selectedSlots: const [],
          selectedDate: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(const BookingError("Không thể tải thông tin lịch sân"));
    }
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
          clickedSlot.status == SlotStatus.unavailable)
        return;

      List<TimeSlot> updatedSlots = List.from(currentState.slots);
      List<TimeSlot> updatedSelectedSlots = List.from(
        currentState.selectedSlots,
      );

      final index = updatedSlots.indexWhere(
        (s) =>
            s.courtName == clickedSlot.courtName &&
            s.timeLabel == clickedSlot.timeLabel,
      );

      if (index != -1) {
        final slotInList = updatedSlots[index];

        if (slotInList.status == SlotStatus.picked) {
          slotInList.status = SlotStatus.available;
          updatedSelectedSlots.removeWhere(
            (s) =>
                s.courtName == clickedSlot.courtName &&
                s.timeLabel == clickedSlot.timeLabel,
          );
        } else {
          slotInList.status = SlotStatus.picked;
          updatedSelectedSlots.add(slotInList);
        }

        // ĐÃ FIX CÁC DÒNG LỖI COPYWITH CŨ: Đẩy đúng danh sách sang State mới
        emit(
          currentState.copyWith(
            slots: updatedSlots,
            selectedSlots: updatedSelectedSlots,
          ),
        );
      }
    }
  }
}
