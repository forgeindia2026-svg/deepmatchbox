import 'package:flutter/material.dart';
import 'business/business_portal.dart';
import 'models/deeba_models.dart';
import 'screens/customer/customer_portal.dart';
import 'state/deeba_store.dart';

void main() {
  runApp(const DeebaMatchHouseApp());
}

class DeebaMatchHouseApp extends StatefulWidget {
  const DeebaMatchHouseApp({super.key});

  @override
  State<DeebaMatchHouseApp> createState() => _DeebaMatchHouseAppState();
}

class _DeebaMatchHouseAppState extends State<DeebaMatchHouseApp> {
  final DeebaStore _store = DeebaStore();
  bool _isMobilePreviewFrame = false;
  bool _showBusinessPortal = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        return MaterialApp(
          title: 'Deeba Match House - Digital Management System',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFB91C1C),
              primary: const Color(0xFFB91C1C),
              secondary: const Color(0xFFD97706),
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          home: Builder(
            builder: (innerContext) {
              final bool isBusinessMode = _showBusinessPortal ||
                  _store.currentRole == UserRole.admin ||
                  _store.currentRole == UserRole.staff;

              final Widget activePortal = isBusinessMode
                  ? BusinessPortal(
                      store: _store,
                      onBackToCustomerWebsite: () {
                        _store.logout();
                        setState(() => _showBusinessPortal = false);
                      },
                    )
                  : CustomerPortal(
                      store: _store,
                      onOpenLoginModal: () =>
                          setState(() => _showBusinessPortal = true),
                    );

              if (_isMobilePreviewFrame) {
                return _buildPhoneFrameWrapper(innerContext, activePortal);
              }

              return Stack(
                children: [
                  activePortal,
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: Material(
                      elevation: 8,
                      shadowColor: Colors.black38,
                      borderRadius: BorderRadius.circular(30),
                      color: const Color(0xFF0F172A),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () =>
                            setState(() => _isMobilePreviewFrame = true),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone_android_rounded,
                                color: Colors.amber.shade400,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Mobile App Preview',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPhoneFrameWrapper(BuildContext context, Widget child) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Column(
        children: [
          // Top Simulator Bar (contains Role Switcher + Back to Website View button)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(
                bottom: BorderSide(color: Colors.white12),
              ),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.smartphone_rounded,
                      color: Colors.amber.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'DEEBA MOBILE APP PREVIEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _store.loadLiveFromBackend(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _store.isApiConnected
                              ? const Color(0xFF065F46)
                              : const Color(0xFF991B1B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _store.isApiConnected
                                  ? Icons.cloud_done_rounded
                                  : Icons.cloud_off_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _store.isApiConnected
                                  ? 'Live MongoDB'
                                  : 'Offline Mode',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _simRolePill(UserRole.customer, 'Customer App'),
                    _simRolePill(UserRole.admin, 'Admin App'),
                    _simRolePill(UserRole.staff, 'Staff App'),
                  ],
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amber.shade400,
                    foregroundColor: const Color(0xFF0F172A),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () =>
                      setState(() => _isMobilePreviewFrame = false),
                  icon: const Icon(Icons.desktop_windows_rounded, size: 16),
                  label: const Text(
                    'Full Website View',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final phoneHeight =
                    (constraints.maxHeight - 24).clamp(480.0, 840.0);
                const phoneWidth = 390.0;

                return Center(
                  child: Container(
                    width: phoneWidth + 16,
                    height: phoneHeight,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(38),
                      border: Border.all(
                        color: const Color(0xFF334155),
                        width: 8,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 30,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          size: Size(phoneWidth, phoneHeight - 16),
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                        ),
                        child: child,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _simRolePill(UserRole role, String label) {
    final selected = _store.currentRole == role;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? const Color(0xFF0F172A) : Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      selected: selected,
      selectedColor: Colors.amber.shade400,
      backgroundColor: const Color(0xFF334155),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      onSelected: (_) {
        if (role == UserRole.customer) {
          _store.logout();
          setState(() => _showBusinessPortal = false);
        } else {
          _store.switchRole(role);
          setState(() => _showBusinessPortal = true);
        }
      },
    );
  }

}
