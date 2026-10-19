import 'package:web/web.dart' as web;
import 'key_value.dart';

class BrowserStore implements KeyValueStore {
  @override
  String? read(String key) => web.window.localStorage.getItem(key);
  @override
  void write(String key, String value) =>
      web.window.localStorage.setItem(key, value);
}
