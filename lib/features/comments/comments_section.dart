import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import 'comments_repository.dart';

class CommentsSection extends StatefulWidget {
  const CommentsSection({
    super.key,
    required this.signId,
    required this.signLabel,
  });

  final String signId;
  final String signLabel;

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  late final CommentsRepository _repository;
  final _controller = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = resolveCommentsRepository();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context);
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = loc.translate('commentsHint'));
      return;
    }
    if (text.length > 600) {
      setState(() => _error = loc.translate('commentsTooLong'));
      return;
    }
    if (_containsProfanity(text)) {
      setState(() => _error = loc.translate('commentsProfanity'));
      return;
    }
    try {
      await _repository.addComment(
        signId: widget.signId,
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        text: text,
      );
      setState(() {
        _controller.clear();
        _error = loc.translate('commentsSuccess');
      });
    } catch (error) {
      setState(() => _error = loc.translate('commentsFailure'));
    }
  }

  bool _containsProfanity(String text) {
    const banned = ['küfür', 'lanet', 'aptal'];
    final lower = text.toLowerCase();
    return banned.any(lower.contains);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final locale = LocaleScope.of(context).locale;
    final formatter = DateFormat.yMMMMd(locale.languageCode);
    final user = FirebaseAuth.instance.currentUser;
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.translate('commentsTitle'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: StreamBuilder<List<CommentEntry>>(
            stream: _repository.watchComments(
                signId: widget.signId, date: todayKey),
            builder: (context, snapshot) {
              final data = snapshot.data ?? [];
              if (data.isEmpty) {
                return Center(
                  child: Text(loc.translate('commentsEmpty')),
                );
              }
              return ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = data[index];
                  final name = entry.userId == 'local'
                      ? loc.translate('commentsLocalUser')
                      : entry.displayName;
                  return _CommentBubble(
                    displayName: name,
                    text: entry.text,
                    time: formatter.format(entry.createdAt),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (user == null)
          Text(
            loc.translate('commentsLogin'),
            style: Theme.of(context).textTheme.bodySmall,
          )
        else ...[
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: loc.translate('commentsHint'),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _submit,
              child: Text(loc.translate('commentsSubmit')),
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ],
    );
  }
}

class _CommentBubble extends StatelessWidget {
  const _CommentBubble({
    required this.displayName,
    required this.text,
    required this.time,
  });

  final String displayName;
  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(displayName, style: theme.textTheme.labelLarge),
              Text(time, style: theme.textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}
