import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../services/settings_service.dart';

class ScheduleScreen extends StatefulWidget {
  final SettingsService settingsService;

  const ScheduleScreen({super.key, required this.settingsService});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late bool _enabled;
  late String _mode;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  SettingsService get _settings => widget.settingsService;

  @override
  void initState() {
    super.initState();
    _enabled = _settings.scheduleEnabled;
    _mode = _settings.scheduleMode;
    _startTime = _settings.scheduleStartTime;
    _endTime = _settings.scheduleEndTime;
  }

  Future<void> _save() async {
    await _settings.setScheduleEnabled(_enabled);
    await _settings.setScheduleMode(_mode);
    await _settings.setScheduleStartTime(_startTime);
    await _settings.setScheduleEndTime(_endTime);
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF6B35),
              surface: Color(0xFF1A1F36),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0A0E21),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
      _save();
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
              const SizedBox(height: 32),
              _buildToggleCard(),
              const SizedBox(height: 20),
              if (_enabled) ...[
                _buildModeSelector(),
                const SizedBox(height: 20),
                if (_mode == 'custom') _buildTimeCards(),
                if (_mode == 'sunset') _buildSunsetInfo(),
              ],
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
          'Schedule',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Auto Schedule',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _enabled ? 'Filter activates automatically' : 'Manual control only',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8B95A2),
                ),
              ),
            ],
          ),
          Switch(
            value: _enabled,
            onChanged: (value) {
              setState(() => _enabled = value);
              _save();
            },
            activeColor: const Color(0xFFFF6B35),
            activeTrackColor: const Color(0xFFFF6B35).withValues(alpha: 0.3),
            inactiveThumbColor: const Color(0xFF8B95A2),
            inactiveTrackColor: const Color(0xFF252A40),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mode',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B95A2),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildModeOption(
                  'Custom',
                  'custom',
                  Icons.access_time_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModeOption(
                  'Sunset',
                  'sunset',
                  Icons.wb_twilight_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption(String label, String value, IconData icon) {
    final isSelected = _mode == value;
    return GestureDetector(
      onTap: () {
        setState(() => _mode = value);
        _save();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFFB347)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : const Color(0xFF252A40),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: -2,
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF8B95A2),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF8B95A2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCards() {
    return Column(
      children: [
        _buildTimeCard('Start Time', _startTime, true, Icons.nightlight_round),
        const SizedBox(height: 12),
        _buildTimeCard('End Time', _endTime, false, Icons.wb_sunny_rounded),
      ],
    );
  }

  Widget _buildTimeCard(
    String label,
    TimeOfDay time,
    bool isStart,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () => _pickTime(isStart),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF252A40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFFFB347), size: 22),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8B95A2),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(time),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.edit_rounded,
              color: const Color(0xFF8B95A2).withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunsetInfo() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF4757)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.wb_twilight_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sunset Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Filter automatically activates at sunset and turns off at sunrise based on your location.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8B95A2),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
