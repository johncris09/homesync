import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/dates.dart';
import '../../shared/sheet_body.dart';
import 'open_file.dart';
import 'vault_providers.dart';
import 'vault_repository.dart';
import 'vault_screen.dart';

/// One document: number (masked until shown), dates, its photos and PDFs,
/// and, for the owner, any version kept from an edit on another device.
class VaultDocumentScreen extends ConsumerStatefulWidget {
  const VaultDocumentScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<VaultDocumentScreen> createState() => _VaultDocumentScreenState();
}

class _VaultDocumentScreenState extends ConsumerState<VaultDocumentScreen> {
  bool _showNumber = false;
  bool _adding = false;

  Future<void> _add(Future<(Uint8List, String, String)?> Function() pick) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final picked = await pick();
    if (picked == null) return;
    setState(() => _adding = true);
    try {
      await ref.read(vaultRepoProvider).addFile(widget.id, picked.$1, name: picked.$2, mime: picked.$3);
    } on VaultFileTooBig {
      messenger.showSnackBar(SnackBar(content: Text(l10n.vaultFileTooBig)));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  static Future<(Uint8List, String, String)?> _photo(ImageSource source) async {
    final x = await ImagePicker().pickImage(source: source, maxWidth: 2400, maxHeight: 2400, imageQuality: 85);
    if (x == null) return null;
    final mime = x.mimeType ?? (x.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg');
    return (await x.readAsBytes(), x.name, mime);
  }

  static Future<(Uint8List, String, String)?> _pdf() async {
    final files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const ['pdf']);
    if (files.isEmpty) return null;
    return (await files.first.readAsBytes(), files.first.name, 'application/pdf');
  }

  Future<void> _delete(VaultDoc doc) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        content: Text(l10n.vaultDeleteConfirm(doc.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l10n.cancel)),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(l10n.vaultDelete)),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(vaultRepoProvider).deleteDoc(doc.item.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final unlocked = ref.watch(vaultSessionProvider.select((s) => s.unlocked));
    // Locking (or someone else taking over the tablet) closes the document.
    if (!unlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
      return const Scaffold();
    }
    final doc = ref.watch(vaultDocProvider(widget.id)).value;
    if (doc == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final repo = ref.watch(vaultRepoProvider);
    final files = ref.watch(vaultFilesProvider(widget.id)).value ?? const <VaultFileMeta>[];
    final conflicts = ref.watch(vaultConflictsProvider(widget.id)).value ?? const <ConflictRecord>[];
    final names = {for (final m in ref.watch(membersProvider).value ?? const <Member>[]) m.id: m.name};
    final fields = doc.fields;
    final days = repo.daysLeft(doc.item);
    String date(String? iso) => DateFormat.yMMMd(locale).format(parseIsoDate(iso)!);

    final caption = doc.item.expiresOn == null
        ? vaultKindLabel(l10n, doc.item.kind)
        : days! < 0
        ? l10n.vaultExpiredOn(date(doc.item.expiresOn))
        : l10n.vaultExpiresCaption(date(doc.item.expiresOn));

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            fit: StackFit.passthrough,
            children: [
              ScreenHeader(
                figure: fields == null ? l10n.vaultUnreadable : doc.title,
                caption: caption,
                color: days != null && days < 0 ? HomeColors.gumamela : HomeColors.narra,
                leading: const BackButton(color: Colors.white),
              ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 4,
                right: 8,
                child: Row(
                  children: [
                    if (fields != null)
                      IconButton(
                        tooltip: l10n.vaultEdit,
                        icon: const Icon(Icons.edit_outlined, color: Colors.white),
                        onPressed: () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => VaultDocForm(doc: doc),
                        ),
                      ),
                    IconButton(
                      tooltip: l10n.vaultDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.white),
                      onPressed: () => _delete(doc),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final c in conflicts) _ConflictCard(conflict: c, names: names),
                if (fields != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (fields.number.isNotEmpty) ...[
                            Text(l10n.vaultNumber, style: const TextStyle(color: Colors.black54)),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _showNumber ? fields.number : maskNumber(fields.number),
                                    key: const Key('vault-number'),
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                IconButton(
                                  tooltip: _showNumber ? l10n.vaultHideNumber : l10n.vaultShowNumber,
                                  icon: Icon(_showNumber ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                  onPressed: () => setState(() => _showNumber = !_showNumber),
                                ),
                                IconButton(
                                  tooltip: l10n.vaultCopy,
                                  icon: const Icon(Icons.copy),
                                  onPressed: () => Clipboard.setData(ClipboardData(text: fields.number)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          _Line(l10n.vaultKind, vaultKindLabel(l10n, doc.item.kind)),
                          if (names[doc.item.memberId] != null) _Line(l10n.vaultWhose, names[doc.item.memberId]!),
                          if (fields.issuer.isNotEmpty) _Line(l10n.vaultIssuer, fields.issuer),
                          if (fields.issuedOn != null) _Line(l10n.vaultIssuedOn, date(fields.issuedOn)),
                          if (doc.item.expiresOn != null) _Line(l10n.vaultExpiresOnLabel, date(doc.item.expiresOn)),
                          if (fields.note.isNotEmpty) ...[const SizedBox(height: 8), Text(fields.note)],
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
                  child: Text(l10n.vaultFiles, style: Theme.of(context).textTheme.titleMedium),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final f in files) _FileTile(meta: f),
                    if (_adding)
                      const SizedBox.square(dimension: 104, child: Center(child: CircularProgressIndicator())),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (Theme.of(context).platform == TargetPlatform.android)
                      ActionChip(
                        avatar: const Icon(Icons.photo_camera_outlined),
                        label: Text(l10n.vaultTakePhoto),
                        onPressed: () => _add(() => _photo(ImageSource.camera)),
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.photo_outlined),
                      label: Text(l10n.vaultAddPhoto),
                      onPressed: () => _add(() => _photo(ImageSource.gallery)),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(l10n.vaultAddPdf),
                      onPressed: () => _add(_pdf),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: const TextStyle(color: Colors.black54)),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

/// A photo (decrypted thumbnail) or a PDF; tap to open.
class _FileTile extends ConsumerStatefulWidget {
  const _FileTile({required this.meta});

  final VaultFileMeta meta;

  @override
  ConsumerState<_FileTile> createState() => _FileTileState();
}

class _FileTileState extends ConsumerState<_FileTile> {
  Future<Uint8List?>? _bytes;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (widget.meta.isImage) _load();
  }

  void _load() {
    _bytes = ref.read(vaultRepoProvider).readFile(widget.meta.file).catchError((Object _) {
      if (mounted) setState(() => _failed = true);
      return null;
    });
  }

  Future<void> _open() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    _bytes ??= ref.read(vaultRepoProvider).readFile(widget.meta.file);
    Uint8List? bytes;
    try {
      bytes = await _bytes;
    } catch (_) {
      _bytes = null;
      messenger.showSnackBar(SnackBar(content: Text(l10n.vaultFileOffline)));
      return;
    }
    if (bytes == null) {
      _bytes = null;
      messenger.showSnackBar(SnackBar(content: Text(l10n.vaultFileNotUploaded)));
      return;
    }
    if (widget.meta.isImage) {
      await navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => _PhotoScreen(meta: widget.meta, bytes: bytes!),
        ),
      );
    } else {
      await openDecryptedFile(bytes, name: widget.meta.name, mime: widget.meta.mime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = widget.meta;
    return InkWell(
      key: Key('vault-file-${meta.file.id}'),
      borderRadius: BorderRadius.circular(14),
      onTap: _open,
      child: Container(
        width: 104,
        height: 104,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: const Color(0xFFD9DDD5), borderRadius: BorderRadius.circular(14)),
        child: meta.isImage && !_failed
            ? FutureBuilder<Uint8List?>(
                future: _bytes,
                builder: (_, snap) => snap.data != null
                    ? Image.memory(snap.data!, fit: BoxFit.cover)
                    : const Center(child: Icon(Icons.photo_outlined, color: Colors.black45)),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(meta.isImage ? Icons.photo_outlined : Icons.picture_as_pdf_outlined, color: Colors.black54),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(meta.name, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PhotoScreen extends ConsumerWidget {
  const _PhotoScreen({required this.meta, required this.bytes});

  final VaultFileMeta meta;
  final Uint8List bytes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: l10n.vaultRemoveFile,
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await ref.read(vaultRepoProvider).removeFile(meta.file.id);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: InteractiveViewer(maxScale: 6, child: Center(child: Image.memory(bytes))),
    );
  }
}

/// A version of the document kept from an edit made on another device at
/// the same time (never auto-merged). The owner chooses.
class _ConflictCard extends ConsumerWidget {
  const _ConflictCard({required this.conflict, required this.names});

  final ConflictRecord conflict;
  final Map<String, String> names;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final owner = ref.watch(isVaultOwnerProvider);
    final repo = ref.watch(vaultRepoProvider);
    final inbox = ref.read(conflictInboxProvider);
    String who(String? id) => names[id] ?? l10n.someone;

    Future<String> describe(String? json) async {
      final v = json == null ? null : jsonDecode(json);
      if (v == null) return l10n.emptyValue;
      if (conflict.field != 'sealed') return '$v';
      final f = await repo.openFields(conflict.entityId, v as String);
      if (f == null) return l10n.vaultUnreadable;
      return [
        f.title,
        if (f.number.isNotEmpty) f.number,
        if (f.issuer.isNotEmpty) f.issuer,
        if (f.note.isNotEmpty) f.note,
      ].join(' · ');
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: const Color(0xFFF7E3B3),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<List<String>>(
            future: Future.wait([describe(conflict.keptValue), describe(conflict.lostValue)]),
            builder: (context, snap) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.vaultConflictTitle, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(l10n.conflictKept(snap.data?[0] ?? '…', who(conflict.keptBy))),
                Text(l10n.conflictLost(snap.data?[1] ?? '…', who(conflict.lostBy))),
                if (owner) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(onPressed: () => inbox.revert(conflict), child: Text(l10n.vaultUseOther)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(onPressed: () => inbox.keep(conflict), child: Text(l10n.keep)),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Text(l10n.vaultConflictOwner),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Add or edit a document.
class VaultDocForm extends ConsumerStatefulWidget {
  const VaultDocForm({super.key, this.doc});

  final VaultDoc? doc;

  @override
  ConsumerState<VaultDocForm> createState() => _VaultDocFormState();
}

class _VaultDocFormState extends ConsumerState<VaultDocForm> {
  late final _title = TextEditingController(text: widget.doc?.fields?.title);
  late final _number = TextEditingController(text: widget.doc?.fields?.number);
  late final _issuer = TextEditingController(text: widget.doc?.fields?.issuer);
  late final _note = TextEditingController(text: widget.doc?.fields?.note);
  late String _kind = widget.doc?.item.kind ?? 'id';
  late String? _memberId = widget.doc?.item.memberId;
  late DateTime? _issued = parseIsoDate(widget.doc?.fields?.issuedOn);
  late DateTime? _expires = parseIsoDate(widget.doc?.item.expiresOn);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_title, _number, _issuer, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_title.text.trim().isEmpty) return setState(() => _error = l10n.vaultTitleRequired);
    setState(() => _busy = true);
    final navigator = Navigator.of(context);
    final id = await ref
        .read(vaultRepoProvider)
        .saveDoc(
          id: widget.doc?.item.id,
          kind: _kind,
          memberId: _memberId,
          expiresOn: _expires == null ? null : isoDate(_expires!),
          fields: VaultFields(
            title: _title.text.trim(),
            number: _number.text.trim(),
            issuer: _issuer.text.trim(),
            issuedOn: _issued == null ? null : isoDate(_issued!),
            note: _note.text.trim(),
          ),
        );
    navigator.pop();
    if (widget.doc == null) {
      await navigator.push(MaterialPageRoute<void>(builder: (_) => VaultDocumentScreen(id: id)));
    }
  }

  Future<DateTime?> _pick(DateTime? initial) {
    final today = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial ?? today,
      firstDate: DateTime(1900),
      lastDate: DateTime(today.year + 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    String date(DateTime d) => DateFormat.yMMMd(locale).format(d);

    Widget dateRow(String label, DateTime? value, ValueChanged<DateTime?> set) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: Text(value == null ? label : '$label · ${date(value)}'),
      trailing: value == null ? null : IconButton(icon: const Icon(Icons.close), onPressed: () => set(null)),
      onTap: () async {
        final picked = await _pick(value);
        if (picked != null) set(picked);
      },
    );

    return SheetBody(
      title: widget.doc == null ? l10n.vaultAdd : l10n.vaultEdit,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final k in vaultKinds)
              ChoiceChip(
                avatar: Icon(vaultKindIcon(k), size: 18),
                label: Text(vaultKindLabel(l10n, k)),
                selected: _kind == k,
                onSelected: (_) => setState(() => _kind = k),
              ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('vault-title'),
          controller: _title,
          autofocus: widget.doc == null,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.vaultTitle, hintText: l10n.vaultTitleHint, errorText: _error),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('vault-number-field'),
          controller: _number,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(labelText: l10n.vaultNumber),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _issuer,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.vaultIssuer, hintText: l10n.vaultIssuerHint),
        ),
        const SizedBox(height: 16),
        Text(l10n.vaultWhose, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.vaultWholeFamily),
              selected: _memberId == null,
              onSelected: (_) => setState(() => _memberId = null),
            ),
            for (final m in members)
              ChoiceChip(
                label: Text(m.name),
                selected: _memberId == m.id,
                onSelected: (_) => setState(() => _memberId = m.id),
              ),
          ],
        ),
        const SizedBox(height: 8),
        dateRow(l10n.vaultIssuedOn, _issued, (d) => setState(() => _issued = d)),
        dateRow(l10n.vaultExpiresOnLabel, _expires, (d) => setState(() => _expires = d)),
        TextField(
          controller: _note,
          minLines: 1,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.vaultNote),
        ),
        const SizedBox(height: 8),
        Text(l10n.vaultEncryptedNote, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 16),
        FilledButton(key: const Key('vault-save'), onPressed: _busy ? null : _save, child: Text(l10n.save)),
      ],
    );
  }
}
