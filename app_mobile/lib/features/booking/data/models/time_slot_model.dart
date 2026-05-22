enum SlotStatus { available, picked, reserved, unavailable }

class TimeSlot {
  final String courtName; // Ví dụ: "Court 1"
  final String timeLabel; // Ví dụ: "8:00", "8:30"
  final DateTime startTime;
  SlotStatus status;

  TimeSlot({
    required this.courtName,
    required this.timeLabel,
    required this.startTime,
    required this.status,
  });
}
