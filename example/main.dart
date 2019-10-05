import 'dart:async';

import 'package:crypted_preferences/crypted_preferences.dart';

class Pref {
  static Completer<Preferences> _completer;

  static Future<Preferences> getInstance(path) async {
    if (_completer == null) {
      _completer = Completer<Preferences>();
      try {
        final test = await Preferences.preferences(path: path);
        _completer.complete(test);
      } on Exception catch (e) {
        _completer.completeError(e);
        final Future<Preferences> prefFuture = _completer.future;
        _completer = null;
        return prefFuture;
      }
    }
    return _completer.future;
  }
}

main() async {
  final prefs = await Pref.getInstance('./example/prefs');

  print(prefs.get('test'));
  print(prefs.get('complex'));
  print(prefs.getPreferencesSerializable(
      'complex', (data) => _Complex.fromMap(data)));

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
