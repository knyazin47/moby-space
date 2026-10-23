import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/family_session.dart';
import '../../core/config/space_inbox_content.dart';
import '../../core/config/space_ui_content.dart';
import '../../core/theme/mt_brand_theme.dart';
import '../../data/server/family_api.dart';
import '../../data/server/family_space.dart';
import 'space_components.dart';

class SpaceInboxSection extends StatefulWidget {
  const SpaceInboxSection({
    required this.session,
    required this.space,
    required this.actions,
    this.onChildSection,
    super.key,
  });
  final FamilySession session;
  final FamilySpace space;
  final SpaceActions actions;
  final ValueChanged<String>? onChildSection;
  @override
  State<SpaceInboxSection> createState() => _SpaceInboxSectionState();
}

class _SpaceInboxSectionState extends State<SpaceInboxSection> {
  final _reading = <String>{};
  final _errors = <String>{};

  JsonMap? _visibleChild(SpaceNotice notice) {
    final session = widget.session;
    if (session.phase != FamilySessionPhase.signedIn ||
        !{'adult', 'child'}.contains(session.role)) {
      return null;
    }
    if (session.role == 'child' &&
        (session.snapshot?['actor'] as JsonMap?)?['childId'] !=
            notice.childId) {
      return null;
    }
    for (final child in session.children) {
      if (child['id'] == notice.childId &&
          child['membershipStatus'] == 'active') {
        return child;
      }
    }
    return null;
  }

  String? _adultChildName(SpaceNotice notice) {
    if (widget.session.role != 'adult') return null;
    return _visibleChild(notice)?['displayName'] as String?;
  }

  VoidCallback? _open(SpaceNotice notice) {
    final section = SpaceInboxContent.sectionsByKind[notice.kind];
    if (section == null || _visibleChild(notice) == null) return null;
    if (widget.session.role == 'child') {
      final callback = widget.onChildSection;
      return callback == null
          ? null
          : () {
              if (widget.session.role == 'child' &&
                  _visibleChild(notice) != null) {
                callback(section);
              }
            };
    }
    return () {
      if (widget.session.role == 'adult' && _visibleChild(notice) != null) {
        context.push('/family/child/${notice.childId}/$section');
      }
    };
  }

  Future<void> _markRead(SpaceNotice notice) async {
    if (_reading.contains(notice.id)) return;
    final actor = (widget.session.snapshot?['actor'] as JsonMap?)?['id'];
    setState(() {
      _reading.add(notice.id);
      _errors.remove(notice.id);
    });
    try {
      await widget.session.markNoticeRead(
        childId: notice.childId,
        noticeId: notice.id,
      );
    } catch (_) {
      if (mounted &&
          (widget.session.snapshot?['actor'] as JsonMap?)?['id'] == actor) {
        setState(() => _errors.add(notice.id));
      }
    } finally {
      if (mounted) setState(() => _reading.remove(notice.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final actorChildId =
        (widget.session.snapshot?['actor'] as JsonMap?)?['childId'];
    final notices =
        widget.space.notices
            .where(
              (notice) =>
                  widget.session.role == 'adult' ||
                  (widget.session.role == 'child' &&
                      notice.childId == actorChildId),
            )
            .toList()
          ..sort((a, b) {
            final byTime = b.createdAt.compareTo(a.createdAt);
            return byTime != 0 ? byTime : b.id.compareTo(a.id);
          });
    if (notices.isEmpty) {
      return const SpaceEmpty(
        title: SpaceUiCopy.inboxEmpty,
        body: SpaceUiCopy.inboxEmptyBody,
        asset: SpaceAssets.allowance,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final notice in notices)
          SpacePanel(
            key: ValueKey('inbox-notice-${notice.id}'),
            cloud: !notice.read,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _icon(notice.kind),
                      size: 24,
                      color: MtBrandColors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_adultChildName(notice) case final name?)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                name,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          Text(
                            notice.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    if (!notice.read)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 8),
                        child: Semantics(
                          label: SpaceInboxContent.unread,
                          child: const Icon(
                            Icons.circle,
                            size: 8,
                            color: MtBrandColors.blue,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(notice.body),
                const SizedBox(height: 10),
                Semantics(
                  label:
                      '${SpaceInboxContent.eventTime(notice.createdAt)}, ${SpaceInboxContent.minskTime}',
                  child: Text(
                    SpaceInboxContent.eventTime(notice.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (_errors.contains(notice.id))
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      SpaceInboxContent.readFailed,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: MtBrandColors.red),
                    ),
                  ),
                if (_open(notice) != null || !notice.read) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (_open(notice) case final open?)
                        OutlinedButton(
                          key: ValueKey('inbox-open-${notice.id}'),
                          onPressed: open,
                          child: const Text(SpaceInboxContent.open),
                        ),
                      if (!notice.read)
                        TextButton(
                          key: ValueKey('inbox-read-${notice.id}'),
                          onPressed:
                              _reading.contains(notice.id) ||
                                  !widget.session.connected
                              ? null
                              : () => _markRead(notice),
                          child: Text(
                            _reading.contains(notice.id)
                                ? SpaceInboxContent.reading
                                : SpaceInboxContent.markRead,
                          ),
                        ),
                    ],
                  ),
                ] else
                  Text(
                    SpaceInboxContent.read,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

IconData _icon(String kind) => switch (SpaceInboxContent.sectionsByKind[kind]) {
  'money' => Icons.account_balance_wallet_outlined,
  'work' => Icons.task_alt_rounded,
  'goals' => Icons.flag_outlined,
  'growth' => Icons.school_outlined,
  'settings' => Icons.shield_outlined,
  _ => Icons.notifications_none_rounded,
};
