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
  String? _firebaseError;
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
    try {
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _location = null;
        _city = null;
        _locationTried = true;
        _loadingWeather = false;
        _loadingTime = false;
        _weatherError = 'Konum alınamadı';
        _timeError = 'Konum alınamadı';
      });
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

    try {
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _weather = null;
        _loadingWeather = false;
        _weatherError = 'Hava durumu alınamadı';
      });
    }
  }

  Future<void> _fetchNetworkTime(LocationSnapshot snapshot) async {
    setState(() {
      _loadingTime = true;
      _timeError = null;
    });

    try {
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _networkTime = null;
        _loadingTime = false;
        _timeError = 'Ağ zamanı alınamadı';
      });
    }
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
      Firebase.app();
    } on FirebaseException catch (e) {
      if (e.code == 'no-app') {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        if (!mounted) return;
        setState(() {
          _firebaseStatus = _FirebaseConnectionState.failure;
          _firebaseError = e.message ?? e.code;
        });
        return;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _firebaseStatus = _FirebaseConnectionState.failure;
        _firebaseError = e.toString();
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _firebaseStatus = _FirebaseConnectionState.success;
      _firebaseError = null;
    });
  }

  void _retryFirebaseCheck() {
    setState(() {
      _firebaseStatus = _FirebaseConnectionState.checking;
      _firebaseError = null;
    });
    _checkFirebaseConnection();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeNow = _networkTime?.dateTime ?? _now;
    final dateLabel = DateFormat('d MMMM y', 'tr_TR').format(activeNow);
    final timeLabel = DateFormat('HH:mm', 'tr_TR').format(activeNow);
    final locationLabel =
        _city ?? (_locationTried ? 'Konum bulunamadı' : 'Konum belirleniyor...');
    final headerLine = '$dateLabel · $timeLabel · $locationLabel';
    final timezoneText = _networkTime != null
        ? '${_networkTime!.timeZone} · ${_networkTime!.utcOffset}'
        : 'Yerel saat';
    final marsInfo = _planetByName('Mars');
    final venusInfo = _planetByName('Venüs');
    final suggestions = _buildDailySuggestions();

    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const _HomeDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF04000C),
              Color(0xFF120A3A),
              Color(0xFF2D1C54),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        tooltip: 'Menüyü aç',
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kozmik akışın',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              letterSpacing: 0.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_sunSign sezonu',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _refreshWeatherAndTime,
                      tooltip: 'Verileri yenile',
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.18),
                      radius: 22,
                      child: Text(
                        _sunSign.characters.first,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: switch (_firebaseStatus) {
                    _FirebaseConnectionState.checking => Container(
                        key: const ValueKey('firebase-checking'),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
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
                            Expanded(
                              child: Text(
                                'Firebase bağlantısı kontrol ediliyor...',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _FirebaseConnectionState.success => Container(
                        key: const ValueKey('firebase-success'),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF123524),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.greenAccent.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified,
                                color: Colors.greenAccent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Firebase bağlantısı başarılı ✅',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _FirebaseConnectionState.failure => Container(
                        key: const ValueKey('firebase-failure'),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D1B1B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.redAccent),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Firebase bağlantısı başarısız ❌',
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _retryFirebaseCheck,
                                  child: const Text('Tekrar dene'),
                                ),
                              ],
                            ),
                            if (_firebaseError != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                _firebaseError!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CosmicSectionCard(
                        title: 'Tarih · Saat · Konum',
                        subtitle: timezoneText,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              headerLine,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_loadingWeather)
                              const _StatusLine(
                                icon: Icons.waves,
                                text: 'Hava durumu yükleniyor...',
                              )
                            else if (_weatherError != null)
                              _StatusLine(
                                icon: Icons.cloud_off,
                                text: _weatherError!,
                                color: Colors.orangeAccent,
                              )
                            else if (_weather != null)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _InfoBadge(
                                    label: 'Hava',
                                    value:
                                        '${_weather!.description} · ${_weather!.temperature.toStringAsFixed(0)}°C',
                                  ),
                                  _InfoBadge(
                                    label: 'Hissedilen',
                                    value:
                                        '${_weather!.apparentTemperature.toStringAsFixed(0)}°C',
                                  ),
                                  _InfoBadge(
                                    label: 'Nem',
                                    value:
                                        '%${_weather!.humidity.toStringAsFixed(0)}',
                                  ),
                                ],
                              ),
                            if (_loadingTime)
                              const Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: _StatusLine(
                                  icon: Icons.schedule,
                                  text: 'Ağ saati senkronize ediliyor...',
                                ),
                              )
                            else if (_timeError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: _StatusLine(
                                  icon: Icons.schedule,
                                  text: _timeError!,
                                  color: Colors.orangeAccent,
                                ),
                              )
                            else if (_networkTime != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: _InfoBadge(
                                  label: 'Ağ saati',
                                  value: timezoneText,
                                ),
                              ),
                          ],
                        ),
                      ),
                      _CosmicSectionCard(
                        title: 'Burç yorumları',
                        subtitle: '$_sunSign için günlük yorum',
                        trailing: _loadingHoroscope
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white70,
                                ),
                              )
                            : IconButton(
                                onPressed: _loadHoroscope,
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.white70,
                                ),
                                tooltip: 'Yorumu yenile',
                              ),
                        child: Builder(
                          builder: (context) {
                            if (_loadingHoroscope) {
                              return const _StatusLine(
                                icon: Icons.auto_awesome,
                                text: 'Günlük burç yorumu hazırlanıyor...',
                              );
                            }
                            if (_horoscopeError != null) {
                              return _StatusLine(
                                icon: Icons.error_outline,
                                text: _horoscopeError!,
                                color: Colors.redAccent,
                              );
                            }
                            if (_horoscope == null) {
                              return const _StatusLine(
                                icon: Icons.info_outline,
                                text: 'Burç yorumu bulunamadı.',
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _horoscope!.daily,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Aylık öne çıkanlar',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                          color: Colors.white70,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _horoscope!.monthly,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: Colors.white70,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      _CosmicSectionCard(
                        title: 'Günün sözü',
                        subtitle: 'İlham verici kozmik fısıltı',
                        trailing: _loadingQuote
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white70,
                                ),
                              )
                            : IconButton(
                                onPressed: _loadQuote,
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.white70,
                                ),
                                tooltip: 'Sözü yenile',
                              ),
                        child: Builder(
                          builder: (context) {
                            if (_loadingQuote) {
                              return const _StatusLine(
                                icon: Icons.auto_fix_high,
                                text: 'Günün sözü yükleniyor...',
                              );
                            }
                            if (_quoteError != null) {
                              return _StatusLine(
                                icon: Icons.error_outline,
                                text: _quoteError!,
                                color: Colors.redAccent,
                              );
                            }
                            return Text(
                              _quote ?? 'Bugünün sözü hazırlanamadı.',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                height: 1.6,
                              ),
                            );
                          },
                        ),
                      ),
                      _CosmicSectionCard(
                        title: 'Astroloji bilgileri',
                        subtitle: 'Yükselen, ay fazı ve gezegen tınıları',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoRow(
                              label: 'Yükselen burç',
                              value: _ascendant,
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              label: 'Ay fazı',
                              value: _moonPhaseDescription(activeNow),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Gezegen konumları',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white70,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_loadingPlanets)
                              const _StatusLine(
                                icon: Icons.auto_graph,
                                text: 'Gezegen konumları yükleniyor...',
                              )
                            else if (_planetaryError != null)
                              _StatusLine(
                                icon: Icons.error_outline,
                                text: _planetaryError!,
                                color: Colors.redAccent,
                              )
                            else if (_planetary?.planets.isNotEmpty ?? false)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _planetary!.planets
                                    .take(4)
                                    .map(
                                      (planet) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: _InfoRow(
                                          label: planet.name,
                                          value: planet.headline,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              )
                            else
                              const _StatusLine(
                                icon: Icons.info_outline,
                                text: 'Gezegen bilgisi bulunamadı.',
                              ),
                          ],
                        ),
                      ),
                      _CosmicSectionCard(
                        title: 'Mars & Venüs görünümü',
                        subtitle: 'Tutku ve uyumun gezegenleri',
                        child: Builder(
                          builder: (context) {
                            if (_loadingPlanets) {
                              return const _StatusLine(
                                icon: Icons.auto_graph,
                                text: 'Gezegen verileri yükleniyor...',
                              );
                            }
                            if (_planetaryError != null) {
                              return _StatusLine(
                                icon: Icons.error_outline,
                                text: _planetaryError!,
                                color: Colors.redAccent,
                              );
                            }
                            final cards = <Widget>[];
                            if (marsInfo != null) {
                              cards.add(
                                _PlanetLookCard(
                                  info: marsInfo,
                                  accent: const Color(0xFFE74C3C),
                                ),
                              );
                            }
                            if (venusInfo != null) {
                              cards.add(
                                _PlanetLookCard(
                                  info: venusInfo,
                                  accent: const Color(0xFFED72B8),
                                ),
                              );
                            }
                            if (cards.isEmpty) {
                              return const _StatusLine(
                                icon: Icons.info_outline,
                                text: 'Mars ve Venüs bilgisi bulunamadı.',
                              );
                            }
                            return Column(
                              children: [
                                for (var i = 0; i < cards.length; i++) ...[
                                  cards[i],
                                  if (i < cards.length - 1)
                                    const SizedBox(height: 12),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                      _CosmicSectionCard(
                        title: 'Bugün için öneriler',
                        subtitle: 'Ritüel listeni oluştur',
                        child: Column(
                          children: [
                            for (var i = 0; i < suggestions.length; i++) ...[
                              _SuggestionTile(
                                index: i + 1,
                                text: suggestions[i],
                              ),
                              if (i < suggestions.length - 1)
                                const Divider(
                                  color: Color(0x22FFFFFF),
                                  height: 20,
                                ),
                            ],
                          ],
                        ),
                      ),
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

  PlanetInfo? _planetByName(String name) {
    final planets = _planetary?.planets;
    if (planets == null) return null;
    try {
      return planets.firstWhere((planet) => planet.name == name);
    } catch (_) {
      return null;
    }
  }

  List<String> _buildDailySuggestions() {
    final base = <String>[
      'Gün içinde en az üç derin nefes molası ver.',
      'Akşam gökyüzüne bakıp kısa bir niyet yaz.',
      'Su içmeyi ve bedenini nazikçe hareket ettirmeyi unutma.',
    ];

    const signHints = {
      'Koç': 'Cesur bir adım at ama kalbini dinlemeyi unutma.',
      'Boğa': 'Konfor alanını güzelleştir ve sadeliği seç.',
      'İkizler': 'Merakını besle, kısa bir sohbet sana iyi gelir.',
      'Yengeç': 'Sevdiklerinden gelen desteği kabul et.',
      'Aslan': 'Yaratıcılığını sergile, ışığını paylaş.',
      'Başak': 'Planlarını sadeleştir ve kendine esneklik tanı.',
      'Terazi': 'Dengeni korumak için minik molalar ekle.',
      'Akrep': 'Sezgilerine güven ve dönüşüme alan aç.',
      'Yay': 'Ufuk açıcı bir makale ya da video izle.',
      'Oğlak': 'Hedeflerine küçük ama kararlı bir adım ekle.',
      'Kova': 'Farklı fikirleri dinle ve vizyonunu tazele.',
      'Balık': 'Rüyalarını not al, sezgilerin seni yönlendirsin.',
    };

    final hint = signHints[_sunSign];
    if (hint != null && !base.contains(hint)) {
      base.insert(0, hint);
    }

    if (_horoscope != null) {
      final sentences = _horoscope!.daily.split(RegExp(r'[.!?]'));
      final highlight = sentences.firstWhere(
        (line) => line.trim().isNotEmpty,
        orElse: () => '',
      );
      final trimmed = highlight.trim();
      if (trimmed.isNotEmpty) {
        final formatted = 'Burç mesajın: $trimmed.';
        if (!base.contains(formatted)) {
          base.add(formatted);
        }
      }
    }

    return base;
  }

  String _moonPhaseDescription(DateTime date) {
    final synodicMonth = 29.530588853;
    final knownNewMoon = DateTime(2000, 1, 6, 18, 14);
    final diff = date.toUtc().difference(knownNewMoon);
    final days = diff.inMilliseconds / Duration.millisecondsPerDay;
    var phase = days % synodicMonth;
    if (phase < 0) {
      phase += synodicMonth;
    }
    final fraction = phase / synodicMonth;

    if (fraction < 0.03) return 'Yeni Ay';
    if (fraction < 0.22) return 'Hilal (büyüyen)';
    if (fraction < 0.28) return 'İlk Dördün';
    if (fraction < 0.47) return 'Şişkin Ay (büyüyen)';
    if (fraction < 0.53) return 'Dolunay';
    if (fraction < 0.72) return 'Şişkin Ay (azalan)';
    if (fraction < 0.78) return 'Son Dördün';
    if (fraction < 0.97) return 'Hilal (azalan)';
    return 'Yeni Ay';
  }

class _CosmicSectionCard extends StatelessWidget {
  const _CosmicSectionCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
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
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white60,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white60,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white12),
      ),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: theme.textTheme.labelMedium?.copyWith(
            color: Colors.white70,
          ),
          children: [
            TextSpan(
              text: value,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.icon,
    required this.text,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedColor = color ?? Colors.white70;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: resolvedColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: resolvedColor,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanetLookCard extends StatelessWidget {
  const _PlanetLookCard({
    required this.info,
    required this.accent,
  });

  final PlanetInfo info;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = info.name == 'Mars'
        ? Icons.local_fire_department
        : Icons.spa_outlined;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(0.35)),
        gradient: LinearGradient(
          colors: [
            accent.withOpacity(0.22),
            Colors.black.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.2),
                  border: Border.all(color: accent.withOpacity(0.6)),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.headline,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            info.detail,
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

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.index,
    required this.text,
  });

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          index.toString().padLeft(2, '0'),
          style: theme.textTheme.labelMedium?.copyWith(
            color: Colors.white54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ),
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
