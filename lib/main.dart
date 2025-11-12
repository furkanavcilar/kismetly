import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home.dart';
import 'screens/compatibility.dart';
import 'firebase_options.dart';

@immutable
class ShellNavigation {
  const ShellNavigation({
    required this.openMenu,
    required this.openCompatibility,
  });

  final VoidCallback openMenu;
  final VoidCallback openCompatibility;
}

class _ShellPage {
  const _ShellPage({
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final Widget Function(ShellNavigation navigation) builder;
}

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final PageController _pageController;
  int _pageIndex = 0;

  static const _compatibilityIndex = 4;

  late final List<_ShellPage> _pages = [
    _ShellPage(
      title: 'Ana Sayfa',
      subtitle: 'Kişisel astrolojik akış',
      builder: (navigation) => HomeScreen(
        onMenuTap: navigation.openMenu,
        onOpenCompatibility: navigation.openCompatibility,
      ),
    ),
    _ShellPage(
      title: 'Rüya yorumlama',
      subtitle: 'Yapay zekâ destekli içgörüler',
      builder: (navigation) => _SimpleInfoScreen(
        onMenuTap: navigation.openMenu,
        title: 'Rüya yorumlama',
        description:
            'Rüyalarını çözmek için semboller, duygular ve temalar arasında gezin. '
            'Yakında kişiselleştirilmiş analizler de burada olacak.',
      ),
    ),
    _ShellPage(
      title: 'Burç yorumları',
      subtitle: 'Günlük · Aylık · Yıllık rehber',
      builder: (navigation) => _SimpleInfoScreen(
        onMenuTap: navigation.openMenu,
        title: 'Burç yorumları',
        description:
            'Tüm burçlar için güncel yorumlar, element bazlı trendler ve '
            'yaklaşan gökyüzü olayları burada toplanıyor.',
        highlightAction: (
          icon: Icons.favorite_outline,
          label: 'Uyumluluğu gör',
          onTap: navigation.openCompatibility,
        ),
      ),
    ),
    _ShellPage(
      title: 'El falı',
      subtitle: 'Avuç içinden karakter',
      builder: (navigation) => _SimpleInfoScreen(
        onMenuTap: navigation.openMenu,
        title: 'El falı',
        description:
            'Avuç çizgilerin enerjisi, karakterini ve kaderini anlatır. '
            'Yakında bu bölümde detaylı analizler yer alacak.',
      ),
    ),
    _ShellPage(
      title: 'Zodyak Uyumu',
      subtitle: 'Aşk, arkadaşlık ve ekip enerjileri',
      builder: (navigation) => ZodiacCompatibilityScreen(
        onMenuTap: navigation.openMenu,
      ),
    ),
    _ShellPage(
      title: 'Kahve falı',
      subtitle: 'Fincandaki semboller',
      builder: (navigation) => _SimpleInfoScreen(
        onMenuTap: navigation.openMenu,
        title: 'Kahve falı',
        description:
            'Fincandaki semboller, ruh hâlini ve geleceğe dair işaretleri '
            'yansıtır. Fal aracımız için hazırlıklar sürüyor.',
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _goToPage(int index) {
    if (index == _pageIndex) {
      Navigator.of(context).maybePop();
      _scaffoldKey.currentState?.closeDrawer();
      return;
    }
    setState(() => _pageIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
    _scaffoldKey.currentState?.closeDrawer();
  }

  void _goToCompatibility() => _goToPage(_compatibilityIndex);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _AppDrawer(
        currentIndex: _pageIndex,
        pages: _pages,
        onSelect: _goToPage,
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (value) => setState(() => _pageIndex = value),
        itemCount: _pages.length,
        itemBuilder: (context, index) {
          final page = _pages[index];
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOut,
            child: KeyedSubtree(
              key: ValueKey(page.title),
              child: page.builder(
                ShellNavigation(
                  openMenu: _openDrawer,
                  openCompatibility: _goToCompatibility,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.currentIndex,
    required this.pages,
    required this.onSelect,
  });

  final int currentIndex;
  final List<_ShellPage> pages;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context).textTheme;
    return Drawer(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text('Kismetly Menü', style: th.titleLarge);
            }
            final page = pages[index - 1];
            final selected = currentIndex == index - 1;
            return _DrawerTile(
              title: page.title,
              subtitle: page.subtitle,
              selected: selected,
              onTap: () => onSelect(index - 1),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemCount: pages.length + 1,
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context).textTheme;
    return Material(
      color: selected ? Colors.white.withOpacity(0.08) : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: th.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: th.bodySmall?.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? Colors.amberAccent : Colors.white24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleInfoScreen extends StatelessWidget {
  const _SimpleInfoScreen({
    required this.onMenuTap,
    required this.title,
    required this.description,
    this.highlightAction,
  });

  final VoidCallback onMenuTap;
  final String title;
  final String description;
  final ({IconData icon, String label, VoidCallback onTap})? highlightAction;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context).textTheme;
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF101010)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: onMenuTap,
                    tooltip: 'Menü',
                  ),
                  const SizedBox(width: 12),
                  Text(title, style: th.titleLarge),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          style: th.bodyLarge?.copyWith(color: Colors.white70),
                        ),
                        if (highlightAction != null) ...[
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                            onPressed: highlightAction!.onTap,
                            icon: Icon(highlightAction!.icon),
                            label: Text(highlightAction!.label),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Firebase varsa çalıştır; yoksa sessizce devam
Future<void> _tryInitFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    debugPrint('Firebase başlatma atlandı: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  await _tryInitFirebase();
  runApp(const KismetlyApp());
}

class KismetlyApp extends StatelessWidget {
  const KismetlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.playfairDisplayTextTheme(
      ThemeData(brightness: Brightness.dark).textTheme,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kismetly',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: textTheme.copyWith(
          bodyMedium: textTheme.bodyMedium?.copyWith(height: 1.45),
          bodyLarge: textTheme.bodyLarge?.copyWith(height: 1.45),
          labelSmall: textTheme.labelSmall?.copyWith(letterSpacing: 0.2),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.white70,
        ),
      ),
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: const _MainShell(),
    );
  }
}
