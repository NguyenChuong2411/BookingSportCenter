import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback onBookNow;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(
          12,
        ), // Tạo khoảng cách thở bên trong thẻ trắng
        decoration: BoxDecoration(
          color: Colors.white, // ĐÚNG YÊU CẦU: Màu nền card trắng tinh khôi
          borderRadius: BorderRadius.circular(20), // Bo góc mềm mại
          boxShadow: [
            // ĐÚNG YÊU CẦU: Hiệu ứng đổ bóng mờ nhẹ, sâu và sang trọng
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= 1. KHỐI ẢNH SỰ KIỆN (BÊN TRÁI) =================
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SizedBox(
                    width: 110,
                    height: 110,
                    child: Image.network(
                      event.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xff1B15FF), Color(0xff100D98)],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.event,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Badge giảm giá/khuyến mãi (Nằm đè nhẹ lên góc trên ảnh)
                if (event.discount != null || event.discountedPrice != null)
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event.discountText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // ================= 2. KHỐI THÔNG TIN CHỮ & NÚT BẤM (BÊN PHẢI) =================
            Expanded(
              child: SizedBox(
                height:
                    110, // Đồng bộ chiều cao bằng khít với khối ảnh bên trái
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Đẩy nút xuống đáy card
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên/Tiêu đề sự kiện (Giới hạn tối đa 1 dòng để tránh vỡ khung)
                        Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Mô tả ngắn sự kiện (Giới hạn 2 dòng mờ, tạo chiều sâu giao diện)
                        Text(
                          event.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),

                    // Hàng chứa Giá tiền và nút Book Now nằm dưới đáy Card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Hiển thị giá (Nếu có giá ưu đãi)
                        if (event.originalPrice != null &&
                            event.discountedPrice != null)
                          Text(
                            '\$${event.discountedPrice!.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          )
                        else
                          const Text(
                            'Free / Join',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),

                        // NÚT BOOK NOW DẠNG CAPSULE GỌN GÀNG GÓC PHẢI
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: onBookNow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors
                                  .primaryBlue, // Đổi sang màu xanh chủ đạo cho đồng bộ thương hiệu
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Book now',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
