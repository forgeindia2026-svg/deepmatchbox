import 'package:flutter/material.dart';
import 'screens/customer/customer_portal.dart';
import 'state/deeba_store.dart';

void main() {
  runApp(const DeebaCustomerApp());
}

class DeebaCustomerApp extends StatefulWidget {
  const DeebaCustomerApp({super.key});

  @override
  State<DeebaCustomerApp> createState() => _DeebaCustomerAppState();
}

class _DeebaCustomerAppState extends State<DeebaCustomerApp> {
  final DeebaStore _store = DeebaStore();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        return MaterialApp(
          title: 'Deeba Match House - Premium Safety Matches',
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
          home: CustomerPortal(
            store: _store,
          ),
        );
      },
    );
  }
}

