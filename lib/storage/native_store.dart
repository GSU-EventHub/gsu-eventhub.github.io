import 'package:path_provider/path_provider.dart';
import 'file_store.dart';
import 'key_value.dart';

Future<KeyValueStore> openStore() async {
  final directory = await getApplicationSupportDirectory();
  return FileStore(directory);
}
