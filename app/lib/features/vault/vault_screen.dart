import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/auth/pin_hash.dart';
import '../../core/db/database.dart';
import '../../core/vault/vault_crypto.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/dates.dart';
import '../../shared/pin_pad.dart';
import '../../shared/sheet_body.dart';
import '../sync/sync_widgets.dart';
import 'vault_document_screen.dart';
import 'vault_providers.dart';
import 'secure_screen.dart';
import 'vault_repository.dart';

IconData vaultKindIcon(String kind) => switch (kind) {
  'id' => Icons.badge_outlined,
  'certificate' => Icons.workspace_premium_outlined,
  'property' => Icons.home_outlined,
  'contract' => Icons.handshake_outlined,
  'insurance' => Icons.shield_outlined,
  'warranty' => Icons.verified_outlined,
  'vehicle' => Icons.directions_car_outlined,
  'pawn' => Icons.diamond_outlined,
  _ => Icons.description_outlined,
};

String vaultKindLabel(AppLocalizations l10n, String kind) => switch (kind) {
  'id' => l10n.vaultKindId,
  'certificate' => l10n.vaultKindCertificate,
  'property' => l10n.vaultKindProperty,
  'contract' => l10n.vaultKindContract,
  'insurance' => l10n.vaultKindInsurance,
  'warranty' => l10n.vaultKindWarranty,
  'vehicle' => l10n.vaultKindVehicle,
  'pawn' => l10n.vaultKindPawn,
  _ => l10n.vaultKindOther,
};

/// Section heading for a kind in the list ("IDs", "Property").
String vaultKindGroup(AppLocalizations l10n, String kind) => switch (kind) {
  'id' => l10n.vaultGroupId,
  'certificate' => l10n.vaultGroupCertificate,
  'property' => l10n.vaultGroupProperty,
  'contract' => l10n.vaultGroupContract,
  'insurance' => l10n.vaultGroupInsurance,
  'warranty' => l10n.vaultGroupWarranty,
  'vehicle' => l10n.vaultGroupVehicle,
  'pawn' => l10n.vaultGroupPawn,
  _ => l10n.vaultGroupOther,
};

/// Document Vault (docs/vault.md): set up by the owner, opened with the
/// household vault passphrase, documents grouped by kind with what needs
/// renewing on top. Narra header: the wooden baul where a Filipino family
/// keeps its titles and birth certificates.
class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyRow = ref.watch(vaultKeyRowProvider);
    final unlocked = ref.watch(vaultSessionProvider.select((s) => s.unlocked));
    if (!keyRow.hasValue) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return SecureScreen(
      child: keyRow.value == null
          ? const _SetUpView()
          : !unlocked
          ? const _LockedView()
          : const _VaultList(),
    );
  }
}

// ------------------------------------------------------------------ set up

class _SetUpView extends ConsumerStatefulWidget {
  const _SetUpView();

  @override
  ConsumerState<_SetUpView> createState() => _SetUpViewState();
}

class _SetUpViewState extends ConsumerState<_SetUpView> {
  final _first = TextEditingController();
  final _second = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  Future<void> _setUp() async {
    final l10n = AppLocalizations.of(context);
    final pass = _first.text.trim();
    if (pass.length < minPassphraseLength) {
      return setState(() => _error = l10n.vaultPassphraseTooShort(minPassphraseLength));
    }
    if (pass != _second.text.trim()) return setState(() => _error = l10n.vaultPassphrasesDontMatch);
    setState(() {
      _busy = true;
      _error = null;
    });
    final services = ref.read(servicesProvider);
    final repo = ref.read(vaultRepoProvider);
    try {
      // Online first, so two devices can't each make a different key.
      await services.engine.sync();
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = l10n.vaultSetUpOffline;
        });
      }
      return;
    }
    if (await repo.keyRow() != null) {
      if (mounted) setState(() => _busy = false); // set up elsewhere meanwhile
      return;
    }
    final code = await repo.setUp(pass, saveKey: ref.read(vaultMayKeepKeyProvider));
    if (!mounted) return;
    await showRecoveryCode(context, code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final owner = ref.watch(isVaultOwnerProvider);
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            figure: l10n.vaultSetUpTitle,
            caption: l10n.vaultSetUpCaption,
            leading: const BackButton(color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: owner
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.vaultSetUpBody),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('vault-pass-1'),
                        controller: _first,
                        obscureText: true,
                        decoration: InputDecoration(labelText: l10n.vaultPassphrase),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('vault-pass-2'),
                        controller: _second,
                        obscureText: true,
                        decoration: InputDecoration(labelText: l10n.vaultPassphraseAgain, errorText: _error),
                        onSubmitted: (_) => _setUp(),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _busy ? null : _setUp,
                        child: _busy ? const _Spinner() : Text(l10n.vaultSetUpButton),
                      ),
                    ],
                  )
                : Text(l10n.vaultNotSetUp),
          ),
        ],
      ),
    );
  }
}

/// Shows a recovery code once and waits until the owner confirms they kept it.
Future<void> showRecoveryCode(BuildContext context, RecoveryCode code) => Navigator.of(
  context,
).push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => _RecoveryCodeScreen(code: code)));

class _RecoveryCodeScreen extends StatefulWidget {
  const _RecoveryCodeScreen({required this.code});

  final RecoveryCode code;

  @override
  State<_RecoveryCodeScreen> createState() => _RecoveryCodeScreenState();
}

class _RecoveryCodeScreenState extends State<_RecoveryCodeScreen> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groups = widget.code.text.split('-');
    return PopScope(
      canPop: _saved,
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            ScreenHeader(figure: l10n.vaultRecoveryTitle, caption: l10n.vaultRecoveryCaption),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                      child: SelectableText(
                        '${groups.sublist(0, 2).join('-')}\n${groups.sublist(2, 4).join('-')}\n${groups.sublist(4).join('-')}',
                        key: const Key('vault-recovery-code'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 24, height: 1.6, letterSpacing: 2),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Clipboard.setData(ClipboardData(text: widget.code.text)),
                    icon: const Icon(Icons.copy),
                    label: Text(l10n.vaultCopy),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.vaultRecoveryBody),
                  const SizedBox(height: 12),
                  Card(
                    child: CheckboxListTile(
                      key: const Key('vault-recovery-saved'),
                      value: _saved,
                      onChanged: (v) => setState(() => _saved = v ?? false),
                      title: Text(l10n.vaultRecoverySaved),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _saved ? () => Navigator.of(context).pop() : null,
                    child: Text(l10n.vaultFinish),
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

// ------------------------------------------------------------------ locked

class _LockedView extends ConsumerStatefulWidget {
  const _LockedView();

  @override
  ConsumerState<_LockedView> createState() => _LockedViewState();
}

class _LockedViewState extends ConsumerState<_LockedView> {
  final _pass = TextEditingController();
  String? _error;
  bool _busy = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _checkSaved();
  }

  @override
  void dispose() {
    _pass.dispose();
    super.dispose();
  }

  Future<void> _checkSaved() async {
    final services = ref.read(servicesProvider);
    final household = ref.read(authProvider).session!.householdId;
    final has = await services.vault.hasSavedKey(household);
    if (!has) return;
    // A key kept while app lock was on is dropped once app lock is off.
    if (!ref.read(vaultMayKeepKeyProvider)) return services.vault.forget(household);
    if (!mounted) return;
    setState(() => _saved = true);
    await _openSaved();
  }

  /// App PIN or fingerprint, then the key kept on this phone.
  Future<void> _openSaved() async {
    final l10n = AppLocalizations.of(context);
    final lock = ref.read(appLockProvider);
    final household = ref.read(authProvider).session!.householdId;
    var ok = lock.biometrics && await lock.unlockWithBiometrics(l10n.vaultBiometricReason);
    if (!ok && mounted) {
      ok =
          await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            builder: (sheet) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: PinPad(
                title: l10n.vaultPinTitle,
                onComplete: (pin) async {
                  try {
                    if (!await lock.unlockWithPin(pin)) return l10n.wrongPin;
                  } on TooManyPinAttempts catch (e) {
                    return l10n.tooManyTries(secondsUntil(e.until));
                  }
                  if (sheet.mounted) Navigator.of(sheet).pop(true);
                  return null;
                },
              ),
            ),
          ) ??
          false;
    }
    if (ok) await ref.read(servicesProvider).vault.openSaved(household);
  }

  Future<void> _unlock() async {
    final l10n = AppLocalizations.of(context);
    if (_pass.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await ref
        .read(vaultRepoProvider)
        .unlockWithPassphrase(_pass.text, saveKey: ref.read(vaultMayKeepKeyProvider));
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = ok ? null : l10n.vaultWrongPassphrase;
    });
  }

  Future<void> _recover() async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(vaultRepoProvider);
    final keep = ref.read(vaultMayKeepKeyProvider);
    final opened = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CodeSheet(
        title: l10n.vaultUseRecovery,
        hint: l10n.vaultRecoveryHint,
        check: (typed) => repo.unlockWithRecovery(typed, saveKey: keep),
        error: l10n.vaultWrongRecovery,
      ),
    );
    if (opened == true && mounted) {
      // The passphrase was forgotten: choose a new one now.
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        builder: (_) => const PassphraseSheet(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.watch(vaultRepoProvider);
    final items = ref.watch(vaultItemsProvider).value ?? const <VaultItem>[];
    final renew = items.where(repo.renewSoon).length;
    final owner = ref.watch(isVaultOwnerProvider);
    final android = ref.watch(vaultMayKeepKeyProvider);
    final appLockOff = !ref.watch(appLockProvider).enabled && Theme.of(context).platform == TargetPlatform.android;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ScreenHeader(
            figure: l10n.vaultDocuments(items.length),
            caption: renew > 0 ? l10n.vaultLockedRenew(renew) : l10n.vaultLockedCaption,
            leading: const BackButton(color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Icon(Icons.lock_outline, size: 48, color: HomeColors.narra),
                const SizedBox(height: 16),
                if (_saved) ...[
                  FilledButton.icon(
                    onPressed: _openSaved,
                    icon: Icon(ref.watch(appLockProvider).biometrics ? Icons.fingerprint : Icons.pin_outlined),
                    label: Text(l10n.vaultUnlock),
                  ),
                ] else ...[
                  TextField(
                    key: const Key('vault-unlock-pass'),
                    controller: _pass,
                    obscureText: true,
                    autofocus: true,
                    decoration: InputDecoration(labelText: l10n.vaultPassphrase, errorText: _error),
                    onSubmitted: (_) => _unlock(),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _busy ? null : _unlock,
                    child: _busy ? const _Spinner() : Text(l10n.vaultUnlock),
                  ),
                  if (_busy) ...[const SizedBox(height: 8), Text(l10n.vaultOpening, textAlign: TextAlign.center)],
                  if (!android && appLockOff) ...[
                    const SizedBox(height: 12),
                    Text(l10n.vaultAppLockHint, textAlign: TextAlign.center),
                  ],
                ],
                if (owner) TextButton(onPressed: _recover, child: Text(l10n.vaultUseRecovery)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) =>
      const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white));
}

/// Sheet with one text field; [check] returns whether it was right.
class _CodeSheet extends StatefulWidget {
  const _CodeSheet({required this.title, required this.hint, required this.check, required this.error});

  final String title;
  final String hint;
  final Future<bool> Function(String) check;
  final String error;

  @override
  State<_CodeSheet> createState() => _CodeSheetState();
}

class _CodeSheetState extends State<_CodeSheet> {
  final _code = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await widget.check(_code.text);
    if (!mounted) return;
    if (ok) return Navigator.of(context).pop(true);
    setState(() {
      _busy = false;
      _error = widget.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SheetBody(
      title: widget.title,
      children: [
        TextField(
          key: const Key('vault-code'),
          controller: _code,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(hintText: widget.hint, errorText: _error),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _busy ? null : _submit, child: _busy ? const _Spinner() : Text(l10n.vaultUnlock)),
      ],
    );
  }
}

/// Owner: choose a new vault passphrase (after recovery, or in settings).
class PassphraseSheet extends ConsumerStatefulWidget {
  const PassphraseSheet({super.key});

  @override
  ConsumerState<PassphraseSheet> createState() => _PassphraseSheetState();
}

class _PassphraseSheetState extends ConsumerState<PassphraseSheet> {
  final _first = TextEditingController();
  final _second = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final pass = _first.text.trim();
    if (pass.length < minPassphraseLength) {
      return setState(() => _error = l10n.vaultPassphraseTooShort(minPassphraseLength));
    }
    if (pass != _second.text.trim()) return setState(() => _error = l10n.vaultPassphrasesDontMatch);
    setState(() => _busy = true);
    await ref.read(vaultRepoProvider).changePassphrase(pass);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SheetBody(
      title: l10n.vaultNewPassphrase,
      children: [
        Text(l10n.vaultNewPassphraseBody),
        const SizedBox(height: 12),
        TextField(
          key: const Key('vault-new-pass-1'),
          controller: _first,
          obscureText: true,
          decoration: InputDecoration(labelText: l10n.vaultPassphrase),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('vault-new-pass-2'),
          controller: _second,
          obscureText: true,
          decoration: InputDecoration(labelText: l10n.vaultPassphraseAgain, errorText: _error),
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: 16),
        FilledButton(onPressed: _busy ? null : _save, child: _busy ? const _Spinner() : Text(l10n.save)),
      ],
    );
  }
}

// -------------------------------------------------------------------- list

class _VaultList extends ConsumerWidget {
  const _VaultList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final repo = ref.watch(vaultRepoProvider);
    final docs = ref.watch(vaultDocsProvider).value ?? const <VaultDoc>[];
    final owner = ref.watch(isVaultOwnerProvider);

    final renew = docs.where((d) => repo.renewSoon(d.item)).toList()
      ..sort((a, b) => a.item.expiresOn!.compareTo(b.item.expiresOn!));
    final next = renew.isEmpty ? null : renew.first;
    final caption = next == null
        ? l10n.vaultKeptSafe
        : l10n.vaultExpiresOn(next.title, DateFormat.yMMMd(locale).format(parseIsoDate(next.item.expiresOn)!));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: HomeColors.mangga,
        foregroundColor: HomeColors.narra,
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const VaultDocForm(),
        ),
        icon: const Icon(Icons.add),
        label: Text(l10n.vaultAdd),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              ScreenHeader(
                figure: l10n.vaultDocuments(docs.length),
                caption: caption,
                leading: const BackButton(color: Colors.white),
              ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 4,
                right: 8,
                child: Row(
                  children: [
                    if (owner)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (v) async {
                          if (v == 'pass') {
                            await showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => const PassphraseSheet(),
                            );
                          } else if (v == 'code') {
                            final code = await repo.newRecoveryCode();
                            if (context.mounted) await showRecoveryCode(context, code);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(value: 'pass', child: Text(l10n.vaultChangePassphrase)),
                          PopupMenuItem(value: 'code', child: Text(l10n.vaultNewRecoveryCode)),
                        ],
                      ),
                    IconButton(
                      tooltip: l10n.vaultLock,
                      icon: const Icon(Icons.lock_outline, color: Colors.white),
                      onPressed: () => ref.read(servicesProvider).vault.lock(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (docs.isEmpty) Padding(padding: const EdgeInsets.only(top: 16), child: Text(l10n.vaultEmpty)),
                if (renew.isNotEmpty) ...[
                  _Heading(l10n.vaultRenewSoon),
                  for (final d in renew) _DocTile(doc: d, showDays: true),
                ],
                for (final kind in vaultKinds)
                  if (docs.any((d) => d.item.kind == kind)) ...[
                    _Heading(vaultKindGroup(l10n, kind)),
                    for (final d in docs.where((d) => d.item.kind == kind)) _DocTile(doc: d),
                  ],
                if (docs.any((d) => !vaultKinds.contains(d.item.kind))) ...[
                  _Heading(l10n.vaultGroupOther),
                  for (final d in docs.where((d) => !vaultKinds.contains(d.item.kind))) _DocTile(doc: d),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _DocTile extends ConsumerWidget {
  const _DocTile({required this.doc, this.showDays = false});

  final VaultDoc doc;
  final bool showDays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final repo = ref.watch(vaultRepoProvider);
    final names = {for (final m in ref.watch(membersProvider).value ?? const <Member>[]) m.id: m.name};
    final item = doc.item;
    final days = repo.daysLeft(item);
    final soon = repo.renewSoon(item);
    final expired = days != null && days < 0;
    final owner = names[item.memberId];
    final title = doc.fields == null
        ? l10n.vaultUnreadable
        : (owner == null ? doc.title : l10n.vaultTitleOf(doc.title, owner));
    final number = doc.fields?.number ?? '';
    final subtitle = showDays && days != null
        ? (expired ? l10n.vaultExpiredDaysAgo(-days) : l10n.vaultDaysLeft(days))
        : number.isNotEmpty
        ? maskNumber(number)
        : vaultKindLabel(l10n, item.kind);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
          leading: CircleAvatar(
            backgroundColor: expired ? HomeColors.gumamela : (soon ? HomeColors.mangga : const Color(0xFFE3E0DA)),
            foregroundColor: expired ? Colors.white : HomeColors.narra,
            child: Icon(vaultKindIcon(item.kind)),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SyncMarker(entity: 'vault_items', id: item.id),
              if (!showDays && soon && item.expiresOn != null)
                Chip(
                  label: Text(DateFormat.MMMd(locale).format(parseIsoDate(item.expiresOn)!)),
                  backgroundColor: expired ? HomeColors.gumamela : HomeColors.mangga,
                  labelStyle: TextStyle(color: expired ? Colors.white : HomeColors.narra),
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          onTap: () =>
              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => VaultDocumentScreen(id: item.id))),
        ),
      ),
    );
  }
}
