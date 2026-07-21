import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings values
  bool _shakeToCall = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _locationSharing = true;
  bool _cancelWindow = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ── Load from storage ────────────────────────────────────
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _shakeToCall = prefs.getBool('shake_to_call') ?? true;
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _locationSharing = prefs.getBool('location_sharing') ?? true;
      _cancelWindow = prefs.getBool('cancel_window') ?? true;
      _isLoading = false;
    });
  }

  // ── Save a single setting ────────────────────────────────
  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE94560)),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Fake Call Settings ─────────────────────
                _sectionHeader('📞  FAKE CALL'),
                const SizedBox(height: 10),

                _settingsTile(
                  icon: Icons.vibration,
                  title: 'Shake to Trigger Call',
                  subtitle: 'Shake your phone 3× to instantly trigger a fake call',
                  value: _shakeToCall,
                  onChanged: (v) {
                    setState(() => _shakeToCall = v);
                    _saveSetting('shake_to_call', v);
                    // Show feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(v
                            ? '📳 Shake to call enabled'
                            : '📳 Shake to call disabled'),
                        backgroundColor: const Color(0xFF0F3460),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                _settingsTile(
                  icon: Icons.volume_up_outlined,
                  title: 'Ringtone Sound',
                  subtitle: 'Play ringtone when fake call is triggered',
                  value: _soundEnabled,
                  onChanged: (v) {
                    setState(() => _soundEnabled = v);
                    _saveSetting('sound_enabled', v);
                  },
                ),
                const SizedBox(height: 10),

                _settingsTile(
                  icon: Icons.phone_android,
                  title: 'Vibration',
                  subtitle: 'Vibrate on incoming fake call',
                  value: _vibrationEnabled,
                  onChanged: (v) {
                    setState(() => _vibrationEnabled = v);
                    _saveSetting('vibration_enabled', v);
                  },
                ),

                const SizedBox(height: 28),

                // ── Emergency Settings ─────────────────────
                _sectionHeader('🆘  EMERGENCY'),
                const SizedBox(height: 10),

                _settingsTile(
                  icon: Icons.location_on_outlined,
                  title: 'Share GPS Location',
                  subtitle: 'Include your coordinates in emergency SMS alerts',
                  value: _locationSharing,
                  onChanged: (v) {
                    setState(() => _locationSharing = v);
                    _saveSetting('location_sharing', v);
                  },
                ),
                const SizedBox(height: 10),

                _settingsTile(
                  icon: Icons.timer_outlined,
                  title: '5-Second Cancel Window',
                  subtitle: 'Show countdown before sending panic alert',
                  value: _cancelWindow,
                  onChanged: (v) {
                    setState(() => _cancelWindow = v);
                    _saveSetting('cancel_window', v);
                  },
                ),

                const SizedBox(height: 28),

                // ── About ──────────────────────────────────
                _sectionHeader('ℹ️  ABOUT'),
                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F3460),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.07)),
                  ),
                  child: Column(
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE94560).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shield,
                              color: Color(0xFFE94560), size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EchoSafe',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            Text(
                              'Version 1.0.0',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                      ]),
                      const SizedBox(height: 14),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 14),
                      Text(
                        'Smart Fake Call & Emergency Exit Planner. '
                        'Built to help you safely exit uncomfortable, '
                        'risky, or threatening situations.',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12,
                            height: 1.6),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Reset all settings
                TextButton.icon(
                  onPressed: _confirmReset,
                  icon: const Icon(Icons.restart_alt,
                      color: Colors.redAccent, size: 18),
                  label: const Text(
                    'Reset All Settings',
                    style: TextStyle(color: Colors.redAccent, fontSize: 14),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
    );
  }

  // ── Confirm reset dialog ─────────────────────────────────
  void _confirmReset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Settings',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will reset all settings to their defaults. Your contacts will not be affected.',
          style: TextStyle(color: Colors.white60, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context);
              await _resetSettings();
            },
            child: const Text('Reset',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Reset all to defaults ────────────────────────────────
  Future<void> _resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('shake_to_call');
    await prefs.remove('sound_enabled');
    await prefs.remove('vibration_enabled');
    await prefs.remove('location_sharing');
    await prefs.remove('cancel_window');
    await _loadSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings reset to defaults'),
          backgroundColor: Color(0xFF0F3460),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // ── Section header ───────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600),
    );
  }

  // ── Reusable settings tile ───────────────────────────────
  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: SwitchListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value
                ? const Color(0xFFE94560).withOpacity(0.15)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: value ? const Color(0xFFE94560) : Colors.white38,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
              color: Colors.white.withOpacity(0.38),
              fontSize: 12,
              height: 1.4),
        ),
        value: value,
        activeColor: const Color(0xFFE94560),
        inactiveThumbColor: Colors.white38,
        inactiveTrackColor: Colors.white12,
        onChanged: onChanged,
      ),
    );
  }
}
