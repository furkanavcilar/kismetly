import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../services/ai_service.dart';
import 'dream_history_entry.dart';
import 'dream_history_store.dart';

class DreamInterpreterScreen extends StatefulWidget {
  const DreamInterpreterScreen({super.key, required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  State<DreamInterpreterScreen> createState() => _DreamInterpreterScreenState();
}

class _DreamInterpreterScreenState extends State<DreamInterpreterScreen> {
  final _controller = TextEditingController();
  final _aiService = AiService();
  String? _result;
  bool _loading = false;
  String? _error;
  DreamHistoryStore? _historyStore;
  List<DreamHistoryEntry> _history = const [];
  bool _historyLoading = true;

  Future<void> _submit() async {
    final text = _controller.text.trim();
    final loc = AppLocalizations.of(context);
    if (text.isEmpty) {
      setState(() => _error = loc.translate('dreamEmpty'));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final locale = LocaleScope.of(context).locale;
    final response = await _aiService.interpretDream(
      prompt: text,
      locale: locale,
    );
    setState(() {
      _loading = false;
      _result = response;
      if (response.isEmpty) {
        _error = loc.translate('dreamError');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final store = await DreamHistoryStore.load();
      final entries = store.readEntries()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (!mounted) return;
      setState(() {
        _historyStore = store;
        _history = entries;
        _historyLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _historyStore = null;
        _history = const [];
        _historyLoading = false;
      });
    }
  }

  Future<void> _saveCurrentResult() async {
    final result = _result;
    final text = _controller.text.trim();
    if (result == null || result.isEmpty || text.isEmpty) {
      return;
    }
    final loc = AppLocalizations.of(context);
    final localeCode = LocaleScope.of(context).locale.languageCode;
    if (_history.any(
      (entry) => entry.prompt == text && entry.interpretation == result,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('dreamAlreadySaved'))),
      );
      return;
    }
    final store = _historyStore ?? await DreamHistoryStore.load();
    final entry = DreamHistoryEntry.create(
      prompt: text,
      interpretation: result,
      localeCode: localeCode,
    );
    final updated = <DreamHistoryEntry>[entry, ..._history];
    updated.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await store.saveEntries(updated);
    if (!mounted) return;
    setState(() {
      _historyStore = store;
      _history = updated;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.translate('dreamSaved'))),
    );
  }

  Future<void> _removeEntry(DreamHistoryEntry entry) async {
    final loc = AppLocalizations.of(context);
    final store = _historyStore ?? await DreamHistoryStore.load();
    final updated = List<DreamHistoryEntry>.from(_history)
      ..removeWhere((element) => element.id == entry.id);
    await store.saveEntries(updated);
    if (!mounted) return;
    setState(() {
      _historyStore = store;
      _history = updated;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.translate('dreamDeleteSuccess'))),
    );
  }

  Future<void> _confirmDelete(DreamHistoryEntry entry) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            final loc = AppLocalizations.of(context);
            return AlertDialog(
              title: Text(loc.translate('dreamDelete')),
              content: Text(loc.translate('dreamDeleteConfirmation')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child:
                      Text(MaterialLocalizations.of(context).cancelButtonLabel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(loc.translate('dreamDelete')),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!confirmed) {
      return;
    }
    await _removeEntry(entry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final locale = LocaleScope.of(context).locale;
    final formatted =
        DateFormat.yMMMMd(locale.languageCode).format(DateTime.now());
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.onMenuTap,
        ),
        title: Text(loc.translate('dreamTitle')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatted,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              minLines: 5,
              maxLines: 8,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: loc.translate('dreamHint'),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text(loc.translate('dreamLoading')),
                        ],
                      )
                    : Text(loc.translate('dreamSubmit')),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _result == null
                        ? Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              loc.translate('dreamEmpty'),
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : _DreamResultCard(
                            key: ValueKey(_result),
                            result: _result!,
                            onSave: _saveCurrentResult,
                          ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loc.translate('dreamHistoryTitle'),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (_historyLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_history.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        loc.translate('dreamHistoryEmpty'),
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ..._history.map(
                      (entry) => Padding(
                        key: ValueKey(entry.id),
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DreamHistoryTile(
                          entry: entry,
                          onDelete: () => _confirmDelete(entry),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DreamResultCard extends StatelessWidget {
  const _DreamResultCard({
    super.key,
    required this.result,
    required this.onSave,
  });

  final String result;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            result,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.bookmark_add_outlined),
            label: Text(loc.translate('dreamSave')),
          ),
        ),
      ],
    );
  }
}

class _DreamHistoryTile extends StatelessWidget {
  const _DreamHistoryTile({
    required this.entry,
    required this.onDelete,
  });

  final DreamHistoryEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final locale = LocaleScope.of(context).locale;
    final formattedDate =
        DateFormat.yMMMMd(locale.languageCode).add_Hm().format(entry.createdAt);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          entry.prompt,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Text(
          formattedDate,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.primary),
        ),
        children: [
          const SizedBox(height: 8),
          Text(
            entry.interpretation,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              label: Text(loc.translate('dreamDelete')),
            ),
          ),
        ],
      ),
    );
  }
}
