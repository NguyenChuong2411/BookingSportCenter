import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/booking_cubit.dart';
import '../bloc/booking_state.dart';
import '../../data/models/time_slot_model.dart';

class BookingTimeTable extends StatelessWidget {
  final BookingLoaded state;

  const BookingTimeTable({super.key, required this.state});

  String _formatCourtLabel(TimeSlot slot) {
    final name = slot.courtName ?? slot.courtId;
    final type = slot.courtType;
    final sport = slot.sportName;
    final parts = <String>[name];
    if (type != null && type.isNotEmpty) parts.add(type);
    if (sport != null && sport.isNotEmpty) parts.add(sport);
    return parts.join('\n');
  }

  List<String> _generateTimeLabels() {
    final labels = <String>[];
    var hour = 5;
    var minute = 0;
    while (hour < 23 || (hour == 23 && minute == 0)) {
      labels.add(
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
      );
      minute += 30;
      if (minute >= 60) {
        minute = 0;
        hour += 1;
      }
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    final timeLabels = _generateTimeLabels();
    final courtIds = state.slots.map((s) => s.courtId).toSet().toList();
    const columnWidth = 55.0;
    final tableWidth = 120 + (timeLabels.length * columnWidth);

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: tableWidth,
          child: Column(
            children: [
              // Hàng hiển thị Khung giờ tiêu đề phía trên
              Container(
                color: const Color(0xffcaefff),
                height: 40,
                child: Row(
                  children: [
                    const SizedBox(width: 120),
                    ...timeLabels.map(
                      (time) => Expanded(
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.only(bottom: 4),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Colors.blue, width: 1.5),
                            ),
                          ),
                          child: Text(
                            time,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Danh sách các sân chạy hàng dọc
              Expanded(
                child: ListView.builder(
                  itemCount: courtIds.length,
                  itemBuilder: (context, courtIdx) {
                    final courtId = courtIds[courtIdx];
                    final courtSlot = state.slots.firstWhere(
                      (s) => s.courtId == courtId,
                    );
                    final courtLabel = _formatCourtLabel(courtSlot);
                    final courtSlots = state.slots
                        .where((s) => s.courtId == courtId)
                        .toList();

                    return Container(
                      height: 64,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 120,
                            color: const Color(0xffdbffee),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  courtSlot.courtName ?? courtSlot.courtId,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if ((courtSlot.courtType ?? '').isNotEmpty)
                                  Text(
                                    courtSlot.courtType!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11,
                                      color: Colors.black.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if ((courtSlot.sportName ?? '').isNotEmpty)
                                  Text(
                                    courtSlot.sportName!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11,
                                      color: Colors.black.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          ...timeLabels.map((timeLabel) {
                            final slot = courtSlots
                                .cast<TimeSlot?>()
                                .firstWhere(
                                  (s) => s?.timeLabel == timeLabel,
                                  orElse: () => null,
                                );
                            final isMissing = slot == null;

                            Color cellColor = Colors.white;
                            if (isMissing) cellColor = Colors.grey;
                            if (slot?.status == SlotStatus.unavailable)
                              cellColor = Colors.grey;
                            if (slot?.status == SlotStatus.reserved)
                              cellColor = const Color(0xffC02F52);
                            if (slot?.status == SlotStatus.picked)
                              cellColor = const Color(0xFF00BA13);

                            return Expanded(
                              child: GestureDetector(
                                onTap: isMissing
                                    ? null
                                    : () {
                                        BlocProvider.of<BookingCubit>(
                                          context,
                                        ).toggleSelectSlot(slot!);
                                      },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cellColor,
                                    border: Border.all(
                                      color: const Color(0xffcaefff),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
