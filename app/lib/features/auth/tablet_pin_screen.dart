import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/auth/pin_hash.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/pin_pad.dart';

/// Shared tablet setup: the person who signed the tablet in chooses the PIN
/// that switches back to them after someone else has used it. Shown by the
/// router until it is set, only while that person is the active profile.
class TabletPinScreen extends ConsumerStatefulWidget {
  const TabletPinScreen({super.key});

  @override
  ConsumerState<TabletPinScreen> createState() => _TabletPinScreenState();
}

class _TabletPinScreenState extends ConsumerState<TabletPinScreen> {
  String? _first;

  Future<String?> _onPin(String pin) async {
    final l10n = AppLocalizations.of(context);
    final first = _first;
    if (first == null) {
      setState(() => _first = pin);
      return null;
    }
    if (pin != first) {
      setState(() => _first = null);
      return l10n.pinsDontMatch;
    }
    final services = ref.read(servicesProvider);
    final session = services.auth.session!;
    // The owner may write members, so their PIN also syncs (other tablets,
    // the members screen). Skipped if their row hasn't synced down yet.
    if (session.main.role == 'owner') {
      final db = services.db;
      final row = await (db.select(db.members)..where((m) => m.id.equals(session.main.memberId))).getSingleOrNull();
      if (row != null) await services.writer.update('members', row.id, {'pin_hash': hashPin(pin)});
    }
    await services.auth.setTabletPin(pin);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(figure: l10n.tabletPinTitle, caption: l10n.tabletPinCaption, color: HomeColors.dagat),
          const SizedBox(height: 24),
          PinPad(
            title: _first == null ? l10n.setPinTitle : l10n.confirmPinTitle,
            onComplete: _onPin,
          ),
        ],
      ),
    );
  }
}
