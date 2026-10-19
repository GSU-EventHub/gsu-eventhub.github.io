import 'dart:io';
import 'key_value.dart';

/// Android uses app-private files. Renaming a completed write protects the
/// previous saved list if writing is interrupted. No storage permission needed.
class FileStore implements KeyValueStore {
  final Directory directory;
  FileStore(this.directory);

  File _file(String key) => File('${directory.path}/$key.json');

  @override
  String? read(String key) {
    final file = _file(key);
    return file.existsSync() ? file.readAsStringSync() : null;
  }

  @override
  void write(String key, String value) {
    directory.createSync(recursive: true);
    final temporary = File('${_file(key).path}.tmp');
    temporary.writeAsStringSync(value, flush: true);
    temporary.renameSync(_file(key).path);
  }
}
