import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../services/settings_service.dart';
import '../services/overlay_service.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settingsService;

  const SettingsScreen({super.key, required this.settingsService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await OverlayService.checkPermission();
    if (mounted) setState(() => _hasPermission = hasPermission);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildPermissionCard(),
              const SizedBox(height: 20),
              _buildAboutCard(),
              const SizedBox(height: 20),
              _buildInfoCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F36).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF8B95A2),
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Permissions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B95A2),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildPermissionItem(
            icon: Icons.layers_rounded,
            title: 'Draw Over Other Apps',
            subtitle: _hasPermission ? 'Granted' : 'Required for screen filter',
            isGranted: _hasPermission,
            onTap: () async {
              if (!_hasPermission) {
                await OverlayService.requestPermission();
                await Future.delayed(const Duration(seconds: 1));
                await _checkPermission();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isGranted
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                  : const Color(0xFFFF6B35).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isGranted
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFFF6B35),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isGranted
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF8B95A2),
                  ),
                ),
              ],
            ),
          ),
          if (isGranted)
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF4CAF50), size: 22)
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFFB347)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Grant',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B95A2),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFFB347)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.brightness_4_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Extra Dim',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8B95A2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'A premium screen dimmer and blue light filter. '
            'Protect your eyes at night by filtering blue light and dimming '
            'your screen below the normal minimum brightness.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF8B95A2),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How It Works',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B95A2),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            Icons.visibility_off_rounded,
            'Blue Light Filter',
            'Draws a warm color overlay to reduce blue light emission from your screen.',
          ),
          const SizedBox(height: 14),
          _buildInfoItem(
            Icons.brightness_low_rounded,
            'Extra Dimming',
            'Reduces brightness below the system minimum, perfect for dark rooms.',
          ),
          const SizedBox(height: 14),
          _buildInfoItem(
            Icons.grid_view_rounded,
            'Pixel Filter (OLED)',
            'Turns off individual pixels in a checkerboard pattern to dim without tinting, preserving normal colors and saving battery.',
          ),
          const SizedBox(height: 14),
          _buildInfoItem(
            Icons.schedule_rounded,
            'Smart Schedule',
            'Automatically activates at your preferred times or at sunset.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF252A40),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFFFB347), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8B95A2),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
