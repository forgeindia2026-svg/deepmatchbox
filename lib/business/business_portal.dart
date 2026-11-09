import 'package:flutter/material.dart';
import '../models/deeba_models.dart';
import '../screens/admin/admin_portal.dart';
import '../screens/salesman/salesman_portal.dart';
import '../state/deeba_store.dart';
import 'auth/login_screen.dart';

class BusinessPortal extends StatelessWidget {
  final DeebaStore store;
  final VoidCallback? onBackToCustomerWebsite;

  const BusinessPortal({
    super.key,
    required this.store,
    this.onBackToCustomerWebsite,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        // If logged in as Field Salesman, render Field Salesman Portal
        if (store.currentRole == UserRole.salesman) {
          return SalesmanPortal(
            store: store,
            onLogout: () => store.logout(),
          );
        }

        // If not logged in as Admin or Staff, display the Role-Based Login Screen
        if (store.currentRole != UserRole.admin &&
            store.currentRole != UserRole.staff) {
          return BusinessLoginScreen(
            store: store,
            onBackToCustomerWebsite: onBackToCustomerWebsite,
          );
        }

        // Authenticated as Admin or Staff -> Render Factory ERP
        return AdminStaffPortal(
          store: store,
          onSwitchRoleModal: () => store.logout(),
        );
      },
    );
  }
}
