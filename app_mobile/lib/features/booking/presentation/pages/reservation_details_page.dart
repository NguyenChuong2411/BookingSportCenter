import 'package:flutter/material.dart';
import 'package:booking_sport/features/booking/presentation/pages/additional_services_page.dart';
import 'package:booking_sport/core/services/booking_api_service.dart';
import '../../data/models/time_slot_model.dart';

class ReservationDetailsPage extends StatefulWidget {
  final String bookingId;
  final List<TimeSlot> bookedSlots;
  final DateTime bookingDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double? courtPrice;
  final double? depositAmount;

  const ReservationDetailsPage({
    super.key,
    required this.bookingId,
    required this.bookedSlots,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    this.courtPrice,
    this.depositAmount,
  });

  @override
  State<ReservationDetailsPage> createState() => _ReservationDetailsPageState();
}

class _ReservationDetailsPageState extends State<ReservationDetailsPage>
    with WidgetsBindingObserver {
  // Bộ điều khiển Form nhập liệu khách hàng
  final TextEditingController _nameController = TextEditingController(
    text: "Minh Sang Le",
  );
  final TextEditingController _phoneController = TextEditingController(
    text: "0912345678",
  );
  final TextEditingController _noteController = TextEditingController();

  // Map lưu trữ danh sách dịch vụ mua kèm nhận từ trang Additional Services gửi về
  Map<String, int> _selectedServices = {};

  // Danh mục giá niêm yết cố định phục vụ thuật toán cộng tiền động
  final Map<String, double> _servicePrices = {
    "Yonex Super Grap Spool": 13.59,
    "Aquafina 500ml": 2.00,
    "Dasani 500ml": 2.00,
    "Pocari 500ml": 5.99,
    "Revive zero calo 500ml": 5.99,
    "ECCO Black socks": 5.99,
  };

  bool _shouldCancelOnExit = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _cancelBookingIfNeeded();
    }
  }

  // TÍNH TIỀN SÂN + DỊCH VỤ (báo giá - khách trả tại sân, không thanh toán online)
  double _calculateTotalPrice(double courtPrice) {
    double serviceTotal = 0.0;
    _selectedServices.forEach((id, qty) {
      double priceEach = _servicePrices[id] ?? 0.0;
      serviceTotal += priceEach * qty;
    });

    return courtPrice + serviceTotal; // = tiền sân + dịch vụ
  }

  double _calculateCourtPriceFromSlots() {
    const slotMinutes = 30;
    final slotHours = slotMinutes / 60.0;
    double total = 0.0;
    for (final slot in widget.bookedSlots) {
      total += slot.pricePerHour * slotHours;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final courtPrice = widget.courtPrice ?? _calculateCourtPriceFromSlots();
    double finalTotal = _calculateTotalPrice(courtPrice);
    double currentPitchPrice = courtPrice;

    // Tính toán tổng thời gian động dựa vào số lượng slot thực tế người dùng đã tích chọn
    int totalMinutes = widget.bookedSlots.length * 30;
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    String durationText = "${hours}h${minutes.toString().padLeft(2, '0')}";

    // Bóc tách tên sân động từ danh sách dữ liệu truyền sang (Mặc định phòng hờ là Court 3)
    String courtName = widget.bookedSlots.isNotEmpty
        ? (widget.bookedSlots.first.courtName ??
              widget.bookedSlots.first.courtId)
        : "3";

    return WillPopScope(
      onWillPop: () async {
        await _cancelBookingIfNeeded();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // ================= 1. HEADER GRADIENT XANH DƯƠNG =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
                bottom: 25,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xff1B15FF), Color(0xff100D98)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () async {
                      await _cancelBookingIfNeeded();
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: 40,
                        ), // Cân bằng trục chữ trung tâm
                        child: Text(
                          "Reservation Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================= LIST THÀNH PHẦN NỘI DUNG CUỘN ĐƯỢC =================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. THẺ COURT INFORMATION
                    _buildCardInfo(
                      icon: const Icon(
                        Icons.map_outlined,
                        color: Color(0xff1B15FF),
                      ),
                      title: "Court information",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Court: $courtName",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Address: (updating)",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. THẺ RESERVATION DETAILS (DỮ LIỆU ĐỘNG)
                    _buildCardInfo(
                      icon: const Icon(
                        Icons.cloud_queue,
                        color: Color(0xff1B15FF),
                      ),
                      title: "Reservation details",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Date: ${_formatDate(widget.bookingDate)}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            "Time: ${_formatTime(widget.startTime)} - ${_formatTime(widget.endTime)}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSubDetailItem("Court", courtName),
                              _buildSubDetailItem("Total time", durationText),
                              _buildSubDetailItem(
                                "Price",
                                "\$${currentPitchPrice.toStringAsFixed(2)}",
                                isPrice: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. THẺ SERVICES CHỨA ĐỒ UỐNG / PHỤ KIỆN (CHỈ XUẤT HIỆN KHI CÓ DATA)
                    if (_selectedServices.isNotEmpty) ...[
                      _buildCardInfo(
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Color(0xff1B15FF),
                        ),
                        title: "Services",
                        child: Column(
                          children: _selectedServices.entries.map((entry) {
                            double itemTotal =
                                (_servicePrices[entry.key] ?? 0.0) *
                                entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${entry.key} x${entry.value}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "\$${itemTotal.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 5. NÚT ĐIỀU HƯỚNG SANG TRANG DỊCH VỤ
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Gọi trang dịch vụ và đợi kết quả trả về từ lệnh Navigator.pop
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdditionalServicesPage(),
                            ),
                          );

                          // Nếu nhận được dữ liệu, tiến hành setState tái tạo giao diện tính tiền
                          if (result != null && result is Map<String, int>) {
                            setState(() {
                              _selectedServices = result;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2A25FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          "Additional Services",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 6. KHỐI FORM Ô NHẬP THÔNG TIN KHÁCH HÀNG
                    _buildInputFieldLabel("Name"),
                    _buildTextField(
                      controller: _nameController,
                      iconClose: true,
                    ),
                    const SizedBox(height: 16),

                    _buildInputFieldLabel("Phone"),
                    _buildTextField(
                      controller: _phoneController,
                      iconClose: true,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    _buildInputFieldLabel("Note for Owner"),
                    _buildTextField(
                      controller: _noteController,
                      hintText: "Add a note ...",
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // 7. KHỐI THÔNG BÁO ĐIỀU KHOẢN CHÍNH SÁCH SÂN (NOTICE CARD)
                    _buildNoticeCard(),
                    const SizedBox(height: 30),

                    // 8. NÚT XÁC NHẬN ĐẶT LỊCH & HIỂN THỊ BÁOO GIÁ
                    // (Khách sẽ trả tiền tại sân - không thanh toán online)
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 180,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _confirmBooking(context, finalTotal);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1B15FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            // Hiển thị báo giá tổng (sân + dịch vụ)
                            "Confirm \$${finalTotal.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CÁC WIDGET CUSTOM ĐƯỢC MODULARIZE TỐI ƯU SẠCH SẼ =================

  Widget _buildCardInfo({
    required Widget icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              icon,
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSubDetailItem(
    String label,
    String value, {
    bool isPrice = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isPrice ? 18 : 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildInputFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.black,
        ),
      ),
    );
  }

  Future<void> _confirmBooking(BuildContext context, double totalPrice) async {
    try {
      final response = await BookingApiService.completeBooking(
        widget.bookingId,
      );
      final status = response['status']?.toString();

      _shouldCancelOnExit = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == null ? "Booking completed" : "Booking completed: $status",
          ),
        ),
      );

      if (mounted) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context, true);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _cancelBookingIfNeeded() async {
    if (!_shouldCancelOnExit) {
      return;
    }

    try {
      await BookingApiService.cancelBooking(widget.bookingId);
    } catch (_) {
      // Ignore cancel errors on exit
    } finally {
      _shouldCancelOnExit = false;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return "$day/$month/$year";
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    bool iconClose = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black26),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
          suffixIcon: iconClose
              ? IconButton(
                  icon: const Icon(
                    Icons.cancel,
                    color: Color(0xff1B15FF),
                    size: 18,
                  ),
                  onPressed: () => controller.clear(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.yellow[700],
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                "Notice",
                style: TextStyle(
                  color: Color(0xff1B15FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNoticeBullet(
            "Payment is made directly between you and the field owner.",
          ),
          _buildNoticeBullet(
            "Spot On acts solely as a platform to help you find and book fields more easily.",
          ),
          _buildNoticeBullet(
            "Each field may have its own rules and policies—please take a moment to review them to protect your rights.",
          ),
          const SizedBox(height: 12),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text:
                      "By tapping Confirm Booking, you confirm that you have read and agreed to the ",
                ),
                TextSpan(
                  text: "Booking Term",
                  style: TextStyle(
                    color: Color(0xff1B15FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: ", "),
                TextSpan(
                  text: "Refund Policy",
                  style: TextStyle(
                    color: Color(0xff1B15FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: ", and "),
                TextSpan(
                  text: "Cancellation Policy",
                  style: TextStyle(
                    color: Color(0xff1B15FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: "."),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "- ",
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
