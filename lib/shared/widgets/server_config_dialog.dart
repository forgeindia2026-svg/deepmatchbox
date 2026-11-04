import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../state/deeba_store.dart';

void showServerConfigDialog(BuildContext context, DeebaStore store) {
  final urlCtrl = TextEditingController(text: store.api.baseUrl);
  bool isTesting = false;
  String? testResultMsg;
  bool? isSuccess;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.dns_rounded, color: Color(0xFFB91C1C)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Server Connection & IP Settings',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configure the Spring Boot REST API address for this device (PC Browser, Mobile App, or Tablet):',
                  style: TextStyle(fontSize: 12.5, color: Colors.black87),
                ),
                const SizedBox(height: 14),

                // Quick Presets
                const Text(
                  'Quick Presets:',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.cloud_done_rounded, size: 14, color: Colors.green),
                      label: const Text('Cloud Live (Render)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      backgroundColor: Colors.green.shade50,
                      onPressed: () {
                        setDialogState(() {
                          urlCtrl.text = ApiService.defaultLiveCloudUrl;
                          testResultMsg = null;
                        });
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.laptop_chromebook_rounded, size: 14),
                      label: const Text('PC Localhost'),
                      onPressed: () {
                        setDialogState(() {
                          urlCtrl.text = ApiService.defaultLocalhostUrl;
                          testResultMsg = null;
                        });
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.wifi_rounded, size: 14),
                      label: const Text('Factory Wi-Fi (192.168.1.170)'),
                      onPressed: () {
                        setDialogState(() {
                          urlCtrl.text = ApiService.defaultLanBaseUrl;
                          testResultMsg = null;
                        });
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.phone_android_rounded, size: 14),
                      label: const Text('Android Emulator (10.0.2.2)'),
                      onPressed: () {
                        setDialogState(() {
                          urlCtrl.text = ApiService.defaultEmulatorBaseUrl;
                          testResultMsg = null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // URL Text Field
                TextField(
                  controller: urlCtrl,
                  decoration: InputDecoration(
                    labelText: 'API Base URL',
                    hintText: 'https://deepmatchbox.onrender.com/api/v1',
                    prefixIcon: const Icon(Icons.link_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),

                // Test Feedback Banner
                if (testResultMsg != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSuccess == true
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSuccess == true
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSuccess == true
                              ? Icons.check_circle_rounded
                              : Icons.error_outline_rounded,
                          color: isSuccess == true ? Colors.green : Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            testResultMsg!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSuccess == true
                                  ? Colors.green.shade900
                                  : Colors.red.shade900,
                              fontWeight: FontWeight.w600,
                            ),
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
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
            ),
            onPressed: isTesting
                ? null
                : () async {
                    setDialogState(() {
                      isTesting = true;
                      testResultMsg = null;
                    });
                    final ok = await store.updateServerUrl(urlCtrl.text);
                    setDialogState(() {
                      isTesting = false;
                      isSuccess = ok;
                      if (ok) {
                        testResultMsg =
                            'Connected successfully! Cloud Database is Online.';
                      } else {
                        testResultMsg =
                            'Connection failed. Check IP address, port 8080, and ensure PC Wi-Fi is reachable.';
                      }
                    });
                    if (ok) {
                      await Future.delayed(const Duration(milliseconds: 600));
                      if (ctx.mounted) Navigator.pop(ctx);
                    }
                  },
            icon: isTesting
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.check_rounded, size: 16),
            label: Text(isTesting ? 'Connecting...' : 'Test & Save IP'),
          ),
        ],
      ),
    ),
  );
}

