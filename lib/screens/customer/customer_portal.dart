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

  void _navigateToOrderWithProduct(String brand, String category) {
    setState(() {
      _preselectedProduct = brand;
      _preselectedCategory = category;
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
                    padding: EdgeInsets.all(isMobile ? 6 : 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      color: const Color(0xFF7F1D1D),
                      size: isMobile ? 20 : 26,
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
                            fontWeight: FontWeight.w900,
                            fontSize: isMobile ? 14.5 : 18,
                            letterSpacing: 0.6,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Safety Matches • Eagle • Pulli • Joker',
                          style: TextStyle(
                            color: Color(0xFFFDE68A),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isWide) ...[
                    _buildTopNavButton(0, 'Home', Icons.home_rounded),
                    _buildTopNavButton(
                        1, 'Products', Icons.inventory_2_rounded),
                    _buildTopNavButton(
                        2, 'Online Order', Icons.shopping_bag_rounded),
                    _buildTopNavButton(3, 'About Us', Icons.business_rounded),
                    _buildTopNavButton(
                        4, 'Contact Us', Icons.contact_phone_rounded),
                    const SizedBox(width: 10),
                  ],
                  if (widget.onOpenLoginModal != null)
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.amber.shade400,
                        foregroundColor: const Color(0xFF7F1D1D),
                        visualDensity: isMobile
                            ? VisualDensity.compact
                            : VisualDensity.standard,
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 10 : 14,
                          vertical: isMobile ? 6 : 10,
                        ),
                      ),
                      onPressed: widget.onOpenLoginModal,
                      icon: const Icon(Icons.admin_panel_settings_rounded,
                          size: 16),
                      label: Text(
                        isWide ? 'Admin / Staff Portal' : 'Portal',
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
            onOrderNow: (brand, cat) => _navigateToOrderWithProduct(brand, cat),
            onContactUs: () => setState(() => _selectedTab = 4),
          ),
          _ProductsSection(
            store: widget.store,
            onOrderProduct: (brand, cat) =>
                _navigateToOrderWithProduct(brand, cat),
          ),
          _OnlineOrderSection(
            store: widget.store,
            initialBrand: _preselectedProduct,
            initialCategory: _preselectedCategory,
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
              onDestinationSelected: (idx) =>
                  setState(() => _selectedTab = idx),
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFFEE2E2),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon:
                      Icon(Icons.home_rounded, color: Color(0xFFB91C1C)),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon:
                      Icon(Icons.inventory_2_rounded, color: Color(0xFFB91C1C)),
                  label: 'Products',
                ),
                NavigationDestination(
                  icon: Icon(Icons.shopping_bag_outlined),
                  selectedIcon: Icon(Icons.shopping_bag_rounded,
                      color: Color(0xFFB91C1C)),
                  label: 'Order',
                ),
                NavigationDestination(
                  icon: Icon(Icons.business_outlined),
                  selectedIcon:
                      Icon(Icons.business_rounded, color: Color(0xFFB91C1C)),
                  label: 'About',
                ),
                NavigationDestination(
                  icon: Icon(Icons.contact_phone_outlined),
                  selectedIcon: Icon(Icons.contact_phone_rounded,
                      color: Color(0xFFB91C1C)),
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
          backgroundColor: isSelected
              ? Colors.white.withValues(alpha: 0.16)
              : Colors.transparent,
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
// 1. HOME SECTION
// ============================================================================
class _HomeSection extends StatelessWidget {
  final DeebaStore store;
  final VoidCallback onExploreProducts;
  final void Function(String brand, String category) onOrderNow;
  final VoidCallback onContactUs;

  const _HomeSection({
    required this.store,
    required this.onExploreProducts,
    required this.onOrderNow,
    required this.onContactUs,
  });

  @override
  Widget build(BuildContext context) {
    final activeProducts = store.products.where((p) => p.isActive).toList();

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
                  // Hero Banner
                  Container(
                    padding: EdgeInsets.all(isMobile ? 20 : 32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isMobile ? 18 : 24),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF450A0A),
                          Color(0xFF991B1B),
                          Color(0xFFB45309)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade400,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'DEEBA MATCH HOUSE • WHOLESALE & RETAIL',
                            style: TextStyle(
                              color: const Color(0xFF450A0A),
                              fontWeight: FontWeight.w900,
                              fontSize: isMobile ? 10 : 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'High-Strike Safety Matches for Every Home, Store & Agency',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 21 : 30,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Manufacturers of Eagle, Pulli, and Joker matchbox brands in Rs. 1 and Rs. 2 categories. Superior wax-dipped splints, damp-proof ignition heads, and bulk bundle supply.',
                          style: TextStyle(
                            color: const Color(0xFFFDE68A),
                            fontSize: isMobile ? 13 : 15,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.amber.shade400,
                                foregroundColor: const Color(0xFF450A0A),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 16 : 22,
                                  vertical: isMobile ? 12 : 15,
                                ),
                              ),
                              onPressed: () => onOrderNow('Eagle', 'Rs. 1'),
                              icon: const Icon(Icons.shopping_cart_checkout,
                                  size: 18),
                              label: const Text(
                                'Place Online Order',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white70),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 16 : 20,
                                  vertical: isMobile ? 12 : 15,
                                ),
                              ),
                              onPressed: onExploreProducts,
                              icon:
                                  const Icon(Icons.grid_view_rounded, size: 18),
                              label: const Text('Explore Products'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 22 : 30),

                  // Product Categories
                  Text(
                    'Product Categories',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (ctx, box) {
                      final cardWidth = box.maxWidth < 720
                          ? box.maxWidth
                          : (box.maxWidth - 32) / 3;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          _CategoryBannerCard(
                            width: cardWidth,
                            title: 'Rs. 1 Matchbox Category',
                            subtitle:
                                'Fast-moving retail packs (40 sticks/box • 600 boxes/bundle) for Eagle, Pulli & Joker.',
                            icon: Icons.currency_rupee_rounded,
                            color: const Color(0xFFB91C1C),
                            onTap: onExploreProducts,
                          ),
                          _CategoryBannerCard(
                            width: cardWidth,
                            title: 'Rs. 2 Matchbox Category',
                            subtitle:
                                'Deluxe jumbo safety matchboxes (70-75 sticks/box • 600 boxes/bundle) for extended use.',
                            icon: Icons.workspace_premium_rounded,
                            color: const Color(0xFFD97706),
                            onTap: onExploreProducts,
                          ),
                          _CategoryBannerCard(
                            width: cardWidth,
                            title: 'Bulk Agent & Store Supply',
                            subtitle:
                                'Direct factory bundle dispatch with custom packaging covers and wholesale pricing.',
                            icon: Icons.local_shipping_rounded,
                            color: const Color(0xFF047857),
                            onTap: () => onOrderNow('Eagle', 'Rs. 1'),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: isMobile ? 22 : 30),

                  // Featured Products
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Featured Matchbox Brands',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onExploreProducts,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: const Text('All Brands'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (ctx, box) {
                      final cardWidth = box.maxWidth < 740
                          ? box.maxWidth
                          : (box.maxWidth - 40) / 3;
                      return Wrap(
                        spacing: 20,
                        runSpacing: 16,
                        children: activeProducts
                            .map(
                              (product) => _ProductCardWidget(
                                width: cardWidth,
                                product: product,
                                store: store,
                                onOrderNow: onOrderNow,
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Company Contact Banner
                  Container(
                    padding: EdgeInsets.all(isMobile ? 18 : 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 14,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need Bulk Orders for Your Agency or Store?',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Deeba Match House • Sivakasi / Kovilpatti Belt, Tamil Nadu\nPhone: +91 98421 55667 • Email: orders@deebamatchhouse.com',
                              style:
                                  TextStyle(color: Colors.black54, height: 1.4),
                            ),
                          ],
                        ),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFB91C1C),
                          ),
                          onPressed: onContactUs,
                          icon: const Icon(Icons.call_rounded, size: 18),
                          label: const Text('Contact Company'),
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

class _CategoryBannerCard extends StatelessWidget {
  final double width;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryBannerCard({
    required this.width,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
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
          border: Border.all(color: color.withValues(alpha: 0.28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
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
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1160),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Our Matchbox Products (Eagle • Pulli • Joker)',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Select any brand to view specifications or place a wholesale bundle order.',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 13),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final filter in [
                            'All',
                            ...widget.store.priceCategories
                          ])
                            ChoiceChip(
                              label: Text(filter),
                              selected: _selectedCategoryFilter == filter,
                              onSelected: (_) => setState(
                                () => _selectedCategoryFilter = filter,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (ctx, box) {
                      final cardWidth = box.maxWidth < 740
                          ? box.maxWidth
                          : (box.maxWidth - 40) / 3;
                      return Wrap(
                        spacing: 20,
                        runSpacing: 16,
                        children: products
                            .map(
                              (p) => _ProductCardWidget(
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

class _ProductCardWidget extends StatelessWidget {
  final double width;
  final ProductItem product;
  final DeebaStore store;
  final void Function(String brand, String category) onOrderNow;

  const _ProductCardWidget({
    required this.width,
    required this.product,
    required this.store,
    required this.onOrderNow,
  });

  void _showProductDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(product.colorHex),
              foregroundColor: Colors.white,
              child: const Icon(Icons.local_fire_department_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${product.name} Safety Matches',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                  Text(
                    product.productType,
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
                  product.description,
                  style: const TextStyle(height: 1.45, fontSize: 13.5),
                ),
                const SizedBox(height: 14),
                const Divider(),
                _detailRow('Brand Name', product.name),
                _detailRow('Product Type', product.productType),
                _detailRow(
                    'Available Options', product.priceCategories.join(', ')),
                _detailRow('Sticks Count', product.sticksPerBox),
                _detailRow('Bundle Packing', product.boxesPerBundle),
                const Divider(),
                const Text(
                  'Wholesale Bundle Pricing:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                for (final cat in product.priceCategories)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$cat Category Bundle:'),
                        Text(
                          'Rs. ${(product.bundlePriceByCategory[cat] ?? 450).toStringAsFixed(0)} / Bundle',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB91C1C),
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
          for (final cat in product.priceCategories)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Color(product.colorHex),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                onOrderNow(product.name, cat);
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
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
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
    final brandColor = Color(product.colorHex);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [
                  brandColor,
                  brandColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade300,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: brandColor,
                        size: 30,
                      ),
                      Text(
                        product.name.toUpperCase(),
                        style: TextStyle(
                          color: brandColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${product.name} Matches',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product.productType,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: product.priceCategories
                            .map(
                              (c) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  c,
                                  style: const TextStyle(
                                    color: Colors.amberAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF7F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      for (final cat in product.priceCategories)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${product.name} ($cat)',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                ),
                              ),
                              Text(
                                'Rs. ${(product.bundlePriceByCategory[cat] ?? 450).toStringAsFixed(0)} / Bundle',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: brandColor,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showProductDetailsDialog(context),
                        child: const Text('Details'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: brandColor,
                        ),
                        onPressed: () => onOrderNow(
                          product.name,
                          product.priceCategories.first,
                        ),
                        icon:
                            const Icon(Icons.shopping_bag_outlined, size: 16),
                        label: const Text('Order'),
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

// ============================================================================
// 3. ONLINE ORDER SECTION
// ============================================================================
class _OnlineOrderSection extends StatefulWidget {
  final DeebaStore store;
  final String? initialBrand;
  final String? initialCategory;

  const _OnlineOrderSection({
    required this.store,
    this.initialBrand,
    this.initialCategory,
  });

  @override
  State<_OnlineOrderSection> createState() => _OnlineOrderSectionState();
}

class _OnlineOrderSectionState extends State<_OnlineOrderSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '25');
  final _notesCtrl = TextEditingController();

  late String _selectedBrand;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedBrand = widget.initialBrand ?? widget.store.brandTypes.first;
    _selectedCategory =
        widget.initialCategory ?? widget.store.priceCategories.first;
  }

  @override
  void didUpdateWidget(covariant _OnlineOrderSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialBrand != null &&
        widget.initialBrand != oldWidget.initialBrand) {
      _selectedBrand = widget.initialBrand!;
    }
    if (widget.initialCategory != null &&
        widget.initialCategory != oldWidget.initialCategory) {
      _selectedCategory = widget.initialCategory!;
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

  void _submitOrder() {
    if (!_formKey.currentState!.validate()) return;
    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 1;

    widget.store.placeOnlineOrder(
      customerName: _nameCtrl.text.trim(),
      mobileNumber: _mobileCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      productBrand: _selectedBrand,
      productCategory: _selectedCategory,
      quantityBundles: qty,
      additionalNotes: _notesCtrl.text.trim(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_rounded,
          color: Colors.green,
          size: 54,
        ),
        title: const Text('Order Placed Successfully!'),
        content: Text(
          'Thank you, ${_nameCtrl.text.trim()}!\n\n'
          'Your order for $qty Bundles of $_selectedBrand ($_selectedCategory) '
          'has been received in the Deeba Match House Admin System.\n\n'
          'Our team will review your order and contact you at ${_mobileCtrl.text.trim()} shortly.',
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
                                  'Place an Online Matchbox Order',
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'No online payment required now. Admin will confirm & contact you.',
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
                          labelText: 'Mobile Number *',
                          prefixIcon: Icon(Icons.phone_android_rounded),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().length < 10)
                            ? 'Enter a valid 10-digit mobile number'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _addressCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Delivery Address / City *',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter delivery address'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedBrand,
                              decoration: const InputDecoration(
                                labelText: 'Product',
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
                          labelText: 'Quantity (in Bundles) *',
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
                          labelText: 'Additional Notes',
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
                          ),
                          onPressed: _submitOrder,
                          icon: const Icon(Icons.send_rounded),
                          label: const Text(
                            'Submit Online Order',
                            style: TextStyle(
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
// 4. ABOUT US SECTION
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
              constraints: const BoxConstraints(maxWidth: 1000),
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
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About Deeba Match House',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF7F1D1D),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Deeba Match House is a premier manufacturer and wholesale supplier of high-quality safety matches. Built on decades of craftsmanship and modern automated box-making & chemical dipping processes, our factory produces trusted household and commercial matchbox brands — Eagle, Pulli, and Joker.',
                          style: TextStyle(fontSize: 14.5, height: 1.55),
                        ),
                        SizedBox(height: 18),
                        Divider(),
                        SizedBox(height: 14),
                        Text(
                          'Our Manufacturing Excellence',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Precision Chemical Formulation (8 Types): Balanced Chlorine, Hydrochlorine, Sulphur, Zinc White, Super Black Capsule, Biogram, Wax & Manjeram for safe single-strike ignition.\n'
                          '• Separate Multi-Tier Packaging: Outer Bundle, Inner Bundle, Packing Cover, Packing Bundle Sheet (including Common Sheet), and Brand Labels.\n'
                          '• Dedicated Workforce & Quality Supervision: Experienced production, packing, labeling, and chemical specialists.',
                          style: TextStyle(fontSize: 14, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (ctx, box) {
                      final cardWidth = box.maxWidth < 700
                          ? box.maxWidth
                          : (box.maxWidth - 20) / 2;
                      return Wrap(
                        spacing: 20,
                        runSpacing: 16,
                        children: [
                          _missionCard(
                            width: cardWidth,
                            title: 'Our Mission',
                            icon: Icons.flag_rounded,
                            color: const Color(0xFFB91C1C),
                            text:
                                'To deliver safe, damp-resistant, and affordable Rs. 1 and Rs. 2 safety matchboxes (Eagle, Pulli & Joker) to every household, retail store, and wholesale agent with 100% timely dispatch.',
                          ),
                          _missionCard(
                            width: cardWidth,
                            title: 'Our Vision',
                            icon: Icons.visibility_rounded,
                            color: const Color(0xFFD97706),
                            text:
                                'To modernize matchbox manufacturing and distribution through transparent digital ordering, real-time stock tracking, and sustainable employment for local workers.',
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
// 5. CONTACT US SECTION
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

  void _sendInquiry() {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter your Name and Phone Number')),
      );
      return;
    }
    widget.store.submitContactInquiry(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      message: _msgCtrl.text.trim(),
    );
    _nameCtrl.clear();
    _phoneCtrl.clear();
    _emailCtrl.clear();
    _msgCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          'Thank you! Your contact details have been submitted to Deeba Match House.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: LayoutBuilder(
                builder: (ctx, box) {
                  final leftWidth =
                      isMobile ? box.maxWidth : box.maxWidth * 0.42;
                  final rightWidth =
                      isMobile ? box.maxWidth : box.maxWidth * 0.54;

                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      Container(
                        width: leftWidth,
                        padding: EdgeInsets.all(isMobile ? 20 : 28),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7F1D1D),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Get in Touch',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Reach out to Deeba Match House for wholesale dealership, store supply, or custom bulk orders.',
                              style: TextStyle(
                                  color: Color(0xFFFDE68A), height: 1.4),
                            ),
                            SizedBox(height: 20),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.phone_in_talk_rounded,
                                  color: Colors.amber),
                              title: Text('Phone Number',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                              subtitle: Text('+91 98421 55667 / +91 94431 88990',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading:
                                  Icon(Icons.email_rounded, color: Colors.amber),
                              title: Text('Email Address',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                              subtitle: Text('orders@deebamatchhouse.com',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.location_on_rounded,
                                  color: Colors.amber),
                              title: Text('Factory & Head Office Address',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                              subtitle: Text(
                                  'Plot No. 14, Match Factory Road, Sivakasi - Kovilpatti Industrial Belt, Tamil Nadu - 626123',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: rightWidth,
                        padding: EdgeInsets.all(isMobile ? 20 : 28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Send Contact Inquiry',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _nameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Your Name *',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _phoneCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Mobile Number *',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _emailCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _msgCtrl,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Message / Inquiry Details',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFB91C1C),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: _sendInquiry,
                                icon: const Icon(Icons.send_rounded),
                                label: const Text('Submit Contact Details'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
