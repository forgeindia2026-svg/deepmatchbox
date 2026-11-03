import 'package:flutter/material.dart';
import 'business/business_portal.dart';
import 'state/deeba_store.dart';

void main() {
  runApp(const DeebaBusinessApp());
}

class DeebaBusinessApp extends StatefulWidget {
  const DeebaBusinessApp({super.key});

  @override
  State<DeebaBusinessApp> createState() => _DeebaBusinessAppState();
}

class _DeebaBusinessAppState extends State<DeebaBusinessApp> {
  final DeebaStore _store = DeebaStore();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        return MaterialApp(
          title: 'Deeba Match House - Factory Operations & ERP',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF1F5F9),
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
          home: BusinessPortal(
            store: _store,
          ),
        );
      },
    );
  }
}

