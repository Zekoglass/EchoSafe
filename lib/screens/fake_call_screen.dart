import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  final _nameCtrl = TextEditingController(text: 'Mom');
  final _numberCtrl = TextEditingController(text: '+251 91 000 0000');
  int _delaySeconds = 5;
  bool _isCountingDown = false;
  int _countdown = 0;
  Timer? _timer;

  final List<String> _presets = ['Mom', 'Dad', 'Work', 'Doctor', 'Friend'];

  @override
  void dispose() {
    _timer?.cancel();
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  void _startFakeCall() {
    HapticFeedback.mediumImpact();
    if (_delaySeconds == 0) {
      _showIncomingCall();
      return;
    }
    setState(() {
      _isCountingDown = true;
      _countdown = _delaySeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _countdown--);
      if (_countdown <= 0) {
        t.cancel();
        setState(() => _isCountingDown = false);
        _showIncomingCall();
      }
    });
  }

  void _cancelCountdown() {
    _timer?.cancel();
    setState(() {
      _isCountingDown = false;
      _countdown = 0;
    });
  }

  void _showIncomingCall() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => AndroidIncomingCallScreen(
          callerName: _nameCtrl.text.trim().isEmpty
              ? 'Unknown'
              : _nameCtrl.text.trim(),
          callerNumber: _numberCtrl.text.trim().isEmpty
              ? '+000 000 0000'
              : _numberCtrl.text.trim(),
        ),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(title: const Text('Fake Call')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F3460),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline,
                    color: Colors.white38, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Simulate a realistic incoming call to safely exit any situation.',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        height: 1.5),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 28),
            _sectionLabel('CALLER NAME'),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _nameCtrl,
              hint: 'e.g. Mom, Doctor...',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((name) {
                final selected = _nameCtrl.text == name;
                return GestureDetector(
                  onTap: () => setState(() => _nameCtrl.text = name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFE94560)
                          : const Color(0xFF0F3460),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFE94560)
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      name,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white60,
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            _sectionLabel('PHONE NUMBER'),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _numberCtrl,
              hint: '+251 91 234 5678',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 24),
            _sectionLabel('CALL DELAY'),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(
                child: Slider(
                  value: _delaySeconds.toDouble(),
                  min: 0,
                  max: 60,
                  divisions: 12,
                  activeColor: const Color(0xFFE94560),
                  inactiveColor: Colors.white12,
                  onChanged: _isCountingDown
                      ? null
                      : (v) => setState(() => _delaySeconds = v.round()),
                ),
              ),
              Container(
                width: 72,
                alignment: Alignment.center,
                child: Text(
                  _delaySeconds == 0 ? 'Instant' : '${_delaySeconds}s',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ]),

            const SizedBox(height: 32),

            if (_isCountingDown) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.timer_outlined,
                          color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Call incoming in ${_countdown}s...',
                        style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.w600),
                      ),
                    ]),
                    TextButton(
                      onPressed: _cancelCountdown,
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isCountingDown ? null : _startFakeCall,
                icon: const Icon(Icons.phone_in_talk),
                label: Text(
                  _isCountingDown
                      ? 'Call scheduled...'
                      : _delaySeconds == 0
                          ? 'Call Now'
                          : 'Schedule Call',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94560),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFFE94560).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: const Color(0xFF0F3460),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  ANDROID-STYLE INCOMING CALL SCREEN WITH SOUND
// ══════════════════════════════════════════════════════════
class AndroidIncomingCallScreen extends StatefulWidget {
  final String callerName;
  final String callerNumber;

  const AndroidIncomingCallScreen({
    super.key,
    required this.callerName,
    required this.callerNumber,
  });

  @override
  State<AndroidIncomingCallScreen> createState() =>
      _AndroidIncomingCallScreenState();
}

class _AndroidIncomingCallScreenState
    extends State<AndroidIncomingCallScreen>
    with TickerProviderStateMixin {
  bool _callAccepted = false;
  int _callDuration = 0;
  Timer? _callTimer;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Ripple animation
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _rippleAnimation = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(
          parent: _rippleController, curve: Curves.easeOut),
    );

    // Start ringtone
    _playRingtone();
  }

  Future<void> _playRingtone() async {
  try {
    // Play ringtone
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.play(AssetSource('sounds/ringtone.wav'));

    // Vibrate in a phone-ring pattern
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(
        pattern: [0, 800, 600, 800, 600, 800],
        repeat: 2,
      );
    }
  } catch (e) {
    debugPrint('Ringtone error: $e');
  }
}
  Future<void> _stopRingtone() async {
  try {
    await _audioPlayer.stop();
    Vibration.cancel();
  } catch (_) {}
}

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _rippleController.dispose();
    _callTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _acceptCall() async {
    HapticFeedback.mediumImpact();
    await _stopRingtone();
    _rippleController.stop();
    setState(() {
      _callAccepted = true;
    });
    _callTimer =
        Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _callDuration++);
    });
  }

  void _declineCall() async {
    HapticFeedback.mediumImpact();
    await _stopRingtone();
    if (mounted) Navigator.of(context).pop();
  }

  void _endCall() async {
    HapticFeedback.mediumImpact();
    await _stopRingtone();
    _callTimer?.cancel();
    if (mounted) Navigator.of(context).pop();
  }

  String get _formattedDuration {
    final m = (_callDuration ~/ 60).toString().padLeft(2, '0');
    final s = (_callDuration % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _avatarColor {
    final colors = [
      const Color(0xFF1565C0),
      const Color(0xFF6A1B9A),
      const Color(0xFF00695C),
      const Color(0xFFAD1457),
      const Color(0xFF4527A0),
      const Color(0xFF00838F),
    ];
    final index = widget.callerName.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _callAccepted ? _buildActiveCall() : _buildIncomingCall(),
    );
  }

  Widget _buildIncomingCall() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _avatarColor.withOpacity(0.9),
            Colors.black,
          ],
          stops: const [0.0, 0.55],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Text(
              'Incoming call',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 14,
                  letterSpacing: 0.5),
            ),
            const SizedBox(height: 28),

            // Avatar with ripple
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _rippleAnimation,
                  builder: (_, __) => Container(
                    width: 120 * _rippleAnimation.value,
                    height: 120 * _rippleAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(
                            0.15 * (1.4 - _rippleAnimation.value)),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _avatarColor,
                    boxShadow: [
                      BoxShadow(
                        color: _avatarColor.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.callerName[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),
            Text(
              widget.callerName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5),
            ),
            const SizedBox(height: 6),
            Text(
              widget.callerNumber,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 15),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Mobile',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12)),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 40, vertical: 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(children: [
                    _callButton(
                      color: const Color(0xFFE53935),
                      icon: Icons.call_end,
                      onTap: _declineCall,
                    ),
                    const SizedBox(height: 12),
                    Text('Decline',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13)),
                  ]),
                  Column(children: [
                    _cosmeticButton(
                      color: const Color(0xFF424242),
                      icon: Icons.message_outlined,
                    ),
                    const SizedBox(height: 12),
                    Text('Message',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13)),
                  ]),
                  Column(children: [
                    _callButton(
                      color: const Color(0xFF43A047),
                      icon: Icons.call,
                      onTap: _acceptCall,
                    ),
                    const SizedBox(height: 12),
                    Text('Accept',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCall() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF1A1A1A),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              _formattedDuration,
              style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 16,
                  letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            Text(
              widget.callerName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 4),
            Text(
              widget.callerNumber,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 14),
            ),
            const SizedBox(height: 40),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: _avatarColor),
              child: Center(
                child: Text(
                  widget.callerName[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w300),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.1,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _inCallAction(Icons.mic_off, 'Mute'),
                  _inCallAction(Icons.dialpad, 'Keypad'),
                  _inCallAction(Icons.volume_up, 'Speaker'),
                  _inCallAction(Icons.add_call, 'Add call'),
                  _inCallAction(Icons.videocam, 'Video'),
                  _inCallAction(Icons.people, 'Contacts'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Column(children: [
              GestureDetector(
                onTap: _endCall,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE53935)),
                  child: const Icon(Icons.call_end,
                      color: Colors.white, size: 32),
                ),
              ),
              const SizedBox(height: 10),
              Text('End',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13)),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _callButton({
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _cosmeticButton({
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  Widget _inCallAction(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
          child: Icon(icon, color: Colors.white70, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.6), fontSize: 11)),
      ],
    );
  }
}