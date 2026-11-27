import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Opens a decrypted file (a PDF) in a new browser tab from memory; nothing
/// is written to the browser's storage.
Future<bool> openDecryptedFile(Uint8List bytes, {required String name, required String mime}) async {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mime));
  final url = web.URL.createObjectURL(blob);
  final opened = web.window.open(url, '_blank');
  // Long enough for the new tab to load it.
  Future<void>.delayed(const Duration(minutes: 1), () => web.URL.revokeObjectURL(url));
  return opened != null;
}
