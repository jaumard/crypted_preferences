import 'package:crypted_preferences/crypted_preferences.dart';

main() async {
  final prefs = await Preferences.preferences(path: './example/prefs');

  print(prefs.get('test'));
  print(prefs.get('complex'));
  print(prefs.getPreferencesSerializable('complex', (data) => _Complex.fromMap(data)));

  await prefs.setString('test', 'ok');
  await prefs.setPreferencesSerializable('complex', _Complex('works', 5));
}

class _Complex with WithPreferencesSerializable {
  final String test;
  final int testInt;

  _Complex(this.test, this.testInt);

  static _Complex fromMap(Map<String, Object> data) {
    return _Complex(data['test'], data['testInt']);
  }

  @override
  Map<String, Object> toMap() {
    return {
      'test': test,
      'testInt': testInt,
    };
  }

  @override
  String toString() {
    return '_Complex{test: $test, testInt: $testInt}';
  }
}
