import 'package:flutter/material.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

/// Cyberpunk Authentication Screen for Sign In, Registration & Quick Persona Testing
class AuthScreen extends StatefulWidget {
  final List<Map<String, dynamic>> availableRoles;
  final Future<bool> Function(String username, String passkey) onLogin;
  final Future<bool> Function({
    required String username,
    required String passkey,
    String? displayName,
    String? role,
  }) onRegister;

  const AuthScreen({
    super.key,
    required this.availableRoles,
    required this.onLogin,
    required this.onRegister,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sign In controllers
  final TextEditingController _loginUsernameController =
      TextEditingController(text: 'cyber_ren');
  final TextEditingController _loginPasskeyController =
      TextEditingController(text: 'neon_ren_2088');

  // Sign Up controllers
  final TextEditingController _regUsernameController = TextEditingController();
  final TextEditingController _regDisplayNameController = TextEditingController();
  final TextEditingController _regPasskeyController = TextEditingController();
  String _selectedRole = 'Creator / Photographer';

  bool _obscurePasskey = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedRoleKey = 'cyber_ren';

  final List<String> _roleOptions = [
    'Creator / Photographer',
    'Cyber Modder / Crypto Specialist',
    'Live Streamer / Audio DJ',
    'Marketplace Merchant / Brand Partner',
    'Consumer / Guest User',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginUsernameController.dispose();
    _loginPasskeyController.dispose();
    _regUsernameController.dispose();
    _regDisplayNameController.dispose();
    _regPasskeyController.dispose();
    super.dispose();
  }

  void _selectQuickRole(Map<String, dynamic> role) {
    setState(() {
      _selectedRoleKey = role['username'] as String?;
      _loginUsernameController.text = role['username'] as String? ?? '';
      _loginPasskeyController.text = role['passkey'] as String? ?? '';
      _errorMessage = null;
    });
  }

  Future<void> _handleLogin() async {
    final username = _loginUsernameController.text.trim();
    final passkey = _loginPasskeyController.text.trim();

    if (username.isEmpty || passkey.isEmpty) {
      setState(() => _errorMessage = 'Neural ID & Quantum Passkey required');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await widget.onLogin(username, passkey);
    if (!mounted) return;

    if (!success) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Handshake failed: Invalid credentials';
      });
    }
  }

  Future<void> _handleRegister() async {
    final username = _regUsernameController.text.trim();
    final displayName = _regDisplayNameController.text.trim();
    final passkey = _regPasskeyController.text.trim();

    if (username.isEmpty || passkey.isEmpty) {
      setState(() => _errorMessage = 'Handle and Passkey required');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await widget.onRegister(
      username: username,
      passkey: passkey,
      displayName: displayName.isNotEmpty ? displayName : username,
      role: _selectedRole,
    );

    if (!mounted) return;

    if (!success) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Registration rejected: Identity conflict';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgVoid,
      body: Stack(
        children: [
          // Background ambient gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.4),
                  radius: 1.2,
                  colors: [
                    Color(0x33FF2D78),
                    Color(0x1100FFCC),
                    CyberColors.bgVoid,
                  ],
                ),
              ),
            ),
          ),

          // Cyber CRT Scanline overlay effect
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.5, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main interactive auth card
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Logo
                      _buildHeader(),
                      const SizedBox(height: 24),

                      // Tabs (Sign In vs Register)
                      _buildTabBar(),
                      const SizedBox(height: 20),

                      // Error Banner
                      if (_errorMessage != null) ...[
                        _buildErrorBanner(_errorMessage!),
                        const SizedBox(height: 16),
                      ],

                      // Active Tab View
                      AnimatedSize(
                        duration: const Duration(milliseconds: 250),
                        child: _tabController.index == 0
                            ? _buildSignInForm()
                            : _buildRegisterForm(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'TOKYO',
              style: CyberTypography.titleLarge.copyWith(
                fontSize: 32,
                color: CyberColors.primaryHotPink,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    color: CyberColors.primaryHotPink.withValues(alpha: 0.8),
                    blurRadius: 16,
                  ),
                ],
              ),
            ),
            Text(
              '.GRAM',
              style: CyberTypography.titleLarge.copyWith(
                fontSize: 32,
                color: CyberColors.secondaryCyan,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    color: CyberColors.secondaryCyan.withValues(alpha: 0.8),
                    blurRadius: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: CyberColors.secondaryCyan,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: CyberColors.secondaryCyan, blurRadius: 6, spreadRadius: 1),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'NEURAL ACCESS TERMINAL // SEC_04',
              style: CyberTypography.hudHeader.copyWith(
                color: CyberColors.secondaryCyan,
                letterSpacing: 2,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: CyberColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CyberColors.borderSubtle),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() => _errorMessage = null),
        indicator: BoxDecoration(
          color: CyberColors.primaryHotPink.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: CyberColors.primaryHotPink),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: CyberColors.textSecondary,
        labelStyle: CyberTypography.bodyBold.copyWith(fontSize: 12),
        tabs: const [
          Tab(
            icon: Icon(Icons.login, size: 18),
            text: 'SIGN IN',
          ),
          Tab(
            icon: Icon(Icons.app_registration, size: 18),
            text: 'MINT IDENTITY',
          ),
        ],
      ),
    );
  }

  Widget _buildSignInForm() {
    final roles = widget.availableRoles.isNotEmpty
        ? widget.availableRoles
        : [
            {
              'username': 'cyber_ren',
              'passkey': 'neon_ren_2088',
              'role': 'Creator',
              'displayName': 'Ren Tanaka',
            },
            {
              'username': 'neon_kaito',
              'passkey': 'quantum_kaito_42',
              'role': 'Modder',
              'displayName': 'Kaito Vance',
            },
            {
              'username': 'kira_synth',
              'passkey': 'synth_kira_99',
              'role': 'Streamer',
              'displayName': 'Kira Oshiro',
            },
            {
              'username': 'neotech_admin',
              'passkey': 'neotech_drop_77',
              'role': 'Merchant',
              'displayName': 'NeoTech Corp',
            },
            {
              'username': 'anon_mesh',
              'passkey': 'guest_token_00',
              'role': 'Guest',
              'displayName': 'Anonymous Explorer',
            },
          ];

    return CyberCard(
      borderColor: CyberColors.secondaryCyan.withValues(alpha: 0.4),
      hasGlow: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Selector Banner
          Text(
            'QUICK-SELECT NEURAL ROLE (1-TAP FILL)',
            style: CyberTypography.hudHeader.copyWith(
              color: CyberColors.secondaryCyan,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),

          // Horizontal Role Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: roles.map((r) {
                final u = r['username'] as String? ?? '';
                final isSelected = _selectedRoleKey == u;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      '@$u',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: CyberColors.secondaryCyan,
                    backgroundColor: CyberColors.surfaceDark,
                    side: BorderSide(
                      color: isSelected ? CyberColors.secondaryCyan : CyberColors.borderSubtle,
                    ),
                    onSelected: (_) => _selectQuickRole(r),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: CyberColors.borderSubtle),
          const SizedBox(height: 14),

          // Username Field
          Text(
            'NEURAL IDENTIFIER / USERNAME',
            style: CyberTypography.hudCaption.copyWith(
              color: CyberColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _loginUsernameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.alternate_email, color: CyberColors.secondaryCyan, size: 20),
              hintText: 'Enter username (e.g. cyber_ren)',
              hintStyle: const TextStyle(color: CyberColors.textMuted),
              filled: true,
              fillColor: CyberColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CyberColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CyberColors.secondaryCyan, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Passkey Field
          Text(
            'QUANTUM PASSKEY',
            style: CyberTypography.hudCaption.copyWith(
              color: CyberColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _loginPasskeyController,
            obscureText: _obscurePasskey,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.key, color: CyberColors.primaryHotPink, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePasskey ? Icons.visibility_off : Icons.visibility,
                  color: CyberColors.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePasskey = !_obscurePasskey),
              ),
              hintText: 'Enter passkey (e.g. neon_ren_2088)',
              hintStyle: const TextStyle(color: CyberColors.textMuted),
              filled: true,
              fillColor: CyberColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CyberColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CyberColors.primaryHotPink, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: CyberColors.primaryHotPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 6,
                shadowColor: CyberColors.primaryHotPink.withValues(alpha: 0.6),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.hub, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'CONNECT TO NEURAL GRID',
                          style: CyberTypography.hudHeader.copyWith(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return CyberCard(
      borderColor: CyberColors.primaryHotPink.withValues(alpha: 0.4),
      hasGlow: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEW CYBER CITIZEN REGISTRATION',
            style: CyberTypography.hudHeader.copyWith(
              color: CyberColors.primaryHotPink,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Handle
          Text(
            'NEURAL HANDLE',
            style: CyberTypography.hudCaption.copyWith(
              color: CyberColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _regUsernameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.alternate_email, color: CyberColors.primaryHotPink, size: 20),
              hintText: 'e.g. synth_ghost_99',
              hintStyle: const TextStyle(color: CyberColors.textMuted),
              filled: true,
              fillColor: CyberColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CyberColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CyberColors.primaryHotPink, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Display Name
          Text(
            'DISPLAY NAME // AVATAR CODENAME',
            style: CyberTypography.hudCaption.copyWith(
              color: CyberColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _regDisplayNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person, color: CyberColors.secondaryCyan, size: 20),
              hintText: 'e.g. Zero Ghost // 幽霊',
              hintStyle: const TextStyle(color: CyberColors.textMuted),
              filled: true,
              fillColor: CyberColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CyberColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CyberColors.secondaryCyan, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Cyber Role Dropdown
          Text(
            'CYBER ROLE & DOMAIN',
            style: CyberTypography.hudCaption.copyWith(
              color: CyberColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: CyberColors.surfaceDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CyberColors.borderSubtle),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRole,
                isExpanded: true,
                dropdownColor: CyberColors.surfaceCard,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                icon: const Icon(Icons.arrow_drop_down, color: CyberColors.secondaryCyan),
                items: _roleOptions.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Passkey
          Text(
            'MINT QUANTUM PASSKEY',
            style: CyberTypography.hudCaption.copyWith(
              color: CyberColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _regPasskeyController,
            obscureText: _obscurePasskey,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.vpn_key, color: CyberColors.tertiaryYellow, size: 20),
              hintText: 'Choose passkey (min 6 characters)',
              hintStyle: const TextStyle(color: CyberColors.textMuted),
              filled: true,
              fillColor: CyberColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CyberColors.borderSubtle),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: CyberColors.tertiaryYellow, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Mint Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: CyberColors.secondaryCyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 6,
                shadowColor: CyberColors.secondaryCyan.withValues(alpha: 0.6),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flash_on, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'MINT NEURAL IDENTITY',
                          style: CyberTypography.hudHeader.copyWith(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x33FF2D78),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CyberColors.primaryHotPink),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: CyberColors.primaryHotPink, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
