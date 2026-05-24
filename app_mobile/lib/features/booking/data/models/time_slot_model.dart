enum SlotStatus { available, picked, reserved, unavailable }

class TimeSlot {
  final String courtId;
  final String? courtName; // Ví dụ: "Court 1"
  final String? courtType;
  final String? sportName;
  final String timeLabel; // Ví dụ: "8:00", "8:30"
  final DateTime startTime;
  final double pricePerHour;
  SlotStatus status;

  TimeSlot({
    required this.courtId,
    this.courtName,
    this.courtType,
    this.sportName,
    required this.timeLabel,
    required this.startTime,
    required this.pricePerHour,
    required this.status,
  });
}
