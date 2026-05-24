import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/booking_cubit.dart';
import '../bloc/booking_state.dart';

class BookingHeader extends StatelessWidget {
  final BookingLoaded state; // Nhận state truyền từ page vào để lấy ngày động

  const BookingHeader({super.key, required this.state});

  // Hàm hiển thị Popup lịch trực tiếp chuẩn Flutter Material
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: state.selectedDate,
      firstDate: DateTime.now(), // Không cho chọn ngày quá khứ
      lastDate: DateTime.now().add(
        const Duration(days: 30),
      ), // Giới hạn đặt trước 1 tháng
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(
                0xff0d1cd3,
              ), // Màu chủ đạo của popup lịch giống app của ông
              onPrimary: Colors.white,
              surface: Color(0xff1e1e1e),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != state.selectedDate) {
      context.read<BookingCubit>().updateSelectedDate(picked);
    }
  }

  // Hàm hiển thị Bảng giá chi tiết vuốt từ dưới lên (Modal Bottom Sheet)
  void _showPricingDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Pricing Details",
                style: TextStyle(
                  color: Color(0xff1B15FF),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildPriceRow("Standard Time Slot (30 mins)", "\$20.00"),
              _buildPriceRow("Peak Hours (17:00 - 22:00)", "\$25.00"),
              _buildPriceRow("Weekend Surcharge", "+\$5.00"),
              const Divider(color: Color(0xff1B15FF), height: 24),
              const Text(
                "* Note: Prices may vary depending on the sport type and court quality.",
                style: TextStyle(
                  color: Color(0xFF1B15FF),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceRow(String title, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 15,
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Định dạng ngày hiển thị dạng DD/MM/YYYY từ state động
    String formattedDate =
        "${state.selectedDate.day.toString().padLeft(2, '0')}/${state.selectedDate.month.toString().padLeft(2, '0')}/${state.selectedDate.year}";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, // Bắt đầu từ góc trên bên trái
          end: Alignment.bottomRight, // Kết thúc ở góc dưới bên phải
          colors: [
            Color(0xff1B15FF), // Mã màu bắt đầu của ông
            Color(0xff100D98), // Mã màu kết thúc của ông
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                "Select slots",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(Colors.white, "Available"),
                  const SizedBox(height: 8),
                  _buildLegendItem(const Color(0xffd12c4c), "Reserved"),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(Colors.green, "Picked"),
                  const SizedBox(height: 8),
                  _buildLegendItem(Colors.grey, "Unavailable"),
                ],
              ),
              // NÚT CHỌN NGÀY VÀ XEM BẢNG GIÁ ĐÃ HOẠT ĐỘNG
              Column(
                children: [
                  // 1. NÚT CHỌN NGÀY (Giữ nguyên viền mẫu của ông)
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white54),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.calendar_month,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10), // Khoảng cách giữa 2 nút
                  // 2. NÚT PRICING DETAILS ĐÃ ĐƯỢC THÊM VIỀN ĐỒNG BỘ 100%
                  GestureDetector(
                    onTap: () =>
                        _showPricingDetails(context), // Kích hoạt mở bảng giá
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ), // Kích thước khoảng cách trong hộp giống nút trên
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white54,
                        ), // Viền trắng mờ giống nút chọn ngày
                        borderRadius: BorderRadius.circular(
                          20,
                        ), // Bo tròn góc tỉ lệ 20 giống nút trên
                      ),
                      child: const Text(
                        "Pricing Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          // Xóa gạch chân cũ đi nhìn cho sạch và hợp form viền mới ông nhé
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
      ],
    );
  }
}
