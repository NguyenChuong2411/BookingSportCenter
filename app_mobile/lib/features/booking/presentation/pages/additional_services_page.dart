import 'package:flutter/material.dart';

class ServiceItem {
  final String id;
  final String title;
  final double price;
  final String category;
  final Widget imageChild;

  ServiceItem({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.imageChild,
  });
}

class AdditionalServicesPage extends StatefulWidget {
  const AdditionalServicesPage({super.key});

  @override
  State<AdditionalServicesPage> createState() => _AdditionalServicesPageState();
}

class _AdditionalServicesPageState extends State<AdditionalServicesPage> {
  // Lưu số lượng sản phẩm được chọn (không hardcode ban đầu)
  final Map<String, int> _cartQuantities = {};

  // Tìm kiếm + filter
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  // Danh sách dịch vụ (data-driven)
  late final List<ServiceItem> _allServices = [
    ServiceItem(
      id: "Yonex Super Grap Spool",
      title: "Yonex Super Grap Spool",
      price: 13.59,
      category: "Grip Tape",
      imageChild: const Icon(
        Icons.album_outlined,
        size: 40,
        color: Colors.orange,
      ),
    ),
    ServiceItem(
      id: "Aquafina 500ml",
      title: "Aquafina 500ml",
      price: 2.00,
      category: "Bottled Water",
      imageChild: const Icon(
        Icons.local_drink_outlined,
        size: 40,
        color: Colors.blue,
      ),
    ),
    ServiceItem(
      id: "Dasani 500ml",
      title: "Dasani 500ml",
      price: 2.00,
      category: "Bottled Water",
      imageChild: const Icon(
        Icons.water_drop_outlined,
        size: 40,
        color: Colors.cyan,
      ),
    ),
    ServiceItem(
      id: "Pocari 500ml",
      title: "Pocari 500ml",
      price: 5.99,
      category: "Sports Drink",
      imageChild: const Icon(Icons.bolt, size: 40, color: Colors.blueAccent),
    ),
    ServiceItem(
      id: "Revive zero calo 500ml",
      title: "Revive zero calo 500ml",
      price: 5.99,
      category: "Sports Drink",
      imageChild: const Icon(Icons.reorder, size: 40, color: Colors.green),
    ),
    ServiceItem(
      id: "ECCO Black socks",
      title: "ECCO Black socks",
      price: 5.99,
      category: "Socks",
      imageChild: const Icon(Icons.layers, size: 40, color: Colors.black87),
    ),
  ];

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                      // 4+. Danh sách dịch vụ động theo filter và search
                      Builder(
                        builder: (context) {
                          final query = _searchController.text
                              .trim()
                              .toLowerCase();
                          final categories = [
                            'All',
                            ...{for (var s in _allServices) s.category},
                          ];

                          final List<Widget> blocks = [];
                          for (final cat in categories) {
                            final items = _allServices.where((s) {
                              final matchesCatLoop = cat == 'All'
                                  ? true
                                  : s.category == cat;
                              final matchesSearch =
                                  query.isEmpty ||
                                  s.title.toLowerCase().contains(query);
                              final matchesSelectedCategory =
                                  _selectedCategory == 'All' ||
                                  s.category == _selectedCategory;
                              return matchesCatLoop &&
                                  matchesSearch &&
                                  matchesSelectedCategory;
                            }).toList();

                            if (items.isEmpty) continue;
                            blocks.add(_buildSectionTitle(cat));
                            for (final item in items) {
                              blocks.add(
                                _buildServiceCard(
                                  id: item.id,
                                  title: item.title,
                                  priceText:
                                      '\$${item.price.toStringAsFixed(2)}',
                                  imageChild: item.imageChild,
                                ),
                              );
                              blocks.add(const SizedBox(height: 12));
                            }
                            blocks.add(const SizedBox(height: 8));
                          }

                          if (blocks.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: Text('No services found')),
                            );
                          }
                          return Column(children: blocks);
                        },
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
              height: 64,
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

                    // Tính tổng dựa trên _allServices
                    final priceLookup = {
                      for (var s in _allServices) s.id: s.price,
                    };
                    _cartQuantities.forEach((id, qty) {
                      totalItems += qty;
                      totalServicePrice += (priceLookup[id] ?? 0.0) * qty;
                    });

                    return Column(
                      mainAxisSize: MainAxisSize.min,
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
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "$totalItems items | Total: \$${totalServicePrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
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
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: "Find the services",
          hintStyle: TextStyle(color: Colors.black26, fontSize: 14),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: InputBorder.none,
          suffixIcon: Icon(Icons.search, color: Color(0xff1B15FF), size: 22),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  // Danh sách bọc hàng ngang các từ khóa danh mục
  Widget _buildCategoryChips() {
    final categories = [
      'All',
      ...{for (var s in _allServices) s.category},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final selected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xff2A25FF) : Colors.white,
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
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
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
