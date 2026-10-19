import 'key_value.dart';

class BrowserStore implements KeyValueStore {
  final Map<String, String> values = {};
  @override
  String? read(String key) => values[key];
  @override
  void write(String key, String value) {
    values[key] = value;
  }
}
