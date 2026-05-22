import 'package:flutter/material.dart';
import '../bloc/booking_state.dart';
import '../pages/reservation_details_page.dart';

class BookingBottomBar extends StatelessWidget {
  final BookingLoaded state;

  const BookingBottomBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // 1. Tính toán tổng thời gian chung của toàn bộ lượt đặt sân
    int hours = state.totalMinutes ~/ 60;
    int minutes = state.totalMinutes % 60;
    String durationText = "${hours}h${minutes.toString().padLeft(2, '0')}";

    return Container(
      // Căn chỉnh padding tiêu chuẩn tạo không gian thở vừa vặn cho khối tổng
      padding: const EdgeInsets.only(left: 50, right: 50, top: 25, bottom: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff1B15FF), // Màu xanh sáng góc trên trái
            Color(0xff100D98), // Màu xanh trầm góc dưới phải
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment
              .start, // Giúp hai cột luôn thẳng hàng tăm tắp từ đỉnh chữ
          children: [
            // ================= CỘT TRÁI: TOTAL TIME =================
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Total time",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  durationText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // ================= CỘT PHẢI: PRICE & NÚT BOOK NOW =================
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Price",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                // Bọc số tiền vào một SizedBox có chiều rộng cố định bằng với độ rộng của nút (130)
                SizedBox(
                  width: 130,
                  child: Text(
                    "\$${state.totalPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Sử dụng khối ẩn hiện động nhưng không làm thay đổi layout của trục chữ ở trên
                AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 200,
                  ), // Thêm chút hiệu ứng mượt mà khi hiện nút
                  height: state.selectedSlots.isNotEmpty
                      ? 64
                      : 0, // 64 = 20 (SizedBox) + 44 (Chiều cao nút)
                  child: state.selectedSlots.isNotEmpty
                      ? Column(
                          children: [
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 130,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () {
                                  // CHUYỂN TRANG TRỰC TIẾP: Nhấn một cái là bay sang trang tóm tắt liền
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ReservationDetailsPage(
                                            bookedSlots: state.selectedSlots,
                                          ),
                                    ),
                                  );
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
          ],
        ),
      ),
    );
  }
}
