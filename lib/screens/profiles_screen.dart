import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../models/filter_profile.dart';
import '../services/settings_service.dart';
import '../services/overlay_service.dart';

class ProfilesScreen extends StatefulWidget {
  final SettingsService settingsService;

  const ProfilesScreen({super.key, required this.settingsService});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  late List<FilterProfile> _profiles;

  @override
  void initState() {
    super.initState();
    _profiles = FilterProfile.defaultProfiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              const Text(
                'Default Profiles',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B95A2),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _profiles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _buildProfileCard(_profiles[index]),
                ),
              ),
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
          'Profiles',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(FilterProfile profile) {
    final isSelected =
        widget.settingsService.currentProfileId == profile.id;
    final previewColor = Color.fromARGB(
      profile.getAlpha().clamp(0, 255),
      profile.red,
      profile.green,
      profile.blue,
    );

    return GestureDetector(
      onTap: () async {
        if (isSelected) return;
        await widget.settingsService.setCurrentProfileId(profile.id);
        await widget.settingsService.setColorRed(profile.red);
        await widget.settingsService.setColorGreen(profile.green);
        await widget.settingsService.setColorBlue(profile.blue);
        await widget.settingsService.setIntensity(profile.intensity);
        await widget.settingsService.setDimLevel(profile.dimLevel);
        await widget.settingsService.setUsePixelFilter(profile.usePixelFilter);
        await widget.settingsService.setPixelFilterLevel(profile.pixelFilterLevel);

        if (widget.settingsService.isFilterActive) {
          final alpha = widget.settingsService.calculateAlpha(
            profile.intensity,
            profile.dimLevel,
          );
          await OverlayService.updateFilter(
            red: profile.red,
            green: profile.green,
            blue: profile.blue,
            alpha: alpha,
            usePixelFilter: profile.usePixelFilter,
            pixelFilterLevel: profile.pixelFilterLevel,
          );
        }
        setState(() {});
      },
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
        children: [
          // Color preview circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: previewColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFF6B35)
                    : Colors.white.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                        blurRadius: 12,
                      )
                    ]
                  : null,
            ),
            child: Icon(
              profile.icon,
              color: Colors.white.withValues(alpha: 0.9),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Profile info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFFCCD1D9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Intensity ${profile.intensity}% · Dim ${profile.dimLevel}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8B95A2),
                  ),
                ),
              ],
            ),
          ),
          // Selected indicator
          if (isSelected)
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFFB347)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              ),
            )
          else
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF8B95A2).withValues(alpha: 0.3),
                ),
              ),
            ),
        ],
      ),
    ),
    );
  }
}
