import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/contacts_provider.dart';
import '../models/contact_model.dart';

class PanicScreen extends StatefulWidget {
  const PanicScreen({super.key});

  @override
  State<PanicScreen> createState() => _PanicScreenState();
}

class _PanicScreenState extends State<PanicScreen>
    with TickerProviderStateMixin {
  PanicState _state = PanicState.idle;
  int _cancelCountdown = 5;
  Timer? _cancelTimer;
  String? _locationText;
  String? _errorMessage;
  int _alertsSent = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _cancelTimer?.cancel();
    super.dispose();
  }

  void _onPanicPressed() {
    HapticFeedback.heavyImpact();
    _scaleController.forward().then((_) => _scaleController.reverse());
    setState(() {
      _state = PanicState.confirming;
      _cancelCountdown = 5;
      _errorMessage = null;
      _alertsSent = 0;
    });
    _cancelTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (_cancelCountdown <= 1) {
        t.cancel();
        await _sendAlert();
      } else {
        setState(() => _cancelCountdown--);
      }
    });
  }

  void _cancelAlert() {
    _cancelTimer?.cancel();
    HapticFeedback.mediumImpact();
    setState(() {
      _state = PanicState.idle;
      _cancelCountdown = 5;
    });
  }

  Future<void> _sendAlert() async {
    setState(() => _state = PanicState.sending);
    try {
      final position = await _getLocation();
      final mapsLink = position != null
          ? 'https://maps.google.com/?q=${position.latitude},${position.longitude}'
          : null;

      setState(() => _locationText = mapsLink ?? 'Could not get location');

      final contacts = context.read<ContactsProvider>().contacts;

      if (contacts.isEmpty) {
        setState(() {
          _state = PanicState.done;
          _alertsSent = 0;
          _errorMessage =
              'No trusted contacts found.\nPlease add contacts first.';
        });
        return;
      }

      final message = mapsLink != null
          ? '🆘 EMERGENCY ALERT!\n\nI need help. My location:\n$mapsLink\n\nPlease contact me immediately.'
          : '🆘 EMERGENCY ALERT!\n\nI need help but could not get my location. Please contact me immediately.';

      for (final contact in contacts) {
        final encoded = Uri.encodeComponent(message);
        final uri = Uri.parse('sms:${contact.phone}?body=$encoded');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          await Future.delayed(const Duration(milliseconds: 800));
          _alertsSent++;
        }
      }

      setState(() => _state = PanicState.done);
    } catch (e) {
      setState(() {
        _state = PanicState.done;
        _errorMessage =
            'Something went wrong.\nPlease call for help manually.';
      });
    }
  }

  Future<Position?> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  void _reset() {
    setState(() {
      _state = PanicState.idle;
      _locationText = null;
      _errorMessage = null;
      _alertsSent = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(title: const Text('Emergency Panic')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              _buildStateContent(),
              const Spacer(),
              _buildBottomContent(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateContent() {
    switch (_state) {
      case PanicState.idle:
        return _buildIdleState();
      case PanicState.confirming:
        return _buildConfirmingState();
      case PanicState.sending:
        return _buildSendingState();
      case PanicState.done:
        return _buildDoneState();
    }
  }

  // ── IDLE ─────────────────────────────────────────────────
  Widget _buildIdleState() {
    return Column(children: [
      const Text(
        'Are you in danger?',
        style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        'Press the button to alert your\ntrusted contacts with your location.',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 14,
            height: 1.5),
      ),
      const SizedBox(height: 52),
      ScaleTransition(
        scale: _pulseAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTap: _onPanicPressed,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE94560),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE94560).withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                  BoxShadow(
                    color: const Color(0xFFE94560).withOpacity(0.15),
                    blurRadius: 80,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.white, size: 52),
                  SizedBox(height: 6),
                  Text(
                    'PANIC',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  // ── CONFIRMING ───────────────────────────────────────────
  Widget _buildConfirmingState() {
    return Column(children: [
      const Text(
        'Sending alert in...',
        style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        'Tap Cancel to stop the alert.',
        style: TextStyle(
            color: Colors.white.withOpacity(0.45), fontSize: 14),
      ),
      const SizedBox(height: 52),
      Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.amber.withOpacity(0.1),
          border:
              Border.all(color: Colors.amber.withOpacity(0.5), width: 3),
        ),
        child: Center(
          child: Text(
            '$_cancelCountdown',
            style: const TextStyle(
                color: Colors.amber,
                fontSize: 72,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
      const SizedBox(height: 36),
      SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: _cancelAlert,
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancel Alert'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white30),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ]);
  }

  // ── SENDING ──────────────────────────────────────────────
  Widget _buildSendingState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: Color(0xFFE94560)),
        SizedBox(height: 24),
        Text(
          'Getting your location\nand sending alerts...',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.5),
        ),
        SizedBox(height: 8),
        Text(
          'Please wait',
          style: TextStyle(color: Colors.white38, fontSize: 14),
        ),
      ],
    );
  }

  // ── DONE ─────────────────────────────────────────────────
  Widget _buildDoneState() {
    final success = _errorMessage == null;
    return Column(children: [
      Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (success ? Colors.green : Colors.redAccent)
              .withOpacity(0.15),
        ),
        child: Icon(
          success ? Icons.check_circle_outline : Icons.error_outline,
          color: success ? Colors.greenAccent : Colors.redAccent,
          size: 48,
        ),
      ),
      const SizedBox(height: 20),
      Text(
        success ? 'SMS App Opened!' : 'Alert Failed',
        style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      Text(
        success
            ? '⚠️ Press SEND in your SMS app\nfor each contact to complete the alert.'
            : _errorMessage!,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: success ? Colors.amber : Colors.white.withOpacity(0.5),
            fontSize: 14,
            height: 1.6,
            fontWeight:
                success ? FontWeight.w600 : FontWeight.normal),
      ),
      if (success && _locationText != null) ...[
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(children: [
            const Icon(Icons.location_on,
                color: Color(0xFFE94560), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _locationText!,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ]),
        ),
      ],
      const SizedBox(height: 32),
      SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh),
          label: const Text('Back to Safety'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F3460),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ]);
  }

  // ── Bottom info tiles ─────────────────────────────────────
  Widget _buildBottomContent() {
    if (_state != PanicState.idle) return const SizedBox.shrink();
    return Column(children: [
      _infoTile(Icons.location_on, 'Shares your GPS coordinates'),
      const SizedBox(height: 8),
      _infoTile(Icons.sms_outlined, 'SMS sent to all trusted contacts'),
      const SizedBox(height: 8),
      _infoTile(Icons.timer_outlined, '5 second window to cancel'),
    ]);
  }

  Widget _infoTile(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFFE94560), size: 16),
        const SizedBox(width: 8),
        Text(text,
            style: TextStyle(
                color: Colors.white.withOpacity(0.45), fontSize: 13)),
      ],
    );
  }
}

// ── Panic state enum ──────────────────────────────────────
enum PanicState { idle, confirming, sending, done }