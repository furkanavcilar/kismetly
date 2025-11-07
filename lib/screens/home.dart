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
  LocationSnapshot? _location;
  WeatherSnapshot? _weather;
  NetworkTimeSnapshot? _networkTime;
  HoroscopeBundle? _horoscope;
  PlanetarySnapshot? _planetary;
  String? _quote;
  bool _locationTried = false;
  bool _loadingQuote = true;
  bool _loadingHoroscope = true;
  bool _loadingPlanets = true;
  bool _loadingWeather = true;
  bool _loadingTime = true;
  String? _quoteError;
  String? _horoscopeError;
  String? _planetaryError;
  String? _weatherError;
  String? _timeError;
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
    _loadQuote();
    _loadHoroscope();
    _loadPlanetary();
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
    final snapshot = await LocationService.currentLocation();
    if (!mounted) return;
    setState(() {
      _location = snapshot;
      _city = snapshot?.city;
      _locationTried = true;
      if (snapshot == null) {
        _loadingWeather = false;
        _loadingTime = false;
        _weatherError = 'Konum alınamadı';
        _timeError = 'Konum alınamadı';
      }
    });

    if (snapshot != null) {
      _fetchWeather(snapshot);
      _fetchNetworkTime(snapshot);
    }
  }

  Future<void> _loadQuote() async {
    setState(() {
      _loadingQuote = true;
      _quoteError = null;
    });

    try {
      final fetched = await AstroService.fetchDailyQuote();
      if (!mounted) return;
      setState(() {
        _quote = fetched;
        _loadingQuote = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _quote = null;
        _loadingQuote = false;
        _quoteError = 'Günün sözü yüklenemedi';
      });
    }
  }

  Future<void> _loadHoroscope() async {
    setState(() {
      _loadingHoroscope = true;
      _horoscopeError = null;
    });

    try {
      final bundle = await AstroService.fetchHoroscopeBundle(_sunSign);
      if (!mounted) return;
      setState(() {
        _horoscope = bundle;
        _loadingHoroscope = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _horoscope = null;
        _loadingHoroscope = false;
        _horoscopeError = 'Burç yorumları alınamadı';
      });
    }
  }

  Future<void> _loadPlanetary() async {
    setState(() {
      _loadingPlanets = true;
      _planetaryError = null;
    });

    try {
      final snapshot = await AstroService.fetchPlanetarySnapshot();
      if (!mounted) return;
      setState(() {
        _planetary = snapshot;
        _loadingPlanets = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _planetary = null;
        _loadingPlanets = false;
        _planetaryError = 'Gezegen bilgileri alınamadı';
      });
    }
  }

  Future<void> _fetchWeather(LocationSnapshot snapshot) async {
    setState(() {
      _loadingWeather = true;
      _weatherError = null;
    });

    final weather = await WeatherService.fetchWeather(
      latitude: snapshot.latitude,
      longitude: snapshot.longitude,
    );

    if (!mounted) return;
    setState(() {
      _weather = weather;
      _loadingWeather = false;
      if (weather == null) {
        _weatherError = 'Hava durumu alınamadı';
      }
    });
  }

  Future<void> _fetchNetworkTime(LocationSnapshot snapshot) async {
    setState(() {
      _loadingTime = true;
      _timeError = null;
    });

    final netTime = await NetworkTimeService.fetchTime(
      latitude: snapshot.latitude,
      longitude: snapshot.longitude,
    );

    if (!mounted) return;
    setState(() {
      _networkTime = netTime;
      _loadingTime = false;
      if (netTime != null) {
        _now = netTime.dateTime;
      } else {
        _timeError = 'Ağ zamanı alınamadı';
      }
    });
  }

  void _refreshWeatherAndTime() {
    final snapshot = _location;
    if (snapshot != null) {
      _fetchWeather(snapshot);
      _fetchNetworkTime(snapshot);
    } else {
      _loadLocation();
    }
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
    final activeNow = _networkTime?.dateTime ?? _now;
    final dateLabel = DateFormat('d MMMM y EEEE', 'tr_TR').format(activeNow);
    final timeLabel = DateFormat('HH:mm', 'tr_TR').format(activeNow);
    final timezoneLabel = _networkTime?.timeZone ?? 'Yerel saat';
    final offsetLabel = _networkTime?.utcOffset ?? '';

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
                          Row(
                            children: [
                              Text(
                                '$dateLabel · $timeLabel',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                      letterSpacing: 0.4,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Text(
                                  offsetLabel.isNotEmpty ? '$timezoneLabel · $offsetLabel' : timezoneLabel,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Colors.white70,
                                        letterSpacing: 0.4,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _refreshWeatherAndTime,
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                      tooltip: 'Verileri yenile',
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 900;
                    final mainColumn = _buildMainColumn(context, activeNow);
                    final sidePanel = _SidePanel(
                      cityLabel: _city ?? (_locationTried ? 'Konum alınamadı' : 'Konum aranıyor...'),
                      weather: _weather,
                      loadingWeather: _loadingWeather,
                      weatherError: _weatherError,
                      networkTime: _networkTime,
                      loadingTime: _loadingTime,
                      timeError: _timeError,
                      fallbackNow: activeNow,
                      onRefresh: _refreshWeatherAndTime,
                    );

                    if (isWide) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(right: 24, bottom: 32),
                                child: mainColumn,
                              ),
                            ),
                            SizedBox(
                              width: 320,
                              child: sidePanel,
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          mainColumn,
                          const SizedBox(height: 24),
                          sidePanel,
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainColumn(BuildContext context, DateTime activeNow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroCard(
          sunSign: _sunSign,
          ascendant: _ascendant,
          quote: _quote,
          quoteLoading: _loadingQuote,
          error: _quoteError,
          onRefresh: _loadQuote,
        ),
        const SizedBox(height: 24),
        _SectionTitle(label: 'Burç yorumları'),
        const SizedBox(height: 12),
        _HoroscopeDeck(
          bundle: _horoscope,
          loading: _loadingHoroscope,
          error: _horoscopeError,
          sunSign: _sunSign,
          onRetry: _loadHoroscope,
        ),
        const SizedBox(height: 24),
        _SectionTitle(label: 'Astroloji bilgileri'),
        const SizedBox(height: 12),
        _AstroInsights(
          ascendant: _ascendant,
          moonPhase: _moonPhaseDescription(activeNow),
        ),
        const SizedBox(height: 24),
        _SectionTitle(label: 'Mars & Venüs görünümü'),
        const SizedBox(height: 12),
        _PlanetaryGrid(
          snapshot: _planetary,
          loading: _loadingPlanets,
          error: _planetaryError,
          onRetry: _loadPlanetary,
        ),
        const SizedBox(height: 24),
        _SectionTitle(label: 'Bugün için öneriler'),
        const SizedBox(height: 12),
        const _RecommendationChips(),
        const SizedBox(height: 48),
      ],
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
    required this.quoteLoading,
    required this.onRefresh,
    this.error,
  });

  final String sunSign;
  final String ascendant;
  final String? quote;
  final bool quoteLoading;
  final VoidCallback onRefresh;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kozmik pusulan hazır.',
                      style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Güneş burcun',
                      style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white60,
                            letterSpacing: 0.6,
                          ),
                    ),
                    Text(
                      sunSign.toUpperCase(),
                      style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Yükselen',
                      style: theme.textTheme.titleSmall?.copyWith(color: Colors.white60),
                    ),
                    Text(
                      ascendant,
                      style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Icons.auto_fix_high, color: Colors.white54, size: 32),
                  const SizedBox(height: 8),
                  const Icon(Icons.rocket_launch_outlined, color: Colors.white70, size: 36),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: quoteLoading ? null : onRefresh,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Yenile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white38,
                      side: BorderSide(color: Colors.white.withOpacity(0.4)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: quoteLoading
                  ? Row(
                      key: const ValueKey('quote-loading'),
                      children: const [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Günün sözü yükleniyor...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    )
                  : Text(
                      quote ?? (error ?? 'Bugünün sözü hazır değil.'),
                      key: ValueKey(quote ?? error ?? 'quote-empty'),
                      style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            height: 1.4,
                          ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoroscopeDeck extends StatelessWidget {
  const _HoroscopeDeck({
    required this.bundle,
    required this.loading,
    required this.error,
    required this.sunSign,
    required this.onRetry,
  });

  final HoroscopeBundle? bundle;
  final bool loading;
  final String? error;
  final String sunSign;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const _StateMessageCard(
        icon: Icons.auto_awesome,
        message: 'Burç yorumları yükleniyor...',
      );
    }

    if (bundle == null) {
      return _StateMessageCard(
        icon: Icons.warning_amber_outlined,
        message: error ?? 'Burç yorumları alınamadı.',
        actionLabel: 'Tekrar dene',
        onAction: onRetry,
      );
    }

    final theme = Theme.of(context);
    final content = bundle!;
    return DefaultTabController(
      length: 3,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$sunSign için kozmik rehber',
              style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Theme(
              data: theme.copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: TabBar(
                labelColor: Colors.white,
                indicatorColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                tabs: const [
                  Tab(text: 'Günlük'),
                  Tab(text: 'Aylık'),
                  Tab(text: 'Yıllık'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _HoroscopeText(content.daily),
                  _HoroscopeText(content.monthly),
                  _HoroscopeText(content.yearly),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoroscopeText extends StatelessWidget {
  const _HoroscopeText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.45,
            ),
      ),
    );
  }
}

class _AstroInsights extends StatelessWidget {
  const _AstroInsights({
    required this.ascendant,
    required this.moonPhase,
  });

  final String ascendant;
  final String moonPhase;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final double? cardWidth = isWide ? (constraints.maxWidth - 16) / 2 : null;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: cardWidth,
              child: _InfoCard(
                icon: Icons.auto_graph,
                title: 'Yükselen enerjin',
                headline: ascendant,
                description: 'Günün temasını yükselen burcun belirliyor. Sosyal adımlarını sezgilerine göre planla.',
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _InfoCard(
                icon: Icons.nightlight_round,
                title: 'Ay fazı',
                headline: moonPhase,
                description: 'Ayın fazı duygularını şekillendirir. Ritüellerini bu ritme göre ayarla.',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.headline,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String headline;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white60,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      headline,
                      style: theme.textTheme.titleLarge?.copyWith(
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
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _PlanetaryGrid extends StatelessWidget {
  const _PlanetaryGrid({
    required this.snapshot,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  final PlanetarySnapshot? snapshot;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const _StateMessageCard(
        icon: Icons.public_outlined,
        message: 'Gezegen bilgileri yükleniyor...',
      );
    }

    final planets = snapshot?.planets ?? [];
    if (planets.isEmpty) {
      return _StateMessageCard(
        icon: Icons.public,
        message: error ?? 'Gezegen bilgileri alınamadı.',
        actionLabel: 'Tekrar dene',
        onAction: onRetry,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final double? cardWidth = isWide ? (constraints.maxWidth - 16) / 2 : null;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: planets.map((planet) {
            return SizedBox(
              width: cardWidth,
              child: _InfoCard(
                icon: _planetIconFor(planet.name),
                title: planet.name,
                headline: planet.headline,
                description: planet.detail,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  IconData _planetIconFor(String name) {
    switch (name.toLowerCase()) {
      case 'venüs':
        return Icons.favorite_border;
      case 'mars':
        return Icons.local_fire_department_outlined;
      case 'merkür':
        return Icons.bolt_outlined;
      default:
        return Icons.public;
    }
  }
}

class _RecommendationChips extends StatelessWidget {
  const _RecommendationChips();

  @override
  Widget build(BuildContext context) {
    const labels = [
      'Meditasyon 10 dk',
      'Nefes çalışması',
      'Astroloji günlüğü',
      'Mars-Venüs ritüeli',
      'Su içmeyi unutma',
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final label in labels) _ChipPill(label: label),
      ],
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _StateMessageCard extends StatelessWidget {
  const _StateMessageCard({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white54),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({
    required this.cityLabel,
    required this.weather,
    required this.loadingWeather,
    required this.weatherError,
    required this.networkTime,
    required this.loadingTime,
    required this.timeError,
    required this.fallbackNow,
    required this.onRefresh,
  });

  final String cityLabel;
  final WeatherSnapshot? weather;
  final bool loadingWeather;
  final String? weatherError;
  final NetworkTimeSnapshot? networkTime;
  final bool loadingTime;
  final String? timeError;
  final DateTime fallbackNow;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WeatherCard(
          cityLabel: cityLabel,
          weather: weather,
          loading: loadingWeather,
          error: weatherError,
          onRefresh: onRefresh,
        ),
        const SizedBox(height: 16),
        _TimeCard(
          networkTime: networkTime,
          loading: loadingTime,
          error: timeError,
          fallbackNow: fallbackNow,
        ),
        const SizedBox(height: 16),
        const _ToolsCard(),
      ],
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({
    required this.cityLabel,
    required this.weather,
    required this.loading,
    required this.error,
    required this.onRefresh,
  });

  final String cityLabel;
  final WeatherSnapshot? weather;
  final bool loading;
  final String? error;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_queue, color: Colors.white70),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hava Durumu',
                  style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              TextButton.icon(
                onPressed: loading ? null : onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Yenile'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (loading)
            Row(
              children: const [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                ),
                SizedBox(width: 12),
                Text('Hava verileri yükleniyor...', style: TextStyle(color: Colors.white70)),
              ],
            )
          else if (weather == null)
            Text(
              error ?? 'Hava durumu alınamadı.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60),
            )
          else ...[
            Text(
              cityLabel,
              style: theme.textTheme.labelLarge?.copyWith(color: Colors.white60),
            ),
            const SizedBox(height: 6),
            Text(
              '${weather!.temperature.toStringAsFixed(1)}°C',
              style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              weather!.description,
              style: theme.textTheme.titleSmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final data = weather!;
                return Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _WeatherMetric(label: 'Hissedilen', value: '${data.apparentTemperature.toStringAsFixed(1)}°C'),
                    _WeatherMetric(label: 'Nem', value: '${data.humidity.toStringAsFixed(0)}%'),
                    _WeatherMetric(label: 'Rüzgar', value: '${data.windSpeed.toStringAsFixed(1)} m/sn'),
                    _WeatherMetric(label: 'Min/Max', value: '${data.minTemp.toStringAsFixed(0)}° / ${data.maxTemp.toStringAsFixed(0)}°'),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _WeatherMetric extends StatelessWidget {
  const _WeatherMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white54)),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.networkTime,
    required this.loading,
    required this.error,
    required this.fallbackNow,
  });

  final NetworkTimeSnapshot? networkTime;
  final bool loading;
  final String? error;
  final DateTime fallbackNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = networkTime?.dateTime ?? fallbackNow;
    final dateLabel = DateFormat('d MMMM y', 'tr_TR').format(active);
    final timeLabel = DateFormat('HH:mm', 'tr_TR').format(active);
    final zone = networkTime?.timeZone ?? 'Yerel saat';
    final offset = networkTime?.utcOffset ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white70),
              const SizedBox(width: 8),
              Text(
                'Ağ Saati',
                style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (loading)
            Row(
              children: const [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                ),
                SizedBox(width: 12),
                Text('Ağ zamanı getiriliyor...', style: TextStyle(color: Colors.white70)),
              ],
            )
          else if (networkTime == null)
            Text(
              error ?? 'Ağ zamanı alınamadı.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60),
            )
          else ...[
            Text(
              timeLabel,
              style: theme.textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              dateLabel,
              style: theme.textTheme.titleSmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              offset.isNotEmpty ? '$zone · $offset' : zone,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
          ],
        ],
      ),
    );
  }
}

class _ToolsCard extends StatelessWidget {
  const _ToolsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spiritüel araçlar',
            style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          const _ToolRow(
            icon: Icons.bedtime_outlined,
            title: 'Rüya yorumlama',
            subtitle: 'Yapay zekâdan kişisel analizler',
          ),
          const Divider(color: Colors.white12),
          const _ToolRow(
            icon: Icons.auto_awesome,
            title: 'Burç yorumları',
            subtitle: 'Günlük · Aylık · Yıllık rehber',
          ),
          const Divider(color: Colors.white12),
          const _ToolRow(
            icon: Icons.pan_tool_alt_outlined,
            title: 'El falı',
            subtitle: 'Avuç içinden karakter analizi',
          ),
          const Divider(color: Colors.white12),
          const _ToolRow(
            icon: Icons.local_cafe_outlined,
            title: 'Kahve falı',
            subtitle: 'Fincandaki sembollerden mesajlar',
          ),
        ],
      ),
    );
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: Colors.white70),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Colors.white38),
      ],
    );
  }
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                    style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const _DrawerTile(
                icon: Icons.bedtime_outlined,
                label: 'Rüya yorumlama',
                subtitle: 'Yapay zekâ destekli içgörüler',
              ),
              const _DrawerTile(
                icon: Icons.auto_awesome,
                label: 'Burç yorumları',
                subtitle: 'Günlük · Aylık · Yıllık analizler',
              ),
              const _DrawerTile(
                icon: Icons.pan_tool_alt_outlined,
                label: 'El falı',
                subtitle: 'Çizgilerinin mesajlarını keşfet',
              ),
              const _DrawerTile(
                icon: Icons.local_cafe_outlined,
                label: 'Kahve falı',
                subtitle: 'Fincanındaki sembolleri çöz',
              ),
              const Spacer(),
              Text(
                'Göklerin sırlarını keşfet!',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        label,
        style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
            )
          : null,
      onTap: () => Navigator.of(context).pop(),
    );
  }
}
