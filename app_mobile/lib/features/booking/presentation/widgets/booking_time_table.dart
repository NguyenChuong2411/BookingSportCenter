import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/booking_cubit.dart';
import '../bloc/booking_state.dart';
import '../../data/models/time_slot_model.dart';

class BookingTimeTable extends StatelessWidget {
  final BookingLoaded state;

  const BookingTimeTable({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final timeLabels = state.slots.map((s) => s.timeLabel).toSet().toList();
    final courts = state.slots.map((s) => s.courtName).toSet().toList();

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width:
              650, // Đảm bảo đủ chiều rộng để trải đều các cột giờ mà không bị bug giao diện
          child: Column(
            children: [
              // Hàng hiển thị Khung giờ tiêu đề phía trên
              Container(
                color: const Color(0xffcaefff),
                height: 40,
                child: Row(
                  children: [
                    const SizedBox(width: 90),
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
                  itemCount: courts.length,
                  itemBuilder: (context, courtIdx) {
                    final courtName = courts[courtIdx];
                    final courtSlots = state.slots
                        .where((s) => s.courtName == courtName)
                        .toList();

                    return Container(
                      height: 50,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 90,
                            color: const Color(0xffdbffee),
                            alignment: Alignment.center,
                            child: Text(
                              courtName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ...courtSlots.map((slot) {
                            Color cellColor = Colors.white;
                            if (slot.status == SlotStatus.unavailable)
                              cellColor = Colors.grey;
                            if (slot.status == SlotStatus.reserved)
                              cellColor = const Color(0xffC02F52);
                            if (slot.status == SlotStatus.picked)
                              cellColor = const Color(0xFF00BA13);

                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  BlocProvider.of<BookingCubit>(
                                    context,
                                  ).toggleSelectSlot(slot);
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
