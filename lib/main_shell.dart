import 'package:flutter/material.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'core/utils/locale_collator.dart';
import 'features/coffee/coffee_reading_screen.dart';
import 'features/dreams/dream_interpreter_screen.dart';
import 'features/profile/profile_screen.dart';
import 'screens/compatibility.dart';
import 'screens/home.dart';
import 'screens/horoscopes_list_screen.dart';
import 'screens/zodiac_encyclopedia_screen.dart';
import 'screens/tarot_reading_screen.dart';
import 'features/palm/palm_reading_screen.dart';
import 'screens/settings_screen.dart';
import 'services/google_auth_service.dart';
import 'features/profile/user_profile_scope.dart';

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
    final openDrawer = _openDrawer;
    final goTo = _goTo;
    return [
      ShellPage(
        id: 'home',
        titleKey: 'menuHome',
        subtitleKey: 'menuHomeSubtitle',
        icon: Icons.auto_awesome,
        builder: (context) => HomeScreen(
          onMenuTap: openDrawer,
          onOpenCompatibility: () => goTo(4),
        ),
      ),
      ShellPage(
        id: 'dreams',
        titleKey: 'menuDreams',
        subtitleKey: 'menuDreamsSubtitle',
        icon: Icons.bedtime,
        builder: (context) => DreamInterpreterScreen(onMenuTap: openDrawer),
      ),
      ShellPage(
        id: 'horoscopes',
        titleKey: 'menuHoroscopes',
        subtitleKey: 'menuHoroscopesSubtitle',
        icon: Icons.auto_graph,
        builder: (context) => HoroscopesListScreen(onMenuTap: openDrawer),
      ),
      ShellPage(
        id: 'zodiac',
        titleKey: 'menuZodiac',
        subtitleKey: 'menuZodiacSubtitle',
        icon: Icons.stars,
        builder: (context) => ZodiacEncyclopediaScreen(onMenuTap: openDrawer),
      ),
      ShellPage(
        id: 'tarot',
        titleKey: 'menuTarot',
        subtitleKey: 'menuTarotSubtitle',
        icon: Icons.style,
        builder: (context) => TarotReadingScreen(onMenuTap: openDrawer),
      ),
      ShellPage(
        id: 'palmistry',
        titleKey: 'menuPalmistry',
        subtitleKey: 'menuPalmistrySubtitle',
        icon: Icons.front_hand,
        builder: (context) => PalmReadingScreen(onMenuTap: openDrawer),
      ),
      ShellPage(
        id: 'compatibility',
        titleKey: 'menuCompatibility',
        subtitleKey: 'menuCompatibilitySubtitle',
        icon: Icons.favorite_outline,
        builder: (context) => ZodiacCompatibilityScreen(onMenuTap: openDrawer),
      ),
      ShellPage(
        id: 'coffee',
        titleKey: 'menuCoffee',
        subtitleKey: 'menuCoffeeSubtitle',
        icon: Icons.local_cafe_outlined,
        builder: (context) => CoffeeReadingScreen(onMenuTap: openDrawer),
      ),
      ShellPage(
        id: 'profile',
        titleKey: 'menuProfile',
        subtitleKey: 'menuProfileSubtitle',
        icon: Icons.person_outline,
        builder: (context) => ProfileScreen(onMenuTap: openDrawer),
      ),
      ShellPage(
        id: 'settings',
        titleKey: 'menuSettings',
        subtitleKey: 'menuSettingsSubtitle',
        icon: Icons.settings_outlined,
        builder: (context) => SettingsScreen(onMenuTap: openDrawer),
      ),
    ];
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.onSelect,
    required this.pages,
  });

  final ValueChanged<int> onSelect;
  final List<ShellPage> pages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final googleAuth = GoogleAuthService();
    final user = googleAuth.currentUser;
    final profileController = UserProfileScope.of(context);
    final profile = profileController.profile;
    
    final displayName = user?.displayName ?? profile?.name ?? 'Guest';
    final photoUrl = user?.photoURL;
    
    // Get initials for avatar
    final initials = displayName
        .split(' ')
        .take(2)
        .map((n) => n.isNotEmpty ? n[0].toUpperCase() : '')
        .join();

    // Find profile page index
    final profileIndex = pages.indexWhere((p) => p.id == 'profile');

    return InkWell(
      onTap: () {
        if (profileIndex != -1) {
          onSelect(profileIndex);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: photoUrl == null
                  ? Text(
                      initials.isNotEmpty ? initials : 'K',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user?.email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      user!.email!,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
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
    // Cache sorted items to avoid re-sorting on every build
    final items = List.generate(pages.length, (index) => index);
    items.sort((a, b) {
      final titleA = loc.translate(pages[a].titleKey);
      final titleB = loc.translate(pages[b].titleKey);
      return collator.compare(titleA, titleB, locale);
    });
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(onSelect: onSelect, pages: pages),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, displayIndex) {
                  final index = items[displayIndex];
                  final page = pages[index];
                  final selected = index == selectedIndex;
                  // Skip profile from menu list - it's in the header
                  if (page.id == 'profile') {
                    return const SizedBox.shrink();
                  }
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
            const _LanguageSwitcher(),
          ],
        ),
      ),
    );
  }
}

class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher();

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
          Text(
            loc.translate('menuLanguage'),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _LocaleChip(
                label: '🇹🇷 ${loc.translate('languageTurkish')}',
                selected: locale.languageCode == 'tr',
                onTap: () async {
                  await provider.setLocale(const Locale('tr'));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(loc.translate('languageSwitchSaved'))),
                  );
                },
              ),
              const SizedBox(width: 12),
              _LocaleChip(
                label: '🇬🇧 ${loc.translate('languageEnglish')}',
                selected: locale.languageCode == 'en',
                onTap: () async {
                  await provider.setLocale(const Locale('en'));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(loc.translate('languageSwitchSaved'))),
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
  const _LocaleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            border: selected
                ? Border(
                    left: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  )
                : null,
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
      backgroundColor: theme.colorScheme.surface,
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
