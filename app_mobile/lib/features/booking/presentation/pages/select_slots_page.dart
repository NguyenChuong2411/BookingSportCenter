import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/booking_cubit.dart';
import '../bloc/booking_state.dart';
import '../widgets/booking_header.dart';
import '../widgets/booking_time_table.dart';
import '../widgets/booking_bottom_bar.dart';
import '../../../home/domain/entities/court.dart';

class SelectSlotsPage extends StatefulWidget {
  // Optional: courtId có thể được truyền từ navigation
  final String? courtId;
  final String? centerId;

  const SelectSlotsPage({super.key, this.courtId, this.centerId});

  @override
  State<SelectSlotsPage> createState() => _SelectSlotsPageState();
}

class _SelectSlotsPageState extends State<SelectSlotsPage> {
  late BookingCubit _bookingCubit;

  @override
  void initState() {
    super.initState();
    _bookingCubit = BookingCubit();

    // Load slots từ API nếu có courtId, nếu không dùng mock data
    if (widget.centerId != null) {
      _bookingCubit.loadCenterBookingSlots(
        centerId: widget.centerId!,
        date: DateTime.now(),
      );
    } else if (widget.courtId != null) {
      _bookingCubit.loadBookingSlots(
        courtId: widget.courtId!,
        date: DateTime.now(),
      );
    } else {
      // Fallback: Load mock data
      _bookingCubit.loadMockBookingSlots();
    }
  }

  @override
  void dispose() {
    _bookingCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _bookingCubit,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: BlocBuilder<BookingCubit, BookingState>(
          builder: (context, state) {
            if (state is BookingLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (state is BookingError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (state is BookingLoaded) {
              return Stack(
                children: [
                  // LỚP 1: Nội dung chính (Header + Bảng lịch) nằm phía dưới
                  Column(
                    children: [
                      BookingHeader(state: state),
                      Expanded(child: BookingTimeTable(state: state)),
                      const SizedBox(
                        height: 110,
                      ), // Khoảng đệm để bảng lịch không bị bottom bar che khuất dòng cuối
                    ],
                  ),

                  // LỚP 2: Ép thanh Bottom Bar cố định nằm sát đáy màn hình
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: BookingBottomBar(state: state),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
