import 'package:flutter/material.dart';
import '../core/cyber_colors.dart';
import '../core/cyber_typography.dart';
import '../core/cyber_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final Map<String, dynamic> initialSettings;
  final ValueChanged<Map<String, dynamic>> onUpdateSettings;
  final VoidCallback onBack;
  final VoidCallback? onLogout;

  const SettingsScreen({
    super.key,
    required this.initialSettings,
    required this.onUpdateSettings,
    required this.onBack,
    this.onLogout,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isPrivateAccount;
  late bool _quantumEncryption;
  late bool _hologramPreview;
  late bool _biometricAuth;
  late bool _hapticFeedback;
  late bool _stealthMode;
  late String _opticsMode;

  @override
  void initState() {
    super.initState();
    _isPrivateAccount = widget.initialSettings['isPrivateAccount'] as bool? ?? false;
    _quantumEncryption = widget.initialSettings['quantumEncryption'] as bool? ?? true;
    _hologramPreview = widget.initialSettings['hologramPreview'] as bool? ?? true;
    _biometricAuth = widget.initialSettings['biometricAuth'] as bool? ?? true;
    _hapticFeedback = widget.initialSettings['hapticFeedback'] as bool? ?? true;
    _stealthMode = widget.initialSettings['stealthMode'] as bool? ?? false;
    _opticsMode = widget.initialSettings['cyberOpticsMode'] as String? ?? 'Neon Vivid';
  }

  void _syncSettings() {
    widget.onUpdateSettings({
      'isPrivateAccount': _isPrivateAccount,
      'quantumEncryption': _quantumEncryption,
      'hologramPreview': _hologramPreview,
      'biometricAuth': _biometricAuth,
      'hapticFeedback': _hapticFeedback,
      'stealthMode': _stealthMode,
      'cyberOpticsMode': _opticsMode,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberColors.bgVoid,
      appBar: AppBar(
        backgroundColor: CyberColors.bgVoid,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: Text(
          'SETTINGS & NEURAL LINK',
          style: CyberTypography.hudHeader.copyWith(color: Colors.white, fontSize: 15),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: CYBER OPTICS & DISPLAY
          Text('CYBER OPTICS & DISPLAY', style: CyberTypography.hudCaption.copyWith(letterSpacing: 1.5)),
          const SizedBox(height: 8),
          CyberCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _opticsMode,
                isExpanded: true,
                dropdownColor: CyberColors.surfaceModal,
                icon: const Icon(Icons.arrow_drop_down, color: CyberColors.secondaryCyan),
                items: ['Neon Vivid', 'High Contrast Cyber', 'Monochrome 2088'].map((mode) {
                  return DropdownMenuItem<String>(
                    value: mode,
                    child: Text(mode, style: CyberTypography.bodyMedium),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _opticsMode = val);
                    _syncSettings();
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Section: SECURITY & QUANTUM MESH
          Text('SECURITY & QUANTUM MESH', style: CyberTypography.hudCaption.copyWith(letterSpacing: 1.5)),
          const SizedBox(height: 8),
          CyberCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSwitchTile(
                  title: 'Quantum End-to-End Encryption',
                  subtitle: '256-bit cryptographic neural key for DMs',
                  value: _quantumEncryption,
                  onChanged: (v) {
                    setState(() => _quantumEncryption = v);
                    _syncSettings();
                  },
                ),
                const Divider(color: CyberColors.borderSubtle, height: 1),
                _buildSwitchTile(
                  title: 'Biometric Neural ID',
                  subtitle: 'Require biometric scan to open vault',
                  value: _biometricAuth,
                  onChanged: (v) {
                    setState(() => _biometricAuth = v);
                    _syncSettings();
                  },
                ),
                const Divider(color: CyberColors.borderSubtle, height: 1),
                _buildSwitchTile(
                  title: 'Stealth Cloak Mode',
                  subtitle: 'Hide active signal from Neo-Tokyo live grid',
                  value: _stealthMode,
                  onChanged: (v) {
                    setState(() => _stealthMode = v);
                    _syncSettings();
                  },
                ),
                const Divider(color: CyberColors.borderSubtle, height: 1),
                _buildSwitchTile(
                  title: 'Private Account Node',
                  subtitle: 'When private, only approved nodes can decrypt your feed & stories',
                  value: _isPrivateAccount,
                  onChanged: (v) {
                    setState(() => _isPrivateAccount = v);
                    _syncSettings();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section: INTERACTION & HAPTICS
          Text('INTERACTION & SENSORS', style: CyberTypography.hudCaption.copyWith(letterSpacing: 1.5)),
          const SizedBox(height: 8),
          CyberCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSwitchTile(
                  title: '3D Hologram Spatial Preview',
                  subtitle: 'Render AR depth coordinates on feed media',
                  value: _hologramPreview,
                  onChanged: (v) {
                    setState(() => _hologramPreview = v);
                    _syncSettings();
                  },
                ),
                const Divider(color: CyberColors.borderSubtle, height: 1),
                _buildSwitchTile(
                  title: 'Neural Haptic Feedback',
                  subtitle: 'Vibrate on double-tap likes and comments',
                  value: _hapticFeedback,
                  onChanged: (v) {
                    setState(() => _hapticFeedback = v);
                    _syncSettings();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Disconnect / Logout
          CyberButton(
            label: 'DISCONNECT NEURAL SESSION (SIGN OUT)',
            isOutlined: true,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: CyberColors.surfaceModal,
                  content: Text('Neural session disconnected. Returning to access terminal.'),
                ),
              );
              widget.onLogout?.call();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: SwitchListTile(
        activeThumbColor: CyberColors.secondaryCyan,
        activeTrackColor: CyberColors.secondaryCyan.withValues(alpha: 0.4),
        title: Text(title, style: CyberTypography.bodyBold.copyWith(fontSize: 13)),
        subtitle: Text(subtitle, style: CyberTypography.bodySecondary.copyWith(fontSize: 11)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
