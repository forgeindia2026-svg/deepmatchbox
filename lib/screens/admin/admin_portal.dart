import 'package:flutter/material.dart';
import '../../models/deeba_models.dart';
import '../../state/deeba_store.dart';
import '../../services/printing_service.dart';
import 'staff_accounts_view.dart';

class AdminStaffPortal extends StatefulWidget {
  final DeebaStore store;
  final VoidCallback onSwitchRoleModal;

  const AdminStaffPortal({
    super.key,
    required this.store,
    required this.onSwitchRoleModal,
  });

  @override
  State<AdminStaffPortal> createState() => _AdminStaffPortalState();
}

class _AdminStaffPortalState extends State<AdminStaffPortal> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _activeModule = 'dashboard';

  List<_NavModuleItem> _getModulesForRole(UserRole role) {
    if (role == UserRole.staff) {
      return const [
        _NavModuleItem('profile', 'Staff Profile', Icons.badge_rounded),
        _NavModuleItem('daily_sheet', 'Daily Factory Sheet',
            Icons.assignment_turned_in_rounded),
        _NavModuleItem(
            'purchases', 'Purchase Entry', Icons.add_shopping_cart_rounded),
        _NavModuleItem('stock', 'Stock Balance', Icons.warehouse_rounded),
        _NavModuleItem('production', 'Production Entry',
            Icons.precision_manufacturing_rounded),
        _NavModuleItem(
            'workers', 'Attendance & Work', Icons.fact_check_rounded),
        _NavModuleItem('sales', 'Assigned Sales', Icons.point_of_sale_rounded),
      ];
    }

    return const [
      _NavModuleItem('dashboard', 'Dashboard', Icons.dashboard_rounded),
      _NavModuleItem('daily_sheet', 'Daily Factory Sheet',
          Icons.assignment_turned_in_rounded),
      _NavModuleItem('sales', 'Agent & Store Sales', Icons.storefront_rounded),
      _NavModuleItem(
          'stock', 'Stock & Finished Goods', Icons.warehouse_rounded),
      _NavModuleItem('production', 'Production',
          Icons.precision_manufacturing_rounded),
      _NavModuleItem('purchases', 'Purchases',
          Icons.shopping_cart_checkout_rounded),
      _NavModuleItem('orders', 'Online Orders', Icons.shopping_bag_rounded),
      _NavModuleItem(
          'materials', 'Materials & Chemicals', Icons.science_rounded),
      _NavModuleItem('products', 'Products & Brands',
          Icons.local_fire_department_rounded),
      _NavModuleItem('workers', 'Workers & Salary', Icons.groups_rounded),
      _NavModuleItem(
          'users', 'Staff & User Accounts', Icons.manage_accounts_rounded),
      _NavModuleItem('reports', 'Reports', Icons.analytics_rounded),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.store.currentRole;
    final modules = _getModulesForRole(role);
    if (!modules.any((m) => m.id == _activeModule)) {
      _activeModule = modules.first.id;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;
    final isCompactMobile = screenWidth < 850;
    final currentTitle =
        modules.firstWhere((m) => m.id == _activeModule).title;

    final activeIdx = modules.indexWhere((m) => m.id == _activeModule);
    final bottomNavIndex = activeIdx < 4 ? activeIdx : 4;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 2,
        titleSpacing: isCompactMobile ? 4 : 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: role == UserRole.admin
                    ? Colors.amber.shade400
                    : Colors.tealAccent.shade400,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                role == UserRole.admin ? 'ADMIN' : 'STAFF',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w900,
                  fontSize: 10.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isCompactMobile
                    ? currentTitle
                    : 'Deeba Match House • $currentTitle',
                style: TextStyle(
                  fontSize: isCompactMobile ? 15 : 17,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Cloud Status Indicator (Subtle & Professional, No Technical Jargon)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Tooltip(
              message: widget.store.isApiConnected
                  ? 'All factory records synced to Cloud'
                  : 'Saved locally on device (Auto-syncs when online)',
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () async {
                  if (!widget.store.isApiConnected) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Checking cloud synchronization...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    await widget.store.loadLiveFromBackend();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.store.isApiConnected
                        ? const Color(0xFF065F46)
                        : const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.store.isApiConnected
                          ? const Color(0xFF34D399).withAlpha(80)
                          : Colors.white24,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.store.isApiConnected
                            ? Icons.cloud_done_rounded
                            : Icons.cloud_queue_rounded,
                        size: 14,
                        color: widget.store.isApiConnected
                            ? const Color(0xFF6EE7B7)
                            : Colors.white70,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.store.isApiConnected ? 'Cloud Synced' : 'Saved Locally',
                        style: TextStyle(
                          color: widget.store.isApiConnected
                              ? const Color(0xFFD1FAE5)
                              : Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isCompactMobile) ...[
            PopupMenuButton<String>(
              tooltip: 'Account Menu',
              icon: const Icon(Icons.more_vert_rounded,
                  color: Colors.white, size: 22),
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (val) {
                if (val == 'password') {
                  showChangePasswordDialog(context, widget.store);
                } else if (val == 'logout') {
                  widget.onSwitchRoleModal();
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  enabled: false,
                  child: Text(
                    widget.store.loggedInUserName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const PopupMenuDivider(height: 1),
                const PopupMenuItem(
                  value: 'password',
                  child: Row(
                    children: [
                      Icon(Icons.lock_reset_rounded,
                          color: Color(0xFF38BDF8), size: 18),
                      SizedBox(width: 10),
                      Text('Change Password',
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded,
                          color: Colors.redAccent, size: 18),
                      SizedBox(width: 10),
                      Text('Logout',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
          ] else ...[
            PopupMenuButton<String>(
              tooltip: 'Account Menu',
              offset: const Offset(0, 42),
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (val) {
                if (val == 'password') {
                  showChangePasswordDialog(context, widget.store);
                } else if (val == 'switch_role') {
                  widget.onSwitchRoleModal();
                } else if (val == 'logout') {
                  widget.store.logout();
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFFD97706),
                      child: Text(
                        widget.store.loggedInUserName.isNotEmpty
                            ? widget.store.loggedInUserName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: Text(
                        widget.store.loggedInUserName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down_rounded,
                        color: Colors.white70, size: 20),
                  ],
                ),
              ),
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.store.loggedInUserName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        widget.store.currentRole == UserRole.admin
                            ? 'Factory Owner / Admin'
                            : 'Factory Supervisor',
                        style: TextStyle(
                          color: Colors.white.withAlpha(160),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                const PopupMenuItem(
                  value: 'password',
                  child: Row(
                    children: [
                      Icon(Icons.lock_reset_rounded,
                          color: Color(0xFF38BDF8), size: 18),
                      SizedBox(width: 10),
                      Text('Change Password',
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuDivider(height: 1),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded,
                          color: Colors.redAccent, size: 18),
                      SizedBox(width: 10),
                      Text('Logout',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout_rounded,
                    color: Colors.redAccent, size: 20),
                onPressed: () => widget.store.logout(),
              ),
            ),
          ],
        ],
      ),
      drawer: isDesktop
          ? null
          : Drawer(
              child: _buildSidebarNavigation(modules, role, closeOnTap: true),
            ),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 255,
              child: _buildSidebarNavigation(modules, role, closeOnTap: false),
            ),
          Expanded(
            child: _buildActiveModuleBody(),
          ),
        ],
      ),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              height: 62,
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFFFEE2E2),
              selectedIndex: bottomNavIndex,
              onDestinationSelected: (idx) {
                if (idx < 4 && idx < modules.length) {
                  setState(() => _activeModule = modules[idx].id);
                } else {
                  _scaffoldKey.currentState?.openDrawer();
                }
              },
              destinations: [
                for (int i = 0; i < 4 && i < modules.length; i++)
                  NavigationDestination(
                    icon: Icon(modules[i].icon, size: 20),
                    selectedIcon: Icon(
                      modules[i].icon,
                      color: const Color(0xFFB91C1C),
                      size: 21,
                    ),
                    label: modules[i].title.split(' ').first,
                  ),
                const NavigationDestination(
                  icon: Icon(Icons.menu_open_rounded, size: 20),
                  label: 'More',
                ),
              ],
            ),
    );
  }

  Widget _buildSidebarNavigation(
    List<_NavModuleItem> modules,
    UserRole role, {
    required bool closeOnTap,
  }) {
    return Container(
      color: const Color(0xFF0F172A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: Color(0xFF7F1D1D),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DEEBA MATCH HOUSE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.store.loggedInUserName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              itemCount: modules.length,
              itemBuilder: (ctx, i) {
                final item = modules[i];
                final selected = _activeModule == item.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    selected: selected,
                    selectedTileColor: const Color(0xFFB91C1C),
                    leading: Icon(
                      item.icon,
                      color: selected ? Colors.white : Colors.white70,
                      size: 20,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13.5,
                      ),
                    ),
                    trailing: item.id == 'orders' &&
                            widget.store.newOnlineOrdersCount > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${widget.store.newOnlineOrdersCount}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          )
                        : null,
                    onTap: () {
                      setState(() => _activeModule = item.id);
                      if (closeOnTap) Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.amber.shade300,
                side: BorderSide(color: Colors.amber.shade300),
              ),
              onPressed: () => widget.store.switchRole(UserRole.customer),
              icon: const Icon(Icons.language_rounded, size: 18),
              label: const Text('Back to Customer View'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveModuleBody() {
    switch (_activeModule) {
      case 'dashboard':
        return _AdminDashboardView(
          store: widget.store,
          onNavigate: (mod) => setState(() => _activeModule = mod),
        );
      case 'profile':
        return _StaffProfileView(
          store: widget.store,
          onNavigate: (mod) => setState(() => _activeModule = mod),
        );
      case 'daily_sheet':
        return _DailyFactorySheetView(store: widget.store);
      case 'orders':
        return _OnlineOrdersAdminView(
          store: widget.store,
          onNavigate: (mod) => setState(() => _activeModule = mod),
        );
      case 'products':
        return _ProductsAdminView(store: widget.store);
      case 'materials':
        return _MaterialsAdminView(store: widget.store);
      case 'purchases':
        return _PurchasesManagementView(store: widget.store);
      case 'stock':
        return _StockManagementView(store: widget.store);
      case 'production':
        return _ProductionManagementView(store: widget.store);
      case 'sales':
        return _SalesManagementView(store: widget.store);
      case 'workers':
        return _WorkersAttendanceSalaryView(store: widget.store);
      case 'users':
        return StaffAccountsManagerView(store: widget.store);
      case 'reports':
        return _ReportsAnalyticsView(store: widget.store);
      default:
        return _AdminDashboardView(
          store: widget.store,
          onNavigate: (mod) => setState(() => _activeModule = mod),
        );
    }
  }
}

class _NavModuleItem {
  final String id;
  final String title;
  final IconData icon;
  const _NavModuleItem(this.id, this.title, this.icon);
}

// ============================================================================
// MODULE 1: ADMIN DASHBOARD
// ============================================================================
void showDailyPaperSlipDialog(BuildContext context, DailyProductionSheet sheet) {
  Widget slipLineItem(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget slipHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
      ),
    );
  }

  Widget slipCell(String text, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: bold ? FontWeight.w800 : FontWeight.normal,
          fontSize: 11,
          color: color,
        ),
      ),
    );
  }

  final openingFrames = (sheet.balanceFrames + sheet.adappuFrames - sheet.dippingFrames);
  final totalDipped = sheet.balanceFrames + sheet.adappuFrames;
  final bundlesFromBoxes = sheet.totalBoxes > 0 ? (sheet.totalBoxes / 600.0).toStringAsFixed(0) : '0';

  final totalOpening = sheet.brandRows.fold(0.0, (s, r) => s + r.openingStock);
  final totalProduced = sheet.brandRows.fold(0.0, (s, r) => s + r.producedBundles);
  final totalAvailable = sheet.brandRows.fold(0.0, (s, r) => s + r.totalAvailable);
  final totalSales = sheet.brandRows.fold(0.0, (s, r) => s + r.salesBundles);
  final totalClosing = sheet.brandRows.fold(0.0, (s, r) => s + r.closingStock);

  final eaaBundles = sheet.brandRows.where((r) => r.brand.toLowerCase() == 'eagle').fold(0.0, (s, r) => s + r.producedBundles);
  final plBundles = sheet.brandRows.where((r) => r.brand.toLowerCase() == 'pulli').fold(0.0, (s, r) => s + r.producedBundles);
  final jokBundles = sheet.brandRows.where((r) => r.brand.toLowerCase() == 'joker').fold(0.0, (s, r) => s + r.producedBundles);

  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF065F46), width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DEEBA MATCH WORKS • Sivakasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF065F46),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Daily Production, Stock & Sales Slip • Recorded by ${sheet.recordedBy}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Date / Thethi : ${sheet.date}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'Day / Naal : ${sheet.dayOfWeek}',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF065F46), thickness: 1.5, height: 18),

                  // Top Two-Column Frame Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            slipLineItem('Adappu Frames Fed :', '${sheet.adappuFrames}'),
                            slipLineItem('Total Boxes (Petti) :', '${sheet.totalBoxes}'),
                            slipLineItem('Average Boxes / Frame :', sheet.avgBoxesPerFrame.toStringAsFixed(1)),
                            slipLineItem('Gross Count (144) :', sheet.grossCount.toStringAsFixed(1)),
                            slipLineItem('Bundles (600) :', bundlesFromBoxes),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            slipLineItem('Opening Frames (Iruppu) :', (openingFrames > 0 ? openingFrames : 0).toString()),
                            slipLineItem('Dipping Frames :', '${sheet.dippingFrames}'),
                            slipLineItem('Total Dipped Frames :', (totalDipped > 0 ? totalDipped : 0).toString(), bold: true),
                            slipLineItem('Adappu Frames Fed :', '${sheet.adappuFrames}'),
                            slipLineItem('= Closing Balance (Meedhi) :', '${sheet.balanceFrames}', bold: true, color: const Color(0xFF065F46)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF065F46), thickness: 1, height: 18),

                  // Middle Madippu Bundle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Madippu Bundles (Folding) : EAA: ${eaaBundles.toInt()} / PL: ${plBundles.toInt()} / JOK: ${jokBundles.toInt()}  TOTAL: ${sheet.totalBundlesProduced}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                      ),
                    ],
                  ),
                  if (sheet.companyMaterialInward.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '1. Company Line : ${sheet.companyMaterialInward}',
                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Table
                  Table(
                    border: TableBorder.all(color: const Color(0xFF065F46), width: 1),
                    columnWidths: const {
                      0: FlexColumnWidth(1.8),
                      1: FlexColumnWidth(1.3),
                      2: FlexColumnWidth(1.3),
                      3: FlexColumnWidth(1.3),
                      4: FlexColumnWidth(1.3),
                      5: FlexColumnWidth(1.5),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFECFDF5)),
                        children: [
                          slipHeader('Brand Name'),
                          slipHeader('Opening (Iruppu)'),
                          slipHeader('Produced (Madippu)'),
                          slipHeader('Total Available'),
                          slipHeader('Sales Bundles'),
                          slipHeader('Closing Stock'),
                        ],
                      ),
                      for (final r in sheet.brandRows)
                        TableRow(
                          children: [
                            slipCell('${r.brand} ${r.priceCategory}', bold: true),
                            slipCell(r.openingStock.toStringAsFixed(0)),
                            slipCell(r.producedBundles.toStringAsFixed(0)),
                            slipCell(r.totalAvailable.toStringAsFixed(0)),
                            slipCell(r.salesBundles.toStringAsFixed(0)),
                            slipCell(r.closingStock.toStringAsFixed(0), bold: true),
                          ],
                        ),
                      TableRow(
                        decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                        children: [
                          slipCell('TOTAL BUNDLE', bold: true),
                          slipCell(totalOpening.toStringAsFixed(0), bold: true),
                          slipCell(totalProduced.toStringAsFixed(0), bold: true),
                          slipCell(totalAvailable.toStringAsFixed(0), bold: true),
                          slipCell(totalSales.toStringAsFixed(0), bold: true),
                          slipCell(totalClosing.toStringAsFixed(0), bold: true),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Bottom Inward, Outward & Closing Card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '•   : ${sheet.companyMaterialInward.isNotEmpty ? sheet.companyMaterialInward : "Nil"}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '•   : ${sheet.companyMaterialOutward.isNotEmpty ? sheet.companyMaterialOutward : "Nil"}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Closing Card Note : ${sheet.closingCardNote.isNotEmpty ? sheet.closingCardNote : "Verified"}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const Text(
                        ' : Eagle, Pulli, Joker',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF065F46),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);

                          PrintingService.instance.printDailyFactorySheet(sheet);

                        },
                        icon: const Icon(Icons.print_rounded, size: 16),
                        label: const Text('Print 1-Page Slip'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _AdminDashboardView extends StatelessWidget {
  final DeebaStore store;
  final void Function(String module) onNavigate;

  const _AdminDashboardView({
    required this.store,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final lowStocks = store.lowStockMaterials;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 640;
        final pad = isMobile ? 14.0 : 24.0;
        final availWidth = constraints.maxWidth - (pad * 2);
        final int cols = availWidth < 520
            ? 2
            : availWidth < 900
                ? 3
                : 4;
        final double kpiWidth = (availWidth - ((cols - 1) * 12)) / cols;

        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF7F1D1D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deeba Match House • Executive Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 17 : 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Live overview of Eagle, Pulli & Joker production, 6 material groups, sales & workforce.',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12.5),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.amber.shade400,
                            foregroundColor: const Color(0xFF0F172A),
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () => onNavigate('production'),
                          icon: const Icon(Icons.add_box_rounded, size: 16),
                          label: const Text(
                            '+ Production',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white24,
                            foregroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () => onNavigate('sales'),
                          icon:
                              const Icon(Icons.point_of_sale_rounded, size: 16),
                          label: const Text('+ Sale'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _KpiCard(
                    width: kpiWidth,
                    title: 'Online Orders',
                    value: '${store.totalOnlineOrdersCount}',
                    subtitle: '${store.newOnlineOrdersCount} New Pending',
                    icon: Icons.shopping_bag_rounded,
                    color: const Color(0xFF2563EB),
                    onTap: () => onNavigate('orders'),
                  ),
                  _KpiCard(
                    width: kpiWidth,
                    title: 'Total Purchases',
                    value: 'Rs. ${store.totalPurchaseAmount.toStringAsFixed(0)}',
                    subtitle: '${store.purchases.length} Invoices',
                    icon: Icons.shopping_cart_rounded,
                    color: const Color(0xFF7C3AED),
                    onTap: () => onNavigate('purchases'),
                  ),
                  _KpiCard(
                    width: kpiWidth,
                    title: 'Raw Material Stock',
                    value:
                        'Rs. ${store.totalRawMaterialStockValue.toStringAsFixed(0)}',
                    subtitle:
                        '${store.totalRawMaterialItemsCount.toInt()} Active Items',
                    icon: Icons.science_rounded,
                    color: const Color(0xFF0D9488),
                    onTap: () => onNavigate('materials'),
                  ),
                  _KpiCard(
                    width: kpiWidth,
                    title: 'Finished Stock',
                    value:
                        '${store.totalFinishedBundlesStock.toStringAsFixed(0)} Bdl',
                    subtitle: 'Eagle, Pulli & Joker',
                    icon: Icons.inventory_2_rounded,
                    color: const Color(0xFF059669),
                    onTap: () => onNavigate('stock'),
                  ),
                  _KpiCard(
                    width: kpiWidth,
                    title: 'Total Production',
                    value:
                        '${store.totalProductionBundles.toStringAsFixed(0)} Bdl',
                    subtitle: '${store.productionRecords.length} Batches',
                    icon: Icons.precision_manufacturing_rounded,
                    color: const Color(0xFFD97706),
                    onTap: () => onNavigate('production'),
                  ),
                  _KpiCard(
                    width: kpiWidth,
                    title: 'Total Sales',
                    value: 'Rs. ${store.totalSalesAmount.toStringAsFixed(0)}',
                    subtitle: '${store.sales.length} Bills',
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFF16A34A),
                    onTap: () => onNavigate('sales'),
                  ),
                  _KpiCard(
                    width: kpiWidth,
                    title: 'Agent Sales',
                    value: 'Rs. ${store.agentSalesAmount.toStringAsFixed(0)}',
                    subtitle: 'Wholesale Agencies',
                    icon: Icons.local_shipping_rounded,
                    color: const Color(0xFF0284C7),
                    onTap: () => onNavigate('sales'),
                  ),
                  _KpiCard(
                    width: kpiWidth,
                    title: 'Store Sales',
                    value: 'Rs. ${store.storeSalesAmount.toStringAsFixed(0)}',
                    subtitle: 'Retail Stores',
                    icon: Icons.storefront_rounded,
                    color: const Color(0xFF4F46E5),
                    onTap: () => onNavigate('sales'),
                  ),
                  _KpiCard(
                    width: kpiWidth,
                    title: 'Pending Payment',
                    value: 'Rs. ${store.totalPendingPayments.toStringAsFixed(0)}',
                    subtitle: 'Receivable Balance',
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFFDC2626),
                    onTap: () => onNavigate('sales'),
                  ),
                  _KpiCard(
                    width: kpiWidth,
                    title: 'Total Workers',
                    value: '${store.totalActiveWorkers}',
                    subtitle: 'Monthly & Daily',
                    icon: Icons.groups_rounded,
                    color: const Color(0xFF475569),
                    onTap: () => onNavigate('workers'),
                  ),
                  _KpiCard(
                    width: kpiWidth,
                    title: "Today's Attendance",
                    value:
                        '${store.todayPresentWorkersCount} / ${store.totalActiveWorkers}',
                    subtitle: 'Present Today',
                    icon: Icons.fact_check_rounded,
                    color: const Color(0xFF0891B2),
                    onTap: () => onNavigate('workers'),
                  ),
                  _KpiCard(
                    width: kpiWidth,
                    title: 'Low Stock Alert',
                    value: '${lowStocks.length} Items',
                    subtitle: lowStocks.isEmpty
                        ? 'Stock Healthy'
                        : 'Purchase Needed',
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFB91C1C),
                    onTap: () => onNavigate('materials'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Live Today's Factory Floor Sheet Status Card
              _buildTodayDailySheetCard(context, store, onNavigate),

              LayoutBuilder(
                builder: (ctx, box) {
                  final panelWidth = box.maxWidth < 760
                      ? box.maxWidth
                      : (box.maxWidth - 16) / 2;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      Container(
                        width: panelWidth,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning_rounded,
                                          color: Colors.red, size: 20),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Low Stock Materials Alert',
                                          style: TextStyle(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => onNavigate('purchases'),
                                  child: const Text('Purchase'),
                                ),
                              ],
                            ),
                            const Divider(),
                            if (lowStocks.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(12),
                                child:
                                    Text('All materials have sufficient stock.'),
                              )
                            else
                              for (final m in lowStocks)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              m.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13.5,
                                              ),
                                            ),
                                            Text(
                                              '${m.category.label} • ${m.supplier}',
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${m.currentBalance.toInt()} ${m.unit}',
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ],
                        ),
                      ),
                      Container(
                        width: panelWidth,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Finished Matchbox Stock (Eagle • Pulli • Joker)',
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => onNavigate('stock'),
                                  child: const Text('Ledger'),
                                ),
                              ],
                            ),
                            const Divider(),
                            for (final fp in store.finishedStocks)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${fp.productBrand} (${fp.priceCategory})',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '+${fp.quantityProduced.toInt()} / -${fp.quantitySold.toInt()}  ',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${fp.currentBalance.toInt()} Bdl',
                                        style: TextStyle(
                                          color: Colors.green.shade800,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayDailySheetCard(
      BuildContext context, DeebaStore store, void Function(String) onNavigate) {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    DailyProductionSheet? sheet = store.todayDailySheet;
    bool isToday = sheet != null && sheet.date == todayStr;

    if (sheet == null) {
      final found =
          store.dailySheets.where((s) => s.date == todayStr).firstOrNull;
      if (found != null) {
        sheet = found;
        isToday = true;
      } else if (store.dailySheets.isNotEmpty) {
        sheet = store.dailySheets.first;
        isToday = false;
      }
    }

    final hasSheet = sheet != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasSheet
              ? (isToday
                  ? const Color(0xFF065F46).withValues(alpha: 0.35)
                  : Colors.blue.shade200)
              : Colors.amber.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (ctx, constraints) {
              final isCardMobile = constraints.maxWidth < 620;

              final headerIconAndText = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: hasSheet
                          ? (isToday
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFEFF6FF))
                          : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.assignment_turned_in_rounded,
                      color: hasSheet
                          ? (isToday
                              ? const Color(0xFF065F46)
                              : const Color(0xFF1D4ED8))
                          : Colors.amber.shade800,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              isToday
                                  ? "Today's Daily Factory Floor Sheet"
                                  : (hasSheet
                                      ? "Latest Daily Factory Floor Sheet (${sheet!.date})"
                                      : "Today's Daily Factory Floor Sheet"),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: hasSheet
                                    ? (isToday
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFEFF6FF))
                                    : Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                hasSheet
                                    ? (isToday ? 'Live Saved' : 'Past Entry')
                                    : 'Pending Floor Entry',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: hasSheet
                                      ? (isToday
                                          ? const Color(0xFF065F46)
                                          : const Color(0xFF1D4ED8))
                                      : Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hasSheet
                              ? 'Recorded by ${sheet!.recordedBy} • Date: ${sheet.date} (${sheet.dayOfWeek})'
                              : 'Floor Staff has not entered today\'s sheet ($todayStr) yet.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final sheetActions = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (hasSheet)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF065F46),
                        side: const BorderSide(color: Color(0xFF065F46)),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () => showDailyPaperSlipDialog(context, sheet!),
                      icon: const Icon(Icons.receipt_long_rounded, size: 16),
                      label: const Text('Paper Slip'),
                    ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF065F46),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => onNavigate('daily_sheet'),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label:
                        Text(hasSheet ? 'Open Full Sheet' : 'Enter Sheet Now'),
                  ),
                ],
              );

              if (isCardMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerIconAndText,
                    const SizedBox(height: 14),
                    sheetActions,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: headerIconAndText),
                  const SizedBox(width: 10),
                  sheetActions,
                ],
              );
            },
          ),
          if (hasSheet) ...[
            const Divider(height: 22),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _kpiBadge('Adappu Frames Fed', '${sheet.adappuFrames} Frames',
                    const Color(0xFF0284C7)),
                _kpiBadge('Dipping Frames', '+${sheet.dippingFrames} Frames',
                    const Color(0xFF0D9488)),
                _kpiBadge('Closing Frames', '${sheet.balanceFrames} Frames',
                    const Color(0xFF16A34A)),
                _kpiBadge(
                    'Boxes Produced',
                    '${sheet.totalBoxes} (${sheet.grossCount.toStringAsFixed(1)} Gross)',
                    const Color(0xFF7C3AED)),
                _kpiBadge('Produced Bundles',
                    '${sheet.totalBundlesProduced} Bdl', const Color(0xFFD97706),
                    bold: true),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final r in sheet.brandRows)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      '${r.brand} (${r.priceCategory}): +${r.producedBundles.toInt()} Produced / -${r.salesBundles.toInt()} Sold -> ${r.closingStock.toInt()} Bdl Closing',
                      style: const TextStyle(
                          fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _kpiBadge(String label, String value, Color color,
      {bool bold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _KpiCard({
    required this.width,
    required this.title,
    required this.value,
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
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
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// STAFF PROFILE & ASSIGNED WORKSPACE
// ============================================================================
class _StaffProfileView extends StatelessWidget {
  final DeebaStore store;
  final void Function(String module) onNavigate;

  const _StaffProfileView({
    required this.store,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 640;
        final pad = isMobile ? 14.0 : 24.0;
        final availWidth = constraints.maxWidth - (pad * 2);
        final int cols = availWidth < 520 ? 2 : 4;
        final double cardWidth = (availWidth - ((cols - 1) * 12)) / cols;

        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 18 : 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF1E293B),
                      Color(0xFF0F766E)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: isMobile ? 54 : 64,
                          height: isMobile ? 54 : 64,
                          decoration: BoxDecoration(
                            color: Colors.tealAccent.shade400,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: isMobile ? 30 : 36,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'STAFF ID: STF-204 • DAY SHIFT (8 AM - 6 PM)',
                                  style: TextStyle(
                                    color: Colors.tealAccent,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                store.loggedInUserName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 17 : 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Production & Floor Supervisor • Deeba Match House',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 12),
                    const Text(
                      'QUICK ACCESS TO ASSIGNED MODULES:',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _QuickActionChip(
                          label: 'Daily Factory Sheet',
                          icon: Icons.assignment_turned_in_rounded,
                          onTap: () => onNavigate('daily_sheet'),
                        ),
                        _QuickActionChip(
                          label: 'Purchase Entry',
                          icon: Icons.add_shopping_cart_rounded,
                          onTap: () => onNavigate('purchases'),
                        ),
                        _QuickActionChip(
                          label: 'Stock Updates',
                          icon: Icons.warehouse_rounded,
                          onTap: () => onNavigate('stock'),
                        ),
                        _QuickActionChip(
                          label: 'Production Entry',
                          icon: Icons.precision_manufacturing_rounded,
                          onTap: () => onNavigate('production'),
                        ),
                        _QuickActionChip(
                          label: 'Worker Attendance & Work',
                          icon: Icons.fact_check_rounded,
                          onTap: () => onNavigate('workers'),
                        ),
                        _QuickActionChip(
                          label: 'Assigned Sales',
                          icon: Icons.point_of_sale_rounded,
                          onTap: () => onNavigate('sales'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Assigned Daily Operations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _KpiCard(
                    width: cardWidth,
                    title: 'Daily Factory Sheet',
                    value: store.todayDailySheet != null
                        ? '${store.todayDailySheet!.totalBundlesProduced} Bdl'
                        : 'Fill Today',
                    subtitle: 'Adappu, Dipping & Stock',
                    icon: Icons.assignment_turned_in_rounded,
                    color: const Color(0xFF4338CA),
                    onTap: () => onNavigate('daily_sheet'),
                  ),
                  _KpiCard(
                    width: cardWidth,
                    title: 'Worker Attendance',
                    value:
                        '${store.todayPresentWorkersCount} / ${store.totalActiveWorkers} Marked',
                    subtitle: 'Present / Half-Day / Leave',
                    icon: Icons.fact_check_rounded,
                    color: const Color(0xFF0891B2),
                    onTap: () => onNavigate('workers'),
                  ),
                  _KpiCard(
                    width: cardWidth,
                    title: 'Production Batch',
                    value: '${store.productionRecords.length} Batches',
                    subtitle: 'Eagle, Pulli & Joker output',
                    icon: Icons.precision_manufacturing_rounded,
                    color: const Color(0xFFD97706),
                    onTap: () => onNavigate('production'),
                  ),
                  _KpiCard(
                    width: cardWidth,
                    title: 'Material Purchase',
                    value: '${store.purchases.length} Entries',
                    subtitle: 'Inward raw material bill',
                    icon: Icons.add_shopping_cart_rounded,
                    color: const Color(0xFF7C3AED),
                    onTap: () => onNavigate('purchases'),
                  ),
                  _KpiCard(
                    width: cardWidth,
                    title: 'Stock Balance',
                    value: '${store.totalFinishedBundlesStock.toInt()} Bdl',
                    subtitle: '6 Raw Groups & Finished',
                    icon: Icons.warehouse_rounded,
                    color: const Color(0xFF059669),
                    onTap: () => onNavigate('stock'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.tealAccent.shade200, size: 15),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MODULE 2: ONLINE ORDER MANAGEMENT (Section 5)
// ============================================================================
class _OnlineOrdersAdminView extends StatefulWidget {
  final DeebaStore store;
  final void Function(String module)? onNavigate;
  const _OnlineOrdersAdminView({required this.store, this.onNavigate});

  @override
  State<_OnlineOrdersAdminView> createState() => _OnlineOrdersAdminViewState();
}

class _OnlineOrdersAdminViewState extends State<_OnlineOrdersAdminView> {
  OrderStatus? _statusFilter;

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return Colors.blue.shade700;
      case OrderStatus.confirmed:
        return Colors.purple.shade700;
      case OrderStatus.processing:
        return Colors.orange.shade800;
      case OrderStatus.completed:
        return Colors.green.shade700;
      case OrderStatus.cancelled:
        return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = widget.store.onlineOrders.where((o) {
      if (_statusFilter == null) return true;
      return o.status == _statusFilter;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 640;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer Online Order Management',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Order Flow: Customer Places Order → Admin Reviews → Updates Status → Contacts Customer',
                style: TextStyle(color: Colors.black54, fontSize: 12.5),
              ),
              const SizedBox(height: 10),

              // Quick Banner connecting to Offline Agent / Kadai Sales
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.storefront_rounded,
                        color: Color(0xFF1D4ED8), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Looking for Offline Agent & Kadai Orders?',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          Text(
                            'Offline wholesale agent bills, retail store (kadai) orders & staff entries are in Agent & Store Sales.',
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              color: const Color(0xFF1E40AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.onNavigate != null) ...[
                      const SizedBox(width: 8),
                      FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: const Color(0xFFDBEAFE),
                        ),
                        onPressed: () => widget.onNavigate!('sales'),
                        child: const Text(
                          'View Sales',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _statusFilter == null,
                    onSelected: (_) => setState(() => _statusFilter = null),
                  ),
                  for (final st in OrderStatus.values)
                    FilterChip(
                      label: Text(st.label),
                      selected: _statusFilter == st,
                      onSelected: (_) => setState(() => _statusFilter = st),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (orders.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 36,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'No Online Orders Yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Orders placed by customers on the public store will show here live.\nAll order updates sync in real time with cloud records.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              for (final order in orders)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(isMobile ? 14 : 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(order.status)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${order.id} • ${order.status.label.toUpperCase()}',
                                    style: TextStyle(
                                      color: _statusColor(order.status),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _formatDate(order.orderDate),
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${order.customerName}  •   ${order.mobileNumber}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ' ${order.address}',
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 13),
                            ),
                            if (order.additionalNotes.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Note: "${order.additionalNotes}"',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: isMobile
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${order.productBrand} (${order.productCategory}) • ${order.quantityBundles} Bundles',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFB91C1C),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Status: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              DropdownButton<OrderStatus>(
                                value: order.status,
                                items: OrderStatus.values
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(
                                          s.label,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _statusColor(s),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (newSt) {
                                  if (newSt != null) {
                                    widget.store
                                        .updateOrderStatus(order.id, newSt);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// MODULE 3: DYNAMIC PRODUCTS & BRANDS MANAGEMENT
// ============================================================================
class _ProductsAdminView extends StatelessWidget {
  final DeebaStore store;
  const _ProductsAdminView({required this.store});

  void _openAddOrEditProductDialog(BuildContext context,
      {ProductItem? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final typeCtrl = TextEditingController(
        text: existing?.productType ?? 'Safety Matches');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final rs1Ctrl = TextEditingController(
      text: (existing?.bundlePriceByCategory['Rs. 1'] ?? 450).toStringAsFixed(0),
    );
    final rs2Ctrl = TextEditingController(
      text: (existing?.bundlePriceByCategory['Rs. 2'] ?? 820).toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null
            ? 'Add New Matchbox Product Brand'
            : 'Edit ${existing.name} Product & Prices'),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Brand Name (e.g. Eagle, Pulli, Joker)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: typeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Product Type Subtitle',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: rs1Ctrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Rs. 1 Bundle Price',
                          prefixText: 'Rs. ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: rs2Ctrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Rs. 2 Bundle Price',
                          prefixText: 'Rs. ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final p1 = double.tryParse(rs1Ctrl.text.trim()) ?? 450;
              final p2 = double.tryParse(rs2Ctrl.text.trim()) ?? 820;

              store.addOrUpdateProduct(
                ProductItem(
                  id: existing?.id ??
                      'PROD-${nameCtrl.text.trim().toUpperCase()}',
                  name: nameCtrl.text.trim(),
                  productType: typeCtrl.text.trim(),
                  priceCategories: List.from(store.priceCategories),
                  bundlePriceByCategory: {
                    'Rs. 1': p1,
                    'Rs. 2': p2,
                  },
                  description: descCtrl.text.trim(),
                  colorHex: existing?.colorHex ?? 0xFFB91C1C,
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save Product'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 640;
        final pad = isMobile ? 14.0 : 24.0;
        final availWidth = constraints.maxWidth - (pad * 2);
        final cardWidth = availWidth < 720 ? availWidth : (availWidth - 36) / 3;

        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dynamic Product & Brand Configuration',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Manage Eagle, Pulli, Joker or add new brands & edit wholesale bundle prices.',
                        style: TextStyle(color: Colors.black54, fontSize: 12.5),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFB91C1C),
                    ),
                    onPressed: () => _openAddOrEditProductDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Product Brand'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 18,
                runSpacing: 16,
                children: store.products
                    .map(
                      (p) => Container(
                        width: cardWidth,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _openAddOrEditProductDialog(
                                    context,
                                    existing: p,
                                  ),
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Edit Product & Prices',
                                ),
                              ],
                            ),
                            Text(
                              p.productType,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p.description,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const Divider(height: 22),
                            for (final cat in p.priceCategories)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('$cat Wholesale Bundle:'),
                                    Text(
                                      'Rs. ${(p.bundlePriceByCategory[cat] ?? 450).toStringAsFixed(0)}',
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
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// MODULE 4: DYNAMIC MATERIAL & CHEMICAL MANAGEMENT (6 Separate Sections)
// ============================================================================
class _MaterialsAdminView extends StatefulWidget {
  final DeebaStore store;
  const _MaterialsAdminView({required this.store});

  @override
  State<_MaterialsAdminView> createState() => _MaterialsAdminViewState();
}

class _MaterialsAdminViewState extends State<_MaterialsAdminView> {
  MaterialCategory? _selectedCategory;
  bool _showDisabled = false;

  void _openAddEditMaterialDialog({MaterialItem? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    MaterialCategory selectedCat =
        existing?.category ?? MaterialCategory.chemical;
    String brandType = existing?.brandType ?? 'Common';
    String priceCat = existing?.priceCategory ?? 'Standard';
    final unitCtrl = TextEditingController(text: existing?.unit ?? 'Kg');
    final priceCtrl = TextEditingController(
      text: (existing?.purchasePrice ?? 100).toStringAsFixed(0),
    );
    final openStockCtrl = TextEditingController(
      text: (existing?.openingStock ?? 50).toStringAsFixed(0),
    );
    final supplierCtrl = TextEditingController(
      text: existing?.supplier ?? 'Sivakasi Suppliers',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: Text(existing == null
              ? 'Add Dynamic Raw Material / Chemical'
              : 'Edit Material (${existing.name})'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Material Name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<MaterialCategory>(
                    initialValue: selectedCat,
                    decoration: const InputDecoration(
                      labelText: 'Material Category',
                      border: OutlineInputBorder(),
                    ),
                    items: MaterialCategory.values
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.label),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setModalState(() => selectedCat = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: [
                            'Common',
                            'All Brands',
                            ...widget.store.brandTypes
                          ].contains(brandType)
                              ? brandType
                              : 'Common',
                          decoration: const InputDecoration(
                            labelText: 'Brand',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            'Common',
                            'All Brands',
                            ...widget.store.brandTypes
                          ]
                              .map(
                                (b) => DropdownMenuItem(
                                  value: b,
                                  child: Text(b),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setModalState(() => brandType = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: [
                            'Standard',
                            'Chemical',
                            'All (Rs. 1 / Rs. 2)',
                            ...widget.store.priceCategories
                          ].contains(priceCat)
                              ? priceCat
                              : 'Standard',
                          decoration: const InputDecoration(
                            labelText: 'Price Category',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            'Standard',
                            'Chemical',
                            'All (Rs. 1 / Rs. 2)',
                            ...widget.store.priceCategories
                          ]
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setModalState(() => priceCat = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: unitCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Unit (Kg, Bundles, Reams)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Purchase Price',
                            prefixText: 'Rs. ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: openStockCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Opening Stock',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: supplierCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Supplier',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                widget.store.addOrUpdateMaterial(
                  MaterialItem(
                    id: existing?.id ??
                        'MAT-${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim(),
                    category: selectedCat,
                    brandType: brandType,
                    priceCategory: priceCat,
                    unit: unitCtrl.text.trim(),
                    purchasePrice:
                        double.tryParse(priceCtrl.text.trim()) ?? 100,
                    openingStock:
                        double.tryParse(openStockCtrl.text.trim()) ?? 0,
                    totalPurchased: existing?.totalPurchased ?? 0,
                    usedQuantity: existing?.usedQuantity ?? 0,
                    supplier: supplierCtrl.text.trim(),
                    lastPurchaseDate:
                        existing?.lastPurchaseDate ?? DateTime.now(),
                    isActive: existing?.isActive ?? true,
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Save Material'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesToDisplay = _selectedCategory == null
        ? MaterialCategory.values
        : [_selectedCategory!];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 680;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Material & Chemical Management (6 Separate Sections)',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '1. Outer Bundle • 2. Inner Bundle • 3. Packing Cover • 4. Packing Bundle Sheet • 5. Label • 6. Chemical (8 Types)',
                        style: TextStyle(color: Colors.black54, fontSize: 12.5),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Show Disabled'),
                        selected: _showDisabled,
                        onSelected: (v) => setState(() => _showDisabled = v),
                      ),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFB91C1C),
                        ),
                        onPressed: () => _openAddEditMaterialDialog(),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Material'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All 6 Sections (Thani Thaniya)'),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                  for (final cat in MaterialCategory.values)
                    ChoiceChip(
                      label: Text(cat.label),
                      selected: _selectedCategory == cat,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              for (final cat in categoriesToDisplay) ...[
                _buildCategorySectionCard(cat, isMobile: isMobile),
                const SizedBox(height: 20),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorySectionCard(MaterialCategory cat,
      {required bool isMobile}) {
    final catMaterials = widget.store.materials.where((m) {
      if (!_showDisabled && !m.isActive) return false;
      return m.category == cat;
    }).toList();

    final sectionColor = _categoryHeaderColor(cat);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sectionColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: sectionColor.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_categoryIcon(cat), color: sectionColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      cat.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: sectionColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${catMaterials.length} Items',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: sectionColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isMobile)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: catMaterials.map((m) {
                  final totalAvailable = m.openingStock + m.totalPurchased;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                m.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  decoration: m.isActive
                                      ? null
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: m.isLowStock
                                    ? Colors.red.shade50
                                    : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Stock: ${m.currentBalance.toInt()} ${m.unit}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: m.isLowStock
                                      ? Colors.red.shade800
                                      : Colors.green.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Brand: ${m.brandType} (${m.priceCategory})  •  Price: Rs. ${m.purchasePrice.toStringAsFixed(0)}/${m.unit}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Total In: ${totalAvailable.toInt()} | Used: ${m.usedQuantity.toInt()} • ${m.supplier}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () =>
                                  _openAddEditMaterialDialog(existing: m),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          else
            LayoutBuilder(
              builder: (ctx, box) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: box.maxWidth),
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor:
                        WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columns: const [
                      DataColumn(label: Text('Material Name')),
                      DataColumn(label: Text('Brand')),
                      DataColumn(label: Text('Category')),
                      DataColumn(label: Text('Unit Price')),
                      DataColumn(label: Text('Available')),
                      DataColumn(label: Text('Used')),
                      DataColumn(label: Text('Remaining Stock')),
                      DataColumn(label: Text('Supplier')),
                      DataColumn(label: Text('Edit')),
                    ],
                    rows: catMaterials.map((m) {
                      final totalAvailable = m.openingStock + m.totalPurchased;
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (m.isLowStock)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 6),
                                    child: Icon(
                                      Icons.warning_rounded,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                  ),
                                Text(
                                  m.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    decoration: m.isActive
                                        ? null
                                        : TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(m.brandType)),
                          DataCell(Text(m.priceCategory)),
                          DataCell(
                            Text(
                              'Rs. ${m.purchasePrice.toStringAsFixed(0)} / ${m.unit}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          DataCell(Text('${totalAvailable.toInt()} ${m.unit}')),
                          DataCell(Text('${m.usedQuantity.toInt()} ${m.unit}')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: m.isLowStock
                                    ? Colors.red.shade50
                                    : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${m.currentBalance.toInt()} ${m.unit}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: m.isLowStock
                                      ? Colors.red.shade800
                                      : Colors.green.shade800,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(m.supplier)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon:
                                      const Icon(Icons.edit_outlined, size: 18),
                                  onPressed: () =>
                                      _openAddEditMaterialDialog(existing: m),
                                ),
                                IconButton(
                                  icon: Icon(
                                    m.isActive
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      widget.store.toggleMaterialActive(m.id),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// MODULE 5: PURCHASE MANAGEMENT (Mobile Summary Cards + Full-Width Web Table)
// ============================================================================
class _PurchasesManagementView extends StatefulWidget {
  final DeebaStore store;
  const _PurchasesManagementView({required this.store});

  @override
  State<_PurchasesManagementView> createState() =>
      _PurchasesManagementViewState();
}

class _PurchasesManagementViewState extends State<_PurchasesManagementView> {
  MaterialCategory _selectedCategory = MaterialCategory.outerMaterial;
  late String _selectedMaterialId;
  final _qtyCtrl = TextEditingController(text: '50');
  final _priceCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final firstMat = widget.store.materials
        .firstWhere((m) => m.category == _selectedCategory);
    _selectedMaterialId = firstMat.id;
    _priceCtrl.text = firstMat.purchasePrice.toStringAsFixed(0);
    _supplierCtrl.text = firstMat.supplier;
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _supplierCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onCategoryChanged(MaterialCategory? cat) {
    if (cat == null) return;
    final catMats = widget.store.materials
        .where((m) => m.isActive && m.category == cat)
        .toList();
    setState(() {
      _selectedCategory = cat;
      if (catMats.isNotEmpty) {
        _selectedMaterialId = catMats.first.id;
        _priceCtrl.text = catMats.first.purchasePrice.toStringAsFixed(0);
        _supplierCtrl.text = catMats.first.supplier;
      }
    });
  }

  void _onMaterialChanged(String? matId) {
    if (matId == null) return;
    final mat = widget.store.materials.firstWhere((m) => m.id == matId);
    setState(() {
      _selectedMaterialId = matId;
      _priceCtrl.text = mat.purchasePrice.toStringAsFixed(0);
      _supplierCtrl.text = mat.supplier;
    });
  }

  void _savePurchase() {
    final qty = double.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    if (qty <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid quantity and purchase price')),
      );
      return;
    }

    widget.store.recordPurchase(
      materialId: _selectedMaterialId,
      quantity: qty,
      purchasePrice: price,
      supplierName: _supplierCtrl.text.trim().isEmpty
          ? 'Standard Supplier'
          : _supplierCtrl.text.trim(),
      purchaseDate: DateTime.now(),
      notes: _notesCtrl.text.trim(),
    );

    _notesCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          'Purchase recorded! Material stock and transaction ledger automatically updated.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeMaterials = widget.store.materials
        .where((m) => m.isActive && m.category == _selectedCategory)
        .toList();
    if (activeMaterials.isNotEmpty &&
        !activeMaterials.any((m) => m.id == _selectedMaterialId)) {
      _selectedMaterialId = activeMaterials.first.id;
    }
    final selectedMat = activeMaterials.isNotEmpty
        ? activeMaterials.firstWhere((m) => m.id == _selectedMaterialId)
        : widget.store.materials.first;
    final qty = double.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final totalAmount = qty * price;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 680;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Purchase Management',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Select Material Section (Outer Bundle, Inner Bundle, Packing Cover, Packing Bundle Sheet, Label, or Chemical 8 Types).',
                style: TextStyle(color: Colors.black54, fontSize: 12.5),
              ),
              const SizedBox(height: 16),

              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Record New Purchase Entry',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final cat in MaterialCategory.values)
                          ChoiceChip(
                            label: Text(cat.label),
                            selected: _selectedCategory == cat,
                            onSelected: (_) => _onCategoryChanged(cat),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        SizedBox(
                          width: isMobile ? double.infinity : 300,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedMaterialId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText:
                                  'Select ${_selectedCategory.label} Item *',
                              border: const OutlineInputBorder(),
                            ),
                            items: activeMaterials
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m.id,
                                    child: Text(
                                      '${m.name} (${m.unit})',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: _onMaterialChanged,
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? double.infinity : 150,
                          child: TextField(
                            controller: _qtyCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Quantity (${selectedMat.unit}) *',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? double.infinity : 165,
                          child: TextField(
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Purchase Price *',
                              prefixText: 'Rs. ',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? double.infinity : 210,
                          child: TextField(
                            controller: _supplierCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Supplier Name *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? double.infinity : 220,
                          child: TextField(
                            controller: _notesCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Notes / Invoice Ref',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${selectedMat.category.label}  •  Total: Rs. ${totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB91C1C),
                          ),
                        ),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFB91C1C),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                          ),
                          onPressed: _savePurchase,
                          icon: const Icon(Icons.save_rounded, size: 18),
                          label: const Text('Save Purchase & Add Stock'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              const Text(
                'Purchase History (Complete Bill Details)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),

              if (widget.store.purchases.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          size: 36,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'No Purchase Records Yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Use the form above to record inward raw material bills.\nNew entries are saved directly to factory records.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                )
              // MOBILE VIEW: Clean, Complete Purchase Summary Cards (Shows all details without side scrolling!)
              else if (isMobile)
                Column(
                  children: widget.store.purchases.map((p) {
                    final catColor = _categoryHeaderColor(p.category);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.025),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 1: ID + Date on left, Total Amount pill on right
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      p.id,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11.5,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatDate(p.purchaseDate),
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Rs. ${p.totalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13.5,
                                    color: Color(0xFFB91C1C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Row 2: Material Name + Section Badge
                          Text(
                            p.materialName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  p.category.label,
                                  style: TextStyle(
                                    color: catColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Qty: ${p.quantity.toInt()} ${p.unit}  Rs. ${p.purchasePrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          const SizedBox(height: 6),
                          // Row 3: Supplier + Notes
                          Row(
                            children: [
                              const Icon(Icons.local_shipping_outlined,
                                  size: 15, color: Colors.black54),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Supplier: ${p.supplierName}${p.notes.isNotEmpty ? ' • ${p.notes}' : ''}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              else
                // DESKTOP VIEW: Full-Width Table with Compact Spacing so all columns are visible at once!
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: LayoutBuilder(
                    builder: (ctx, box) => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: box.maxWidth),
                        child: DataTable(
                          columnSpacing: 18,
                          headingRowColor: WidgetStateProperty.all(
                              const Color(0xFFF8FAFC)),
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Material Name')),
                            DataColumn(label: Text('Section')),
                            DataColumn(label: Text('Qty & Unit')),
                            DataColumn(label: Text('Unit Price')),
                            DataColumn(label: Text('Total Amount')),
                            DataColumn(label: Text('Supplier')),
                          ],
                          rows: widget.store.purchases
                              .map(
                                (p) => DataRow(
                                  cells: [
                                    DataCell(Text(
                                      p.id,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                    DataCell(Text(_formatDate(p.purchaseDate))),
                                    DataCell(Text(
                                      p.materialName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700),
                                    )),
                                    DataCell(Text(p.category.label)),
                                    DataCell(Text(
                                        '${p.quantity.toInt()} ${p.unit}')),
                                    DataCell(Text(
                                        'Rs. ${p.purchasePrice.toStringAsFixed(0)}')),
                                    DataCell(
                                      Text(
                                        'Rs. ${p.totalAmount.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFB91C1C),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(p.supplierName)),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// MODULE 6: STOCK MANAGEMENT & FINISHED PRODUCT STOCK
// ============================================================================
class _StockManagementView extends StatefulWidget {
  final DeebaStore store;
  const _StockManagementView({required this.store});

  @override
  State<_StockManagementView> createState() => _StockManagementViewState();
}

class _StockManagementViewState extends State<_StockManagementView> {
  int _tabIndex = 0; // 0: Finished Product Stock, 1: Raw Material Stock (6 Separate Sections), 2: Stock Transactions
  MaterialCategory? _rawMaterialCatFilter;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 680;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Automated Stock Management System',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.calculate_rounded,
                        color: Color(0xFFB45309), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Formula: Opening Stock + New Purchase / Produced - Used for Production - Sold = Current Available Stock',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF78350F),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    avatar: const Icon(Icons.inventory_2_rounded, size: 16),
                    label: const Text('Finished Products Stock'),
                    selected: _tabIndex == 0,
                    onSelected: (_) => setState(() => _tabIndex = 0),
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.science_rounded, size: 16),
                    label: const Text('Raw Materials (6 Sections)'),
                    selected: _tabIndex == 1,
                    onSelected: (_) => setState(() => _tabIndex = 1),
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.receipt_long_rounded, size: 16),
                    label: const Text('Stock Transactions'),
                    selected: _tabIndex == 2,
                    onSelected: (_) => setState(() => _tabIndex = 2),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              if (_tabIndex == 0)
                _buildFinishedProductsView(isMobile: isMobile),
              if (_tabIndex == 1)
                _buildRawMaterialsStockView(isMobile: isMobile),
              if (_tabIndex == 2) _buildTransactionsView(isMobile: isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinishedProductsView({required bool isMobile}) {
    if (isMobile) {
      return Column(
        children: widget.store.finishedStocks.map((fp) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${fp.productBrand} (${fp.priceCategory})',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Available: ${fp.currentBalance.toInt()} Bundles',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Opening: ${fp.openingBalance.toInt()}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Text(
                      'Produced: +${fp.quantityProduced.toInt()}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sold: -${fp.quantitySold.toInt()}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: LayoutBuilder(
        builder: (ctx, box) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: box.maxWidth),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Product Brand')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Opening Stock')),
                DataColumn(label: Text('Produced')),
                DataColumn(label: Text('Sold / Dispatched')),
                DataColumn(label: Text('Current Balance')),
              ],
              rows: widget.store.finishedStocks
                  .map(
                    (fp) => DataRow(
                      cells: [
                        DataCell(Text(
                          fp.productBrand,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        )),
                        DataCell(Text(fp.priceCategory)),
                        DataCell(Text('${fp.openingBalance.toInt()} Bundles')),
                        DataCell(Text(
                          '+${fp.quantityProduced.toInt()} Bundles',
                          style: const TextStyle(color: Colors.green),
                        )),
                        DataCell(Text(
                          '-${fp.quantitySold.toInt()} Bundles',
                          style: const TextStyle(color: Colors.red),
                        )),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${fp.currentBalance.toInt()} Bundles',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRawMaterialsStockView({required bool isMobile}) {
    final categories = _rawMaterialCatFilter == null
        ? MaterialCategory.values
        : [_rawMaterialCatFilter!];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All 6 Sections (Thani Thaniya)'),
              selected: _rawMaterialCatFilter == null,
              onSelected: (_) =>
                  setState(() => _rawMaterialCatFilter = null),
            ),
            for (final cat in MaterialCategory.values)
              ChoiceChip(
                label: Text(cat.label),
                selected: _rawMaterialCatFilter == cat,
                onSelected: (_) =>
                    setState(() => _rawMaterialCatFilter = cat),
              ),
          ],
        ),
        const SizedBox(height: 16),
        for (final cat in categories) ...[
          _buildSingleCategoryStockCard(cat, isMobile: isMobile),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildSingleCategoryStockCard(MaterialCategory cat,
      {required bool isMobile}) {
    final items = widget.store.materials
        .where((m) => m.isActive && m.category == cat)
        .toList();
    final headerColor = _categoryHeaderColor(cat);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: headerColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(_categoryIcon(cat), color: headerColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      cat.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: headerColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${items.length} Items',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: headerColor,
                  ),
                ),
              ],
            ),
          ),
          if (isMobile)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: items.map((m) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                m.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: m.isLowStock
                                    ? Colors.red.shade50
                                    : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${m.currentBalance.toInt()} ${m.unit}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: m.isLowStock
                                      ? Colors.red
                                      : Colors.green.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Open: ${m.openingStock.toInt()}',
                              style: const TextStyle(
                                  fontSize: 11.5, color: Colors.black54),
                            ),
                            Text(
                              'Purchased: +${m.totalPurchased.toInt()}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Used: -${m.usedQuantity.toInt()}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          else
            LayoutBuilder(
              builder: (ctx, box) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: box.maxWidth),
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor:
                        WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columns: const [
                      DataColumn(label: Text('Material Name')),
                      DataColumn(label: Text('Brand (Eagle/Pulli/Joker)')),
                      DataColumn(label: Text('Option (Rs. 1 / Rs. 2)')),
                      DataColumn(label: Text('Opening Stock')),
                      DataColumn(label: Text('Total Purchased')),
                      DataColumn(label: Text('Used (Production)')),
                      DataColumn(label: Text('Current Balance')),
                    ],
                    rows: items
                        .map(
                          (m) => DataRow(
                            cells: [
                              DataCell(Text(
                                m.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              )),
                              DataCell(Text(m.brandType)),
                              DataCell(Text(m.priceCategory)),
                              DataCell(
                                  Text('${m.openingStock.toInt()} ${m.unit}')),
                              DataCell(Text(
                                '+${m.totalPurchased.toInt()} ${m.unit}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                              DataCell(Text(
                                '-${m.usedQuantity.toInt()} ${m.unit}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: m.isLowStock
                                        ? Colors.red.shade50
                                        : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${m.currentBalance.toInt()} ${m.unit}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: m.isLowStock
                                          ? Colors.red
                                          : Colors.green.shade800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionsView({required bool isMobile}) {
    if (isMobile) {
      return Column(
        children: widget.store.stockTransactions.map((t) {
          final isPositive = t.quantity > 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${t.id} • ${_formatDate(t.date)}',
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Text(
                      '${isPositive ? '+' : ''}${t.quantity.toInt()} ${t.unit}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  t.itemName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${t.transactionType} • Balance After: ${t.balanceAfter.toInt()} ${t.unit}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
                Text(
                  t.referenceNote,
                  style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: LayoutBuilder(
        builder: (ctx, box) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: box.maxWidth),
            child: DataTable(
              columnSpacing: 18,
              columns: const [
                DataColumn(label: Text('Txn ID')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Item Name')),
                DataColumn(label: Text('Item Type')),
                DataColumn(label: Text('Movement')),
                DataColumn(label: Text('Quantity')),
                DataColumn(label: Text('Balance After')),
                DataColumn(label: Text('Reference')),
              ],
              rows: widget.store.stockTransactions
                  .map(
                    (t) => DataRow(
                      cells: [
                        DataCell(Text(t.id)),
                        DataCell(Text(_formatDate(t.date))),
                        DataCell(Text(
                          t.itemName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        )),
                        DataCell(Text(t.itemType)),
                        DataCell(Text(t.transactionType)),
                        DataCell(
                          Text(
                            '${t.quantity > 0 ? '+' : ''}${t.quantity.toInt()} ${t.unit}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: t.quantity > 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                        DataCell(Text('${t.balanceAfter.toInt()} ${t.unit}')),
                        DataCell(Text(t.referenceNote)),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MODULE 7: PRODUCTION MANAGEMENT
// ============================================================================
class _ProductionManagementView extends StatefulWidget {
  final DeebaStore store;
  const _ProductionManagementView({required this.store});

  @override
  State<_ProductionManagementView> createState() =>
      _ProductionManagementViewState();
}

class _ProductionManagementViewState extends State<_ProductionManagementView> {
  late String _selectedBrand;
  late String _selectedCategory;
  final _qtyProducedCtrl = TextEditingController(text: '100');
  final _staffCtrl = TextEditingController(text: 'Ramesh (Floor Supervisor)');
  final _notesCtrl = TextEditingController();
  bool _useCommonBundleSheet = false;

  @override
  void initState() {
    super.initState();
    _selectedBrand = widget.store.brandTypes.first;
    _selectedCategory = widget.store.priceCategories.first;
  }

  @override
  void dispose() {
    _qtyProducedCtrl.dispose();
    _staffCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submitProductionBatch() {
    final qty = double.tryParse(_qtyProducedCtrl.text.trim()) ?? 0;
    if (qty <= 0) return;

    final usageList = <MaterialUsageItem>[];

    final outerMat = widget.store.materials.firstWhere(
      (m) =>
          m.category == MaterialCategory.outerMaterial &&
          m.brandType == _selectedBrand &&
          m.priceCategory == _selectedCategory,
      orElse: () => widget.store.materials.first,
    );
    usageList.add(
      MaterialUsageItem(
        materialId: outerMat.id,
        materialName: outerMat.name,
        quantityUsed: (qty * 0.35).roundToDouble(),
        unit: outerMat.unit,
      ),
    );

    final innerMat = widget.store.materials.firstWhere(
      (m) =>
          m.category == MaterialCategory.innerBundle &&
          m.brandType == _selectedBrand &&
          m.priceCategory == _selectedCategory,
      orElse: () => widget.store.materials.first,
    );
    usageList.add(
      MaterialUsageItem(
        materialId: innerMat.id,
        materialName: innerMat.name,
        quantityUsed: (qty * 0.35).roundToDouble(),
        unit: innerMat.unit,
      ),
    );

    final sheetMat = _useCommonBundleSheet
        ? widget.store.materials.firstWhere(
            (m) => m.id == 'MAT-SHT-COMMON',
            orElse: () => widget.store.materials.first,
          )
        : widget.store.materials.firstWhere(
            (m) =>
                m.category == MaterialCategory.bundleSheet &&
                m.brandType == _selectedBrand &&
                m.priceCategory == _selectedCategory,
            orElse: () => widget.store.materials.firstWhere(
              (m) => m.id == 'MAT-SHT-COMMON',
            ),
          );
    usageList.add(
      MaterialUsageItem(
        materialId: sheetMat.id,
        materialName: sheetMat.name,
        quantityUsed: (qty * 0.05).clamp(1, 50).roundToDouble(),
        unit: sheetMat.unit,
      ),
    );

    final chlorine = widget.store.materials.firstWhere(
      (m) => m.id == 'MAT-CHEM-1',
      orElse: () => widget.store.materials.last,
    );
    usageList.add(
      MaterialUsageItem(
        materialId: chlorine.id,
        materialName: chlorine.name,
        quantityUsed: (qty * 0.2).roundToDouble(),
        unit: chlorine.unit,
      ),
    );

    widget.store.recordProduction(
      productionDate: DateTime.now(),
      productBrand: _selectedBrand,
      priceCategory: _selectedCategory,
      quantityProduced: qty,
      materialsUsed: usageList,
      staffResponsible: _staffCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );

    _notesCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          'Production recorded! +${qty.toInt()} Bundles added to $_selectedBrand ($_selectedCategory).',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 680;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Production Management',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const Text(
                'After production entry: Raw Material stock decreases & Finished Product stock increases.',
                style: TextStyle(color: Colors.black54, fontSize: 12.5),
              ),
              const SizedBox(height: 16),

              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter Matchbox Production Batch',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        SizedBox(
                          width: isMobile ? double.infinity : 200,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedBrand,
                            decoration: const InputDecoration(
                              labelText: 'Brand (Eagle/Pulli/Joker)',
                              border: OutlineInputBorder(),
                            ),
                            items: widget.store.brandTypes
                                .map((b) =>
                                    DropdownMenuItem(value: b, child: Text(b)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedBrand = v);
                            },
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? double.infinity : 180,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Price Category',
                              border: OutlineInputBorder(),
                            ),
                            items: widget.store.priceCategories
                                .map((c) =>
                                    DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedCategory = v);
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? double.infinity : 200,
                          child: TextField(
                            controller: _qtyProducedCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantity Produced (Bundles) *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? double.infinity : 230,
                          child: TextField(
                            controller: _staffCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Staff Responsible',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? double.infinity : 250,
                          child: TextField(
                            controller: _notesCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Batch Notes',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _useCommonBundleSheet,
                      onChanged: (v) =>
                          setState(() => _useCommonBundleSheet = v ?? false),
                      title: const Text(
                        'Use Common Packing Bundle Sheet (When brand sheet is unavailable)',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: isMobile ? double.infinity : null,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFB91C1C),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        onPressed: _submitProductionBatch,
                        icon: const Icon(Icons.precision_manufacturing_rounded,
                            size: 18),
                        label: const Text('Record Production & Update Stock'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Production Batch Records',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              for (final prod in widget.store.productionRecords)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(isMobile ? 14 : 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Text(
                            '${prod.id} • ${prod.productBrand} (${prod.priceCategory})    +${prod.quantityProduced.toInt()} Bundles',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${_formatDate(prod.productionDate)} • ${prod.staffResponsible}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: prod.materialsUsed
                            .map(
                              (u) => _BadgeChip(
                                '${u.materialName}: -${u.quantityUsed.toInt()} ${u.unit}',
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// MODULE 8: SALES MANAGEMENT (Mobile Cards + Full-Width Web Table)
// ============================================================================
class _SalesManagementView extends StatefulWidget {
  final DeebaStore store;
  const _SalesManagementView({required this.store});

  @override
  State<_SalesManagementView> createState() => _SalesManagementViewState();
}

class _SalesManagementViewState extends State<_SalesManagementView> {
  CustomerType? _typeFilter;
  String _paymentFilter = 'All';
  String _searchQuery = '';

  void _openNewSaleDialog() {
    CustomerType selectedType = CustomerType.agent;
    final partyCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    String selectedBrand = widget.store.brandTypes.first;
    String selectedCat = widget.store.priceCategories.first;
    final qtyCtrl = TextEditingController(text: '40');
    final priceCtrl = TextEditingController(text: '450');
    final receivedCtrl = TextEditingController(text: '10000');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final qty = double.tryParse(qtyCtrl.text.trim()) ?? 0;
          final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
          final total = qty * price;
          final received = double.tryParse(receivedCtrl.text.trim()) ?? 0;
          final pending = (total - received).clamp(0, double.infinity);

          return AlertDialog(
            title: const Text('Record Agent / Store / Direct Sale'),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<CustomerType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Customer Type',
                        border: OutlineInputBorder(),
                      ),
                      items: CustomerType.values
                          .map((c) => DropdownMenuItem(
                              value: c, child: Text(c.label)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => selectedType = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: partyCtrl,
                      decoration: InputDecoration(
                        labelText: '${selectedType.label} Name *',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: mobileCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Mobile *',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: addressCtrl,
                            decoration: const InputDecoration(
                              labelText: 'City / Address',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedBrand,
                            decoration: const InputDecoration(
                              labelText: 'Product',
                              border: OutlineInputBorder(),
                            ),
                            items: widget.store.brandTypes
                                .map((b) =>
                                    DropdownMenuItem(value: b, child: Text(b)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setModalState(() => selectedBrand = v);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedCat,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                            items: widget.store.priceCategories
                                .map((c) =>
                                    DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setModalState(() {
                                  selectedCat = v;
                                  priceCtrl.text =
                                      v == 'Rs. 1' ? '450' : '820';
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: qtyCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setModalState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Qty (Bundles)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: priceCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setModalState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Price / Bundle',
                              prefixText: 'Rs. ',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: receivedCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setModalState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Amount Received Now',
                        prefixText: 'Rs. ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: Rs. ${total.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Pending: Rs. ${pending.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.red,
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
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (partyCtrl.text.trim().isEmpty || qty <= 0) return;
                  widget.store.recordSale(
                    customerType: selectedType,
                    partyName: partyCtrl.text.trim(),
                    mobileNumber: mobileCtrl.text.trim(),
                    address: addressCtrl.text.trim(),
                    productBrand: selectedBrand,
                    priceCategory: selectedCat,
                    quantity: qty,
                    salePrice: price,
                    amountReceived: received,
                    salesDate: DateTime.now(),
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Save Sale'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openReceivePaymentDialog(SaleRecord sale) {
    final ctrl = TextEditingController(
      text: sale.pendingAmount.toStringAsFixed(0),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Collect Payment • ${sale.partyName}'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText:
                'Amount Received (Pending: Rs. ${sale.pendingAmount.toStringAsFixed(0)})',
            prefixText: 'Rs. ',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amt = double.tryParse(ctrl.text.trim()) ?? 0;
              if (amt > 0) {
                widget.store.receiveSalePayment(sale.id, amt);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Update Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredSales = widget.store.sales.where((s) {
      if (_typeFilter != null && s.customerType != _typeFilter) return false;
      if (_paymentFilter != 'All' && s.paymentStatus != _paymentFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty &&
          !s.partyName.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !s.productBrand.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 680;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales Management (Agent, Store & Direct Sales)',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Track Agent-wise and Store-wise sales, received amounts, and pending balances.',
                        style: TextStyle(color: Colors.black54, fontSize: 12.5),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFB91C1C),
                    ),
                    onPressed: _openNewSaleDialog,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Record Sale'),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('All Sales'),
                    selected: _typeFilter == null,
                    onSelected: (_) => setState(() => _typeFilter = null),
                  ),
                  for (final ct in CustomerType.values)
                    ChoiceChip(
                      label: Text(ct.label),
                      selected: _typeFilter == ct,
                      onSelected: (_) => setState(() => _typeFilter = ct),
                    ),
                  DropdownButton<String>(
                    value: _paymentFilter,
                    items: ['All', 'Paid', 'Partial', 'Pending']
                        .map((st) => DropdownMenuItem(
                            value: st, child: Text('Payment: $st')))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _paymentFilter = v);
                    },
                  ),
                  SizedBox(
                    width: isMobile ? double.infinity : 220,
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Filter Agent / Store / Brand...',
                        prefixIcon: Icon(Icons.search, size: 18),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (filteredSales.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          size: 36,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'No Sales Records Found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Click "Record Sale" above to log wholesale agent or retail store bills.\nAll entries sync in real time with factory records.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                )
              else if (isMobile)
                Column(
                  children: filteredSales.map((s) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Wrap(
                                spacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    '${s.id} • ${_formatDate(s.salesDate)}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      s.customerType.label == 'Agent'
                                          ? 'Wholesale Agent'
                                          : s.customerType.label == 'Store'
                                              ? 'Retail Kadai'
                                              : 'Direct Buyer',
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: s.pendingAmount > 0
                                      ? Colors.red.shade50
                                      : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  s.paymentStatus,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11.5,
                                    color: s.pendingAmount > 0
                                        ? Colors.red
                                        : Colors.green.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            s.partyName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15.5,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.badge_rounded,
                                  size: 13, color: Color(0xFF4338CA)),
                              const SizedBox(width: 4),
                              Text(
                                'Entered by: ${s.recordedBy}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4338CA),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            ' ${s.mobileNumber} • ${s.address}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Product: ${s.productBrand} (${s.priceCategory}) • ${s.quantity.toInt()} Bundles @ Rs. ${s.salePrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: Color(0xFFB91C1C),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total: Rs. ${s.totalAmount.toStringAsFixed(0)} | Paid: Rs. ${s.amountReceived.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Pending: Rs. ${s.pendingAmount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: s.pendingAmount > 0
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              Wrap(
                                spacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  IconButton.filledTonal(
                                    tooltip: 'Print A4 Invoice / PDF',
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.blue.shade50,
                                      foregroundColor: Colors.blue.shade800,
                                    ),
                                    onPressed: () => PrintingService.instance.printSalesInvoiceA4(s),
                                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                                  ),
                                  IconButton.filledTonal(
                                    tooltip: 'Print Thermal Slip (58/80mm)',
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.amber.shade50,
                                      foregroundColor: Colors.amber.shade900,
                                    ),
                                    onPressed: () => PrintingService.instance.printSalesReceiptThermal(s),
                                    icon: const Icon(Icons.receipt_long_rounded, size: 18),
                                  ),
                                  if (s.pendingAmount > 0)
                                    FilledButton.tonal(
                                      onPressed: () =>
                                          _openReceivePaymentDialog(s),
                                      child: const Text('Collect'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: LayoutBuilder(
                    builder: (ctx, box) => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: box.maxWidth),
                        child: DataTable(
                          columnSpacing: 18,
                          columns: const [
                            DataColumn(label: Text('ID / Date')),
                            DataColumn(label: Text('Type / Entered By')),
                            DataColumn(label: Text('Agent / Store Name')),
                            DataColumn(label: Text('Product')),
                            DataColumn(label: Text('Qty')),
                            DataColumn(label: Text('Total')),
                            DataColumn(label: Text('Received')),
                            DataColumn(label: Text('Pending')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: filteredSales.map((s) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text('${s.id}\n${_formatDate(s.salesDate)}',
                                      style: const TextStyle(fontSize: 12)),
                                ),
                                DataCell(
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.customerType.label == 'Agent'
                                            ? 'Wholesale Agent'
                                            : s.customerType.label == 'Store'
                                                ? 'Retail Kadai'
                                                : 'Direct Buyer',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800),
                                      ),
                                      Text(
                                        'By: ${s.recordedBy}',
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          color: Color(0xFF4338CA),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.partyName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800),
                                      ),
                                      Text(
                                        '${s.mobileNumber} • ${s.address}',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(Text(
                                    '${s.productBrand} (${s.priceCategory})')),
                                DataCell(Text('${s.quantity.toInt()} Bdl')),
                                DataCell(Text(
                                  'Rs. ${s.totalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                )),
                                DataCell(Text(
                                  'Rs. ${s.amountReceived.toStringAsFixed(0)}',
                                  style: const TextStyle(color: Colors.green),
                                )),
                                DataCell(
                                  Text(
                                    'Rs. ${s.pendingAmount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: s.pendingAmount > 0
                                          ? Colors.red
                                          : Colors.black45,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  s.pendingAmount > 0
                                      ? FilledButton.tonal(
                                          onPressed: () =>
                                              _openReceivePaymentDialog(s),
                                          child: const Text('Collect'),
                                        )
                                      : const _BadgeChip(
                                          'Paid',
                                          textColor: Colors.green,
                                        ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// MODULE 9: WORKER MANAGEMENT, DAILY ATTENDANCE, ACTIVITY & SALARY
// ============================================================================
class _WorkersAttendanceSalaryView extends StatefulWidget {
  final DeebaStore store;
  const _WorkersAttendanceSalaryView({required this.store});

  @override
  State<_WorkersAttendanceSalaryView> createState() =>
      _WorkersAttendanceSalaryViewState();
}

class _WorkersAttendanceSalaryViewState
    extends State<_WorkersAttendanceSalaryView> {
  int _subTab = 0;

  void _showManageWorkersDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Factory Workers - Database Options'),
        content: const Text(
          'Choose an action for Factory Workers list:\n\n'
          '1. "Reset Paid Salaries to Rs. 0": Keeps all workers and resets their paid salary balances to Rs. 0.\n\n'
          '2. "Clear All Workers (Fresh Start)": Completely deletes all test workers from the system so you can add real factory staff members from scratch.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.store.resetAllWorkerSalaries();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All worker paid salaries reset to Rs. 0!'),
                  ),
                );
              }
            },
            child: const Text('Reset Paid to Rs. 0'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade800),
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.store.clearAllWorkers();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'All test workers removed! Ready for fresh staff entry.',
                    ),
                  ),
                );
              }
            },
            child: const Text('Clear All Workers'),
          ),
        ],
      ),
    );
  }

  void _openAddWorkerDialog() {
    final nameCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final jobCtrl = TextEditingController(text: 'Packing & Box Filling');
    SalaryType selectedSalaryType = SalaryType.daily;
    final salaryCtrl = TextEditingController(text: '450');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: const Text('Add New Factory Worker'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Worker Name *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: mobileCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Mobile Number *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: jobCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Job Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<SalaryType>(
                    initialValue: selectedSalaryType,
                    decoration: const InputDecoration(
                      labelText: 'Salary Type',
                      border: OutlineInputBorder(),
                    ),
                    items: SalaryType.values
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s.label)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setModalState(() {
                          selectedSalaryType = v;
                          salaryCtrl.text =
                              v == SalaryType.monthly ? '15000' : '450';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: salaryCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: selectedSalaryType == SalaryType.monthly
                          ? 'Monthly Fixed Salary (Rs.)'
                          : 'Daily Wage Rate (Rs. / Day)',
                      prefixText: 'Rs. ',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                widget.store.addOrUpdateWorker(
                  WorkerModel(
                    id: 'WKR-${101 + widget.store.workers.length}',
                    name: nameCtrl.text.trim(),
                    mobileNumber: mobileCtrl.text.trim(),
                    jobType: jobCtrl.text.trim(),
                    joiningDate: DateTime.now(),
                    salaryType: selectedSalaryType,
                    salaryAmount:
                        double.tryParse(salaryCtrl.text.trim()) ?? 450,
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Save Worker'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 680;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workers, Daily Attendance & Salary Management',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Staff marks daily attendance, work performed, and manages salary payouts.',
                        style: TextStyle(color: Colors.black54, fontSize: 12.5),
                      ),
                    ],
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFB91C1C),
                    ),
                    onPressed: _openAddWorkerDialog,
                    icon: const Icon(Icons.person_add_rounded, size: 18),
                    label: const Text('Add Worker'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _showManageWorkersDialog,
                    icon: const Icon(Icons.cleaning_services_rounded, size: 16),
                    label: const Text('Reset / Clear Workers'),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    avatar: const Icon(Icons.fact_check_rounded, size: 16),
                    label: const Text('Daily Attendance & Work'),
                    selected: _subTab == 0,
                    onSelected: (_) => setState(() => _subTab = 0),
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.payments_rounded, size: 16),
                    label: const Text('Salary Calculation & Payouts'),
                    selected: _subTab == 1,
                    onSelected: (_) => setState(() => _subTab = 1),
                  ),
                  ChoiceChip(
                    avatar: const Icon(Icons.badge_rounded, size: 16),
                    label: const Text('Worker Directory'),
                    selected: _subTab == 2,
                    onSelected: (_) => setState(() => _subTab = 2),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_subTab == 0) _buildDailyAttendanceSheet(),
              if (_subTab == 1)
                _buildSalaryManagementView(isMobile: isMobile),
              if (_subTab == 2)
                _buildWorkerDirectoryView(isMobile: isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyAttendanceSheet() {
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  color: Colors.blue, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Today's Attendance & Work Register (${_formatDate(now)})",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (widget.store.workers.where((w) => w.isActive).isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.people_outline_rounded,
                    size: 44, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                const Text(
                  'No active workers in database yet',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap "+ Add Worker" above to register factory workers.',
                  style: TextStyle(fontSize: 12.5, color: Colors.black54),
                ),
              ],
            ),
          )
        else
          for (final worker in widget.store.workers.where((w) => w.isActive))
          _WorkerDailyRowCard(worker: worker, store: widget.store),
      ],
    );
  }

  Widget _buildSalaryManagementView({required bool isMobile}) {
    if (widget.store.workers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.payments_outlined, size: 44, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            const Text(
              'No workers in salary register',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap "+ Add Worker" above to register factory staff.',
              style: TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
          ],
        ),
      );
    }
    if (isMobile) {
      return Column(
        children: widget.store.workers.map((w) {
          final workingDays = widget.store.getWorkingDaysForWorker(w.id);
          final totalSalary = widget.store.calculateTotalSalaryForWorker(w);
          final pending =
              (totalSalary - w.paidSalaryAmount).clamp(0.0, double.infinity);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      w.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                      ),
                    ),
                    Text(
                      w.salaryType.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  w.salaryType == SalaryType.monthly
                      ? 'Fixed Rate: Rs. ${w.salaryAmount.toStringAsFixed(0)} / Month'
                      : 'Rate: Rs. ${w.salaryAmount.toStringAsFixed(0)}/Day × $workingDays Working Days',
                  style: const TextStyle(fontSize: 12.5),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total: Rs. ${totalSalary.toStringAsFixed(0)} | Paid: Rs. ${w.paidSalaryAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Pending: Rs. ${pending.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                            color: pending > 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    if (pending > 0)
                      FilledButton.tonal(
                        onPressed: () =>
                            widget.store.recordSalaryPayment(w.id, pending),
                        child: const Text('Pay Pending'),
                      )
                    else
                      const Text(
                        'Settled ✓',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: LayoutBuilder(
        builder: (ctx, box) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: box.maxWidth),
            child: DataTable(
              columnSpacing: 18,
              columns: const [
                DataColumn(label: Text('Worker Name')),
                DataColumn(label: Text('Salary Type')),
                DataColumn(label: Text('Base Rate')),
                DataColumn(label: Text('Working Days')),
                DataColumn(label: Text('Total Salary')),
                DataColumn(label: Text('Paid')),
                DataColumn(label: Text('Pending')),
                DataColumn(label: Text('Action')),
              ],
              rows: widget.store.workers.map((w) {
                final workingDays = widget.store.getWorkingDaysForWorker(w.id);
                final totalSalary =
                    widget.store.calculateTotalSalaryForWorker(w);
                final pending = (totalSalary - w.paidSalaryAmount)
                    .clamp(0.0, double.infinity);

                return DataRow(
                  cells: [
                    DataCell(Text(
                      w.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    )),
                    DataCell(Text(w.salaryType.label)),
                    DataCell(
                      Text(
                        w.salaryType == SalaryType.monthly
                            ? 'Rs. ${w.salaryAmount.toStringAsFixed(0)} / Mo'
                            : 'Rs. ${w.salaryAmount.toStringAsFixed(0)} / Day',
                      ),
                    ),
                    DataCell(
                      Text(
                        w.salaryType == SalaryType.daily
                            ? '$workingDays Days'
                            : 'Fixed Monthly',
                      ),
                    ),
                    DataCell(
                      Text(
                        'Rs. ${totalSalary.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    DataCell(
                      Text(
                        'Rs. ${w.paidSalaryAmount.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                    DataCell(
                      Text(
                        'Rs. ${pending.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: pending > 0 ? Colors.red : Colors.black45,
                        ),
                      ),
                    ),
                    DataCell(
                      pending > 0
                          ? FilledButton.tonal(
                              onPressed: () {
                                widget.store.recordSalaryPayment(w.id, pending);
                              },
                              child: const Text('Pay Pending'),
                            )
                          : const Text(
                              'Settled ✓',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkerDirectoryView({required bool isMobile}) {
    if (widget.store.workers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.badge_outlined, size: 44, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            const Text(
              'No workers registered in directory yet',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap "+ Add Worker" above to register real factory staff members.',
              style: TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
          ],
        ),
      );
    }
    if (isMobile) {
      return Column(
        children: widget.store.workers.map((w) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${w.name} (${w.id})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${w.jobType} • Ph: ${w.mobileNumber}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs. ${w.salaryAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                    Text(
                      w.salaryType.label,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: LayoutBuilder(
        builder: (ctx, box) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: box.maxWidth),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Worker Name')),
                DataColumn(label: Text('Mobile')),
                DataColumn(label: Text('Job Type')),
                DataColumn(label: Text('Joined')),
                DataColumn(label: Text('Salary Type')),
                DataColumn(label: Text('Rate')),
                DataColumn(label: Text('Action')),
              ],
              rows: widget.store.workers
                  .map(
                    (w) => DataRow(
                      cells: [
                        DataCell(Text(w.id)),
                        DataCell(Text(
                          w.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )),
                        DataCell(Text(w.mobileNumber)),
                        DataCell(Text(w.jobType)),
                        DataCell(Text(_formatDate(w.joiningDate))),
                        DataCell(Text(w.salaryType.label)),
                        DataCell(
                            Text('Rs. ${w.salaryAmount.toStringAsFixed(0)}')),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 18),
                            tooltip: 'Delete Worker',
                            onPressed: () => widget.store.removeWorker(w.id),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkerDailyRowCard extends StatefulWidget {
  final WorkerModel worker;
  final DeebaStore store;

  const _WorkerDailyRowCard({
    required this.worker,
    required this.store,
  });

  @override
  State<_WorkerDailyRowCard> createState() => _WorkerDailyRowCardState();
}

class _WorkerDailyRowCardState extends State<_WorkerDailyRowCard> {
  late AttendanceStatus _status;
  late WorkType _workType;
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final existing = widget.store.dailyRecords.where(
      (r) =>
          r.workerId == widget.worker.id &&
          r.date.year == now.year &&
          r.date.month == now.month &&
          r.date.day == now.day,
    );
    if (existing.isNotEmpty) {
      _status = existing.first.attendanceStatus;
      _workType = existing.first.workPerformed;
      _notesCtrl = TextEditingController(text: existing.first.notes);
    } else {
      _status = AttendanceStatus.present;
      _workType = WorkType.packing;
      _notesCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _saveNow() {
    widget.store.markWorkerDailyRecord(
      workerId: widget.worker.id,
      date: DateTime.now(),
      attendanceStatus: _status,
      workPerformed: _workType,
      notes: _notesCtrl.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(
          'Updated ${widget.worker.name}: ${_status.label} (${_workType.label})',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.worker.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${widget.worker.jobType} • ${widget.worker.salaryType.label}',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          DropdownButton<AttendanceStatus>(
            value: _status,
            items: AttendanceStatus.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _status = v);
                _saveNow();
              }
            },
          ),
          DropdownButton<WorkType>(
            value: _workType,
            items: WorkType.values
                .map((w) => DropdownMenuItem(value: w, child: Text(w.label)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _workType = v);
                _saveNow();
              }
            },
          ),
          SizedBox(
            width: 220,
            child: TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                isDense: true,
                labelText: 'Work Notes',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _saveNow(),
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: _saveNow,
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MODULE 10: REPORTS & ANALYTICS
// ============================================================================
class _ReportsAnalyticsView extends StatelessWidget {
  final DeebaStore store;
  const _ReportsAnalyticsView({required this.store});

  @override
  Widget build(BuildContext context) {
    final agentSales = store.sales
        .where((s) => s.customerType == CustomerType.agent)
        .toList();
    final storeSales = store.sales
        .where((s) => s.customerType == CustomerType.store)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 740;
        final pad = isMobile ? 14.0 : 24.0;
        final availWidth = constraints.maxWidth - (pad * 2);
        final cardWidth = isMobile ? availWidth : (availWidth - 20) / 2;

        return SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Company Reports & Financial Analytics',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const Text(
                'Agent-wise Sales, Store-wise Sales, and Pending Receivable Summary.',
                style: TextStyle(color: Colors.black54, fontSize: 12.5),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 20,
                runSpacing: 16,
                children: [
                  Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Agent-Wise Sales & Pending Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Divider(),
                        for (final s in agentSales)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              s.partyName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${s.productBrand} (${s.priceCategory}) • ${s.quantity.toInt()} Bundles',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total: Rs. ${s.totalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  'Pending: Rs. ${s.pendingAmount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: s.pendingAmount > 0
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Store-Wise Sales & Pending Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Divider(),
                        for (final s in storeSales)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              s.partyName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              '${s.productBrand} (${s.priceCategory}) • ${s.quantity.toInt()} Bundles',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total: Rs. ${s.totalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  'Pending: Rs. ${s.pendingAmount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: s.pendingAmount > 0
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
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
        );
      },
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final Color? textColor;
  const _BadgeChip(this.label, {this.textColor});

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: textColor != null ? FontWeight.bold : FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}

Color _categoryHeaderColor(MaterialCategory cat) {
  switch (cat) {
    case MaterialCategory.outerMaterial:
      return const Color(0xFFB91C1C);
    case MaterialCategory.innerBundle:
      return const Color(0xFFD97706);
    case MaterialCategory.packageCover:
      return const Color(0xFF0284C7);
    case MaterialCategory.bundleSheet:
      return const Color(0xFF7C3AED);
    case MaterialCategory.labels:
      return const Color(0xFF059669);
    case MaterialCategory.chemical:
      return const Color(0xFF0F766E);
  }
}

IconData _categoryIcon(MaterialCategory cat) {
  switch (cat) {
    case MaterialCategory.outerMaterial:
      return Icons.all_inbox_rounded;
    case MaterialCategory.innerBundle:
      return Icons.view_module_rounded;
    case MaterialCategory.packageCover:
      return Icons.layers_rounded;
    case MaterialCategory.bundleSheet:
      return Icons.description_rounded;
    case MaterialCategory.labels:
      return Icons.label_important_rounded;
    case MaterialCategory.chemical:
      return Icons.science_rounded;
  }
}

String _formatDate(DateTime dt) {
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  return '$d/$m/${dt.year}';
}

// ==================== DAILY FACTORY PRODUCTION & STOCK SHEET ====================
class _DailyFactorySheetView extends StatefulWidget {
  final DeebaStore store;

  const _DailyFactorySheetView({required this.store});

  @override
  State<_DailyFactorySheetView> createState() => _DailyFactorySheetViewState();
}

class _DailyRowController {
  final String brand;
  final String priceCategory;
  double openingStock;
  final TextEditingController producedCtrl = TextEditingController(text: '0');
  final TextEditingController salesCtrl = TextEditingController(text: '0');

  _DailyRowController({
    required this.brand,
    required this.priceCategory,
    this.openingStock = 0.0,
  });

  double get produced => double.tryParse(producedCtrl.text.trim()) ?? 0.0;
  double get sales => double.tryParse(salesCtrl.text.trim()) ?? 0.0;
  double get available => openingStock + produced;
  double get closing => available - sales;

  void dispose() {
    producedCtrl.dispose();
    salesCtrl.dispose();
  }
}

class _DailyFactorySheetViewState extends State<_DailyFactorySheetView> {
  DateTime _selectedDate = DateTime.now();
  late String _dayName;
  bool _isSaving = false;

  // Image 2 Top Left: Adappu & Box metrics
  final TextEditingController _adappuCtrl = TextEditingController(text: '0');
  final TextEditingController _totalBoxesCtrl =
      TextEditingController(text: '0');

  // Image 2 Top Right: Frame Dipping Balance Math
  final TextEditingController _openingFramesCtrl =
      TextEditingController(text: '0');
  final TextEditingController _dippingCtrl = TextEditingController(text: '0');

  // Image 2 Middle: Company lines
  final TextEditingController _company1Ctrl = TextEditingController();
  final TextEditingController _company2Ctrl = TextEditingController();
  final TextEditingController _companyTotalCtrl = TextEditingController();

  // Image 1 Bottom: Inward, Outward & Closing Card
  final TextEditingController _materialInwardCtrl = TextEditingController();
  final TextEditingController _materialOutwardCtrl = TextEditingController();
  final TextEditingController _closingCardNoteCtrl = TextEditingController();

  final List<_DailyRowController> _rowControllers = [];

  @override
  void initState() {
    super.initState();
    _updateDayName();
    _initRowControllers();

    _adappuCtrl.addListener(() => setState(() {}));
    _totalBoxesCtrl.addListener(() => setState(() {}));
    _openingFramesCtrl.addListener(() => setState(() {}));
    _dippingCtrl.addListener(() => setState(() {}));
    _company1Ctrl.addListener(() => setState(() {}));
    _company2Ctrl.addListener(() => setState(() {}));

    _checkForExistingSheet();
  }

  String _toIsoDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  void _checkForExistingSheet() {
    final iso = _toIsoDate(_selectedDate);
    final existing = widget.store.dailySheets
            .where((s) => s.date == iso)
            .firstOrNull ??
        (widget.store.todayDailySheet?.date == iso
            ? widget.store.todayDailySheet
            : null);
    if (existing != null) {
      _loadSheetData(existing);
    }
  }

  void _loadSheetData(DailyProductionSheet s) {
    final parts = s.date.split('-');
    if (parts.length == 3) {
      _selectedDate = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      _updateDayName();
    }
    _adappuCtrl.text = s.adappuFrames.toString();
    _totalBoxesCtrl.text = s.totalBoxes.toString();
    _dippingCtrl.text = s.dippingFrames.toString();
    final opFrames = s.balanceFrames + s.adappuFrames - s.dippingFrames;
    _openingFramesCtrl.text = (opFrames > 0 ? opFrames : 0).toString();

    _materialInwardCtrl.text = s.companyMaterialInward;
    _materialOutwardCtrl.text = s.companyMaterialOutward;
    _closingCardNoteCtrl.text = s.closingCardNote;

    for (final r in s.brandRows) {
      final ctrl = _rowControllers.firstWhere(
        (c) =>
            c.brand.toLowerCase() == r.brand.toLowerCase() &&
            c.priceCategory.toLowerCase() == r.priceCategory.toLowerCase(),
        orElse: () => _rowControllers.first,
      );
      ctrl.openingStock = r.openingStock;
      ctrl.producedCtrl.text =
          r.producedBundles > 0 ? r.producedBundles.toStringAsFixed(0) : '';
      ctrl.salesCtrl.text =
          r.salesBundles > 0 ? r.salesBundles.toStringAsFixed(0) : '';
    }
  }

  void _resetControllersToStock() {
    _adappuCtrl.text = '0';
    _totalBoxesCtrl.text = '0';
    _openingFramesCtrl.text = '0';
    _dippingCtrl.text = '0';
    _company1Ctrl.clear();
    _company2Ctrl.clear();
    _companyTotalCtrl.clear();
    _materialInwardCtrl.clear();
    _materialOutwardCtrl.clear();
    _closingCardNoteCtrl.clear();

    for (final rc in _rowControllers) {
      final existingFp = widget.store.finishedStocks.firstWhere(
        (fs) =>
            fs.productBrand.toLowerCase() == rc.brand.toLowerCase() &&
            fs.priceCategory.toLowerCase() == rc.priceCategory.toLowerCase(),
        orElse: () => FinishedProductStock(
          id: '',
          productBrand: rc.brand,
          priceCategory: rc.priceCategory,
          openingBalance: 0,
          quantityProduced: 0,
          salePricePerBundle: 450,
        ),
      );
      rc.openingStock = existingFp.currentBalance;
      rc.producedCtrl.text = '0';
      rc.salesCtrl.text = '0';
    }
  }

  void _updateDayName() {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    _dayName = days[_selectedDate.weekday - 1];
  }

  void _initRowControllers() {
    for (final c in _rowControllers) {
      c.dispose();
    }
    _rowControllers.clear();

    final brandList = [
      {'b': 'Eagle', 'c': 'Rs. 1'},
      {'b': 'Eagle', 'c': 'Rs. 2'},
      {'b': 'Pulli', 'c': 'Rs. 1'},
      {'b': 'Pulli', 'c': 'Rs. 2'},
      {'b': 'Joker', 'c': 'Rs. 1'},
      {'b': 'Joker', 'c': 'Rs. 2'},
    ];

    for (final item in brandList) {
      final b = item['b']!;
      final cat = item['c']!;
      double opening = 0.0;
      final existingFp = widget.store.finishedStocks.firstWhere(
        (fs) =>
            fs.productBrand.toLowerCase() == b.toLowerCase() &&
            fs.priceCategory.toLowerCase() == cat.toLowerCase(),
        orElse: () => FinishedProductStock(
          id: '',
          productBrand: b,
          priceCategory: cat,
          openingBalance: 0,
          quantityProduced: 0,
          salePricePerBundle: 450,
        ),
      );
      opening = existingFp.currentBalance;

      final rc = _DailyRowController(
        brand: b,
        priceCategory: cat,
        openingStock: opening,
      );
      rc.producedCtrl.addListener(() => setState(() {}));
      rc.salesCtrl.addListener(() => setState(() {}));
      _rowControllers.add(rc);
    }
  }

  @override
  void dispose() {
    _adappuCtrl.dispose();
    _totalBoxesCtrl.dispose();
    _openingFramesCtrl.dispose();
    _dippingCtrl.dispose();
    _company1Ctrl.dispose();
    _company2Ctrl.dispose();
    _companyTotalCtrl.dispose();
    _materialInwardCtrl.dispose();
    _materialOutwardCtrl.dispose();
    _closingCardNoteCtrl.dispose();
    for (final c in _rowControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // Image 2 Left Calculations
  double get _adappuFrames => double.tryParse(_adappuCtrl.text.trim()) ?? 0.0;
  double get _totalBoxes => double.tryParse(_totalBoxesCtrl.text.trim()) ?? 0.0;
  double get _avgBoxesPerFrame =>
      _adappuFrames > 0 ? _totalBoxes / _adappuFrames : 0.0;
  double get _grossCount => _totalBoxes > 0 ? _totalBoxes / 144.0 : 0.0;
  double get _totalBundlesFromBoxes =>
      _totalBoxes > 0 ? _totalBoxes / 600.0 : 0.0;

  // Image 2 Right Calculations (Frame Stock Math)
  double get _openingFrames =>
      double.tryParse(_openingFramesCtrl.text.trim()) ?? 0.0;
  double get _dippingFrames => double.tryParse(_dippingCtrl.text.trim()) ?? 0.0;
  double get _totalDippedFrames => _openingFrames + _dippingFrames;
  double get _closingFrames => _totalDippedFrames - _adappuFrames;

  // Image 2 Middle: Madippu Bundle quick totals
  double get _eaaBundles => _rowControllers
      .where((r) => r.brand.toLowerCase() == 'eagle')
      .fold(0.0, (sum, r) => sum + r.produced);
  double get _plBundles => _rowControllers
      .where((r) => r.brand.toLowerCase() == 'pulli')
      .fold(0.0, (sum, r) => sum + r.produced);
  double get _jokBundles => _rowControllers
      .where((r) => r.brand.toLowerCase() == 'joker')
      .fold(0.0, (sum, r) => sum + r.produced);
  double get _totalMadippuBundles => _eaaBundles + _plBundles + _jokBundles;

  // Master Table Totals
  double get _totalOpening =>
      _rowControllers.fold(0.0, (sum, r) => sum + r.openingStock);
  double get _totalProduced =>
      _rowControllers.fold(0.0, (sum, r) => sum + r.produced);
  double get _totalAvailable =>
      _rowControllers.fold(0.0, (sum, r) => sum + r.available);
  double get _totalSales =>
      _rowControllers.fold(0.0, (sum, r) => sum + r.sales);
  double get _totalClosing =>
      _rowControllers.fold(0.0, (sum, r) => sum + r.closing);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _updateDayName();
        final iso = _toIsoDate(_selectedDate);
        final existing = widget.store.dailySheets
                .where((s) => s.date == iso)
                .firstOrNull ??
            (widget.store.todayDailySheet?.date == iso
                ? widget.store.todayDailySheet
                : null);
        if (existing != null) {
          _loadSheetData(existing);
        } else {
          _resetControllersToStock();
        }
      });
    }
  }

  Future<void> _saveSheet() async {
    setState(() => _isSaving = true);
    final sheetDateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final sheetId = 'DS-${sheetDateStr.replaceAll('-', '')}';

    final brandRows = _rowControllers.map((r) {
      return DailySheetBrandRow(
        brand: r.brand,
        priceCategory: r.priceCategory,
        openingStock: r.openingStock,
        producedBundles: r.produced,
        salesBundles: r.sales,
      );
    }).toList();

    final sheet = DailyProductionSheet(
      sheetId: sheetId,
      date: sheetDateStr,
      dayOfWeek: _dayName,
      recordedBy: widget.store.loggedInUserName,
      adappuFrames: _adappuFrames.toInt(),
      dippingFrames: _dippingFrames.toInt(),
      balanceFrames: _closingFrames.toInt(),
      totalBoxes: _totalBoxes.toInt(),
      avgBoxesPerFrame: _avgBoxesPerFrame,
      grossCount: _grossCount,
      totalBundlesProduced: _totalMadippuBundles.toInt(),
      brandRows: brandRows,
      companyMaterialInward: _company1Ctrl.text.isNotEmpty
          ? '1. ${_company1Ctrl.text} | 2. ${_company2Ctrl.text} | Inward: ${_materialInwardCtrl.text}'
          : _materialInwardCtrl.text.trim(),
      companyMaterialOutward: _materialOutwardCtrl.text.trim(),
      closingCardNote: _closingCardNoteCtrl.text.trim(),
    );

    final ok = await widget.store.saveDailyProductionSheet(sheet);
    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              ok
                  ? 'Daily Factory Sheet saved successfully to Factory Records!'
                  : 'Saved locally in memory.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF065F46),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPrintSlipDialog() {
    final sheetDateStr = _toIsoDate(_selectedDate);
    final brandRows = _rowControllers.map((r) {
      return DailySheetBrandRow(
        brand: r.brand,
        priceCategory: r.priceCategory,
        openingStock: r.openingStock,
        producedBundles: r.produced,
        salesBundles: r.sales,
      );
    }).toList();

    final sheet = DailyProductionSheet(
      sheetId: 'DS-${sheetDateStr.replaceAll('-', '')}',
      date: sheetDateStr,
      dayOfWeek: _dayName,
      recordedBy: widget.store.loggedInUserName,
      adappuFrames: _adappuFrames.toInt(),
      dippingFrames: _dippingFrames.toInt(),
      balanceFrames: _closingFrames.toInt(),
      totalBoxes: _totalBoxes.toInt(),
      avgBoxesPerFrame: _avgBoxesPerFrame,
      grossCount: _grossCount,
      totalBundlesProduced: _totalMadippuBundles.toInt(),
      brandRows: brandRows,
      companyMaterialInward: _company1Ctrl.text.isNotEmpty
          ? '1. ${_company1Ctrl.text} | 2. ${_company2Ctrl.text} | Inward: ${_materialInwardCtrl.text}'
          : _materialInwardCtrl.text.trim(),
      companyMaterialOutward: _materialOutwardCtrl.text.trim(),
      closingCardNote: _closingCardNoteCtrl.text.trim(),
    );

    showDailyPaperSlipDialog(context, sheet);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 12 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Action Header
              Container(
                padding: EdgeInsets.all(isMobile ? 14 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.assignment_turned_in_rounded,
                                color: Color(0xFF065F46), size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Daily Factory Production & Stock Sheet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Digitized Factory Slip • Date: ${_formatDate(_selectedDate)} ($_dayName) • By ${widget.store.loggedInUserName}',
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_month_rounded, size: 16),
                          label: Text(
                            '${_formatDate(_selectedDate)} ($_dayName)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF065F46),
                            side: const BorderSide(color: Color(0xFF065F46)),
                          ),
                          onPressed: _showPrintSlipDialog,
                          icon: const Icon(Icons.print_rounded, size: 16),
                          label: const Text('Preview Paper Slip (Image 1 & 2)'),
                        ),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF065F46),
                          ),
                          onPressed: _isSaving ? null : _saveSheet,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.save_rounded, size: 18),
                          label: Text(_isSaving ? 'Saving...' : 'Save Daily Sheet'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==================== SECTION 1: TWO-COLUMN FRAME & BOX METRICS (EXACT IMAGE 2) ====================
              Container(
                padding: EdgeInsets.all(isMobile ? 14 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '1. Frame & Box Volume Metrics (Adappu & Dipping Frames - Image 2)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Matches Paper Top Half',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Side-by-Side Two Columns matching Image 2
                    if (!isMobile)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Box: Machine Output Metrics
                          Expanded(
                            child: _buildLeftMetricsCard(),
                          ),
                          const SizedBox(width: 16),
                          // Right Box: Dipping Balance Math
                          Expanded(
                            child: _buildRightDippingMathCard(),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildLeftMetricsCard(),
                          const SizedBox(height: 12),
                          _buildRightDippingMathCard(),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==================== SECTION 2: MADIPPU BUNDLE & COMPANY LINES (EXACT IMAGE 2) ====================
              Container(
                padding: EdgeInsets.all(isMobile ? 14 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '2. Madippu Bundles & Company Lines (Folding Summary - Image 2)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),

                    // Madippu Bundle Row (EAA, PL, JOK, TOTAL)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Madippu Bundles (Folding Bundles Produced Today):',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 10,
                            children: [
                              _brandBundlePill('EAA (Eagle)', _eaaBundles, const Color(0xFFB91C1C)),
                              _brandBundlePill('PL (Pulli)', _plBundles, const Color(0xFF0284C7)),
                              _brandBundlePill('JOK (Joker)', _jokBundles, const Color(0xFFD97706)),
                              _brandBundlePill('TOTAL Madippu', _totalMadippuBundles, const Color(0xFF065F46), isTotal: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 1. Company & 2. Company Inputs
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: isMobile ? double.infinity : 320,
                          child: TextField(
                            controller: _company1Ctrl,
                            decoration: const InputDecoration(
                              labelText: '1. Company Line [Inward / Outward]',
                              hintText: 'E.g. Sivakasi Print Pack - 200 Bdls',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? double.infinity : 320,
                          child: TextField(
                            controller: _company2Ctrl,
                            decoration: const InputDecoration(
                              labelText: '2. Company Line [Inward / Outward]',
                              hintText: 'E.g. Madurai Board Mills - 150 Bdls',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isMobile ? double.infinity : 220,
                          child: TextField(
                            controller: _companyTotalCtrl,
                            decoration: InputDecoration(
                              labelText: 'TOTAL •',
                              hintText: '${_totalMadippuBundles.toStringAsFixed(0)} Bundles',
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==================== SECTION 3: MASTER BRAND STOCK RECONCILIATION TABLE (IMAGE 1) ====================
              Container(
                padding: EdgeInsets.all(isMobile ? 14 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '3. Master Brand Stock Reconciliation (Brand Stock & Sales)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              'Opening + Produced (Madippu) = Total Available - Sales = Closing Stock',
                              style: TextStyle(fontSize: 11.5, color: Colors.black54),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Closing Total: ${_totalClosing.toStringAsFixed(0)} Bundles',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // MOBILE VIEW: Interactive Cards
                    if (isMobile)
                      Column(
                        children: _rowControllers.map((r) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${r.brand} ${r.priceCategory}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFA7F3D0)),
                                      ),
                                      child: Text(
                                        'Closing: ${r.closing.toStringAsFixed(0)} Bdl',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                          color: Color(0xFF065F46),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _compactMetricPill(
                                        'Opening ',
                                        r.openingStock.toStringAsFixed(0),
                                        Colors.blueGrey,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _compactMetricPill(
                                        'Total Available',
                                        r.available.toStringAsFixed(0),
                                        Colors.indigo,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: r.producedCtrl,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          labelText: 'Produced (Madippu)',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: r.salesCtrl,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          labelText: 'Sales (Virpanai)',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    else
                      // DESKTOP TABLE VIEW
                      Table(
                        border: TableBorder.all(color: Colors.grey.shade300),
                        columnWidths: const {
                          0: FlexColumnWidth(1.8),
                          1: FlexColumnWidth(1.2),
                          2: FlexColumnWidth(1.5),
                          3: FlexColumnWidth(1.4),
                          4: FlexColumnWidth(1.5),
                          5: FlexColumnWidth(1.4),
                        },
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                            ),
                            children: [
                              _tableHead('Brand Name\n(Brand)'),
                              _tableHead('Opening Stock\n(Iruppu)'),
                              _tableHead('Produced (Madippu)\n(Madippu)'),
                              _tableHead('Total Available\n(Moththam)'),
                              _tableHead('Sales Bundles\n(Sales)'),
                              _tableHead('Closing Stock\n(Meedhi Iruppu)'),
                            ],
                          ),
                          for (final r in _rowControllers)
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    '${r.brand} ${r.priceCategory}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    r.openingStock.toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: TextField(
                                    controller: r.producedCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      r.available.toStringAsFixed(0),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: TextField(
                                    controller: r.salesCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      r.closing.toStringAsFixed(0),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF065F46),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          // Totals Row
                          TableRow(
                            decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'TOTAL BUNDLE\n(Moththam)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  _totalOpening.toStringAsFixed(0),
                                  style: const TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  _totalProduced.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  _totalAvailable.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  _totalSales.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF7C3AED),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  _totalClosing.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFB91C1C),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==================== SECTION 4: INWARD, OUTWARD & CLOSING CARD ====================
              Container(
                padding: EdgeInsets.all(isMobile ? 14 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '4. Material Inward, Issue & Closing Card (Varavu, Veliyedu & Iruppu - Image 1)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _materialInwardCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Company Material Inward (Varavu)',
                        hintText: 'E.g. Sivakasi Print Pack Outer Boards - 200 Bundles',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _materialOutwardCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Company Material Outward (Issue / Veliyedu)',
                        hintText: 'E.g. Issued 150 Bundles Outer Board to Line 1 Floor',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _closingCardNoteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Closing Card Note (Brand & Shift Notes)',
                        hintText: 'E.g. Shift 1 all drying frames inspected and locked',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF065F46),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _saveSheet,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.cloud_upload_rounded, size: 20),
                  label: Text(
                    _isSaving ? 'Saving Daily Factory Sheet...' : 'Save Daily Production Sheet',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ==================== SECTION 5: DAILY FACTORY SHEETS ARCHIVE & HISTORY ====================
              _buildArchiveSection(isMobile),
            ],
          ),
        );
      },
    );
  }

  // Left card: Machine Output
  Widget _buildLeftMetricsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Machine Output (Petti & Adappu Frames):',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _adappuCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Adappu Frames Fed (Machine Input)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _totalBoxesCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                                          labelText: 'Produced (Madippu)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          _autoMetricRow('Average Boxes / Frame (Avg Petti)', '${_avgBoxesPerFrame.toStringAsFixed(1)} Boxes'),
          _autoMetricRow('Gross Count (1 Gross = 144 Boxes)', '${_grossCount.toStringAsFixed(1)} Gross'),
          _autoMetricRow('Produced Bundles (1 Bdl = 600 Boxes)', '${_totalBundlesFromBoxes.toStringAsFixed(0)} Bundles', isHighlight: true),
        ],
      ),
    );
  }

  // Right card: Dipping Frame Stock Math
  Widget _buildRightDippingMathCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dipping Frame Balance Math (Frame Iruppu):',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _openingFramesCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Opening Frames (Aaramba Iruppu)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _dippingCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '+ Dipping Frames Today (Dipping Frame)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const Divider(height: 14),
          _autoMetricRow('= Total Dipped Frames (Moththam)', '${_totalDippedFrames.toStringAsFixed(0)} Frames', isHighlight: true),
          const Divider(height: 14),
          _autoMetricRow('- Adappu Frames Fed (Fed to Machine)', '${_adappuFrames.toStringAsFixed(0)} Frames'),
          const SizedBox(height: 4),
          _autoMetricRow('= Closing Balance Frames (Meedhi Iruppu)', '${_closingFrames.toStringAsFixed(0)} Frames', isSuccess: true),
        ],
      ),
    );
  }

  Widget _autoMetricRow(String label, String value, {bool isHighlight = false, bool isSuccess = false}) {
    Color bg = const Color(0xFFF1F5F9);
    Color fg = Colors.black87;
    if (isHighlight) {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF1D4ED8);
    } else if (isSuccess) {
      bg = const Color(0xFFECFDF5);
      fg = const Color(0xFF065F46);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _brandBundlePill(String brand, double bundles, Color color, {bool isTotal = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isTotal ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: isTotal ? 0.5 : 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(brand, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(
            '${bundles.toStringAsFixed(0)} Bundles',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }

  Widget _compactMetricPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          Text(value, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _tableHead(String text) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 11.5,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildArchiveSection(bool isMobile) {
    final sheets = widget.store.dailySheets;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.history_rounded,
                      color: Color(0xFF0F172A), size: 22),
                  SizedBox(width: 8),
                  Text(
              '5. Factory Daily Sheets Archive (History)',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${sheets.length} Recorded Sheets',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Chronological list of all daily factory production sheets saved in factory records. Admin can inspect, reload, or print past physical slips.',
            style: TextStyle(fontSize: 12.5, color: Colors.black54),
          ),
          const Divider(height: 20),
          if (sheets.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.folder_open_rounded,
                      size: 44, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  const Text(
                    'No saved factory sheets found yet.',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Once staff fills and saves today\'s sheet, it will appear here permanently.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            for (final s in sheets) _buildArchiveSheetCard(s),
        ],
      ),
    );
  }

  Widget _buildArchiveSheetCard(DailyProductionSheet s) {
    final isCurrent = s.date == _toIsoDate(_selectedDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? const Color(0xFF065F46) : Colors.grey.shade300,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${s.date} (${s.dayOfWeek})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'By ${s.recordedBy}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      color: Colors.black87,
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF065F46),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Currently Loaded',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF065F46),
                      side: const BorderSide(color: Color(0xFF065F46)),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => showDailyPaperSlipDialog(context, s),
                    icon: const Icon(Icons.print_rounded, size: 15),
                    label: const Text('Paper Slip'),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: isCurrent
                          ? Colors.grey.shade700
                          : const Color(0xFF065F46),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: isCurrent
                        ? null
                        : () {
                            _loadSheetData(s);
                            ScaffoldMessenger.of(context).showSnackBar(
  
                              SnackBar(
                                content: Text(
                                    'Loaded Daily Sheet for ${s.date} (${s.dayOfWeek})'),
                                duration: const Duration(seconds: 2),
                              ));
  
                          },
                    icon: const Icon(Icons.edit_note_rounded, size: 16),
                    label: const Text('Load Into Editor'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _compactBadge(
                  'Adappu', '${s.adappuFrames} Frames', Colors.blue.shade700),
              _compactBadge(
                  'Dipping', '+${s.dippingFrames} Frames', Colors.teal.shade700),
              _compactBadge(
                  'Closing', '${s.balanceFrames} Frames', Colors.green.shade700),
              _compactBadge(
                  'Boxes',
                  '${s.totalBoxes} Boxes (${s.grossCount.toStringAsFixed(1)} Gross)',
                  Colors.purple.shade700),
              _compactBadge('Produced', '${s.totalBundlesProduced} Bundles',
                  const Color(0xFFD97706),
                  bold: true),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final r in s.brandRows)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    '${r.brand} (${r.priceCategory}): +${r.producedBundles.toInt()} Bdl',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compactBadge(String label, String value, Color color,
      {bool bold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
