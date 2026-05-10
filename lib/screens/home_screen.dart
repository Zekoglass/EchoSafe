import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/contacts_provider.dart';
import 'fake_call_screen.dart';
import 'panic_screen.dart';
import 'contacts_screen.dart';
import 'settings_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../services/shake_service.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final ShakeService _shakeService = ShakeService();
  bool _shakeEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadShakeSetting();
  }

  Future<void> _loadShakeSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _shakeEnabled = prefs.getBool('shake_to_call') ?? true;
    if (_shakeEnabled) _startShakeListener();
  }

  void _startShakeListener() {
    _shakeService.start(onShake: () {
      if (!mounted) return;
      // Navigate to fake call tab first
      setState(() => _currentIndex = 1);
      // Then show incoming call after short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: true,
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (_, __, ___) => const AndroidIncomingCallScreen(
              callerName: 'Mom',
              callerNumber: '+251 91 000 0000',
            ),
            transitionsBuilder: (_, animation, __, child) =>
                SlideTransition(
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
      });
    });
  }

  @override
  void dispose() {
    _shakeService.dispose();
    super.dispose();
  }

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _DashboardPage(onNavigate: _navigateTo),
      const FakeCallScreen(),
      const PanicScreen(),
      const ContactsScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _navigateTo,
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFFE94560),
          unselectedItemColor: Colors.white38,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.phone_outlined),
              activeIcon: Icon(Icons.phone),
              label: 'Fake Call',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber_outlined),
              activeIcon: Icon(Icons.warning_amber_rounded),
              label: 'Panic',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Contacts',
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  DASHBOARD PAGE
// ══════════════════════════════════════════════════════════
class _DashboardPage extends StatelessWidget {
  final void Function(int) onNavigate;
  const _DashboardPage({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final contacts = context.watch<ContactsProvider>().contacts;
    final hasContacts = contacts.isNotEmpty;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE94560).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield,
                        color: Color(0xFFE94560), size: 24),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'EchoSafe',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ]),
                IconButton(
                  icon: const Icon(Icons.settings_outlined,
                      color: Colors.white38),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Greeting ─────────────────────────────────
            const Text(
              'Stay Safe,\nStay in Control.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.3),
            ),
            const SizedBox(height: 6),
            Text(
              'Your personal safety toolkit.',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4), fontSize: 14),
            ),

            const SizedBox(height: 24),

            // ── Warning if no contacts ────────────────────
            if (!hasContacts)
              GestureDetector(
                onTap: () => onNavigate(3),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.amber, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No trusted contacts yet. Tap to add one so panic alerts work.',
                        style: TextStyle(
                            color: Colors.amber.withOpacity(0.9),
                            fontSize: 12,
                            height: 1.4),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.amber, size: 12),
                  ]),
                ),
              ),

            // ── Panic Card ───────────────────────────────
            _PanicCard(onTap: () => onNavigate(2)),

            const SizedBox(height: 20),

            // ── Quick Actions label ───────────────────────
            const Text(
              'QUICK ACTIONS',
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // ── Quick Action Cards ────────────────────────
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.phone_in_talk,
                    label: 'Fake Call',
                    subtitle: 'Instant or scheduled',
                    onTap: () => onNavigate(1),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.people_alt_outlined,
                    label: 'Contacts',
                    subtitle: hasContacts
                        ? '${contacts.length} trusted ${contacts.length == 1 ? 'person' : 'people'}'
                        : 'No contacts yet',
                    onTap: () => onNavigate(3),
                    badge: hasContacts ? '${contacts.length}' : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Status summary card ───────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'APP STATUS',
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  _statusRow(
                    Icons.people,
                    'Trusted Contacts',
                    hasContacts
                        ? '${contacts.length} added'
                        : 'None added',
                    hasContacts,
                  ),
                  const SizedBox(height: 8),
                  _statusRow(
                    Icons.phone_in_talk,
                    'Fake Call',
                    'Ready',
                    true,
                  ),
                  const SizedBox(height: 8),
                  _statusRow(
                    Icons.warning_amber_rounded,
                    'Panic Button',
                    hasContacts ? 'Ready' : 'Add contacts first',
                    hasContacts,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Tip ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(children: [
                const Icon(Icons.lightbulb_outline,
                    color: Colors.amber, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tip: Shake your phone 3× to instantly trigger a fake call anytime.',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.38),
                        fontSize: 12,
                        height: 1.5),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(
      IconData icon, String label, String value, bool ok) {
    return Row(children: [
      Icon(icon,
          color: ok ? const Color(0xFFE94560) : Colors.white24,
          size: 16),
      const SizedBox(width: 10),
      Expanded(
        child: Text(label,
            style:
                const TextStyle(color: Colors.white60, fontSize: 13)),
      ),
      Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: ok
              ? Colors.green.withOpacity(0.12)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          value,
          style: TextStyle(
              color: ok ? Colors.greenAccent : Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w600),
        ),
      ),
    ]);
  }
}

// ── Panic Card ─────────────────────────────────────────────
class _PanicCard extends StatelessWidget {
  final VoidCallback onTap;
  const _PanicCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE94560), Color(0xFFb52a42)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE94560).withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PANIC BUTTON',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      letterSpacing: 1.2),
                ),
                SizedBox(height: 4),
                Text(
                  'Send location & alert all trusted contacts instantly',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              color: Colors.white60, size: 16),
        ]),
      ),
    );
  }
}

// ── Quick Action Card ──────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF0F3460),
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE94560).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon,
                      color: const Color(0xFFE94560), size: 22),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE94560),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(badge!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11)),
          ],
        ),
      ),
    );
  }
}