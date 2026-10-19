import 'key_value.dart';
import 'web_store.dart' if (dart.library.io) 'native_store.dart' as platform;

Future<KeyValueStore> openStore() => platform.openStore();
