import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'core/utils/locale_collator.dart';
import 'features/coffee/coffee_reading_screen.dart';
import 'features/dreams/dream_interpreter_screen.dart';
import 'screens/compatibility.dart';
import 'screens/home.dart';
import 'theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR');
  await initializeDateFormatting('en_US');
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    debugPrint('Firebase not configured, continuing without it.');
  }
  final localeProvider = LocaleProvider();
  await localeProvider.loadSavedLocale();
  runApp(
    LocaleScope(
      notifier: localeProvider,
      child: KismetlyApp(localeProvider: localeProvider),
    ),
  );
}

class KismetlyApp extends StatelessWidget {
  const KismetlyApp({super.key, required this.localeProvider});

  final LocaleProvider localeProvider;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: localeProvider,
      builder: (context, _) {
        return MaterialApp(
          title: 'Kismetly',
          theme: AppTheme.theme(),
          locale: localeProvider.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const MainShell(),
        );
      },
    );
  }
}

class ShellPage {
  const ShellPage({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
    required this.builder,
  });

  final String id;
  final String titleKey;
  final String subtitleKey;
  final IconData icon;
  final WidgetBuilder builder;
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _goTo(int index) {
    setState(() => _index = index);
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
    _scaffoldKey.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final pages = _pages(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        selectedIndex: _index,
        pages: pages,
        onSelect: _goTo,
      ),
      body: PageView.builder(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (value) => setState(() => _index = value),
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final page = pages[index];
          return page.builder(context);
        },
      ),
      floatingActionButton: Visibility(
        visible: _index != 0,
        child: FloatingActionButton.extended(
          onPressed: () => _goTo(0),
          icon: const Icon(Icons.home_outlined),
          label: Text(loc.translate('menuHome')),
        ),
      ),
    );
  }

  List<ShellPage> _pages(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return [
      ShellPage(
        id: 'home',
        titleKey: 'menuHome',
        subtitleKey: 'menuHomeSubtitle',
        icon: Icons.auto_awesome,
        builder: (context) => HomeScreen(
          onMenuTap: _openDrawer,
          onOpenCompatibility: () => _goTo(4),
        ),
      ),
      ShellPage(
        id: 'dreams',
        titleKey: 'menuDreams',
        subtitleKey: 'menuDreamsSubtitle',
        icon: Icons.bedtime,
        builder: (context) => DreamInterpreterScreen(onMenuTap: _openDrawer),
      ),
      ShellPage(
        id: 'horoscopes',
        titleKey: 'menuHoroscopes',
        subtitleKey: 'menuHoroscopesSubtitle',
        icon: Icons.auto_graph,
        builder: (context) => PlaceholderScreen(
          onMenuTap: _openDrawer,
          title: loc.translate('menuHoroscopes'),
          subtitle: loc.translate('menuHoroscopesSubtitle'),
        ),
      ),
      ShellPage(
        id: 'palmistry',
        titleKey: 'menuPalmistry',
        subtitleKey: 'menuPalmistrySubtitle',
        icon: Icons.front_hand,
        builder: (context) => PlaceholderScreen(
          onMenuTap: _openDrawer,
          title: loc.translate('menuPalmistry'),
          subtitle: loc.translate('menuPalmistrySubtitle'),
        ),
      ),
      ShellPage(
        id: 'compatibility',
        titleKey: 'menuCompatibility',
        subtitleKey: 'menuCompatibilitySubtitle',
        icon: Icons.favorite_outline,
        builder: (context) => ZodiacCompatibilityScreen(onMenuTap: _openDrawer),
      ),
      ShellPage(
        id: 'coffee',
        titleKey: 'menuCoffee',
        subtitleKey: 'menuCoffeeSubtitle',
        icon: Icons.local_cafe_outlined,
        builder: (context) => CoffeeReadingScreen(onMenuTap: _openDrawer),
      ),
    ];
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.pages,
    required this.onSelect,
  });

  final int selectedIndex;
  final List<ShellPage> pages;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final locale = LocaleScope.of(context).locale;
    final collator = const LocaleCollator();
    final items = List.generate(pages.length, (index) => index);
    items.sort((a, b) {
      final titleA = loc.translate(pages[a].titleKey);
      final titleB = loc.translate(pages[b].titleKey);
      return collator.compare(titleA, titleB, locale);
    });
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  loc.translate('appTitle'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, displayIndex) {
                  final index = items[displayIndex];
                  final page = pages[index];
                  final selected = index == selectedIndex;
                  return ListTile(
                    leading: Icon(page.icon),
                    title: Text(loc.translate(page.titleKey)),
                    subtitle: Text(loc.translate(page.subtitleKey)),
                    selected: selected,
                    onTap: () => onSelect(index),
                  );
                },
              ),
            ),
            const Divider(),
            _LanguageSwitcher(),
          ],
        ),
      ),
    );
  }
}

class _LanguageSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = LocaleScope.of(context);
    final loc = AppLocalizations.of(context);
    final locale = provider.locale;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loc.translate('menuLanguage'), style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              _LocaleChip(
                label: '🇹🇷 ${loc.translate('languageTurkish')}',
                selected: locale.languageCode == 'tr',
                onTap: () async {
                  await provider.setLocale(const Locale('tr'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.translate('languageSwitchSaved'))),
                  );
                },
              ),
              const SizedBox(width: 12),
              _LocaleChip(
                label: '🇬🇧 ${loc.translate('languageEnglish')}',
                selected: locale.languageCode == 'en',
                onTap: () async {
                  await provider.setLocale(const Locale('en'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.translate('languageSwitchSaved'))),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocaleChip extends StatelessWidget {
  const _LocaleChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.onMenuTap,
    required this.title,
    required this.subtitle,
  });

  final VoidCallback onMenuTap;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: onMenuTap),
        title: Text(title),
      ),
      body: Center(
        child: Text(
          subtitle,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
