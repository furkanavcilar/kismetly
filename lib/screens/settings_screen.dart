import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/localization/app_localizations.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _dailyHoroscopeNotifications = true;
  bool _nightlyMotivationNotifications = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt('theme_mode') ?? 0;
      _themeMode = ThemeMode.values[themeModeIndex.clamp(0, 2)];
      _dailyHoroscopeNotifications = prefs.getBool('notifications_daily_horoscope') ?? true;
      _nightlyMotivationNotifications = prefs.getBool('notifications_nightly_motivation') ?? true;
    } catch (e) {
      // Use defaults
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    // Notify app to update theme - trigger rebuild
    if (mounted) {
      // Force app rebuild by navigating away and back (simple approach)
      // In production, could use a ValueNotifier or similar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('settingsThemeSaved') ?? 'Theme saved'),
          duration: const Duration(seconds: 1),
        ),
      );
      // Theme change will be picked up on next app rebuild
    }
  }

  Future<void> _saveNotificationSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    
    // Update notification schedules
    final notificationService = NotificationService();
    if (key == 'notifications_daily_horoscope') {
      if (value) {
        await notificationService.scheduleDailyHoroscope();
      } else {
        await notificationService.cancelDailyHoroscope();
      }
    } else if (key == 'notifications_nightly_motivation') {
      if (value) {
        await notificationService.scheduleNightlyMotivation();
      } else {
        await notificationService.cancelNightlyMotivation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: widget.onMenuTap,
          ),
          title: Text(loc.translate('menuSettings')),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.onMenuTap,
        ),
        title: Text(loc.translate('menuSettings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            loc.translate('settingsTheme') ?? 'Theme',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _ThemeSelector(
            selectedMode: _themeMode,
            onChanged: _saveThemeMode,
          ),
          const SizedBox(height: 32),
          Text(
            loc.translate('settingsNotifications') ?? 'Notifications',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(loc.translate('settingsNotificationsDailyHoroscope') ?? 'Daily Horoscope'),
            subtitle: Text(loc.translate('settingsNotificationsDailyHoroscopeDesc') ?? 'Receive daily horoscope notifications'),
            value: _dailyHoroscopeNotifications,
            onChanged: (value) {
              setState(() => _dailyHoroscopeNotifications = value);
              _saveNotificationSetting('notifications_daily_horoscope', value);
            },
          ),
          SwitchListTile(
            title: Text(loc.translate('settingsNotificationsNightly') ?? 'Nightly Motivation'),
            subtitle: Text(loc.translate('settingsNotificationsNightlyDesc') ?? 'Receive nightly motivation messages'),
            value: _nightlyMotivationNotifications,
            onChanged: (value) {
              setState(() => _nightlyMotivationNotifications = value);
              _saveNotificationSetting('notifications_nightly_motivation', value);
            },
          ),
          const SizedBox(height: 32),
          Text(
            loc.translate('settingsData') ?? 'Data',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ListTile(
            title: Text(loc.translate('settingsClearCache') ?? 'Clear Cache'),
            subtitle: Text(loc.translate('settingsClearCacheDesc') ?? 'Clear saved readings cache'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              // Clear cache keys (but keep user preferences)
              final keys = prefs.getKeys();
              for (final key in keys) {
                if (key.startsWith('ai_insight_') || 
                    key.startsWith('horoscope_') || 
                    key.startsWith('zodiac_details_')) {
                  await prefs.remove(key);
                }
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.translate('settingsCacheCleared') ?? 'Cache cleared'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({
    required this.selectedMode,
    required this.onChanged,
  });

  final ThemeMode selectedMode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    
    return Row(
      children: [
        Expanded(
          child: _ThemeOption(
            label: loc.translate('settingsThemeLight') ?? 'Light',
            mode: ThemeMode.light,
            selected: selectedMode == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ThemeOption(
            label: loc.translate('settingsThemeDark') ?? 'Dark',
            mode: ThemeMode.dark,
            selected: selectedMode == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ThemeOption(
            label: loc.translate('settingsThemeSystem') ?? 'System',
            mode: ThemeMode.system,
            selected: selectedMode == ThemeMode.system,
            onTap: () => onChanged(ThemeMode.system),
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected 
                ? theme.colorScheme.primary 
                : theme.dividerColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? theme.colorScheme.primary : null,
            ),
          ),
        ),
      ),
    );
  }
}

