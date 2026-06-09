import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/dimmer_dial.dart';
import '../widgets/gradient_slider.dart';
import '../widgets/animated_toggle.dart';
import '../widgets/profile_chip.dart';
import '../models/filter_profile.dart';
import '../services/overlay_service.dart';
import '../services/settings_service.dart';
import 'schedule_screen.dart';
import 'profiles_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final SettingsService settingsService;

  const HomeScreen({super.key, required this.settingsService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isFilterActive = false;
  bool _hasPermission = false;
  String _currentProfileId = 'default_candle';
  int _dimLevel = 20;
  int _intensity = 40;
  int _colorRed = 255;
  int _colorGreen = 120;
  int _colorBlue = 0;
  bool _usePixelFilter = false;
  int _pixelFilterLevel = 0;
  List<FilterProfile> _profiles = const [];
  late AnimationController _pulseController;

  SettingsService get _settings => widget.settingsService;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkPermission();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    _isFilterActive = _settings.isFilterActive;
    _currentProfileId = _settings.currentProfileId;
    _dimLevel = _settings.dimLevel;
    _intensity = _settings.intensity;
    _colorRed = _settings.colorRed;
    _colorGreen = _settings.colorGreen;
    _colorBlue = _settings.colorBlue;
    _usePixelFilter = _settings.usePixelFilter;
    _pixelFilterLevel = _settings.pixelFilterLevel;
    _profiles = FilterProfile.defaultProfiles;
  }

  Future<void> _checkPermission() async {
    final hasPermission = await OverlayService.checkPermission();
    if (mounted) {
      setState(() => _hasPermission = hasPermission);
    }
    if (hasPermission) {
      final isRunning = await OverlayService.checkIsRunning();
      if (mounted) {
        setState(() => _isFilterActive = isRunning);
      }
    }
  }

  Future<void> _toggleFilter() async {
    if (!_hasPermission) {
      await _requestPermission();
      return;
    }

    if (_isFilterActive) {
      await OverlayService.stopOverlay();
      setState(() => _isFilterActive = false);
      await _settings.setFilterActive(false);
    } else {
      final alpha = _settings.calculateAlpha(_intensity, _dimLevel);
      await OverlayService.startOverlay(
        red: _colorRed,
        green: _colorGreen,
        blue: _colorBlue,
        alpha: alpha,
        usePixelFilter: _usePixelFilter,
        pixelFilterLevel: _pixelFilterLevel,
      );
      setState(() => _isFilterActive = true);
      await _settings.setFilterActive(true);
    }
  }

  Future<void> _requestPermission() async {
    await OverlayService.requestPermission();
    // Check again after returning from settings
    await Future.delayed(const Duration(seconds: 1));
    await _checkPermission();
  }

  Future<void> _updateOverlay() async {
    if (!_isFilterActive) return;
    final alpha = _settings.calculateAlpha(_intensity, _dimLevel);
    await OverlayService.updateFilter(
      red: _colorRed,
      green: _colorGreen,
      blue: _colorBlue,
      alpha: alpha,
      usePixelFilter: _usePixelFilter,
      pixelFilterLevel: _pixelFilterLevel,
    );
  }

  void _selectProfile(FilterProfile profile) {
    setState(() {
      _currentProfileId = profile.id;
      _colorRed = profile.red;
      _colorGreen = profile.green;
      _colorBlue = profile.blue;
      _intensity = profile.intensity;
      _dimLevel = profile.dimLevel;
      _usePixelFilter = profile.usePixelFilter;
      _pixelFilterLevel = profile.pixelFilterLevel;
    });
    _settings.setCurrentProfileId(profile.id);
    _settings.setColorRed(profile.red);
    _settings.setColorGreen(profile.green);
    _settings.setColorBlue(profile.blue);
    _settings.setIntensity(profile.intensity);
    _settings.setDimLevel(profile.dimLevel);
    _settings.setUsePixelFilter(profile.usePixelFilter);
    _settings.setPixelFilterLevel(profile.pixelFilterLevel);
    _updateOverlay();
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
              const SizedBox(height: 24),
              _buildMainControl(),
              const SizedBox(height: 28),
              _buildProfileSelector(),
              const SizedBox(height: 24),
              _buildSliders(),
              const SizedBox(height: 24),
              _buildPixelFilterCard(),
              const SizedBox(height: 24),
              _buildScheduleCard(),
              const SizedBox(height: 24),
              _buildColorPreview(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Extra Dim',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
                shadows: _isFilterActive
                    ? [
                        Shadow(
                          color: const Color(0xFFFF6B35).withValues(alpha: 0.5),
                          blurRadius: 20,
                        )
                      ]
                    : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isFilterActive ? 'Filter is active' : 'Filter is off',
              style: TextStyle(
                fontSize: 14,
                color: _isFilterActive
                    ? const Color(0xFFFFB347)
                    : const Color(0xFF8B95A2),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildHeaderButton(
              icon: Icons.tune_rounded,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(settingsService: _settings),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F36).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Icon(icon, color: const Color(0xFF8B95A2), size: 22),
      ),
    );
  }

  Widget _buildMainControl() {
    return Center(
      child: Column(
        children: [
          // Dimmer dial shows dim level
          DimmerDial(
            value: _dimLevel / 100.0,
            onChanged: (value) {
              setState(() => _dimLevel = (value * 100).round());
              _settings.setDimLevel(_dimLevel);
              _updateOverlay();
            },
            label: 'DIM LEVEL',
          ),
          const SizedBox(height: 24),
          // Power toggle
          AnimatedToggle(
            isActive: _isFilterActive,
            onToggle: _toggleFilter,
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Text(
                _isFilterActive
                    ? 'TAP TO DISABLE'
                    : (_hasPermission ? 'TAP TO ENABLE' : 'TAP TO GRANT PERMISSION'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: _isFilterActive
                      ? Color.lerp(
                          const Color(0xFFFF6B35),
                          const Color(0xFFFFB347),
                          _pulseController.value,
                        )
                      : const Color(0xFF8B95A2).withValues(alpha: 0.7),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Profiles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProfilesScreen(settingsService: _settings),
                ),
              ),
              child: const Text(
                'Manage',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFFF6B35),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _profiles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final profile = _profiles[index];
              return ProfileChip(
                name: profile.name,
                icon: profile.icon,
                isSelected: profile.id == _currentProfileId,
                onTap: () => _selectProfile(profile),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSliders() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          IgnorePointer(
            ignoring: _usePixelFilter,
            child: Opacity(
              opacity: _usePixelFilter ? 0.35 : 1.0,
              child: Column(
                children: [
                  GradientSlider(
                    value: _intensity / 100.0,
                    onChanged: (value) {
                      setState(() => _intensity = (value * 100).round());
                      _settings.setIntensity(_intensity);
                      _updateOverlay();
                    },
                    label: 'Intensity',
                    valueText: '$_intensity%',
                  ),
                  const SizedBox(height: 20),
                  GradientSlider(
                    value: _colorRed / 255.0,
                    onChanged: (value) {
                      setState(() => _colorRed = (value * 255).round());
                      _settings.setColorRed(_colorRed);
                      _updateOverlay();
                    },
                    label: 'Warmth',
                    valueText: '${(_colorRed / 255 * 100).round()}%',
                  ),
                  const SizedBox(height: 20),
                  GradientSlider(
                    value: _colorGreen / 255.0,
                    onChanged: (value) {
                      setState(() => _colorGreen = (value * 255).round());
                      _settings.setColorGreen(_colorGreen);
                      _updateOverlay();
                    },
                    label: 'Tone',
                    valueText: '${(_colorGreen / 255 * 100).round()}%',
                  ),
                ],
              ),
            ),
          ),
          if (_usePixelFilter) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFFFB347),
                  size: 14,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Color filter settings are disabled in Pixel Filter mode to keep normal screen colors.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFFFB347),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPixelFilterCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.grid_view_rounded,
                    color: _usePixelFilter ? const Color(0xFFFFB347) : const Color(0xFF8B95A2),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pixel Filter Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _usePixelFilter,
                onChanged: (value) {
                  setState(() {
                    _usePixelFilter = value;
                    if (value) {
                      // Preserve colors by clearing color filters
                      _colorRed = 0;
                      _colorGreen = 0;
                      _colorBlue = 0;
                      _intensity = 0;
                      if (_pixelFilterLevel == 0) {
                        _pixelFilterLevel = 50;
                      }
                    } else {
                      // Revert back to warm candle tint if disabled
                      _colorRed = 255;
                      _colorGreen = 120;
                      _colorBlue = 0;
                      _intensity = 40;
                    }
                  });
                  _settings.setUsePixelFilter(_usePixelFilter);
                  _settings.setColorRed(_colorRed);
                  _settings.setColorGreen(_colorGreen);
                  _settings.setColorBlue(_colorBlue);
                  _settings.setIntensity(_intensity);
                  _settings.setPixelFilterLevel(_pixelFilterLevel);
                  _updateOverlay();
                },
                activeColor: const Color(0xFFFF6B35),
                activeTrackColor: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                inactiveThumbColor: const Color(0xFF8B95A2),
                inactiveTrackColor: const Color(0xFF1A1F36),
              ),
            ],
          ),
          if (_usePixelFilter) ...[
            const SizedBox(height: 12),
            const Text(
              'Draws a black pixel pattern over the screen, turning off individual pixels. Preserves normal colors while reducing brightness. Optimized for AMOLED burn-in protection.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF8B95A2),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Grid Density',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B95A2),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildDensityOption('25% Grid', 25),
                const SizedBox(width: 8),
                _buildDensityOption('50% Checker', 50),
                const SizedBox(width: 8),
                _buildDensityOption('75% Dark', 75),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildDensityOption(String label, int level) {
    final isSelected = _pixelFilterLevel == level;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _pixelFilterLevel = level);
          _settings.setPixelFilterLevel(level);
          _updateOverlay();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFFB347)],
                  )
                : null,
            color: isSelected ? null : const Color(0xFF1A1F36),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF8B95A2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    final scheduleEnabled = _settings.scheduleEnabled;
    final startTime = _settings.scheduleStartTime;
    final endTime = _settings.scheduleEndTime;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScheduleScreen(settingsService: _settings),
          ),
        );
        setState(() {}); // Refresh after returning
      },
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: scheduleEnabled
                    ? const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFFFFB347)],
                      )
                    : null,
                color: scheduleEnabled ? null : const Color(0xFF252A40),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.schedule_rounded,
                color: scheduleEnabled ? Colors.white : const Color(0xFF8B95A2),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: scheduleEnabled
                          ? Colors.white
                          : const Color(0xFF8B95A2),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    scheduleEnabled
                        ? '${_formatTime(startTime)} — ${_formatTime(endTime)}'
                        : 'Not configured',
                    style: TextStyle(
                      fontSize: 13,
                      color: scheduleEnabled
                          ? const Color(0xFFFFB347)
                          : const Color(0xFF8B95A2).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF8B95A2).withValues(alpha: 0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPreview() {
    final alpha = _settings.calculateAlpha(_intensity, _dimLevel);
    final previewColor = _usePixelFilter 
        ? Colors.black.withValues(alpha: (_pixelFilterLevel / 100.0 * 0.8))
        : Color.fromARGB(alpha.clamp(0, 255), _colorRed, _colorGreen, _colorBlue);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Preview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: previewColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Center(
              child: Text(
                _usePixelFilter
                    ? 'Pixel Filter Active: ${_pixelFilterLevel}% Pattern'
                    : 'RGBA(${_colorRed}, ${_colorGreen}, ${_colorBlue}, ${(alpha / 255 * 100).round()}%)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
