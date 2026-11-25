import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Four dots and a number pad. [onComplete] gets the 4 digits and returns an
/// error message to show, or null when the PIN was accepted.
class PinPad extends StatefulWidget {
  const PinPad({super.key, required this.title, required this.onComplete, this.extra});

  final String title;
  final Future<String?> Function(String pin) onComplete;

  /// Optional action under the pad (e.g. biometrics).
  final Widget? extra;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _pin = '';
  String? _error;
  bool _busy = false;

  Future<void> _tap(String digit) async {
    if (_busy || _pin.length == 4) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length < 4) return;
    setState(() => _busy = true);
    final error = await widget.onComplete(_pin);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _pin = '';
      _error = error;
    });
  }

  void _back() {
    if (_busy || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget key(String label, {VoidCallback? onTap, Widget? child}) => Padding(
      padding: const EdgeInsets.all(6),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Material(
          color: HomeColors.card,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Center(child: child ?? Text(label, style: text.headlineSmall)),
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.title, style: text.titleMedium),
        const SizedBox(height: 16),
        Semantics(
          label: '${_pin.length} of 4',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 4; i++)
                Container(
                  margin: const EdgeInsets.all(8),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _pin.length ? HomeColors.narra : HomeColors.narra.withValues(alpha: 0.15),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 24,
          child: _error == null ? null : Text(_error!, style: text.bodyMedium?.copyWith(color: HomeColors.gumamela)),
        ),
        for (final row in const [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9']])
          Row(mainAxisSize: MainAxisSize.min, children: [for (final d in row) key(d, onTap: () => _tap(d))]),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 84),
            key('0', onTap: () => _tap('0')),
            key('', onTap: _back, child: const Icon(Icons.backspace_outlined)),
          ],
        ),
        if (widget.extra != null) ...[const SizedBox(height: 8), widget.extra!],
      ],
    );
  }
}

/// Whole seconds until [until], at least 1 (for "try again in … s").
int secondsUntil(DateTime until) {
  final s = until.difference(DateTime.now()).inSeconds;
  return s < 1 ? 1 : s;
}
