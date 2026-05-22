import 'package:flutter/material.dart';

class AdditionalServicesPage extends StatefulWidget {
  const AdditionalServicesPage({super.key});

  @override
  State<AdditionalServicesPage> createState() => _AdditionalServicesPageState();
}

class _AdditionalServicesPageState extends State<AdditionalServicesPage> {
  // Giả lập lưu số lượng sản phẩm được chọn (Dùng Map với ID hoặc Tên sản phẩm)
  final Map<String, int> _cartQuantities = {
    "Aquafina 500ml": 1,
    "Dasani 500ml": 1, // Đổi tên sản phẩm thứ 2 cho khác biệt
  };

  // Hàm xử lý tăng giảm số lượng nước/phụ kiện
  void _updateQuantity(String productName, int change) {
    setState(() {
      int current = _cartQuantities[productName] ?? 0;
      int newValue = current + change;
      if (newValue <= 0) {
        _cartQuantities.remove(productName);
      } else {
        _cartQuantities[productName] = newValue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Nền trắng toàn bộ theo ảnh mockup của ông
      body: Stack(
        children: [
          Column(
            children: [
              // ================= 1. HEADER GRADIENT (Có nút Back) =================
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
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(right: 40),
                          child: Text(
                            "Additional Services", // Sửa chính tả chữ Addtional từ ảnh của ông nha
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

              // ================= DANH SÁCH DỊCH VỤ / SẢN PHẨM CUỘN ĐƯỢC =================
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: 100,
                  ), // Bottom padding rộng để tránh bị thanh toán đè
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. THANH TÌM KIẾM (SEARCH BAR)
                      _buildSearchBar(),
                      const SizedBox(height: 16),

                      // 3. DANH SÁCH TAG LỌC NHANH (CATEGORY CHIPS)
                      _buildCategoryChips(),
                      const SizedBox(height: 20),

                      // 4. NHÓM SẢN PHẨM: GRIP TAPE
                      _buildSectionTitle("Grip Tape"),
                      _buildServiceCard(
                        id: "Yonex Super Grap Spool",
                        title: "Yonex Super Grap Spool",
                        priceText: "\$13.59 / pack",
                        imageChild: const Icon(
                          Icons.album_outlined,
                          size: 40,
                          color: Colors.orange,
                        ), // Giả lập ảnh cuộn quấn cán
                      ),
                      const SizedBox(height: 16),

                      // 5. NHÓM SẢN PHẨM: BOTTLED WATER
                      _buildSectionTitle("Bottled Water"),
                      _buildServiceCard(
                        id: "Aquafina 500ml",
                        title: "Aquafina 500ml",
                        priceText: "\$2.00 / bottle",
                        imageChild: const Icon(
                          Icons.local_drink_outlined,
                          size: 40,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildServiceCard(
                        id: "Dasani 500ml",
                        title: "Dasani 500ml",
                        priceText: "\$2.00 / bottle",
                        imageChild: const Icon(
                          Icons.water_drop_outlined,
                          size: 40,
                          color: Colors.cyan,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 6. NHÓM SẢN PHẨM: SPORTS DRINK
                      _buildSectionTitle("Sports Drink"),
                      _buildServiceCard(
                        id: "Pocari 500ml",
                        title: "Pocari 500ml",
                        priceText: "\$5.99 / bottle",
                        imageChild: const Icon(
                          Icons.bolt,
                          size: 40,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildServiceCard(
                        id: "Revive zero calo 500ml",
                        title: "Revive zero calo 500ml",
                        priceText: "\$5.99 / bottle",
                        imageChild: const Icon(
                          Icons.reorder,
                          size: 40,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 7. NHÓM SẢN PHẨM: SOCKS
                      _buildSectionTitle("Socks"),
                      _buildServiceCard(
                        id: "ECCO Black socks",
                        title: "ECCO Black socks",
                        priceText: "\$5.99 / pair",
                        imageChild: const Icon(
                          Icons.layers,
                          size: 40,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ================= 8. THANH TỔNG KẾT GHIM ĐÁY (ADD TO CART BAR) =================
          // ================= ADDITIONAL SERVICES PAGE (CẬP NHẬT THANH GHIM ĐÁY ĐỘNG) =================
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff2A25FF), Color(0xff100D98)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff1B15FF).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Trả Map chứa danh sách sản phẩm và số lượng đã chọn về màn hình trước
                  Navigator.pop(context, _cartQuantities);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    // Tính toán số lượng và tổng tiền dịch vụ hiển thị động dưới nút
                    int totalItems = 0;
                    double totalServicePrice = 0.0;

                    // Bảng giá để tính toán nhanh hiển thị
                    final Map<String, double> prices = {
                      "Yonex Super Grap Spool": 13.59,
                      "Aquafina 500ml": 2.00,
                      "Dasani 500ml": 2.00,
                      "Pocari 500ml": 5.99,
                      "Revive zero calo 500ml": 5.99,
                      "ECCO Black socks": 5.99,
                    };

                    _cartQuantities.forEach((id, qty) {
                      totalItems += qty;
                      totalServicePrice += (prices[id] ?? 0.0) * qty;
                    });

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Add to cart",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (totalItems > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            "$totalItems items | Total: \$${totalServicePrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Khung ô Tìm kiếm có nút kính lúp mờ bên phải
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Find the services",
          hintStyle: TextStyle(color: Colors.black26, fontSize: 14),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: InputBorder.none,
          suffixIcon: Icon(Icons.search, color: Color(0xff1B15FF), size: 22),
        ),
      ),
    );
  }

  // Danh sách bọc hàng ngang các từ khóa danh mục
  Widget _buildCategoryChips() {
    final categories = ["Grip Tape", "Bottled Water", "Sports Drink", "Socks"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              cat,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xff1B15FF),
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  // Widget custom thẻ dịch vụ đổ bóng bo góc kèm nút tăng giảm số lượng
  Widget _buildServiceCard({
    required String id,
    required String title,
    required String priceText,
    required Widget imageChild,
  }) {
    int currentQty = _cartQuantities[id] ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Khung bọc ảnh sản phẩm
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withOpacity(0.03)),
            ),
            child: Center(
              child: imageChild,
            ), // Sau này ông đổi thành Image.asset hoặc Image.network nhé
          ),
          const SizedBox(width: 14),

          // Cột chữ thông tin tên và giá
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  priceText,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          // XỬ LÝ NÚT BẤM (ADD HOẶC THANH TĂNG GIẢM ĐỘNG)
          currentQty == 0
              ? OutlinedButton(
                  onPressed: () => _updateQuantity(id, 1),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xff1B15FF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    "Add",
                    style: TextStyle(
                      color: Color(0xff1B15FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xff2A25FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed: () => _updateQuantity(id, -1),
                      ),
                      Text(
                        "$currentQty",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                        onPressed: () => _updateQuantity(id, 1),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
