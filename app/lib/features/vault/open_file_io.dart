import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Opens a decrypted file (a PDF) in another app. The copy is written to the
/// app's cache and removed the next time a file is opened.
Future<bool> openDecryptedFile(Uint8List bytes, {required String name, required String mime}) async {
  final dir = Directory('${(await getTemporaryDirectory()).path}/vault-open');
  if (await dir.exists()) await dir.delete(recursive: true);
  await dir.create(recursive: true);
  final safe = name.replaceAll(RegExp(r'[^\w.\- ]'), '_');
  final file = File('${dir.path}/${safe.isEmpty ? 'document.pdf' : safe}');
  await file.writeAsBytes(bytes, flush: true);
  final result = await OpenFilex.open(file.path, type: mime);
  return result.type == ResultType.done;
}
