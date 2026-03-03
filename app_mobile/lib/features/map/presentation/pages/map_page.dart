import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/court_marker.dart';
import '../widgets/map_pin_widget.dart';
import '../widgets/sport_filter_chip.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  LatLng _currentLocation = const LatLng(
    10.8231,
    106.6297,
  ); // Ho Chi Minh City default
  final List<Marker> _markers = [];
  bool _isLoading = true;
  String? _selectedSportFilter; // null means show all
  String? _selectedCourtId; // Track selected court marker
  String _searchQuery = ''; // Search text
  bool _showSuggestions = false; // Control suggestion dropdown visibility

  // Mock court markers data - structured for backend integration
  // Backend endpoint: GET /api/courts/nearby?lat={lat}&lng={lng}&radius={radius}
  final List<CourtMarker> _courtMarkers = [
    CourtMarker(
      id: '1',
      courtName: 'Thanh Phat Football Pitch',
      sportType: 'Football',
      location: const LatLng(10.8231, 106.6297),
      address: '123 Luy Ban Bich, Tan Phu, HCMC',
      rating: 4.0,
      reviewCount: 120,
      pricePerHour: 150000,
      facilities: ['Parking', 'Shower', 'Locker'],
      isAvailable: true,
    ),
    CourtMarker(
      id: '2',
      courtName: 'Central Sports Complex',
      sportType: 'Basketball',
      location: const LatLng(10.7769, 106.7009),
      address: '456 Le Loi, District 1, HCMC',
      rating: 4.5,
      reviewCount: 200,
      pricePerHour: 200000,
      facilities: ['Parking', 'Shower', 'Locker', 'Cafe'],
      isAvailable: true,
    ),
    CourtMarker(
      id: '3',
      courtName: 'Golden Star Tennis Court',
      sportType: 'Tennis',
      location: const LatLng(10.7881, 106.6844),
      address: '789 Nguyen Thi Minh Khai, District 3, HCMC',
      rating: 4.2,
      reviewCount: 85,
      pricePerHour: 180000,
      facilities: ['Parking', 'Shower'],
      isAvailable: true,
    ),
    CourtMarker(
      id: '4',
      courtName: 'Sunrise Volleyball Arena',
      sportType: 'Volleyball',
      location: const LatLng(10.7950, 106.7200),
      address: '321 Pham Ngu Lao, District 1, HCMC',
      rating: 4.3,
      reviewCount: 95,
      pricePerHour: 120000,
      facilities: ['Parking', 'Locker'],
      isAvailable: false,
    ),
    CourtMarker(
      id: '5',
      courtName: 'Victory Football Field',
      sportType: 'Football',
      location: const LatLng(10.8100, 106.6500),
      address: '555 Tran Hung Dao, District 5, HCMC',
      rating: 4.1,
      reviewCount: 150,
      pricePerHour: 160000,
      facilities: ['Parking', 'Shower', 'Cafe'],
      isAvailable: true,
    ),
    CourtMarker(
      id: '6',
      courtName: 'Elite Basketball Court',
      sportType: 'Basketball',
      location: const LatLng(10.7650, 106.6800),
      address: '888 Le Duan, District 1, HCMC',
      rating: 4.7,
      reviewCount: 220,
      pricePerHour: 250000,
      facilities: ['Parking', 'Shower', 'Locker', 'Cafe', 'Gym'],
      isAvailable: true,
    ),
    CourtMarker(
      id: '7',
      courtName: 'City Tennis Club',
      sportType: 'Tennis',
      location: const LatLng(10.8300, 106.6400),
      address: '999 Nguyen Van Cu, Tan Binh, HCMC',
      rating: 4.4,
      reviewCount: 180,
      pricePerHour: 220000,
      facilities: ['Parking', 'Shower', 'Locker', 'Cafe'],
      isAvailable: true,
    ),
    CourtMarker(
      id: '8',
      courtName: 'Paradise Football Ground',
      sportType: 'Football',
      location: const LatLng(10.7700, 106.6950),
      address: '111 Hai Ba Trung, District 3, HCMC',
      rating: 3.9,
      reviewCount: 75,
      pricePerHour: 140000,
      facilities: ['Parking'],
      isAvailable: true,
    ),
    CourtMarker(
      id: '9',
      courtName: 'Champion Basketball Arena',
      sportType: 'Basketball',
      location: const LatLng(10.8050, 106.7100),
      address: '222 Xo Viet Nghe Tinh, Binh Thanh, HCMC',
      rating: 4.6,
      reviewCount: 190,
      pricePerHour: 230000,
      facilities: ['Parking', 'Shower', 'Locker', 'Cafe'],
      isAvailable: true,
    ),
  ];

  // Sport filter options
  final List<Map<String, dynamic>> _sportFilters = [
    {
      'name': 'Football',
      'color': const Color(0xFF00FF00),
      'icon': Icons.sports_soccer,
    },
    {
      'name': 'Tennis',
      'color': const Color(0xFF7CB342),
      'icon': Icons.sports_tennis,
    },
    {
      'name': 'Basketball',
      'color': const Color(0xFFFF6600),
      'icon': Icons.sports_basketball,
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _addMarkers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Get filtered court suggestions for search
  List<CourtMarker> _getSearchSuggestions() {
    if (_searchQuery.isEmpty) {
      return [];
    }

    final query = _searchQuery.toLowerCase();
    return _courtMarkers
        .where((court) {
          final courtName = court.courtName.toLowerCase();
          final address = court.address.toLowerCase();
          final sportType = court.sportType.toLowerCase();

          return courtName.contains(query) ||
              address.contains(query) ||
              sportType.contains(query);
        })
        .take(5)
        .toList(); // Limit to 5 suggestions
  }

  // Handle selecting a court from suggestions
  void _selectCourtFromSuggestion(CourtMarker court) {
    setState(() {
      _selectedCourtId = court.id;
      _searchQuery = court.courtName;
      _searchController.text = court.courtName;
      _showSuggestions = false;
    });
    _searchFocusNode.unfocus();
    _addMarkers();
    _mapController.move(court.location, 16); // Zoom to selected court
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      _mapController.move(_currentLocation, 14);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _addMarkers() {
    // Filter courts based on selected sport and search query
    var filteredCourts = _courtMarkers.toList();

    // Apply sport filter
    if (_selectedSportFilter != null) {
      filteredCourts = filteredCourts
          .where((court) => court.sportType == _selectedSportFilter)
          .toList();
    }

    // Apply search filter (case-insensitive)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredCourts = filteredCourts.where((court) {
        final courtName = court.courtName.toLowerCase();
        final address = court.address.toLowerCase();
        final sportType = court.sportType.toLowerCase();

        return courtName.contains(query) ||
            address.contains(query) ||
            sportType.contains(query);
      }).toList();
    }

    _markers.clear();

    // Add custom pin markers for each filtered court
    for (final court in filteredCourts) {
      _markers.add(
        Marker(
          point: court.location,
          width: 50,
          height: 60,
          child: MapPinWidget(
            sportType: court.sportType,
            isSelected: _selectedCourtId == court.id,
            onTap: () {
              setState(() {
                _selectedCourtId = court.id;
              });
              _showCourtDetails(court);
            },
          ),
        ),
      );
    }
  }

  void _showCourtDetails(CourtMarker court) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Court name and sport type badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    court.courtName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getSportColor(
                      court.sportType,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getSportColor(court.sportType),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    court.sportType,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getSportColor(court.sportType),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Address
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    court.address,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Rating and price
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: AppColors.starYellow),
                const SizedBox(width: 4),
                Text(
                  '${court.rating} (${court.reviewCount} reviews)',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${court.pricePerHour.toStringAsFixed(0)}đ/hour',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Facilities
            if (court.facilities.isNotEmpty) ...[
              const Text(
                'Facilities',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: court.facilities
                    .map(
                      (facility) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundGray,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          facility,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Availability status
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: court.isAvailable
                        ? AppColors.primaryGreen
                        : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  court.isAvailable ? 'Available Now' : 'Currently Booked',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: court.isAvailable
                        ? AppColors.primaryGreen
                        : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement directions - integrate with Google Maps/Apple Maps
                      // Example: launch('https://maps.google.com/?q=${court.location.latitude},${court.location.longitude}')
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: court.isAvailable
                        ? () {
                            Navigator.pop(context);
                            // TODO: Navigate to booking page with court data
                            // Example: Navigator.push(context, MaterialPageRoute(builder: (_) => BookingPage(court: court)))
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Booking ${court.courtName}... (Backend integration pending)',
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.textWhite,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getSportColor(String sportType) {
    switch (sportType.toLowerCase()) {
      case 'football':
      case 'soccer':
        return const Color(0xFF00FF00);
      case 'basketball':
        return const Color(0xFFFF6600);
      case 'tennis':
        return const Color(0xFF7CB342);
      case 'volleyball':
        return Colors.grey;
      default:
        return AppColors.primaryGreen;
    }
  }

  IconData _getSportIcon(String sportType) {
    switch (sportType.toLowerCase()) {
      case 'football':
      case 'soccer':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      case 'tennis':
        return Icons.sports_tennis;
      case 'volleyball':
        return Icons.sports_volleyball;
      default:
        return Icons.sports_soccer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 14,
              minZoom: 5,
              maxZoom: 18,
            ),
            children: [
              // Map tiles from OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.booking_sport',
                maxZoom: 19,
              ),

              // Markers layer
              MarkerLayer(markers: _markers),

              // User location marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation,
                    width: 60,
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer pulse circle
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryBlue.withValues(alpha: 0.2),
                          ),
                        ),
                        // Inner dot
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryBlue,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Top section with search and filters
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search bar
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Search icon
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      // Search field
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Search courts near you...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                              _selectedCourtId =
                                  null; // Clear selection when searching
                              _showSuggestions = value.isNotEmpty;
                            });
                            _addMarkers();
                          },
                          onTap: () {
                            setState(() {
                              _showSuggestions = _searchQuery.isNotEmpty;
                            });
                          },
                        ),
                      ),

                      // Clear search button (show only when there's text)
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                              _selectedCourtId = null;
                              _showSuggestions = false;
                            });
                            _addMarkers();
                          },
                        ),

                      // Filter button
                      IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: () {
                          // TODO: Show advanced filter options (price range, rating, etc.)
                        },
                      ),
                    ],
                  ),
                ),

                // Search suggestions dropdown
                if (_showSuggestions && _getSearchSuggestions().isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      maxHeight: 250, // Limit height to 5 items
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _getSearchSuggestions().length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: AppColors.backgroundGray),
                      itemBuilder: (context, index) {
                        final court = _getSearchSuggestions()[index];
                        return InkWell(
                          onTap: () => _selectCourtFromSuggestion(court),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                // Sport icon
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: _getSportColor(
                                      court.sportType,
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getSportIcon(court.sportType),
                                    size: 20,
                                    color: _getSportColor(court.sportType),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Court info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        court.courtName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              court.address,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Sport badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getSportColor(
                                      court.sportType,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    court.sportType,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: _getSportColor(court.sportType),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Sport filter chips
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // "All" filter
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSportFilter = null;
                              _selectedCourtId = null;
                              _showSuggestions = false;
                            });
                            _searchFocusNode.unfocus();
                            _addMarkers();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedSportFilter == null
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedSportFilter == null
                                    ? AppColors.primaryBlue
                                    : Colors.grey.shade300,
                                width: _selectedSportFilter == null ? 2 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'All Sports',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: _selectedSportFilter == null
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: _selectedSportFilter == null
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Sport filters
                      ..._sportFilters.map((filter) {
                        final isSelected =
                            _selectedSportFilter == filter['name'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: SportFilterChip(
                            sportName: filter['name'] as String,
                            color: filter['color'] as Color,
                            icon: filter['icon'] as IconData,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedSportFilter = filter['name'] as String;
                                _selectedCourtId = null;
                                _showSuggestions = false;
                              });
                              _searchFocusNode.unfocus();
                              _addMarkers();
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: AppColors.backgroundWhite.withValues(alpha: 0.8),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryBlue,
                  ),
                ),
              ),
            ),

          // My location button
          Positioned(
            right: 16,
            bottom: 100,
            child: FloatingActionButton(
              backgroundColor: AppColors.backgroundWhite,
              onPressed: () {
                _mapController.move(_currentLocation, 14);
              },
              child: const Icon(
                Icons.my_location,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
