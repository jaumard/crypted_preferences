import 'dart:convert';
import 'dart:io';

import 'package:crypted_preferences/src/preferences_base.dart';
import 'package:meta/meta.dart';

Future<Preferences> createPreferences({
  @required String path,
  Encoding encoding = utf8,
}) {
  return IOPreferences.preferences(path: path, encoding: encoding);
}

Future<Preferences> createMockedPreferences({
  @required Map<String, Object> data,
}) {
  return IOPreferences.getMockedPreferences(data: data);
}

Future<Preferences> createCryptedPreferences({
  @required String path,
  @required String passPhrase,
  Encoding encoding = utf8,
}) {
  return IOPreferences.cryptedPreferences(path: path, passPhrase: passPhrase, encoding: encoding);
}

class IOPreferences extends Preferences {
  static Future<IOPreferences> getMockedPreferences({
    @required Map<String, Object> data,
  }) async {
    return IOPreferences._(data, false, null, null);
  }

  static Future<IOPreferences> preferences({
    @required String path,
    Encoding encoding = utf8,
  }) async {
    final file = File(path);
    var data = <String, Object>{};
    if (await file.exists()) {
      final content = await file.readAsString(encoding: encoding);
      data = json.decode(content);
    }
    return IOPreferences._(data, false, null, path);
  }

  static Future<IOPreferences> cryptedPreferences({
    @required String path,
    @required String passPhrase,
    Encoding encoding = utf8,
  }) async {
    //TODO uncryped
    final file = File(path);
    var data = <String, Object>{};
    if (await file.exists()) {
      final content = await file.readAsString(encoding: encoding);
      data = json.decode(content);
    }
    return IOPreferences._(data, true, passPhrase, path);
  }

  IOPreferences._(this.preferenceCache, this.isCrypted, this.passPhrase, this.filePath);

  /// is the preferences file crypted
  final bool isCrypted;

  /// file path to save preferences
  final String filePath;

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

    if (filePath != null) {
      final file = File(filePath);
      if (isCrypted) {
        //TODO cryped
      }
      try {
        await file.writeAsString(json.encode(preferenceCache));
      } catch (err) {
        return false;
      }
    }
    return true;
  }

  /// Completes with true once the user preferences for the app has been cleared.
  @override
  Future<bool> clear() async {
    preferenceCache.clear();
    if (filePath != null) {
      final file = File(filePath);
      try {
        await file.delete();
      } catch (err) {
        return false;
      }
    }
    return true;
  }
}
