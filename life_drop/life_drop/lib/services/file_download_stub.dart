import 'dart:io';

/// Non-web fallback for saving files locally to the user's Downloads directory.
void downloadFile({
  required String filename,
  required String content,
  required String mimeType,
}) {
  try {
    final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '.';
    final downloadDir = Directory('$home/Downloads');
    final targetDir = downloadDir.existsSync() ? downloadDir : Directory.current;
    final file = File('${targetDir.path}/$filename');
    file.writeAsStringSync(content);
  } catch (_) {}
}
