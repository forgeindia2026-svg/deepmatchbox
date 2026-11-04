import 'package:flutter/material.dart';
import '../../shared/widgets/server_config_dialog.dart';
import '../../state/deeba_store.dart';

class BusinessLoginScreen extends StatefulWidget {
  final DeebaStore store;
  final VoidCallback? onBackToCustomerWebsite;

  const BusinessLoginScreen({
    super.key,
    required this.store,
    this.onBackToCustomerWebsite,
  });

  @override
  State<BusinessLoginScreen> createState() => _BusinessLoginScreenState();
}

class _BusinessLoginScreenState extends State<BusinessLoginScreen> {
  int _selectedRoleTab = 0; // 0 = Admin, 1 = Staff
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController(text: 'admin');
    _passwordCtrl = TextEditingController(text: 'admin123');
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onRoleTabChanged(int index) {
    setState(() {
      _selectedRoleTab = index;
      _errorMessage = null;
      if (index == 0) {
        _usernameCtrl.text = 'admin';
        _passwordCtrl.text = 'admin123';
      } else {
        _usernameCtrl.text = 'staff';
        _passwordCtrl.text = 'staff123';
      }
    });
  }

  Future<void> _attemptLogin() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both username and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await widget.store.loginOnline(username, password);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = (result['message'] != null &&
                result['message'].toString().isNotEmpty)
            ? result['message'].toString()
            : 'Invalid username or password. Check credentials or connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top Row: Back button + Cloud Status Badge with Settings Tap
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.onBackToCustomerWebsite != null)
                        TextButton.icon(
                          onPressed: widget.onBackToCustomerWebsite,
                          icon: const Icon(Icons.arrow_back_rounded,
                              size: 16, color: Colors.white70),
                          label: const Text(
                            'Customer Website',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () =>
                            showServerConfigDialog(context, widget.store),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: widget.store.isApiConnected
                                ? const Color(0xFF065F46)
                                : const Color(0xFF991B1B),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.store.isApiConnected
                                    ? Icons.cloud_done_rounded
                                    : Icons.cloud_off_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.store.isApiConnected
                                    ? 'Cloud Online'
                                    : 'Server Settings',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(Icons.settings_outlined,
                                  size: 11, color: Colors.white70),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Brand Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB91C1C), Color(0xFF7F1D1D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(38),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_fire_department_rounded,
                            size: 38,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'DEEBA MATCH HOUSE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Factory ERP & Operations Portal',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main Login Form Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobile ? 20 : 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 25,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Select Login Role',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Role Selector Tabs (Admin vs Staff)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => _onRoleTabChanged(0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 11),
                                    decoration: BoxDecoration(
                                      color: _selectedRoleTab == 0
                                          ? const Color(0xFFB91C1C)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: _selectedRoleTab == 0
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFFB91C1C)
                                                    .withAlpha(76),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.security_rounded,
                                          size: 18,
                                          color: _selectedRoleTab == 0
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Admin',
                                          style: TextStyle(
                                            color: _selectedRoleTab == 0
                                                ? Colors.white
                                                : Colors.black87,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () => _onRoleTabChanged(1),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 11),
                                    decoration: BoxDecoration(
                                      color: _selectedRoleTab == 1
                                          ? const Color(0xFF0F766E)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: _selectedRoleTab == 1
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF0F766E)
                                                    .withAlpha(76),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.engineering_rounded,
                                          size: 18,
                                          color: _selectedRoleTab == 1
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Staff / Floor',
                                          style: TextStyle(
                                            color: _selectedRoleTab == 1
                                                ? Colors.white
                                                : Colors.black87,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Role Description Banner
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _selectedRoleTab == 0
                                ? Colors.red.shade50
                                : Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedRoleTab == 0
                                  ? Colors.red.shade100
                                  : Colors.teal.shade100,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _selectedRoleTab == 0
                                    ? Icons.admin_panel_settings_rounded
                                    : Icons.badge_rounded,
                                color: _selectedRoleTab == 0
                                    ? Colors.red.shade700
                                    : Colors.teal.shade700,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _selectedRoleTab == 0
                                      ? 'Owner / Executive: Full access to Dashboard, Financial Reports, Salary Payouts, Sheet Approval & All Dispatches.'
                                      : 'Floor Supervisor: Focused access to Today\'s Paper Slip, Raw Material Inward, Production Entry, Attendance & Stock.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedRoleTab == 0
                                        ? Colors.red.shade900
                                        : Colors.teal.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Username Field
                        TextField(
                          controller: _usernameCtrl,
                          decoration: InputDecoration(
                            labelText: 'Username or Email',
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Password Field
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          onSubmitted: (_) => _attemptLogin(),
                        ),
                        const SizedBox(height: 12),

                        // Error message if any
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    size: 16, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Login Button
                        SizedBox(
                          height: 50,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: _selectedRoleTab == 0
                                  ? const Color(0xFFB91C1C)
                                  : const Color(0xFF0F766E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : _attemptLogin,
                            child: _isLoading
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Logging in...',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Login to Portal',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_rounded,
                                          size: 18),
                                    ],
                                  ),
                          ),
                        ),
                        if (_isLoading) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Connecting to Cloud API... Please wait a few seconds.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),

                        // Quick 1-Click Fill Helpers (for easy testing)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Quick Test Fill: ',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black45),
                            ),
                            InkWell(
                              onTap: () {
                                _onRoleTabChanged(0);
                                _attemptLogin();
                              },
                              child: const Text(
                                'Admin (Owner)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB91C1C),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const Text('  •  ',
                                style: TextStyle(color: Colors.black26)),
                            InkWell(
                              onTap: () {
                                _onRoleTabChanged(1);
                                _attemptLogin();
                              },
                              child: const Text(
                                'Staff (Ramesh)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F766E),
                                  decoration: TextDecoration.underline,
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
          ),
        ),
      ),
    );
  }
}
