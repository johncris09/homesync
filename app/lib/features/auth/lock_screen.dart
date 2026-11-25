import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/auth/pin_hash.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/pin_pad.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _biometrics());
  }

  Future<void> _biometrics() async {
    final lock = ref.read(appLockProvider);
    if (lock.biometrics && mounted) {
      await lock.unlockWithBiometrics(AppLocalizations.of(context).biometricReason);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lock = ref.watch(appLockProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: PinPad(
              title: l10n.lockTitle,
              onComplete: (pin) async {
                try {
                  return await lock.unlockWithPin(pin) ? null : l10n.wrongPin;
                } on TooManyPinAttempts catch (e) {
                  return l10n.tooManyTries(secondsUntil(e.until));
                }
              },
              extra: lock.biometrics
                  ? TextButton.icon(onPressed: _biometrics, icon: const Icon(Icons.fingerprint), label: Text(l10n.useBiometrics))
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
