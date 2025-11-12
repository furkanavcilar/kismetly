import 'dart:async';

import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onMenuTap,
    required this.onOpenCompatibility,
  });

  final VoidCallback onMenuTap;
  final VoidCallback onOpenCompatibility;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _now;
  late final String _sunSign;
  late final String _ascendant;
  late final List<String> _signs = AstroService.signs;

  LocationSnapshot? _loc;
  WeatherSnapshot? _weather;
  NetworkTimeSnapshot? _net;
  HoroscopeBundle? _horo;
  PlanetarySnapshot? _planets;
  String? _quote;

  bool _loadingLoc = true;
  bool _loadingWeather = true;
  bool _loadingTime = true;
  bool _loadingHoro = true;
  bool _loadingPlanets = true;
  bool _loadingQuote = true;

  String? _errLoc, _errW, _errT, _errH, _errP;

  Timer? _ticker;
  int _selectedHoroscopeIndex = 0;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _sunSign = AstroService.sunSign(_now);
    _ascendant = AstroService.approxAscendant(TimeOfDay.fromDateTime(_now));
    _startTicker();
    _boot();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  Future<void> _boot() async {
    await _loadLocation();
    _loadQuoteAndHoro();
    _loadPlanets();
  }

  Future<void> _loadLocation() async {
    setState(() {
      _loadingLoc = true;
      _errLoc = null;
    });
    try {
      final l = await LocationService.currentLocation();
      if (!mounted) return;
      setState(() {
        _loc = l;
        _loadingLoc = false;
      });
      if (l != null) {
        _fetchWeather(l);
        _fetchNet(l);
      } else {
        setState(() {
          _loadingWeather = false;
          _loadingTime = false;
          _errW = 'Konum alınamadı';
          _errT = 'Konum alınamadı';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingLoc = false;
        _errLoc = 'Konum hatası';
      });
    }
  }

  Future<void> _fetchWeather(LocationSnapshot l) async {
    setState(() {
      _loadingWeather = true;
      _errW = null;
    });
    final w = await WeatherService.fetchWeather(
      latitude: l.latitude,
      longitude: l.longitude,
    );
    if (!mounted) return;
    setState(() {
      _weather = w;
      _loadingWeather = false;
      if (w == null) _errW = 'Hava durumu alınamadı';
    });
  }

  Future<void> _fetchNet(LocationSnapshot l) async {
    setState(() {
      _loadingTime = true;
      _errT = null;
    });
    final t = await NetworkTimeService.fetchTime(
      latitude: l.latitude,
      longitude: l.longitude,
    );
    if (!mounted) return;
    setState(() {
      _net = t;
      _loadingTime = false;
      if (t != null) {
        _now = t.dateTime;
      } else {
        _errT = 'Ağ zamanı alınamadı';
      }
    });
  }

  Future<void> _loadQuoteAndHoro() async {
    setState(() {
      _loadingHoro = true;
      _loadingQuote = true;
      _errH = null;
    });
    try {
      final results = await Future.wait<dynamic>([
        AstroService.fetchDailyQuote(),
        AstroService.fetchHoroscopeBundle(_sunSign),
      ]);
      if (!mounted) return;
      setState(() {
        _quote = results[0] as String;
        _horo = results[1] as HoroscopeBundle;
        _loadingHoro = false;
        _loadingQuote = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingHoro = false;
        _loadingQuote = false;
        _errH = 'Burç yorumu alınamadı';
      });
    }
  }

  Future<void> _loadPlanets() async {
    setState(() {
      _loadingPlanets = true;
      _errP = null;
    });
    try {
      final p = await AstroService.fetchPlanetarySnapshot();
      if (!mounted) return;
      setState(() {
        _planets = p;
        _loadingPlanets = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingPlanets = false;
        _errP = 'Gezegen bilgisi alınamadı';
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String get _partnerSign =>
      _signs[(_now.day + _now.month) % _signs.length];

  String get _collabSign =>
      _signs[(_now.month * 3 + _now.weekday) % _signs.length];

  List<_EnergyFocus> _dailyEnergies(DateTime date) {
    final weekday = DateFormat('EEEE', 'tr_TR').format(date);
    return [
      _EnergyFocus(
        title: 'Duygusal ritim',
        detail: '$weekday enerjisi sezgileri güçlendiriyor.',
        icon: Icons.self_improvement,
      ),
      _EnergyFocus(
        title: 'Zihin odağı',
        detail: 'Yükselen $_ascendant ile stratejik planlara yer aç.',
        icon: Icons.psychology_outlined,
      ),
      _EnergyFocus(
        title: 'Topluluk',
        detail: '$_sunSign burcu bağlantıları derinleştirmek için uygun.',
        icon: Icons.groups,
      ),
    ];
  }

  List<_InteractionPreview> _interactionPreviews() {
    final loveReport = AstroService.compatibility(_sunSign, _partnerSign);
    final collabReport = AstroService.compatibility(_ascendant, _collabSign);
    final wildCardSign = _signs[(_now.day * 2) % _signs.length];
    final wildReport = AstroService.compatibility(_sunSign, wildCardSign);
    return [
      _InteractionPreview(
        title: 'Aşk uyumu',
        subtitle: '$_sunSign × $_partnerSign',
        icon: Icons.favorite,
        report: loveReport,
      ),
      _InteractionPreview(
        title: 'Takım enerjisi',
        subtitle: '$_ascendant × $_collabSign',
        icon: Icons.handshake,
        report: collabReport,
      ),
      _InteractionPreview(
        title: 'Sürpriz eşleşme',
        subtitle: '$_sunSign × $wildCardSign',
        icon: Icons.auto_awesome,
        report: wildReport,
      ),
    ];
  }

  String _horoscopeTextForIndex(int index) {
    final h = _horo;
    if (h == null) return '—';
    switch (index) {
      case 0:
        return h.daily;
      case 1:
        return h.monthly;
      case 2:
        return h.yearly;
      default:
        return h.daily;
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _net?.dateTime ?? _now;
    final dateText = DateFormat('d MMMM y EEEE', 'tr_TR').format(active);
    final timeText = DateFormat('HH:mm', 'tr_TR').format(active);
    final zoneText =
        _net != null ? '${_net!.timeZone} · ${_net!.utcOffset}' : 'Yerel saat';
    final th = Theme.of(context).textTheme;
    final energies = _dailyEnergies(active);
    final interactions = _interactionPreviews();

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF0E0E0E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: widget.onMenuTap,
                    tooltip: 'Menü',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        _loc?.city ?? 'Konum belirleniyor…',
                        key: ValueKey(_loc?.city ?? '—'),
                        overflow: TextOverflow.ellipsis,
                        style: th.titleMedium?.copyWith(
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white70),
                    tooltip: 'Yenile',
                    onPressed: () async {
                      final l = _loc;
                      if (l != null) {
                        await Future.wait([
                          _fetchWeather(l),
                          _fetchNet(l),
                        ]);
                      } else {
                        await _loadLocation();
                      }
                    },
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white12,
                    child: Text(
                      _sunSign.characters.first,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white12),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroBlock(
                      dateText: dateText,
                      timeText: timeText,
                      zoneText: zoneText,
                      sun: _sunSign,
                      asc: _ascendant,
                    ),
                    const SizedBox(height: 20),
                    _QuickShortcuts(
                      onOpenCompatibility: widget.onOpenCompatibility,
                      onSeeHoroscope: () {
                        setState(() => _selectedHoroscopeIndex = 0);
                        _loadQuoteAndHoro();
                      },
                    ),
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Bugünün ilhamı',
                      trailing: IconButton(
                        icon: const Icon(Icons.refresh, size: 18, color: Colors.white70),
                        onPressed: _loadQuoteAndHoro,
                        tooltip: 'Yenile',
                      ),
                      child: _loadingQuote
                          ? const _LoaderLine('İlham yükleniyor…')
                          : (_quote != null
                              ? AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    _quote!,
                                    key: ValueKey(_quote),
                                    style: th.bodyLarge,
                                  ),
                                )
                              : const _ErrLine('İlham alınamadı')), 
                    ),
                    _Section(
                      title: 'Tarih · Saat · Konum',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$dateText · $timeText · ${_loc?.city ?? "—"}',
                              style: th.titleLarge),
                          const SizedBox(height: 8),
                          _KV('Saat dilimi', zoneText),
                          const SizedBox(height: 8),
                          if (_loadingWeather)
                            const _LoaderLine('Hava durumu yükleniyor…')
                          else if (_errW != null)
                            _ErrLine(_errW!)
                          else if (_weather != null)
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                _Chip('Hava',
                                    '${_weather!.description} · ${_weather!.temperature.toStringAsFixed(0)}°C'),
                                _Chip('Hissedilen',
                                    '${_weather!.apparentTemperature.toStringAsFixed(0)}°C'),
                                _Chip('Nem', '%${_weather!.humidity.toStringAsFixed(0)}'),
                                _Chip('Rüzgar',
                                    '${_weather!.windSpeed.toStringAsFixed(1)} m/sn'),
                              ],
                            ),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Günlük enerjiler',
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final energy in energies)
                            _EnergyCard(focus: energy),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Burç yorumları',
                      trailing: SegmentedButton<int>(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith(
                            (states) => states.contains(MaterialState.selected)
                                ? Colors.white.withOpacity(0.14)
                                : Colors.white.withOpacity(0.03),
                          ),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        segments: const [
                          ButtonSegment(value: 0, label: Text('Günlük')),
                          ButtonSegment(value: 1, label: Text('Aylık')),
                          ButtonSegment(value: 2, label: Text('Yıllık')),
                        ],
                        selected: <int>{_selectedHoroscopeIndex},
                        onSelectionChanged: (values) {
                          final index = values.first;
                          setState(() => _selectedHoroscopeIndex = index);
                        },
                      ),
                      child: _loadingHoro
                          ? const _LoaderLine('Burç yorumları yükleniyor…')
                          : (_errH != null
                              ? _ErrLine(_errH!)
                              : AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    _horoscopeTextForIndex(_selectedHoroscopeIndex),
                                    key: ValueKey(
                                      '${_selectedHoroscopeIndex}_${_horoscopeTextForIndex(_selectedHoroscopeIndex).hashCode}',
                                    ),
                                    style: th.bodyLarge,
                                  ),
                                )),
                    ),
                    _Section(
                      title: 'Astroloji bilgileri',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _KV('Güneş burcu', _sunSign),
                          const SizedBox(height: 8),
                          _KV('Yükselen', _ascendant),
                          const SizedBox(height: 8),
                          _KV('Ay fazı', _moonPhaseDesc(active)),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Astroloji etkileşimleri',
                      trailing: TextButton.icon(
                        onPressed: widget.onOpenCompatibility,
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text('Detaya git'),
                      ),
                      child: Column(
                        children: [
                          for (final interaction in interactions)
                            _InteractionTile(interaction: interaction),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Mars & Venüs görünümü',
                      child: _loadingPlanets
                          ? const _LoaderLine('Gezegen verileri yükleniyor…')
                          : (_errP != null
                              ? _ErrLine(_errP!)
                              : _PlanetsList(snapshot: _planets)),
                    ),
                    _Section(
                      title: 'Bugün için öneriler',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _Bullet('Nefes araları ver.'),
                          _Bullet('Kısa bir niyet yaz.'),
                          _Bullet('Su içmeyi unutma.'),
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
    );
  }

  String _moonPhaseDesc(DateTime date) {
    const synodic = 29.530588853;
    final diff = date.toUtc().difference(DateTime(2000, 1, 6, 18, 14));
    var days = diff.inMilliseconds / Duration.millisecondsPerDay;
    var phase = days % synodic;
    if (phase < 0) phase += synodic;
    final f = phase / synodic;
    if (f < 0.03) return 'Yeni Ay';
    if (f < 0.22) return 'Hilal (büyüyen)';
    if (f < 0.28) return 'İlk Dördün';
    if (f < 0.47) return 'Şişkin (büyüyen)';
    if (f < 0.53) return 'Dolunay';
    if (f < 0.72) return 'Şişkin (azalan)';
    if (f < 0.78) return 'Son Dördün';
    if (f < 0.97) return 'Hilal (azalan)';
    return 'Yeni Ay';
  }
}

class _HeroBlock extends StatelessWidget {
  const _HeroBlock({
    required this.dateText,
    required this.timeText,
    required this.zoneText,
    required this.sun,
    required this.asc,
  });

  final String dateText;
  final String timeText;
  final String zoneText;
  final String sun;
  final String asc;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
        color: Colors.white.withOpacity(0.02),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Astroloji for life on Earth.', style: th.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  '$dateText · $timeText',
                  style: th.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  zoneText,
                  style: th.labelSmall?.copyWith(color: Colors.white60),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('GÜNEŞ',
                  style: th.labelSmall?.copyWith(color: Colors.white60)),
              Text(sun.toUpperCase(), style: th.titleLarge),
              const SizedBox(height: 8),
              Text('YÜKSELEN',
                  style: th.labelSmall?.copyWith(color: Colors.white60)),
              Text(asc, style: th.titleLarge),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        color: Colors.white.withOpacity(0.02),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: th.titleMedium)),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _KV extends StatelessWidget {
  const _KV(this.k, this.v);

  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context).textTheme;
    return RichText(
      text: TextSpan(
        text: '$k: ',
        style: th.bodyMedium?.copyWith(color: Colors.white70),
        children: [
          TextSpan(
            text: v,
            style: th.bodyMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white12),
        color: Colors.white.withOpacity(0.04),
      ),
      child: Text('$label: $value'),
    );
  }
}

class _LoaderLine extends StatelessWidget {
  const _LoaderLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context).textTheme;
    return Row(
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white70,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: th.bodyMedium?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class _ErrLine extends StatelessWidget {
  const _ErrLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context).textTheme;
    return Text(
      text,
      style: th.bodyMedium?.copyWith(color: Colors.orangeAccent),
    );
  }
}

class _PlanetsList extends StatelessWidget {
  const _PlanetsList({required this.snapshot});

  final PlanetarySnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final p = snapshot?.planets ?? [];
    if (p.isEmpty) return const Text('—');
    final th = Theme.of(context).textTheme;
    return Column(
      children: [
        for (final e in p)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.public, size: 18, color: Colors.white70),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.name, style: th.titleSmall),
                      Text(
                        e.detail,
                        style: th.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _EnergyFocus {
  const _EnergyFocus({
    required this.title,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String detail;
  final IconData icon;
}

class _EnergyCard extends StatelessWidget {
  const _EnergyCard({required this.focus});

  final _EnergyFocus focus;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context).textTheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        color: Colors.white.withOpacity(0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(focus.icon, color: Colors.amberAccent),
          const SizedBox(height: 12),
          Text(focus.title, style: th.titleMedium),
          const SizedBox(height: 8),
          Text(
            focus.detail,
            style: th.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _QuickShortcuts extends StatelessWidget {
  const _QuickShortcuts({
    required this.onOpenCompatibility,
    required this.onSeeHoroscope,
  });

  final VoidCallback onOpenCompatibility;
  final VoidCallback onSeeHoroscope;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: _ShortcutButton(
            icon: Icons.favorite,
            label: 'Uyum hesapla',
            onTap: onOpenCompatibility,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ShortcutButton(
            icon: Icons.star,
            label: 'Trend burçlar',
            onTap: onSeeHoroscope,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ShortcutButton(
            icon: Icons.spa,
            label: 'Ritüel önerisi',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bugün minik bir niyet defteri molası öneriyoruz.'),
                duration: Duration(seconds: 3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  const _ShortcutButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
          color: Colors.white.withOpacity(0.03),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.amberAccent),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractionPreview {
  const _InteractionPreview({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.report,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final CompatibilityReport report;
}

class _InteractionTile extends StatelessWidget {
  const _InteractionTile({required this.interaction});

  final _InteractionPreview interaction;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context).textTheme;
    final percent = (interaction.report.score * 100).round();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
        color: Colors.white.withOpacity(0.025),
      ),
      child: Row(
        children: [
          Icon(interaction.icon, color: Colors.amberAccent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(interaction.title, style: th.titleMedium),
                const SizedBox(height: 4),
                Text(
                  interaction.subtitle,
                  style: th.bodySmall?.copyWith(color: Colors.white60),
                ),
                const SizedBox(height: 6),
                Text(
                  interaction.report.tone,
                  style: th.bodySmall?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$percent%', style: th.titleLarge),
              Text(
                'uyum',
                style: th.bodySmall?.copyWith(color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
