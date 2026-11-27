import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _channel = MethodChannel('homesync/secure_screen');

/// Blocks screenshots and the recent-apps preview (Android FLAG_SECURE)
/// while [child] is shown. Does nothing on web.
class SecureScreen extends StatefulWidget {
  const SecureScreen({super.key, required this.child});

  final Widget child;

  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> {
  static int _active = 0;

  static Future<void> _set(bool on) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod<void>('set', on);
    } on MissingPluginException {
      // Tests and other hosts.
    }
  }

  @override
  void initState() {
    super.initState();
    if (_active++ == 0) _set(true);
  }

  @override
  void dispose() {
    if (--_active == 0) _set(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
