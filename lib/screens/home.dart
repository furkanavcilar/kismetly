import 'dart:async';

import 'package:characters/characters.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services.dart';
import '../firebase_options.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _FirebaseConnectionState { checking, success, failure }

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _now;
  late final String _sunSign;
  late final String _ascendant;
  String? _city;
  bool _locationTried = false;
  _FirebaseConnectionState _firebaseStatus = _FirebaseConnectionState.checking;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _sunSign = AstroService.sunSign(_now);
    _ascendant = AstroService.approxAscendant(TimeOfDay.fromDateTime(_now));
    _startTicker();
    _loadLocation();
    _checkFirebaseConnection();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  Future<void> _loadLocation() async {
    final city = await LocationService.currentCity();
    if (!mounted) return;
    setState(() {
      _city = city;
      _locationTried = true;
    });
  }

  Future<void> _checkFirebaseConnection() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        // Varsayılan uygulamanın elde edilmesi bağlantının kurulduğunu doğrular.
        Firebase.app();
      }
      if (!mounted) return;
      setState(() {
        _firebaseStatus = _FirebaseConnectionState.success;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _firebaseStatus = _FirebaseConnectionState.failure;
      });
    }
  }

  String? get _firebaseStatusMessage {
    switch (_firebaseStatus) {
      case _FirebaseConnectionState.success:
        return 'Firebase bağlantısı başarılı ✅';
      case _FirebaseConnectionState.failure:
        return 'Firebase bağlantısı başarısız ❌';
      case _FirebaseConnectionState.checking:
        return null;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('d MMMM y EEEE', 'tr_TR').format(_now);
    final timeLabel = DateFormat('HH:mm', 'tr_TR').format(_now);
    final quote = AstroService.dailyQuote();
    final horoscope = AstroService.dailyHoroscope(_sunSign);

    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const _HomeDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0912), Color(0xFF1C1A2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _city ?? (_locationTried ? 'Konum alınamadı' : 'Konum aranıyor...'),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$dateLabel · $timeLabel',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                  letterSpacing: 0.4,
                                ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      child: Text(
                        _sunSign.characters.first,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              if (_firebaseStatusMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      _firebaseStatusMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroCard(
                        sunSign: _sunSign,
                        ascendant: _ascendant,
                        quote: quote,
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(label: 'Günlük Burç Haritan'),
                      const SizedBox(height: 12),
                      _InfoCard(
                        title: 'Güneşin: ${_sunSign.toUpperCase()}',
                        subtitle: 'Günün Yorumu',
                        description: horoscope,
                        leadingIcon: Icons.brightness_5_outlined,
                      ),
                      const SizedBox(height: 16),
                      _InfoCard(
                        title: 'Günün Sözü',
                        subtitle: 'Anlam & Önemi',
                        description: '$quote\n\nBugün bu cümleyi düşün ve enerjini buna göre yönlendir.',
                        leadingIcon: Icons.auto_awesome,
                      ),
                      const SizedBox(height: 16),
                      _InfoCard(
                        title: 'Astroloji Notları',
                        subtitle: 'Ay & Yükselen',
                        description:
                            'Yükselenin: $_ascendant\nAy fazı: ${_moonPhaseDescription(_now)}\nEnerjini dengede tutmak için sezgilerine kulak ver.',
                        leadingIcon: Icons.nights_stay_outlined,
                      ),
                      const SizedBox(height: 24),
                      _SectionTitle(label: 'Bugün İçin Öneriler'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: const [
                          _ChipPill(label: 'Mindfulness'),
                          _ChipPill(label: 'Ritüeller'),
                          _ChipPill(label: 'Günlük Tut'),
                          _ChipPill(label: 'Su İçmeyi Unutma'),
                        ],
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _moonPhaseDescription(DateTime date) {
    final synodicMonth = 29.530588853;
    final knownNewMoon = DateTime(2000, 1, 6, 18, 14);
    final diff = date.toUtc().difference(knownNewMoon);
    final days = diff.inHours / 24.0;
    final phase = (days % synodicMonth) / synodicMonth;

    if (phase < 0.03 || phase > 0.97) return 'Yeni Ay';
    if (phase < 0.22) return 'İlk Dördün';
    if (phase < 0.28) return 'İlk Dördün Zirvesi';
    if (phase < 0.47) return 'Dolunay Öncesi';
    if (phase < 0.53) return 'Dolunay';
    if (phase < 0.72) return 'Dolunay Sonrası';
    if (phase < 0.78) return 'Son Dördün Zirvesi';
    return 'Son Dördün';
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.sunSign,
    required this.ascendant,
    required this.quote,
  });

  final String sunSign;
  final String ascendant;
  final String quote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2156), Color(0xFF120B2C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 24,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NASA verileri yıldızların konumunu tam olarak çıkarıyor.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Güneş Burcun',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white60,
                            letterSpacing: 0.6,
                          ),
                    ),
                    Text(
                      sunSign.toUpperCase(),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Yükselen Burcun',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white60,
                          ),
                    ),
                    Text(
                      ascendant,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                children: const [
                  Icon(Icons.rocket_launch_outlined, color: Colors.white70, size: 36),
                  SizedBox(height: 12),
                  Icon(Icons.auto_fix_high, color: Colors.white54, size: 32),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.format_quote, color: Colors.white70),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    quote,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          height: 1.4,
                        ),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.leadingIcon,
  });

  final String title;
  final String subtitle;
  final String description;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(leadingIcon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white54,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _ChipPill extends StatelessWidget {
  const _ChipPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
      ),
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0F0C1B),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white70),
                  const SizedBox(width: 12),
                  Text(
                    'Kismetly Menü',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const _DrawerTile(icon: Icons.bedtime_outlined, label: 'Rüya Yorumu'),
              const _DrawerTile(icon: Icons.public_outlined, label: 'Astroloji Haritası'),
              const _DrawerTile(icon: Icons.pan_tool_alt_outlined, label: 'El Falı'),
              const _DrawerTile(icon: Icons.local_cafe_outlined, label: 'Kahve Falı'),
              const Spacer(),
              Text(
                'Göklerin sırlarını keşfet!',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white38),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
      ),
      onTap: () => Navigator.of(context).pop(),
    );
  }
}
