import 'package:equatable/equatable.dart';
import '../../data/models/time_slot_model.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<TimeSlot> slots;
  final List<TimeSlot>
  selectedSlots; // Đổi từ single object sang List để chọn nhiều ô
  final DateTime selectedDate; // Quản lý ngày đang xem lịch đặt sân

  const BookingLoaded({
    required this.slots,
    required this.selectedSlots,
    required this.selectedDate,
  });

  // Tính toán tổng thời gian: Số ô đã chọn * 30 phút
  int get totalMinutes => selectedSlots.length * 30;

  // Tính tổng tiền: Số ô đã chọn * 20$
  double get totalPrice => selectedSlots.length * 20.0;

  BookingLoaded copyWith({
    List<TimeSlot>? slots,
    List<TimeSlot>? selectedSlots,
    DateTime? selectedDate,
  }) {
    return BookingLoaded(
      slots: slots ?? this.slots,
      selectedSlots: selectedSlots ?? this.selectedSlots,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [slots, selectedSlots, selectedDate];
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);

  @override
  List<Object> get props => [message];
}
