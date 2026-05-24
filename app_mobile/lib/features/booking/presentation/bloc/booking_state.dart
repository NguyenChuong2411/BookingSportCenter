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
  final List<TimeSlot> selectedSlots; // Danh sách khung giờ được chọn
  final DateTime selectedDate; // Ngày đang xem lịch đặt sân
  final Map<String, int>
  selectedServices; // Dịch vụ bổ sung được chọn {serviceName: quantity}
  final Map<String, double> servicePrices; // Giá dịch vụ bổ sung

  const BookingLoaded({
    required this.slots,
    required this.selectedSlots,
    required this.selectedDate,
    this.selectedServices = const {},
    this.servicePrices = const {},
  });

  // Tính toán tổng thời gian: Số ô đã chọn * 30 phút
  int get totalMinutes => selectedSlots.length * 30;

  // TÍNH TIỀN SÂN: Tổng các slot theo pricePerHour (mặc định 30 phút mỗi slot)
  double get courtPrice {
    const slotMinutes = 30;
    final slotHours = slotMinutes / 60.0;
    double total = 0.0;
    for (final slot in selectedSlots) {
      total += slot.pricePerHour * slotHours;
    }
    return total;
  }

  double get servicesPrice {
    double total = 0.0;
    selectedServices.forEach((service, quantity) {
      if (servicePrices.containsKey(service)) {
        total += servicePrices[service]! * quantity;
      }
    });
    return total;
  }

  // Tổng = Tiền sân + Dịch vụ bổ sung (báo giá để khách trả tại sân)
  double get totalPrice => courtPrice + servicesPrice;

  BookingLoaded copyWith({
    List<TimeSlot>? slots,
    List<TimeSlot>? selectedSlots,
    DateTime? selectedDate,
    Map<String, int>? selectedServices,
    Map<String, double>? servicePrices,
  }) {
    return BookingLoaded(
      slots: slots ?? this.slots,
      selectedSlots: selectedSlots ?? this.selectedSlots,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedServices: selectedServices ?? this.selectedServices,
      servicePrices: servicePrices ?? this.servicePrices,
    );
  }

  @override
  List<Object?> get props => [
    slots,
    selectedSlots,
    selectedDate,
    selectedServices,
    servicePrices,
  ];
}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);

  @override
  List<Object> get props => [message];
}
