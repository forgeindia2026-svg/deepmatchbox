import 'package:flutter/material.dart';
import '../../models/deeba_models.dart';
import '../../state/deeba_store.dart';

class CustomerPortal extends StatefulWidget {
  final DeebaStore store;
  final VoidCallback? onOpenLoginModal;

  const CustomerPortal({
    super.key,
    required this.store,
    this.onOpenLoginModal,
  });

  @override
  State<CustomerPortal> createState() => _CustomerPortalState();
}

class _CustomerPortalState extends State<CustomerPortal> {
  int _selectedTab = 0; // 0: Home, 1: Products, 2: Online Order, 3: About Us, 4: Contact Us
  String? _preselectedProduct;
  String? _preselectedCategory;
  int? _preselectedQty;

  void _navigateToOrderWithProduct(String brand, String category, {int? quantity}) {
    setState(() {
      _preselectedProduct = brand;
      _preselectedCategory = category;
      _preselectedQty = quantity;
      _selectedTab = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 880;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isMobile ? 60 : 68),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7F1D1D), Color(0xFFB91C1C), Color(0xFFD97706)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFF991B1B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DEEBA MATCH HOUSE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 15 : 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Safety Matches • Eagle • Pulli • Joker',
                          style: TextStyle(
                            color: Colors.amber.shade200,
                            fontSize: isMobile ? 10.5 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isWide) ...[
                    _buildTopNavButton(0, 'Home', Icons.home_rounded),
                    _buildTopNavButton(1, 'Products', Icons.inventory_2_rounded),
                    _buildTopNavButton(2, 'Online Order', Icons.shopping_bag_rounded),
                    _buildTopNavButton(3, 'About Us', Icons.business_rounded),
                    _buildTopNavButton(4, 'Contact Us', Icons.contact_phone_rounded),
                  ],
                  if (widget.onOpenLoginModal != null)
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF991B1B),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 10 : 14,
                          vertical: isMobile ? 8 : 10,
                        ),
                      ),
                      onPressed: widget.onOpenLoginModal,
                      icon: const Icon(Icons.lock_outline_rounded, size: 16),
                      label: Text(
                        isWide ? 'Staff / Admin Portal' : 'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: isMobile ? 12 : 13.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _HomeSection(
            store: widget.store,
            onExploreProducts: () => setState(() => _selectedTab = 1),
            onOrderNow: (brand, cat, [qty]) => _navigateToOrderWithProduct(brand, cat, quantity: qty),
            onContactUs: () => setState(() => _selectedTab = 4),
          ),
          _ProductsSection(
            store: widget.store,
            onOrderProduct: (brand, cat) => _navigateToOrderWithProduct(brand, cat),
          ),
          _OnlineOrderSection(
            store: widget.store,
            initialBrand: _preselectedProduct,
            initialCategory: _preselectedCategory,
            initialQuantity: _preselectedQty,
          ),
          const _AboutUsSection(),
          _ContactUsSection(store: widget.store),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              height: 64,
              selectedIndex: _selectedTab,
              onDestinationSelected: (idx) => setState(() => _selectedTab = idx),
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFFEE2E2),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded, color: Color(0xFFB91C1C)),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2_rounded, color: Color(0xFFB91C1C)),
                  label: 'Products',
                ),
                NavigationDestination(
                  icon: Icon(Icons.shopping_bag_outlined),
                  selectedIcon: Icon(Icons.shopping_bag_rounded, color: Color(0xFFB91C1C)),
                  label: 'Order',
                ),
                NavigationDestination(
                  icon: Icon(Icons.business_outlined),
                  selectedIcon: Icon(Icons.business_rounded, color: Color(0xFFB91C1C)),
                  label: 'About',
                ),
                NavigationDestination(
                  icon: Icon(Icons.contact_phone_outlined),
                  selectedIcon: Icon(Icons.contact_phone_rounded, color: Color(0xFFB91C1C)),
                  label: 'Contact',
                ),
              ],
            ),
    );
  }

  Widget _buildTopNavButton(int index, String title, IconData icon) {
    final isSelected = _selectedTab == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: isSelected ? Colors.amber.shade300 : Colors.white,
          backgroundColor: isSelected ? Colors.white.withAlpha(40) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => setState(() => _selectedTab = index),
        icon: Icon(icon, size: 18),
        label: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 1. HOME SECTION (HIGH-CONTENT MANUFACTURER & EXPORTER SHOWCASE)
// ============================================================================
class _HomeSection extends StatefulWidget {
  final DeebaStore store;
  final VoidCallback onExploreProducts;
  final void Function(String brand, String category, [int? quantity]) onOrderNow;
  final VoidCallback onContactUs;

  const _HomeSection({
    required this.store,
    required this.onExploreProducts,
    required this.onOrderNow,
    required this.onContactUs,
  });

  @override
  State<_HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<_HomeSection> {
  // Calculator state
  String _calcBrand = 'Eagle';
  String _calcCategory = 'Rs. 1';
  int _calcBundles = 25; // 25 bundles default (15,000 boxes)

  // FAQ Expanded State
  final Set<int> _expandedFaqs = {0};

  @override
  Widget build(BuildContext context) {
    final activeProducts = widget.store.products.where((p) => p.isActive).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 640;
        final pad = isMobile ? 14.0 : 24.0;

        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1160),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. HERO BANNER
                  _buildHeroBanner(isMobile),
                  const SizedBox(height: 24),

                  // 2. TRUST & SCALE STATISTICS BAR
                  _buildTrustStatsBar(isMobile),
                  SizedBox(height: isMobile ? 24 : 36),

                  // 3. PRODUCT CATEGORIES (Rs. 1, Rs. 2, Bulk)
                  _buildSectionHeading(
                    title: 'Our Matchbox Categories',
                    subtitle: 'Supplying standard retail and jumbo household matchboxes in 10-Gross bundles',
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 14),
                  _buildCategoryBannerCards(isMobile),
                  SizedBox(height: isMobile ? 28 : 40),

                  // 4. FEATURED BRANDS SHOWCASE (Eagle, Pulli, Joker)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildSectionHeading(
                          title: 'Featured Safety Match Brands',
                          subtitle: 'Manufactured with carbonized splints & damp-proof friction heads',
                          isMobile: isMobile,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: widget.onExploreProducts,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('View All Brands'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildFeaturedBrandsGrid(activeProducts, isMobile),
                  SizedBox(height: isMobile ? 28 : 44),

                  // 5. INTERACTIVE WHOLESALE ESTIMATOR & CALCULATOR
                  _buildWholesaleCalculator(isMobile),
                  SizedBox(height: isMobile ? 28 : 44),

                  // 6. SIVAKASI MANUFACTURING PROCESS (5-STEP ROADMAP)
                  _buildManufacturingProcessRoadmap(isMobile),
                  SizedBox(height: isMobile ? 28 : 44),

                  // 7. WHOLESALE DEALERSHIP & AGENCY NETWORK
                  _buildDealershipBanner(isMobile),
                  SizedBox(height: isMobile ? 28 : 44),

                  // 10. CLIENT & DISTRIBUTOR TESTIMONIALS
                  _buildTestimonials(isMobile),
                  SizedBox(height: isMobile ? 28 : 44),

                  // 11. FREQUENTLY ASKED QUESTIONS (FAQ)
                  _buildFaqSection(isMobile),
                  SizedBox(height: isMobile ? 28 : 44),

                  // 12. RICH CORPORATE INDUSTRIAL FOOTER
                  _buildCorporateFooter(isMobile),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== SECTION 1: HERO BANNER ====================
  Widget _buildHeroBanner(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isMobile ? 20 : 26),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B0707),
            Color(0xFF7F1D1D),
            Color(0xFFB91C1C),
            Color(0xFFB45309),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.amber.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF450A0A)),
                    const SizedBox(width: 5),
                    Text(
                      'SIVAKASI INDUSTRIAL SAFETY MATCHES • ESTD. 1998',
                      style: TextStyle(
                        color: const Color(0xFF450A0A),
                        fontWeight: FontWeight.w900,
                        fontSize: isMobile ? 10 : 11.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Leading Safety Matches Manufacturer & Bulk Wholesale Exporter',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 22 : 34,
              fontWeight: FontWeight.w900,
              height: 1.22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Crafting India\'s most reliable high-strike safety matches for over 25+ years. Manufacturers of Eagle, Pulli, and Joker matchbox brands. Engineered with carbonized wooden splints, damp-resistant friction chemistry, and bulk 10-Gross bundle supplies for wholesale dealers, supermarket chains, and pan-India lorry transport.',
            style: TextStyle(
              color: const Color(0xFFFEF3C7),
              fontSize: isMobile ? 13.5 : 15.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amber.shade400,
                  foregroundColor: const Color(0xFF450A0A),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 18 : 24,
                    vertical: isMobile ? 13 : 16,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => widget.onOrderNow('Eagle', 'Rs. 1'),
                icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 19),
                label: const Text(
                  'Place Wholesale Order',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70, width: 1.5),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 22,
                    vertical: isMobile ? 13 : 16,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: widget.onExploreProducts,
                icon: const Icon(Icons.grid_view_rounded, size: 18),
                label: const Text(
                  'Explore All Brands',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.amber.shade200,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onPressed: widget.onContactUs,
                icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                label: const Text(
                  'Call Sivakasi Works',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== SECTION 2: TRUST & SCALE STATISTICS BAR ====================
  Widget _buildTrustStatsBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (ctx, box) {
          final itemWidth = isMobile ? (box.maxWidth - 12) / 2 : (box.maxWidth - 48) / 4;
          return Wrap(
            spacing: 16,
            runSpacing: 14,
            alignment: WrapAlignment.spaceAround,
            children: [
              _statPill(itemWidth, '50M+ Boxes', 'Monthly Production', Icons.factory_rounded, const Color(0xFFB91C1C)),
              _statPill(itemWidth, '25+ States', 'Pan-India Lorry Network', Icons.local_shipping_rounded, const Color(0xFF0F766E)),
              _statPill(itemWidth, '100% Damp-Proof', 'Monsoon Ready Formula', Icons.water_drop_rounded, const Color(0xFF0284C7)),
              _statPill(itemWidth, 'Direct Factory', 'Zero Middlemen Margins', Icons.price_check_rounded, const Color(0xFFD97706)),
            ],
          );
        },
      ),
    );
  }

  Widget _statPill(double width, String title, String subtitle, IconData icon, Color color) {
    return SizedBox(
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withAlpha(22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                    color: Colors.grey.shade900,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SECTION 3: CATEGORIES BANNER ====================
  Widget _buildCategoryBannerCards(bool isMobile) {
    return LayoutBuilder(
      builder: (ctx, box) {
        final cardWidth = box.maxWidth < 720 ? box.maxWidth : (box.maxWidth - 32) / 3;
        return Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            _CategoryBannerCard(
              width: cardWidth,
              title: 'Rs. 1 Safety Matchboxes',
              subtitle: '40-42 sticks per box • 600 boxes/bundle (10 Gross) • High-speed carbonized Aspen wood splints.',
              icon: Icons.currency_rupee_rounded,
              color: const Color(0xFFB91C1C),
              badge: 'Fastest Moving',
              onTap: widget.onExploreProducts,
            ),
            _CategoryBannerCard(
              width: cardWidth,
              title: 'Rs. 2 Jumbo Matchboxes',
              subtitle: '70-75 deluxe sticks per box • 600 boxes/bundle • Extended burn time for kitchens & hotels.',
              icon: Icons.workspace_premium_rounded,
              color: const Color(0xFFD97706),
              badge: 'Deluxe Pack',
              onTap: widget.onExploreProducts,
            ),
            _CategoryBannerCard(
              width: cardWidth,
              title: 'Wholesale Lorry Loads',
              subtitle: 'Direct factory master cartons (10 Bundles / 6,000 boxes) with transport door delivery.',
              icon: Icons.local_shipping_rounded,
              color: const Color(0xFF047857),
              badge: 'Agency Dealership',
              onTap: () => widget.onOrderNow('Eagle', 'Rs. 1', 50),
            ),
          ],
        );
      },
    );
  }

  // ==================== SECTION 4: FEATURED BRANDS GRID ====================
  Widget _buildFeaturedBrandsGrid(List<ProductItem> activeProducts, bool isMobile) {
    return LayoutBuilder(
      builder: (ctx, box) {
        final cardWidth = box.maxWidth < 740 ? box.maxWidth : (box.maxWidth - 40) / 3;
        return Wrap(
          spacing: 20,
          runSpacing: 16,
          children: activeProducts
              .map(
                (product) => _ProductCardWidget(
                  width: cardWidth,
                  product: product,
                  store: widget.store,
                  onOrderNow: (brand, cat) => widget.onOrderNow(brand, cat),
                ),
              )
              .toList(),
        );
      },
    );
  }

  // ==================== SECTION 5: WHOLESALE BUNDLE CALCULATOR ====================
  Widget _buildWholesaleCalculator(bool isMobile) {
    // Pricing table
    double pricePerBdl = 450;
    if (_calcBrand == 'Eagle') {
      pricePerBdl = _calcCategory == 'Rs. 1' ? 450 : 840;
    } else if (_calcBrand == 'Pulli') {
      pricePerBdl = _calcCategory == 'Rs. 1' ? 430 : 800;
    } else if (_calcBrand == 'Joker') {
      pricePerBdl = _calcCategory == 'Rs. 1' ? 420 : 780;
    }

    final totalBoxes = _calcBundles * 600;
    final totalGross = (totalBoxes / 144).toStringAsFixed(1);
    final masterCartons = (_calcBundles / 10).toStringAsFixed(1);
    final totalAmount = pricePerBdl * _calcBundles;

    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD97706).withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calculate_rounded, color: Color(0xFFD97706), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Interactive Wholesale Price & Bundle Estimator',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      'Select brand, category & bundle quantity to calculate wholesale pricing & lorry consignment volume.',
                      style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Selector row
          Wrap(
            spacing: 20,
            runSpacing: 14,
            children: [
              // Brand Selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Brand:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: ['Eagle', 'Pulli', 'Joker'].map((b) {
                      final isSel = _calcBrand == b;
                      return ChoiceChip(
                        label: Text(b),
                        selected: isSel,
                        selectedColor: const Color(0xFFB91C1C),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setState(() => _calcBrand = b),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Category Selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price Variant:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: ['Rs. 1', 'Rs. 2'].map((c) {
                      final isSel = _calcCategory == c;
                      return ChoiceChip(
                        label: Text(c == 'Rs. 1' ? 'Rs. 1 (40 sticks)' : 'Rs. 2 (70 sticks)'),
                        selected: isSel,
                        selectedColor: const Color(0xFFD97706),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => setState(() => _calcCategory = c),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bundle quantity selector chips
          const Text('Select Consignment Volume (Bundles):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [5, 10, 25, 50, 100].map((qty) {
              final isSel = _calcBundles == qty;
              return ChoiceChip(
                label: Text('$qty Bundles (${qty * 600} Boxes)'),
                selected: isSel,
                selectedColor: const Color(0xFF0F766E),
                labelStyle: TextStyle(
                  color: isSel ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) => setState(() => _calcBundles = qty),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Live Calculation Results Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Unit Bundle Rate:', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    Text('₹${pricePerBdl.toStringAsFixed(0)} / Bundle (600 Boxes)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  ],
                ),
                const Divider(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Physical Matchboxes:', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    Text('$totalBoxes Matchboxes', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Gross Volume / Master Cartons:', style: TextStyle(fontSize: 13, color: Colors.black54)),
                    Text('$totalGross Gross • $masterCartons Master Cartons', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estimated Factory Invoice Total:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      '₹${totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFB91C1C)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Direct Action Buttons
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB91C1C),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => widget.onOrderNow(_calcBrand, _calcCategory, _calcBundles),
                icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 18),
                label: Text(
                  'Order $_calcBundles Bundles of $_calcBrand Now',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF065F46),
                  side: const BorderSide(color: Color(0xFF065F46)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: widget.onContactUs,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text('Request Dealership / Custom Packing'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== SECTION 7: MANUFACTURING ROADMAP ====================
  Widget _buildManufacturingProcessRoadmap(bool isMobile) {
    final steps = [
      {'num': '1', 'title': 'Splint Carbonization', 'desc': 'Aspen timber sliced into precision 40/48mm splints and vacuum chemical treated to eliminate dropping embers.'},
      {'num': '2', 'title': 'Chemical Dipping', 'desc': 'Heads dipped into specialized damp-proof pyrotechnic compound in continuous hot-air drying chambers.'},
      {'num': '3', 'title': 'Box Making & Print', 'desc': 'Outer & inner boxes formed from 250 GSM duplex boards with vivid 4-color offset brand printing.'},
      {'num': '4', 'title': 'Electronic Box Filling', 'desc': 'Automated high-speed electronic stick counting, insertion, and side friction painting.'},
      {'num': '5', 'title': 'Madippu 10-Gross Bundling', 'desc': '600 boxes bundled in heavy moisture-proof craft wrap, banded, and palletized for nationwide transport.'},
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 28),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.amber.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.precision_manufacturing_rounded, color: Color(0xFF0F172A), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'The Sivakasi Matchmaking Process (Factory Tour)',
                  style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'From raw Russian timber to moisture-proof finished bundles ready for dispatch.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (ctx, box) {
              final stepWidth = isMobile ? box.maxWidth : (box.maxWidth - 48) / 5;
              return Wrap(
                spacing: 12,
                runSpacing: 14,
                children: steps.map((s) {
                  return Container(
                    width: stepWidth,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withAlpha(25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFFB91C1C),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              s['num']!,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          s['title']!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s['desc']!,
                          style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== SECTION 9: DEALERSHIP BANNER ====================
  Widget _buildDealershipBanner(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 16,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA7F3D0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'EXCLUSIVE REGIONAL DEALERSHIPS OPEN',
                    style: TextStyle(color: Color(0xFF064E3B), fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Become an Authorized Deeba Match Dealer in Your Town',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Exclusive territory distribution rights, monthly volume incentive slabs, point-of-sale banners, and flexible lorry consignment dispatch for verified stockists.',
                  style: TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.45),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF064E3B),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: widget.onContactUs,
            icon: const Icon(Icons.handshake_rounded, size: 20),
            label: const Text('Apply for Dealership', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
          ),
        ],
      ),
    );
  }

  // ==================== SECTION 10: TESTIMONIALS ====================
  Widget _buildTestimonials(bool isMobile) {
    return _TestimonialsSection(isMobile: isMobile);
  }

  // ==================== SECTION 11: FAQ ACCORDION ====================
  Widget _buildFaqSection(bool isMobile) {
    final faqs = [
      {
        'q': 'What is the Minimum Order Quantity (MOQ) for wholesale supply?',
        'a': 'We supply from as small as 5 Bundles (3,000 boxes) for sample retail trials up to full lorry consignments (50 to 200+ Master Cartons). Direct factory bundle dispatch is available nationwide.',
      },
      {
        'q': 'How many matchboxes are packed in 1 Bundle and 1 Master Carton?',
        'a': '1 Bundle = 600 matchboxes (10 Gross). 1 Master Carton = 10 Bundles (6,000 matchboxes). All cartons are heavy-duty corrugated board suitable for multi-state lorry transit.',
      },
      {
        'q': 'How does lorry transport and delivery work to other states?',
        'a': 'Sivakasi is India\'s largest industrial transport hub. We load daily consignments onto leading logistics services (VRL, ABT, KPN, ARC, Navata, TCI) with door delivery or godown pickup across Tamil Nadu, Kerala, Karnataka, Andhra, Maharashtra, and North India.',
      },
      {
        'q': 'Can we get custom private labeling or promotional matchboxes for export?',
        'a': 'Yes! We offer OEM private label manufacturing with custom brand names, specific barcode printing, and moisture-proof export master packaging. Contact our sales department for plate making & MOQ requirements.',
      },
      {
        'q': 'What are the payment and billing terms for wholesale agencies?',
        'a': 'Initial consignments are dispatched against bank transfer / advance payment with full GST tax invoice. Established recurring agency dealers qualify for credit cycles and seasonal volume rebate slabs.',
      },
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeading(
            title: 'Frequently Asked Questions (Wholesale & Agency)',
            subtitle: 'Clear answers about ordering, bundle packaging, lorry transport & pricing',
            isMobile: isMobile,
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < faqs.length; i++) ...[
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() {
                  if (_expandedFaqs.contains(i)) {
                    _expandedFaqs.remove(i);
                  } else {
                    _expandedFaqs.add(i);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _expandedFaqs.contains(i) ? const Color(0xFFF8FAFC) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _expandedFaqs.contains(i) ? Colors.grey.shade300 : Colors.transparent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            faqs[i]['q']!,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                              color: _expandedFaqs.contains(i) ? const Color(0xFFB91C1C) : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Icon(
                          _expandedFaqs.contains(i) ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                    if (_expandedFaqs.contains(i)) ...[
                      const SizedBox(height: 8),
                      Text(
                        faqs[i]['a']!,
                        style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.45),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (i < faqs.length - 1) const Divider(height: 12),
          ],
        ],
      ),
    );
  }

  // ==================== SECTION 12: RICH CORPORATE INDUSTRIAL FOOTER ====================
  Widget _buildCorporateFooter(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 22 : 36),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 30,
            runSpacing: 24,
            alignment: WrapAlignment.spaceBetween,
            children: [
              // Company details
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFF991B1B), size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'DEEBA MATCH HOUSE',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16.5, letterSpacing: 0.8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Sivakasi\'s premier safety matchbox manufacturing and export house. Supplying Eagle, Pulli & Joker brands to wholesale distributors nationwide.',
                      style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.45),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '🏭 Factory Works: Match Industrial Estate, Sivakasi – Sattur Road, Virudhunagar Dist, Tamil Nadu – 626123, India.',
                      style: TextStyle(color: Colors.amberAccent, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),

              // Quick Contact
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Direct Sales & Inquiry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    const Text('📞 Wholesale Desk: +91 98421 55667', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                    const SizedBox(height: 4),
                    const Text('📱 WhatsApp Order: +91 94431 22345', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                    const SizedBox(height: 4),
                    const Text('✉️ Email: orders@deebamatchhouse.com', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                    const SizedBox(height: 4),
                    const Text('🕒 Hours: Mon – Sat: 8:30 AM – 7:30 PM', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                  ],
                ),
              ),

              // Direct Actions
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Wholesale Portals', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () => widget.onOrderNow('Eagle', 'Rs. 1'),
                      child: const Text('🛒 Place Online Order →', style: TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: widget.onExploreProducts,
                      child: const Text('📦 Full Product Catalog →', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: widget.onContactUs,
                      child: const Text('🤝 Agency Application →', style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2026 Deeba Match House • Sivakasi. All rights reserved.',
                style: TextStyle(color: Colors.white.withAlpha(140), fontSize: 11.5),
              ),
              Text(
                'ISO 9001:2015 Compliant • GSTIN Verified',
                style: TextStyle(color: Colors.white.withAlpha(140), fontSize: 11.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading({required String title, required String subtitle, required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: isMobile ? 12 : 13,
          ),
        ),
      ],
    );
  }
}

// ==================== SECTION 10: TESTIMONIALS CAROUSEL WIDGET ====================
class _TestimonialsSection extends StatefulWidget {
  final bool isMobile;
  const _TestimonialsSection({required this.isMobile});

  @override
  State<_TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<_TestimonialsSection> {
  late final PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _reviews = const [
    {
      'quote': 'Eagle brand is our fastest-moving Rs. 1 matchbox across 120 retail shops in Madurai. Splints never snap, and customers specifically ask for Eagle.',
      'author': 'Senthil Murugan Traders',
      'city': 'Madurai, Tamil Nadu',
      'tenure': '5 Years Partner',
      'initials': 'SM',
      'color': 0xFF059669,
    },
    {
      'quote': 'During Karnataka monsoon other matches get damp and fail. Deeba\'s moisture-proof chemical head strikes every single time. Absolutely reliable.',
      'author': 'Venkateshwara Agencies',
      'city': 'Bengaluru, Karnataka',
      'tenure': '3 Years Partner',
      'initials': 'VA',
      'color': 0xFF2563EB,
    },
    {
      'quote': 'Lorry loads arrive directly from Sivakasi in pristine master cartons. Accurate bundle billing and prompt communication by their factory sales team.',
      'author': 'Patel Wholesale Mart',
      'city': 'Pune / Mumbai, Maharashtra',
      'tenure': '4 Years Partner',
      'initials': 'PW',
      'color': 0xFFD97706,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: widget.isMobile ? 0.90 : 1.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCard(Map<String, dynamic> r, {bool isMobileCard = false}) {
    return Container(
      padding: EdgeInsets.all(isMobileCard ? 18 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Row(
                children: List.generate(
                  5,
                  (_) => const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, size: 13, color: Color(0xFF059669)),
                    const SizedBox(width: 4),
                    Text(
                      r['tenure'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${r['quote']}"',
            style: const TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.45,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: Color(r['color'] as int),
                child: Text(
                  r['initials'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r['author'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            r['city'] as String,
                            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trusted by Wholesale Dealers Nationwide',
                    style: TextStyle(
                      fontSize: widget.isMobile ? 19 : 26,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'What agency owners, stockists, and supermarket suppliers say about Deeba Match House',
                    style: TextStyle(
                      fontSize: widget.isMobile ? 12.5 : 14.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.isMobile)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_currentPage + 1} / ${_reviews.length}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (widget.isMobile) ...[
          // MOBILE VIEW: SWIPEABLE CAROUSEL WITH PEEK
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _reviews.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (ctx, idx) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildCard(_reviews[idx], isMobileCard: true),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // CONTROLS & DOTS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                onPressed: _currentPage > 0
                    ? () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: const Color(0xFF0F172A),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_reviews.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFB91C1C) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),
              IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                onPressed: _currentPage < _reviews.length - 1
                    ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                color: const Color(0xFF0F172A),
              ),
            ],
          ),
        ] else ...[
          // DESKTOP: 3-COLUMN SIDE BY SIDE
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _reviews.map((r) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildCard(r),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _CategoryBannerCard extends StatelessWidget {
  final double width;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _CategoryBannerCard({
    required this.width,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(70)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 3),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.black54, fontSize: 12.5, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. PRODUCTS & PRODUCT DETAILS SECTION
// ============================================================================
class _ProductsSection extends StatefulWidget {
  final DeebaStore store;
  final void Function(String brand, String category) onOrderProduct;

  const _ProductsSection({
    required this.store,
    required this.onOrderProduct,
  });

  @override
  State<_ProductsSection> createState() => _ProductsSectionState();
}

class _ProductsSectionState extends State<_ProductsSection> {
  String _selectedCategoryFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final products = widget.store.products.where((p) {
      if (!p.isActive) return false;
      if (_selectedCategoryFilter == 'All') return true;
      return p.priceCategories.contains(_selectedCategoryFilter);
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 640;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 28,
            vertical: isMobile ? 16 : 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Premium Section Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobile ? 18 : 24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 16,
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD97706).withAlpha(40),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFFBBF24)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded, size: 14, color: Color(0xFFFBBF24)),
                                  SizedBox(width: 5),
                                  Text(
                                    'Sivakasi Direct Factory Wholesale',
                                    style: TextStyle(
                                      color: Color(0xFFFBBF24),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isMobile)
                              const Text(
                                '600 Boxes / Master Bundle',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Our Safety Matchbox Brands',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Premium carbonized safety matches engineered for instant ignition, damp-resistance, and smooth strike across Tamil Nadu and South India.',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Filter Chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Category:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final filter in ['All', ...widget.store.priceCategories])
                            ChoiceChip(
                              label: Text(filter == 'All' ? 'All Brands' : '$filter Matches'),
                              selected: _selectedCategoryFilter == filter,
                              selectedColor: const Color(0xFFB91C1C),
                              labelStyle: TextStyle(
                                color: _selectedCategoryFilter == filter ? Colors.white : const Color(0xFF1E293B),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                              onSelected: (_) => setState(() => _selectedCategoryFilter = filter),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Responsive Cards Layout
                  LayoutBuilder(
                    builder: (ctx, box) {
                      final cardWidth = box.maxWidth < 740 ? box.maxWidth : (box.maxWidth - 40) / 3;
                      return Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: products
                            .map(
                              (p) => _ModernProductCardWidget(
                                width: cardWidth,
                                product: p,
                                store: widget.store,
                                onOrderNow: widget.onOrderProduct,
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

typedef _ProductCardWidget = _ModernProductCardWidget;

// ==================== MODERN REDESIGNED PRODUCT CARD ====================
class _ModernProductCardWidget extends StatefulWidget {
  final double width;
  final ProductItem product;
  final DeebaStore store;
  final void Function(String brand, String category) onOrderNow;

  const _ModernProductCardWidget({
    required this.width,
    required this.product,
    required this.store,
    required this.onOrderNow,
  });

  @override
  State<_ModernProductCardWidget> createState() => _ModernProductCardWidgetState();
}

class _ModernProductCardWidgetState extends State<_ModernProductCardWidget> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.product.priceCategories.first;
  }

  Color get _brandPrimaryColor {
    final name = widget.product.name.toLowerCase();
    if (name.contains('eagle')) return const Color(0xFFB91C1C); // Crimson
    if (name.contains('pulli')) return const Color(0xFFBE185D); // Rose Ruby
    return const Color(0xFFD97706); // Amber Fire for Joker
  }

  Color get _brandDarkColor {
    final name = widget.product.name.toLowerCase();
    if (name.contains('eagle')) return const Color(0xFF7F1D1D);
    if (name.contains('pulli')) return const Color(0xFF831843);
    return const Color(0xFF92400E);
  }

  String get _badgeText {
    final name = widget.product.name.toLowerCase();
    if (name.contains('eagle')) return '★ BESTSELLER • WHOLESALE #1';
    if (name.contains('pulli')) return '♥ HOUSEHOLD FAVORITE';
    return '⚡ FASTEST MOVING';
  }

  String get _brandSubtitle {
    final name = widget.product.name.toLowerCase();
    if (name.contains('eagle')) return 'Premium Carbonized Safety Matches';
    if (name.contains('pulli')) return 'Household & Kitchen Matches';
    return 'High-Strike Retail & Petty Store Matches';
  }

  double get _currentPrice {
    return widget.product.bundlePriceByCategory[_selectedCategory] ?? 450.0;
  }

  double get _pricePerBox {
    return _currentPrice / 600.0;
  }

  String get _sticksPerBox {
    return _selectedCategory == 'Rs. 1' ? '40 Sticks' : '75 Jumbo Sticks';
  }

  void _showProductDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _brandPrimaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.local_fire_department_rounded, color: _brandPrimaryColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.product.name} Safety Matches',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                  Text(
                    widget.product.productType,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.description,
                  style: const TextStyle(height: 1.45, fontSize: 13.5),
                ),
                const SizedBox(height: 14),
                const Divider(),
                _detailRow('Brand Name', widget.product.name),
                _detailRow('Product Type', widget.product.productType),
                _detailRow('Available Options', widget.product.priceCategories.join(', ')),
                _detailRow('Sticks Count', widget.product.sticksPerBox),
                _detailRow('Bundle Packing', widget.product.boxesPerBundle),
                const Divider(),
                const Text(
                  'Wholesale Bundle Pricing:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                for (final cat in widget.product.priceCategories)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$cat Category Bundle:'),
                        Text(
                          '₹${(widget.product.bundlePriceByCategory[cat] ?? 450).toStringAsFixed(0)} / Bundle',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: _brandPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          for (final cat in widget.product.priceCategories)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _brandPrimaryColor,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                widget.onOrderNow(widget.product.name, cat);
              },
              child: Text('Order $cat'),
            ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. BRAND HERO HEADER WITH 3D MATCHBOX PACKAGING
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              gradient: LinearGradient(
                colors: [_brandDarkColor, _brandPrimaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(70),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        _badgeText,
                        style: const TextStyle(
                          color: Color(0xFFFDE68A),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: Color(0xFFFBBF24)),
                        SizedBox(width: 2),
                        Text(
                          '4.9 (500+ Dealers)',
                          style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Matchbox 3D Pack + Brand Title Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Realistic Sivakasi 3D Matchbox Mockup Graphic
                    _buildRealisticMatchboxGraphic(),
                    const SizedBox(width: 14),

                    // Title & Specs
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.product.name} Matches',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _brandSubtitle,
                            style: const TextStyle(
                              color: Color(0xFFF1F5F9),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(35),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Direct Lorry Load Available',
                              style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. CARD BODY & INTERACTIVE CONTROLS
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Interactive Category Switcher (Rs. 1 / Rs. 2)
                const Text(
                  'Choose Matchbox Size / Variant:',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: widget.product.priceCategories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  cat == 'Rs. 1' ? 'Rs. 1 Regular' : 'Rs. 2 Jumbo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? _brandPrimaryColor : const Color(0xFF475569),
                                  ),
                                ),
                                Text(
                                  cat == 'Rs. 1' ? '40 Sticks / Box' : '75 Sticks / Box',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),

                // Live Wholesale Price & Economics Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Wholesale Bundle Rate:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '₹${_currentPrice.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: _brandPrimaryColor,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '/ Bundle',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Only ₹${_pricePerBox.toStringAsFixed(2)} / Box',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16, thickness: 0.8),

                      // Wholesale Box Packing Breakdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildEconomyPill('600 Boxes', '10 Pack × 60', Icons.inventory_2_outlined),
                          _buildEconomyPill(_sticksPerBox, 'Carbonized', Icons.local_fire_department_outlined),
                          _buildEconomyPill('25% Margin', 'Retail Profit', Icons.trending_up_rounded),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Feature Highlights
                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF16A34A)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '100% Moisture Proof Head • Damp Weather Tested',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF16A34A)),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Instant Ignition Side Friction Striker Coated',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF334155),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _showProductDetailsDialog(context),
                        child: const Text('Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                        label: Text(
                          'Order $_selectedCategory',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        onPressed: () => widget.onOrderNow(
                          widget.product.name,
                          _selectedCategory,
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
    );
  }

  Widget _buildEconomyPill(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ],
    );
  }

  // Realistic Sivakasi 3D Matchbox Mockup Graphic with authentic striker strip
  Widget _buildRealisticMatchboxGraphic() {
    return Container(
      width: 72,
      height: 94,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Matchbox Main Face
          Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFDE68A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFD97706), width: 1),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _brandPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFFDE68A),
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.product.name.toUpperCase(),
                      style: TextStyle(
                        color: _brandDarkColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Text(
                      'MATCHES',
                      style: TextStyle(
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w800,
                        fontSize: 7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Brown Friction Striker Strip along left edge
          Positioned(
            left: 0,
            top: 10,
            bottom: 10,
            child: Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF451A03), // Matchbox dark brown phosphor friction strip
                borderRadius: BorderRadius.horizontal(right: Radius.circular(2)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// 3. ONLINE ORDER SECTION
// ============================================================================
class _OnlineOrderSection extends StatefulWidget {
  final DeebaStore store;
  final String? initialBrand;
  final String? initialCategory;
  final int? initialQuantity;

  const _OnlineOrderSection({
    required this.store,
    this.initialBrand,
    this.initialCategory,
    this.initialQuantity,
  });

  @override
  State<_OnlineOrderSection> createState() => _OnlineOrderSectionState();
}

class _OnlineOrderSectionState extends State<_OnlineOrderSection> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedBrand;
  late String _selectedCategory;
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '25');
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedBrand = widget.initialBrand ?? widget.store.brandTypes.first;
    _selectedCategory = widget.initialCategory ?? widget.store.priceCategories.first;
    if (widget.initialQuantity != null) {
      _qtyCtrl.text = widget.initialQuantity.toString();
    }
  }

  @override
  void didUpdateWidget(covariant _OnlineOrderSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialBrand != null && widget.initialBrand != oldWidget.initialBrand) {
      _selectedBrand = widget.initialBrand!;
    }
    if (widget.initialCategory != null && widget.initialCategory != oldWidget.initialCategory) {
      _selectedCategory = widget.initialCategory!;
    }
    if (widget.initialQuantity != null && widget.initialQuantity != oldWidget.initialQuantity) {
      _qtyCtrl.text = widget.initialQuantity.toString();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _addressCtrl.dispose();
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool _isSubmitting = false;

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 25;
    final customerName = _nameCtrl.text.trim();
    final mobile = _mobileCtrl.text.trim();
    final brand = _selectedBrand;
    final category = _selectedCategory;

    await widget.store.placeOnlineOrder(
      customerName: customerName,
      mobileNumber: mobile,
      address: _addressCtrl.text.trim(),
      productBrand: brand,
      productCategory: category,
      quantityBundles: qty,
      additionalNotes: _notesCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('Order Placed Successfully!'),
          ],
        ),
        content: Text(
          'Thank you, $customerName! Your wholesale order for $qty bundles of $brand ($category) has been recorded.\n\n'
          'Our factory dispatch desk will review your order and call $mobile shortly for transport booking.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );

    _nameCtrl.clear();
    _mobileCtrl.clear();
    _addressCtrl.clear();
    _qtyCtrl.text = '25';
    _notesCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final brands = widget.store.brandTypes;
    final categories = widget.store.priceCategories;
    if (!brands.contains(_selectedBrand)) _selectedBrand = brands.first;
    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Container(
                padding: EdgeInsets.all(isMobile ? 18 : 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.shopping_bag_rounded,
                              color: Color(0xFFB91C1C),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Place a Wholesale Matchbox Order',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Direct factory booking with no advance online gateway needed. Dispatch team will confirm lorry details.',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Customer / Agency / Store Name *',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter customer name'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _mobileCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number (for Transport Delivery) *',
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().length < 10)
                            ? 'Please enter valid 10-digit mobile'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _addressCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Delivery Town / Godown Address / Lorry Shed *',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter destination address or town'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedBrand,
                              decoration: const InputDecoration(
                                labelText: 'Brand',
                                border: OutlineInputBorder(),
                              ),
                              items: brands
                                  .map(
                                    (b) => DropdownMenuItem(
                                      value: b,
                                      child: Text(b),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => _selectedBrand = v);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                              items: categories
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setState(() => _selectedCategory = v);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantity (in Bundles - 1 Bundle = 600 Boxes) *',
                          prefixIcon: Icon(Icons.numbers_rounded),
                          suffixText: 'Bundles',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n <= 0) {
                            return 'Enter valid bundle quantity';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _notesCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Preferred Transport / Special Instructions',
                          hintText: 'E.g. Book via VRL Logistics to Hubli Godown',
                          prefixIcon: Icon(Icons.note_alt_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFB91C1C),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _isSubmitting ? null : _submitOrder,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded),
                          label: Text(
                            _isSubmitting
                                ? 'Submitting to Factory Server...'
                                : 'Submit Wholesale Order Booking',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// 4. ABOUT US SECTION (EXPANDED INDUSTRIAL PROFILE)
// ============================================================================
class _AboutUsSection extends StatelessWidget {
  const _AboutUsSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 640;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 18 : 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About Deeba Match House',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF7F1D1D),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Deeba Match House is a premier industrial manufacturer and wholesale supplier of high-quality safety matches, based in the renowned matchmaking capital of Sivakasi, Tamil Nadu. Established with a vision to deliver dependable, damp-proof, and safe matches, our manufacturing complex operates continuous automatic box-making, chemical head dipping, and precision stick-filling machinery.',
                          style: TextStyle(fontSize: 14.5, height: 1.6),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Over the past 25+ years, Deeba Match House has earned the trust of over 500+ wholesale stockists, government civil supplies, and supermarket distributors across Tamil Nadu, Kerala, Karnataka, Andhra Pradesh, Maharashtra, and Central India.',
                          style: TextStyle(fontSize: 14.5, height: 1.6),
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 16),
                        const Text(
                          'Our Manufacturing Excellence & Infrastructure',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _aboutBullet('Automated Box Making & Stick Counter Filling: State-of-the-art high-speed machines ensuring every box contains an exact 40-42 or 72-75 sticks without splint breakage.'),
                        _aboutBullet('Precision 8-Chemical Dipping Lab: Chlorine, Hydrochlorine, Sulphur, Zinc White, Super Black Capsule, Biogram, Wax, and Manjeram binders formulating non-flying embers.'),
                        _aboutBullet('Damp-Proof Monsoon Friction Technology: Double-pass red phosphorus side painting resistant to coastal humidity in western and southern India.'),
                        _aboutBullet('Strict Quality Inspection: Drop tests, ignition sensitivity tests, after-glow suppression, and 10-Gross moisture-barrier bundling.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (ctx, box) {
                      final cardWidth = box.maxWidth < 700 ? box.maxWidth : (box.maxWidth - 20) / 2;
                      return Wrap(
                        spacing: 20,
                        runSpacing: 16,
                        children: [
                          _missionCard(
                            width: cardWidth,
                            title: 'Our Mission',
                            icon: Icons.flag_rounded,
                            color: const Color(0xFFB91C1C),
                            text: 'To manufacture safe, moisture-resistant, and high-strike Rs. 1 and Rs. 2 safety matchboxes (Eagle, Pulli & Joker) for every household and commercial enterprise, backed by seamless nationwide lorry dispatch.',
                          ),
                          _missionCard(
                            width: cardWidth,
                            title: 'Our Vision',
                            icon: Icons.visibility_rounded,
                            color: const Color(0xFFD97706),
                            text: 'To lead the transformation of the matchbox industry into an efficient digital ecosystem with transparent live inventory, automated factory ERP tracking, and sustainable employment for local artisans.',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _aboutBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13.5, height: 1.45))),
        ],
      ),
    );
  }

  static Widget _missionCard({
    required double width,
    required String title,
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 5. CONTACT US SECTION (FULL DIRECTORY)
// ============================================================================
class _ContactUsSection extends StatefulWidget {
  final DeebaStore store;
  const _ContactUsSection({required this.store});

  @override
  State<_ContactUsSection> createState() => _ContactUsSectionState();
}

class _ContactUsSectionState extends State<_ContactUsSection> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _submitContact() {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name and phone number')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green),
            SizedBox(width: 8),
            Text('Inquiry Submitted'),
          ],
        ),
        content: Text(
          'Thank you, ${_nameCtrl.text.trim()}! Our Sivakasi factory sales desk will contact you at ${_phoneCtrl.text.trim()} within 2 hours.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    _nameCtrl.clear();
    _phoneCtrl.clear();
    _emailCtrl.clear();
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 18 : 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contact Deeba Match House Works',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF7F1D1D),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Reach our Sivakasi sales and dispatch desk for wholesale booking, dealership applications & freight transport details.',
                          style: TextStyle(fontSize: 13.5, color: Colors.black54),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: Color(0xFFB91C1C), size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Deeba Match House Works, Match Industrial Area, Sivakasi – Sattur Road, Virudhunagar Dist, Tamil Nadu – 626123.',
                                style: TextStyle(fontSize: 13.5, color: Colors.grey.shade800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.phone_rounded, color: Color(0xFF0F766E), size: 20),
                            const SizedBox(width: 10),
                            Text('Factory Office: +91 98421 55667 / +91 94431 22345', style: TextStyle(fontSize: 13.5, color: Colors.grey.shade800)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.email_rounded, color: Color(0xFF0284C7), size: 20),
                            const SizedBox(width: 10),
                            Text('Email: orders@deebamatchhouse.com / sales@deebamatchhouse.com', style: TextStyle(fontSize: 13.5, color: Colors.grey.shade800)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: Color(0xFFD97706), size: 20),
                            const SizedBox(width: 10),
                            Text('Working Hours: Monday – Saturday: 8:30 AM – 7:30 PM (Sunday Closed)', style: TextStyle(fontSize: 13.5, color: Colors.grey.shade800)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(isMobile ? 18 : 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Send Direct Inquiry / Request Call Back',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(labelText: 'Your Name *', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: 'Mobile Number *', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _msgCtrl,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Message / Inquiry Details', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFB91C1C),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _submitContact,
                            icon: const Icon(Icons.send_rounded),
                            label: const Text('Submit Factory Inquiry', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
