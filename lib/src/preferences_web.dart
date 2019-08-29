import 'dart:convert';
import 'dart:html';

import 'package:crypted_preferences/src/preferences_base.dart';
import 'package:meta/meta.dart';

Future<Preferences> createPreferences({
  @required String path,
  Encoding encoding = utf8,
}) {
  return WebPreferences.preferences(path: path, encoding: encoding);
}

Future<Preferences> createMockedPreferences({
  @required Map<String, Object> data,
}) {
  return WebPreferences.getMockedPreferences(data: data);
}

Future<Preferences> createCryptedPreferences({
  @required String path,
  @required String passPhrase,
  Encoding encoding = utf8,
}) {
  return WebPreferences.cryptedPreferences(path: path, passPhrase: passPhrase, encoding: encoding);
}

class WebPreferences extends Preferences {
  static Future<WebPreferences> getMockedPreferences({
    @required Map<String, Object> data,
  }) async {
    return WebPreferences._(data, false, null);
  }

  static Future<WebPreferences> preferences({
    @required String path,
    Encoding encoding = utf8,
  }) async {
    return WebPreferences._(window.localStorage, false, null);
  }

  static Future<WebPreferences> cryptedPreferences({
    @required String path,
    @required String passPhrase,
    Encoding encoding = utf8,
  }) async {
    //TODO uncryped
    return WebPreferences._(window.localStorage, true, passPhrase);
  }

  WebPreferences._(this.preferenceCache, this.isCrypted, this.passPhrase);

  /// is the preferences file crypted
  final bool isCrypted;

  /// PassPhrase used to encrypt the file
  final String passPhrase;

  /// The cache that holds all preferences.
  ///
  /// It is instantiated to the current state of the SharedPreferences or
  /// NSUserDefaults object and then kept in sync via setter methods in this
  /// class.
  ///
  /// It is NOT guaranteed that this cache and the device prefs will remain
  /// in sync since the setter method might fail for any reason.
  final Map<String, Object> preferenceCache;

  @override
  Future<bool> setValue(String key, Object value) async {
    if (key == null) {
      preferenceCache.clear();
      preferenceCache.addAll(value);
    } else if (value == null) {
      preferenceCache.remove(key);
    } else {
      preferenceCache[key] = value;
    }

    return true;
  }

  /// Completes with true once the user preferences for the app has been cleared.
  @override
  Future<bool> clear() async {
    preferenceCache.clear();
    return true;
  }
}
