import 'package:flutter/material.dart';
import '../../models/deeba_models.dart';
import '../../state/deeba_store.dart';

class StaffAccountsManagerView extends StatefulWidget {
  final DeebaStore store;

  const StaffAccountsManagerView({super.key, required this.store});

  @override
  State<StaffAccountsManagerView> createState() =>
      _StaffAccountsManagerViewState();
}

class _StaffAccountsManagerViewState extends State<StaffAccountsManagerView> {
  String _search = '';
  String _filterRole = 'all'; // all, staff, admin
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  Future<void> _refreshUsers() async {
    setState(() => _isLoading = true);
    await widget.store.reloadUsers();
    if (mounted) setState(() => _isLoading = false);
  }

  void _showAddUserDialog() {
    final formKey = GlobalKey<FormState>();
    final usernameCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final designationCtrl = TextEditingController();
    final passwordCtrl = TextEditingController(text: 'staff123');
    String selectedRole = 'staff';
    bool obscure = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_add_alt_1_rounded,
                    color: Color(0xFF0F766E), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Add New Staff Login',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: usernameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Username * (lowercase)',
                        hintText: 'e.g. suresh, murugan',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Username is required';
                        }
                        if (val.trim().contains(' ')) {
                          return 'Username cannot have spaces';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        hintText: 'e.g. Suresh (Packing Head)',
                        prefixIcon: Icon(Icons.badge_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Full name is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Role *',
                              prefixIcon: Icon(Icons.admin_panel_settings_rounded),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'staff',
                                child: Text('Staff (Factory Floor)'),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('Admin (Full Access)'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setDlgState(() => selectedRole = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Mobile Number',
                              hintText: '10-digit mobile',
                              prefixIcon: Icon(Icons.phone_rounded),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: designationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Designation / Department',
                        hintText: 'e.g. Floor Supervisor, Mixing Master',
                        prefixIcon: Icon(Icons.work_outline_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordCtrl,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: 'Initial Password *',
                        hintText: 'Minimum 4 characters',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () =>
                              setDlgState(() => obscure = !obscure),
                        ),
                      ),
                      validator: (val) => val == null || val.trim().length < 4
                          ? 'Password must be at least 4 characters'
                          : null,
                    ),
                  ],
                ),
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
                backgroundColor: const Color(0xFF0F766E),
              ),
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx);
                  final res = await widget.store.addSystemUser({
                    'username': usernameCtrl.text.trim().toLowerCase(),
                    'name': nameCtrl.text.trim(),
                    'role': selectedRole,
                    'phone': phoneCtrl.text.trim(),
                    'designation': designationCtrl.text.trim(),
                    'password': passwordCtrl.text.trim(),
                    'active': true,
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: res['success'] == true
                            ? const Color(0xFF065F46)
                            : Colors.red.shade800,
                        content: Text(res['message'] ?? 'Account created!'),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(UserModel user) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);
    final designationCtrl = TextEditingController(text: user.designation);
    final newPasswordCtrl = TextEditingController();
    String selectedRole = user.role;
    bool isActive = user.active;
    bool obscure = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.manage_accounts_rounded,
                    color: Color(0xFF1D4ED8), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Edit Staff: @${user.username}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        prefixIcon: Icon(Icons.badge_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Full name is required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'Role',
                              prefixIcon: Icon(Icons.admin_panel_settings_rounded),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'staff',
                                child: Text('Staff'),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('Admin'),
                              ),
                            ],
                            onChanged: user.username == 'admin'
                                ? null // Cannot change default admin role
                                : (val) {
                                    if (val != null) {
                                      setDlgState(() => selectedRole = val);
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Mobile Number',
                              prefixIcon: Icon(Icons.phone_rounded),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: designationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Designation / Department',
                        prefixIcon: Icon(Icons.work_outline_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: newPasswordCtrl,
                      obscureText: obscure,
                      decoration: InputDecoration(
                        labelText: 'Reset Password (optional)',
                        hintText: 'Leave empty to keep current password',
                        prefixIcon: const Icon(Icons.lock_reset_rounded),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () =>
                              setDlgState(() => obscure = !obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Account Active Status',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        isActive
                            ? 'User can log in to factory portal'
                            : 'Login blocked (deactivated)',
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: isActive,
                      onChanged: user.username == 'admin'
                          ? null // Cannot deactivate primary admin
                          : (val) => setDlgState(() => isActive = val),
                    ),
                  ],
                ),
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
                backgroundColor: const Color(0xFF1D4ED8),
              ),
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx);
                  final updates = <String, dynamic>{
                    'name': nameCtrl.text.trim(),
                    'role': selectedRole,
                    'phone': phoneCtrl.text.trim(),
                    'designation': designationCtrl.text.trim(),
                    'active': isActive,
                  };
                  if (newPasswordCtrl.text.trim().isNotEmpty) {
                    updates['password'] = newPasswordCtrl.text.trim();
                  }

                  final res = await widget.store.updateSystemUser(user.id, updates);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: res['success'] == true
                            ? const Color(0xFF065F46)
                            : Colors.red.shade800,
                        content: Text(res['message'] ?? 'User updated!'),
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteUser(UserModel user) {
    if (user.username == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Cannot delete the primary admin account!'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Staff: ${user.name}?'),
        content: Text(
          'Are you sure you want to delete @${user.username}? This will remove their login access completely.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await widget.store.deleteSystemUser(user.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: ok ? Colors.black87 : Colors.red,
                    content: Text(ok
                        ? 'Staff account @${user.username} deleted.'
                        : 'Failed to delete user.'),
                  ),
                );
              }
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final users = widget.store.systemUsers;

    // Filter
    final filtered = users.where((u) {
      final matchesRole = _filterRole == 'all' || u.role.toLowerCase() == _filterRole;
      final q = _search.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          u.username.toLowerCase().contains(q) ||
          u.name.toLowerCase().contains(q) ||
          u.phone.contains(q) ||
          u.designation.toLowerCase().contains(q);
      return matchesRole && matchesSearch;
    }).toList();

    final totalStaff = users.where((u) => u.isStaff).length;
    final totalAdmin = users.where((u) => u.isAdmin).length;
    final totalActive = users.where((u) => u.active).length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E).withAlpha(128),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.manage_accounts_rounded,
                          color: Color(0xFF5EEAD4), size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Staff & System User Accounts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Create & manage separate login credentials for factory floor supervisors, store in-charges, and admin.',
                            style: TextStyle(color: Colors.white70, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onPressed: _showAddUserDialog,
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                      label: const Text('Add Staff Login',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      onPressed: _refreshUsers,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Refresh'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFDE047),
                        side: const BorderSide(color: Color(0xFFFDE047)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      onPressed: () => showChangePasswordDialog(
                          context, widget.store),
                      icon: const Icon(Icons.key_rounded, size: 18),
                      label: const Text('Change My Password'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // KPI Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Users',
                  users.length.toString(),
                  Icons.people_alt_rounded,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Staff Logins',
                  totalStaff.toString(),
                  Icons.engineering_rounded,
                  const Color(0xFF0F766E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Admin Accounts',
                  totalAdmin.toString(),
                  Icons.shield_rounded,
                  const Color(0xFFB91C1C),
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Active Now',
                    totalActive.toString(),
                    Icons.check_circle_rounded,
                    const Color(0xFF065F46),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),

          // Search and Filters
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search staff by name, username, phone...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (val) => setState(() => _search = val),
                  ),
                ),
                const SizedBox(width: 12),
                Wrap(
                  spacing: 6,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _filterRole == 'all',
                      onSelected: (_) => setState(() => _filterRole = 'all'),
                    ),
                    ChoiceChip(
                      label: const Text('Staff'),
                      selected: _filterRole == 'staff',
                      onSelected: (_) => setState(() => _filterRole = 'staff'),
                    ),
                    ChoiceChip(
                      label: const Text('Admin'),
                      selected: _filterRole == 'admin',
                      onSelected: (_) => setState(() => _filterRole = 'admin'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // User Cards List
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (filtered.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.person_off_rounded,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'No staff accounts found',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap "+ Add Staff Login" above to create separate logins for supervisors.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final u = filtered[idx];
                return _buildUserCard(u, isMobile);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel u, bool isMobile) {
    final isAdmin = u.isAdmin;
    final primaryColor = isAdmin ? const Color(0xFFB91C1C) : const Color(0xFF0F766E);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: u.active ? Colors.grey.shade200 : Colors.red.shade100,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: primaryColor.withAlpha(30),
            child: Icon(
              isAdmin ? Icons.shield_rounded : Icons.person_rounded,
              color: primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        u.name,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        u.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (!u.active)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'BLOCKED',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text(
                      '@${u.username}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    if (u.designation.isNotEmpty)
                      Text(
                        '| ${u.designation}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    if (u.phone.isNotEmpty)
                      Text(
                        '| Ph: ${u.phone}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit Details / Reset Password',
                icon: const Icon(Icons.edit_note_rounded, size: 22),
                color: Colors.blue.shade700,
                onPressed: () => _showEditUserDialog(u),
              ),
              if (u.username != 'admin')
                IconButton(
                  tooltip: 'Delete Account',
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: Colors.red.shade600,
                  onPressed: () => _confirmDeleteUser(u),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// Reusable Change Password Dialog for Admin or Staff
void showChangePasswordDialog(BuildContext context, DeebaStore store) {
  final formKey = GlobalKey<FormState>();
  final oldPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();
  bool obscureOld = true;
  bool obscureNew = true;
  bool isSaving = false;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDlgState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.key_rounded,
                  color: Color(0xFFD97706), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Change Password',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(
                    'Logged in as @${store.loggedInUserUsername}',
                    style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldPassCtrl,
                  obscureText: obscureOld,
                  decoration: InputDecoration(
                    labelText: 'Current Password *',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_open_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(obscureOld
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setDlgState(() => obscureOld = !obscureOld),
                    ),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Current password is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newPassCtrl,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password *',
                    hintText: 'Minimum 4 characters',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setDlgState(() => obscureNew = !obscureNew),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().length < 4) {
                      return 'New password must be at least 4 characters';
                    }
                    if (val.trim() == oldPassCtrl.text.trim()) {
                      return 'New password cannot be the same as old';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPassCtrl,
                  obscureText: obscureNew,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.check_circle_outline_rounded),
                  ),
                  validator: (val) {
                    if (val == null || val.trim() != newPassCtrl.text.trim()) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: isSaving ? null : () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF065F46),
            ),
            onPressed: isSaving
                ? null
                : () async {
                    if (formKey.currentState?.validate() ?? false) {
                      final messenger = ScaffoldMessenger.of(context);
                      setDlgState(() => isSaving = true);
                      final res = await store.changeMyPassword(
                        oldPassword: oldPassCtrl.text.trim(),
                        newPassword: newPassCtrl.text.trim(),
                      );
                      setDlgState(() => isSaving = false);
                      if (ctx.mounted) Navigator.pop(ctx);

                      messenger.showSnackBar(
                        SnackBar(
                          backgroundColor: res['success'] == true
                              ? const Color(0xFF065F46)
                              : Colors.red.shade800,
                          content: Text(
                              res['message'] ?? 'Password update complete.'),
                        ),
                      );
                    }
                  },
            icon: isSaving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save_rounded, size: 16),
            label: const Text('Update Password'),
          ),
        ],
      ),
    ),
  );
}
