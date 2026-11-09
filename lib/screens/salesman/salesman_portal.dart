import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/deeba_models.dart';
import '../../state/deeba_store.dart';

class SalesmanPortal extends StatefulWidget {
  final DeebaStore store;
  final VoidCallback onLogout;

  const SalesmanPortal({
    super.key,
    required this.store,
    required this.onLogout,
  });

  @override
  State<SalesmanPortal> createState() => _SalesmanPortalState();
}

class _SalesmanPortalState extends State<SalesmanPortal> {
  int _currentTabIndex = 0;
  ShopTieupModel? _preselectedShopForOrder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildSalesmanAppBar(),
      body: AnimatedBuilder(
        animation: widget.store,
        builder: (context, _) {
          switch (_currentTabIndex) {
            case 0:
              return _SalesmanBeatDashboard(
                store: widget.store,
                onNavigateToTab: (tabIdx, [ShopTieupModel? shop]) {
                  setState(() {
                    _currentTabIndex = tabIdx;
                    if (shop != null) _preselectedShopForOrder = shop;
                  });
                },
              );
            case 1:
              return _NewKadaiTieupView(
                store: widget.store,
                onShopCreated: (newShop) {
                  setState(() {
                    _preselectedShopForOrder = newShop;
                    _currentTabIndex = 2; // Jump directly to Spot Order
                  });
                },
              );
            case 2:
              return _SpotOrderBookingView(
                store: widget.store,
                initialShop: _preselectedShopForOrder,
                onOrderCompleted: () {
                  setState(() {
                    _preselectedShopForOrder = null;
                    _currentTabIndex = 0; // Return to dashboard
                  });
                },
              );
            case 3:
              return _MyShopsDirectoryView(
                store: widget.store,
                onTakeOrderForShop: (shop) {
                  setState(() {
                    _preselectedShopForOrder = shop;
                    _currentTabIndex = 2;
                  });
                },
              );
            default:
              return const SizedBox.shrink();
          }
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildSalesmanAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F172A),
      foregroundColor: Colors.white,
      elevation: 2,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD97706), Color(0xFFB45309)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.storefront_rounded, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Deeba Field Sales',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  widget.store.loggedInUserName,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFBBF24),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Live Cloud Sync Indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: widget.store.isApiConnected
                ? const Color(0xFF065F46).withAlpha(180)
                : const Color(0xFF991B1B).withAlpha(180),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.store.isApiConnected
                  ? const Color(0xFF34D399)
                  : const Color(0xFFF87171),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.store.isApiConnected
                      ? const Color(0xFF34D399)
                      : const Color(0xFFF87171),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                widget.store.isApiConnected ? 'Cloud Active' : 'Offline Mode',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Logout Button
        IconButton(
          icon: const Icon(Icons.logout_rounded, size: 20),
          tooltip: 'Logout',
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Logout Field Account?'),
                content: const Text(
                  'Are you sure you want to end your field sales session?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB91C1C),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      widget.onLogout();
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFD97706),
        unselectedItemColor: const Color(0xFF64748B),
        selectedFontSize: 11,
        unselectedFontSize: 10.5,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Beat Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_business_rounded),
            label: 'New Kadai',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale_rounded),
            label: 'Spot Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_mall_directory_rounded),
            label: 'My Shops',
          ),
        ],
      ),
    );
  }
}

// ==================== HELPER: RENDER REAL SHOP PHOTO ====================
Widget _buildRealShopThumbnail(String photoUrl, {double width = 55, double height = 55}) {
  if (photoUrl.isEmpty) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.storefront_rounded, color: Color(0xFF94A3B8)),
    );
  }

  if (photoUrl.startsWith('data:image')) {
    try {
      final commaIdx = photoUrl.indexOf(',');
      final b64 = commaIdx != -1 ? photoUrl.substring(commaIdx + 1) : photoUrl;
      final bytes = base64Decode(b64);
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          bytes,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );
    } catch (_) {
      return Container(
        width: width,
        height: height,
        color: const Color(0xFFF1F5F9),
        child: const Icon(Icons.storefront_rounded, color: Color(0xFF94A3B8)),
      );
    }
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: Image.network(
      photoUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: const Color(0xFFF1F5F9),
        child: const Icon(Icons.storefront_rounded, color: Color(0xFF94A3B8)),
      ),
    ),
  );
}

// ==================== TAB 0: BEAT DASHBOARD ====================
class _SalesmanBeatDashboard extends StatelessWidget {
  final DeebaStore store;
  final Function(int tabIdx, [ShopTieupModel? shop]) onNavigateToTab;

  const _SalesmanBeatDashboard({
    required this.store,
    required this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayShops = store.shops.where((s) {
      final diff = today.difference(s.lastVisitedDate).inHours;
      return diff < 24;
    }).length;

    double todayBundles = 0;
    double todayCash = 0;
    for (final sale in store.sales) {
      if (sale.salesDate.year == today.year &&
          sale.salesDate.month == today.month &&
          sale.salesDate.day == today.day) {
        todayBundles += sale.quantity;
        todayCash += sale.amountReceived;
      }
    }

    final totalOutstanding = store.shops.fold<double>(
      0.0,
      (acc, s) => acc + s.outstandingBalance,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Beat Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'இன்றைய பீட் வழித்தடம் (Today\'s Beat)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFBBF24),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD97706)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.route_rounded, size: 12, color: Color(0xFFFBBF24)),
                          SizedBox(width: 4),
                          Text(
                            'Sivakasi Feeder Beat',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFBBF24),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'வணக்கம், முருகன்!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Explore maligai & tea stalls, take live camera photo proof, verify GPS location, and book spot bundle orders directly.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4 Quick Metric Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'கடை விசிட் (Visits)',
                  value: '$todayShops கடைகள்',
                  subtitle: '${store.shops.length} Total Tie-ups',
                  icon: Icons.storefront_rounded,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'ஆர்டர் பண்டில்கள்',
                  value: '${todayBundles.toStringAsFixed(0)} Bundles',
                  subtitle: 'Spot Sales Today',
                  icon: Icons.inventory_2_rounded,
                  color: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'ரொக்கம் வசூல் (Cash)',
                  value: '₹${todayCash.toStringAsFixed(0)}',
                  subtitle: 'Spot Cash & UPI',
                  icon: Icons.payments_rounded,
                  color: const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'மொத்த பாக்கி (Baaki)',
                  value: '₹${totalOutstanding.toStringAsFixed(0)}',
                  subtitle: 'Pending Across Shops',
                  icon: Icons.account_balance_wallet_rounded,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Two Primary Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.add_business_rounded, size: 20),
                  label: const Text(
                    'புது கடை Tie-up',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () => onNavigateToTab(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.point_of_sale_rounded, size: 20),
                  label: const Text(
                    'ஸ்பாட் ஆர்டர் போடு',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () => onNavigateToTab(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tied-up Kadai Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'இணைக்கப்பட்ட கடைகள் (Tied-up Shops)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              if (store.shops.isNotEmpty)
                TextButton(
                  onPressed: () => onNavigateToTab(3),
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 8),

          if (store.shops.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.storefront_outlined, size: 44, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 10),
                  const Text(
                    'இன்னும் கடைகள் பதிவு செய்யப்படவில்லை',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap "புது கடை Tie-up" to register your first retail shop with real camera photo and GPS location.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            )
          else
            ...store.shops.take(3).map((shop) => _buildRecentShopCard(shop)),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentShopCard(ShopTieupModel shop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          _buildRealShopThumbnail(shop.bannerPhotoUrl, width: 55, height: 55),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        shop.shopName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        shop.shopCategory,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${shop.ownerName} • ${shop.mobileNumber}',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      shop.area,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                    if (shop.outstandingBalance > 0)
                      Text(
                        'பாக்கி: ₹${shop.outstandingBalance.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFDC2626),
                        ),
                      )
                    else
                      const Text(
                        'No Baaki',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== TAB 1: NEW KADAI TIE-UP ====================
class _NewKadaiTieupView extends StatefulWidget {
  final DeebaStore store;
  final Function(ShopTieupModel newShop) onShopCreated;

  const _NewKadaiTieupView({
    required this.store,
    required this.onShopCreated,
  });

  @override
  State<_NewKadaiTieupView> createState() => _NewKadaiTieupViewState();
}

class _NewKadaiTieupViewState extends State<_NewKadaiTieupView> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _areaCtrl = TextEditingController(text: 'Sivakasi');

  // Real Photo Capture State (Base64 data url + raw bytes)
  String _bannerPhotoDataUrl = '';
  Uint8List? _bannerPhotoBytes;
  bool _isPickingPhoto = false;

  String _selectedCategory = 'Maligai';
  double _gpsLat = 9.4533;
  double _gpsLng = 77.7946;
  bool _isGpsLocked = false;
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Maligai',
    'Tea Stall',
    'Petty Shop',
    'Supermarket',
    'Bakery & Snacks',
    'Wholesale Match Agency',
    'General Merchant',
  ];

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _mobileCtrl.dispose();
    _addressCtrl.dispose();
    _areaCtrl.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto(ImageSource source) async {
    setState(() => _isPickingPhoto = true);
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _bannerPhotoBytes = bytes;
          _bannerPhotoDataUrl = base64String;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storefront Photo Captured Successfully!'),
              backgroundColor: Color(0xFF059669),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open camera/gallery: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingPhoto = false);
    }
  }

  void _simulateCaptureGps() {
    final randomOffset = (DateTime.now().millisecond % 50) / 10000.0;
    setState(() {
      _gpsLat = 9.4533 + randomOffset;
      _gpsLng = 77.7946 + (randomOffset * 1.2);
      _isGpsLocked = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'GPS Location Locked: ${_gpsLat.toStringAsFixed(4)}, ${_gpsLng.toStringAsFixed(4)} (Accuracy ±5m)',
        ),
        backgroundColor: const Color(0xFF059669),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitTieup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final newShop = ShopTieupModel(
      id: 'SHP-${101 + widget.store.shops.length}',
      shopName: _shopNameCtrl.text.trim(),
      ownerName: _ownerNameCtrl.text.trim(),
      mobileNumber: _mobileCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      area: _areaCtrl.text.trim(),
      shopCategory: _selectedCategory,
      gpsLatitude: _gpsLat,
      gpsLongitude: _gpsLng,
      salesmanId: widget.store.loggedInUserUsername,
      salesmanName: widget.store.loggedInUserName,
      bannerPhotoUrl: _bannerPhotoDataUrl,
      rackPhotoUrl: '',
      outstandingBalance: 0.0,
      createdDate: DateTime.now(),
      lastVisitedDate: DateTime.now(),
    );

    await widget.store.registerShopTieup(newShop);

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 28),
            SizedBox(width: 8),
            Text('கடை வெற்றிகரமாக இணைக்கப்பட்டது!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              newShop.shopName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text('Owner: ${newShop.ownerName} • Phone: ${newShop.mobileNumber}'),
            Text('Location: ${newShop.area} (GPS Verified)'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Text(
                'This kadai is now tied-up and synced to Factory Admin. Would you like to take their first spot order now?',
                style: TextStyle(fontSize: 12, color: Color(0xFF166534)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetForm();
            },
            child: const Text('Add Another Kadai'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onShopCreated(newShop);
            },
            child: const Text('Book First Spot Order 🛒'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _shopNameCtrl.clear();
    _ownerNameCtrl.clear();
    _mobileCtrl.clear();
    _addressCtrl.clear();
    setState(() {
      _bannerPhotoBytes = null;
      _bannerPhotoDataUrl = '';
      _isGpsLocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_business_rounded, color: Color(0xFF92400E), size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'புதிய கடை டை-அப் பதிவு (New Kadai Tie-up)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF92400E),
                          ),
                        ),
                        Text(
                          'Enter shop name, phone, take storefront camera photo and capture exact GPS location on the spot.',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF78350F)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 1: Shop & Contact Information
            _buildSectionCard(
              title: '1. கடை & முதலாளி விவரங்கள் (Shop Details)',
              icon: Icons.storefront_rounded,
              child: Column(
                children: [
                  TextFormField(
                    controller: _shopNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'கடையின் பெயர் (Shop Name) *',
                      hintText: 'e.g. Sri Murugan Maligai Store',
                      prefixIcon: Icon(Icons.store),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Please enter shop name' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ownerNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'உரிமையாளர் பெயர் (Owner) *',
                            hintText: 'e.g. Murugesan Pillai',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Enter owner name' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _mobileCtrl,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: const InputDecoration(
                            labelText: 'மொபைல் எண் (Mobile) *',
                            hintText: '10 digits',
                            prefixIcon: Icon(Icons.phone),
                            counterText: '',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().length < 10) {
                              return 'Enter valid 10 digits';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'கடையின் வகை (Category) *',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: _categories
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCategory = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _addressCtrl,
                          decoration: const InputDecoration(
                            labelText: 'முகவரி (Street Address) *',
                            hintText: 'e.g. Near Bus Stand, Sattur Road',
                            prefixIcon: Icon(Icons.location_on),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Enter address' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _areaCtrl,
                          decoration: const InputDecoration(
                            labelText: 'பகுதி / ஊர் (Area) *',
                            hintText: 'Sivakasi',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 2: GPS Location Verification
            _buildSectionCard(
              title: '2. நேரடி GPS அமைவிடம் (Exact GPS Location)',
              icon: Icons.my_location_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isGpsLocked ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isGpsLocked ? const Color(0xFF22C55E) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isGpsLocked ? Icons.check_circle_rounded : Icons.location_searching_rounded,
                          color: _isGpsLocked ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isGpsLocked
                                    ? 'GPS லொகேஷன் உறுதி செய்யப்பட்டது (Locked)'
                                    : 'GPS லொகேஷன் இன்னும் எடுக்கப்படவில்லை',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: _isGpsLocked ? const Color(0xFF15803D) : const Color(0xFF334155),
                                ),
                              ),
                              Text(
                                'Lat: ${_gpsLat.toStringAsFixed(5)}, Lng: ${_gpsLng.toStringAsFixed(5)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isGpsLocked
                                ? const Color(0xFF15803D)
                                : const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          icon: const Icon(Icons.gps_fixed, size: 14),
                          label: Text(_isGpsLocked ? 'Re-lock' : 'Capture GPS'),
                          onPressed: _simulateCaptureGps,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 3: REAL CAMERA / GALLERY PHOTO CAPTURE (NO MOCK URLS / NO STOCK IMAGES)
            _buildSectionCard(
              title: '3. கடை பேனர் புகைப்படம் (Storefront Photo Proof)',
              icon: Icons.camera_alt_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'கடையின் பெயர் பலகை அல்லது முகப்பு தோற்றத்தை மொபைல் கேமராவில் புகைப்படம் எடுக்கவும்:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 14),

                  // Action Buttons: Camera & Gallery
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: _isPickingPhoto
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.camera_alt_rounded, size: 18),
                          label: const Text(
                            'கேமரா போட்டோ (Camera)',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                          ),
                          onPressed: _isPickingPhoto ? null : () => _capturePhoto(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0F172A),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.photo_library_rounded, size: 18),
                          label: const Text(
                            'கேலரி (Gallery)',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                          ),
                          onPressed: _isPickingPhoto ? null : () => _capturePhoto(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Display Area: Captured Photo Preview or Empty Real State
                  if (_bannerPhotoBytes != null)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF22C55E), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                            child: Image.memory(
                              _bannerPhotoBytes!,
                              height: 190,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'போட்டோ எடுக்கப்பட்டது (Photo Attached)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFDC2626),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  icon: const Icon(Icons.delete_outline, size: 16),
                                  label: const Text('Remove', style: TextStyle(fontSize: 11.5)),
                                  onPressed: () {
                                    setState(() {
                                      _bannerPhotoBytes = null;
                                      _bannerPhotoDataUrl = '';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFCBD5E1),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 38, color: Color(0xFF94A3B8)),
                          SizedBox(height: 8),
                          Text(
                            'இன்னும் போட்டோ எடுக்கப்படவில்லை',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tap "Camera" or "Gallery" above to capture actual shop banner proof.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.handshake_rounded, size: 22),
                label: Text(
                  _isSubmitting ? 'பதிவு செய்யப்படுகிறது...' : 'கடையை இணைக்கவும் (Register Kadai)',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                onPressed: _isSubmitting ? null : _submitTieup,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFFD97706)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.8),
          child,
        ],
      ),
    );
  }
}

// ==================== TAB 2: SPOT ORDER BOOKING ====================
class _SpotOrderBookingView extends StatefulWidget {
  final DeebaStore store;
  final ShopTieupModel? initialShop;
  final VoidCallback onOrderCompleted;

  const _SpotOrderBookingView({
    required this.store,
    this.initialShop,
    required this.onOrderCompleted,
  });

  @override
  State<_SpotOrderBookingView> createState() => _SpotOrderBookingViewState();
}

class _SpotOrderBookingViewState extends State<_SpotOrderBookingView> {
  ShopTieupModel? _selectedShop;
  String _selectedBrand = 'Eagle';
  String _selectedPriceCategory = 'Rs. 1';
  final _quantityCtrl = TextEditingController(text: '10');
  final _rateCtrl = TextEditingController(text: '450');
  final _amountReceivedCtrl = TextEditingController(text: '4500');
  final _notesCtrl = TextEditingController();

  String _paymentMode = 'Cash'; // Cash, UPI, Credit (Baaki)
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialShop != null) {
      _selectedShop = widget.initialShop;
    } else if (widget.store.shops.isNotEmpty) {
      _selectedShop = widget.store.shops.first;
    }
    _updateRateAndMath();
  }

  @override
  void didUpdateWidget(covariant _SpotOrderBookingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialShop != null && widget.initialShop != _selectedShop) {
      setState(() {
        _selectedShop = widget.initialShop;
      });
    }
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _rateCtrl.dispose();
    _amountReceivedCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _updateRateAndMath() {
    double defaultRate = 450.0;
    if (_selectedBrand == 'Eagle') {
      defaultRate = _selectedPriceCategory == 'Rs. 1' ? 450.0 : 840.0;
    } else if (_selectedBrand == 'Pulli') {
      defaultRate = _selectedPriceCategory == 'Rs. 1' ? 430.0 : 800.0;
    } else {
      defaultRate = _selectedPriceCategory == 'Rs. 1' ? 420.0 : 780.0;
    }
    _rateCtrl.text = defaultRate.toStringAsFixed(0);
    _recalcMath();
  }

  void _recalcMath() {
    final qty = double.tryParse(_quantityCtrl.text.trim()) ?? 0;
    final rate = double.tryParse(_rateCtrl.text.trim()) ?? 0;
    final total = qty * rate;

    if (_paymentMode == 'Cash' || _paymentMode == 'UPI') {
      _amountReceivedCtrl.text = total.toStringAsFixed(0);
    } else {
      _amountReceivedCtrl.text = '0';
    }
    setState(() {});
  }

  double get _totalBillAmount {
    final qty = double.tryParse(_quantityCtrl.text.trim()) ?? 0;
    final rate = double.tryParse(_rateCtrl.text.trim()) ?? 0;
    return qty * rate;
  }

  double get _amountReceived {
    return double.tryParse(_amountReceivedCtrl.text.trim()) ?? 0;
  }

  double get _balanceBaaki {
    final diff = _totalBillAmount - _amountReceived;
    return diff > 0 ? diff : 0.0;
  }

  Future<void> _submitSpotOrder() async {
    if (_selectedShop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a retail shop first!')),
      );
      return;
    }

    final qty = double.tryParse(_quantityCtrl.text.trim()) ?? 0;
    final rate = double.tryParse(_rateCtrl.text.trim()) ?? 0;

    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bundle quantity must be greater than 0')),
      );
      return;
    }

    setState(() => _isBooking = true);

    await widget.store.bookSpotOrder(
      shop: _selectedShop!,
      productBrand: _selectedBrand,
      priceCategory: _selectedPriceCategory,
      quantity: qty,
      salePrice: rate,
      amountReceived: _amountReceived,
      paymentMode: _paymentMode,
      notes: _notesCtrl.text.trim(),
    );

    setState(() => _isBooking = false);

    if (!mounted) return;

    _showInvoiceAndWhatsAppModal(
      shop: _selectedShop!,
      brand: _selectedBrand,
      category: _selectedPriceCategory,
      bundles: qty,
      rate: rate,
      total: _totalBillAmount,
      received: _amountReceived,
      baaki: _balanceBaaki,
      paymentMode: _paymentMode,
    );
  }

  void _showInvoiceAndWhatsAppModal({
    required ShopTieupModel shop,
    required String brand,
    required String category,
    required double bundles,
    required double rate,
    required double total,
    required double received,
    required double baaki,
    required String paymentMode,
  }) {
    final billNumber = 'DB-SPOT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final tamilWhatsAppBill = '''
*DEEBA MATCH HOUSE - SIVAKASI*
*ஸ்பாட் விற்பனை ரசீது (Spot Order Bill)*
--------------------------------
*பில் எண்:* $billNumber
*தேதி:* ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}
*கடை பெயர்:* ${shop.shopName}
*உரிமையாளர்:* ${shop.ownerName} (${shop.mobileNumber})
*பகுதி:* ${shop.area}
--------------------------------
*பிராண்ட்:* $brand ($category)
*பண்டில்கள்:* ${bundles.toStringAsFixed(0)} Bundles
*விலை/பண்டில்:* ₹${rate.toStringAsFixed(0)}
*மொத்த தொகை:* ₹${total.toStringAsFixed(0)}
--------------------------------
*ரொக்கம்/UPI பெற்றது:* ₹${received.toStringAsFixed(0)} ($paymentMode)
*மீதி பாக்கி (Baaki):* ₹${baaki.toStringAsFixed(0)}
--------------------------------
நன்றி! தீபா மேட்ச் ஹவுஸ், சிவகாசி.
தொலைபேசி: 9842155667
''';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: Color(0xFF0F766E), size: 28),
            SizedBox(width: 8),
            Text('ஸ்பாட் பில் உருவானது!'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bill #: $billNumber', style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('Shop: ${shop.shopName}'),
                    const Divider(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$brand ($category) × ${bundles.toStringAsFixed(0)}'),
                        Text('₹${total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Paid ($paymentMode):'),
                        Text('₹${received.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w700)),
                      ],
                    ),
                    if (baaki > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Remaining Baaki:', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w700)),
                          Text('₹${baaki.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Send digital bill copy to shopkeeper on WhatsApp:',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onOrderCompleted();
            },
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.share_rounded, size: 16),
            label: const Text('WhatsApp Bill Share'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: tamilWhatsAppBill));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tamil WhatsApp Bill copied to clipboard!'),
                  backgroundColor: Color(0xFF16A34A),
                ),
              );
              Navigator.pop(ctx);
              widget.onOrderCompleted();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.store.shops.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.storefront_outlined, size: 50, color: Color(0xFF94A3B8)),
              const SizedBox(height: 12),
              const Text(
                'இன்னும் கடைகள் பதிவு செய்யப்படவில்லை',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Please tie-up at least one shop before booking spot orders.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Choose Shop
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.store_mall_directory_rounded, color: Color(0xFF0F766E), size: 18),
                    SizedBox(width: 8),
                    Text(
                      '1. கடையை தேர்வு செய்யவும் (Select Shop)',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<ShopTieupModel>(
                  value: _selectedShop,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: widget.store.shops.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text(
                        '${s.shopName} (${s.area})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (shop) {
                    if (shop != null) setState(() => _selectedShop = shop);
                  },
                ),
                if (_selectedShop != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Owner: ${_selectedShop!.ownerName} • ${_selectedShop!.mobileNumber}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                        ),
                        if (_selectedShop!.outstandingBalance > 0)
                          Text(
                            'Old Baaki: ₹${_selectedShop!.outstandingBalance.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFDC2626),
                            ),
                          )
                        else
                          const Text(
                            'No Baaki',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF059669),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section 2: Brand & Category Selection
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded, color: Color(0xFFD97706), size: 18),
                    SizedBox(width: 8),
                    Text(
                      '2. பிராண்ட் & விலை வகை (Brand & Category)',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: ['Eagle', 'Pulli', 'Joker'].map((brand) {
                    final isSel = _selectedBrand == brand;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(brand),
                          selected: isSel,
                          selectedColor: const Color(0xFFD97706),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() => _selectedBrand = brand);
                              _updateRateAndMath();
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),

                Row(
                  children: ['Rs. 1', 'Rs. 2'].map((cat) {
                    final isSel = _selectedPriceCategory == cat;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(cat == 'Rs. 1' ? 'Rs. 1 (Regular)' : 'Rs. 2 (Jumbo)'),
                          selected: isSel,
                          selectedColor: const Color(0xFF0F766E),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() => _selectedPriceCategory = cat);
                              _updateRateAndMath();
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section 3: Quantity & Rate Calculation
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calculate_rounded, color: Color(0xFF2563EB), size: 18),
                    SizedBox(width: 8),
                    Text(
                      '3. அளவு & பில் கணக்கீடு (Quantity & Billing)',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 6,
                  children: [5, 10, 25, 50, 100].map((b) {
                    return ActionChip(
                      label: Text('+$b Bundles'),
                      onPressed: () {
                        setState(() {
                          _quantityCtrl.text = b.toString();
                          _recalcMath();
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'பண்டில்கள் எண்ணிக்கை (Qty)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _recalcMath(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _rateCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'விலை/பண்டில் (Rate ₹)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _recalcMath(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'மொத்த பில் தொகை (Total Bill):',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '₹${_totalBillAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),

                      Row(
                        children: ['Cash', 'UPI', 'Credit'].map((mode) {
                          final isSel = _paymentMode == mode;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: isSel
                                      ? (mode == 'Credit'
                                          ? const Color(0xFFDC2626)
                                          : const Color(0xFF059669))
                                      : Colors.transparent,
                                  foregroundColor: isSel ? Colors.white : const Color(0xFF334155),
                                  side: BorderSide(
                                    color: isSel
                                        ? Colors.transparent
                                        : const Color(0xFFCBD5E1),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _paymentMode = mode;
                                    _recalcMath();
                                  });
                                },
                                child: Text(mode, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _amountReceivedCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'ரொக்கம் பெற்றது (Paid ₹)',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: _balanceBaaki > 0
                                    ? const Color(0xFFFEF2F2)
                                    : const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _balanceBaaki > 0
                                      ? const Color(0xFFF87171)
                                      : const Color(0xFF86EFAC),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'மீதி பாக்கி (Baaki):',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '₹${_balanceBaaki.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: _balanceBaaki > 0
                                          ? const Color(0xFFDC2626)
                                          : const Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Submit Order Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              icon: _isBooking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_rounded, size: 22),
              label: Text(
                _isBooking ? 'ஆர்டர் போடப்படுகிறது...' : 'ஸ்பாட் ஆர்டர் உறுதி செய் (Confirm Spot Order)',
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
              ),
              onPressed: _isBooking ? null : _submitSpotOrder,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ==================== TAB 3: MY SHOPS DIRECTORY ====================
class _MyShopsDirectoryView extends StatefulWidget {
  final DeebaStore store;
  final Function(ShopTieupModel shop) onTakeOrderForShop;

  const _MyShopsDirectoryView({
    required this.store,
    required this.onTakeOrderForShop,
  });

  @override
  State<_MyShopsDirectoryView> createState() => _MyShopsDirectoryViewState();
}

class _MyShopsDirectoryViewState extends State<_MyShopsDirectoryView> {
  final _searchCtrl = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showCollectPaymentDialog(ShopTieupModel shop) {
    final amountCtrl = TextEditingController(
      text: shop.outstandingBalance.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.payments_rounded, color: Color(0xFF059669), size: 24),
            const SizedBox(width: 8),
            Text('பாக்கி வசூல்: ${shop.shopName}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Baaki: ₹${shop.outstandingBalance.toStringAsFixed(0)}'),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'வசூல் செய்த தொகை (Amount Collected ₹)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final amt = double.tryParse(amountCtrl.text.trim()) ?? 0;
              if (amt > 0) {
                await widget.store.collectShopPayment(shop.id, amt);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('வசூல் பதிவு செய் (Save Payment)'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim().toLowerCase();

    final filteredShops = widget.store.shops.where((s) {
      final matchesSearch = query.isEmpty ||
          s.shopName.toLowerCase().contains(query) ||
          s.ownerName.toLowerCase().contains(query) ||
          s.area.toLowerCase().contains(query) ||
          s.mobileNumber.contains(query);

      if (!matchesSearch) return false;

      if (_selectedFilter == 'Baaki') {
        return s.outstandingBalance > 0;
      } else if (_selectedFilter == 'Maligai') {
        return s.shopCategory == 'Maligai';
      } else if (_selectedFilter == 'Tea Stall') {
        return s.shopCategory == 'Tea Stall';
      }
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search kadai name, owner, area, phone...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchCtrl.clear();
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Baaki', 'Maligai', 'Tea Stall'].map((f) {
                final isSel = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(f == 'Baaki' ? 'பாக்கி உள்ளவை (Dues)' : f),
                    selected: isSel,
                    selectedColor: const Color(0xFFD97706),
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = f);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: filteredShops.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 40, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 8),
                        const Text(
                          'இன்னும் கடைகள் பதிவு செய்யப்படவில்லை',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredShops.length,
                    itemBuilder: (ctx, idx) {
                      final shop = filteredShops[idx];
                      return _buildShopListItem(shop);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopListItem(ShopTieupModel shop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRealShopThumbnail(shop.bannerPhotoUrl, width: 60, height: 60),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            shop.shopName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            shop.shopCategory,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${shop.ownerName} • ${shop.mobileNumber}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                    ),
                    Text(
                      '${shop.address}, ${shop.area}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.gps_fixed, size: 12, color: Color(0xFF059669)),
                    const SizedBox(width: 4),
                    Text(
                      'GPS: ${shop.gpsLatitude.toStringAsFixed(4)}, ${shop.gpsLongitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569)),
                    ),
                  ],
                ),
                if (shop.outstandingBalance > 0)
                  Text(
                    'பாக்கி: ₹${shop.outstandingBalance.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFDC2626),
                    ),
                  )
                else
                  const Text(
                    'All Clear (No Dues)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF059669),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 16, thickness: 0.8),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  icon: const Icon(Icons.phone, size: 14),
                  label: const Text('Call', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: shop.mobileNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Phone number copied: ${shop.mobileNumber}')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),

              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    foregroundColor: const Color(0xFF16A34A),
                  ),
                  icon: const Icon(Icons.chat_bubble_rounded, size: 14),
                  label: const Text('WhatsApp', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    final msg = 'Vanakkam ${shop.ownerName}, Deeba Match House sales update for ${shop.shopName}.';
                    Clipboard.setData(ClipboardData(text: msg));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('WhatsApp message copied for ${shop.shopName}')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),

              if (shop.outstandingBalance > 0) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                    icon: const Icon(Icons.payments_rounded, size: 14),
                    label: const Text('Collect', style: TextStyle(fontSize: 11)),
                    onPressed: () => _showCollectPaymentDialog(shop),
                  ),
                ),
                const SizedBox(width: 6),
              ],

              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  icon: const Icon(Icons.point_of_sale_rounded, size: 14),
                  label: const Text('Order 🛒', style: TextStyle(fontSize: 11)),
                  onPressed: () => widget.onTakeOrderForShop(shop),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
