import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

mixin WithPreferencesSerializable {
  Map<String, Object> toMap();
}

class Preferences {
  static Future<Preferences> getMockedPreferences({
    @required Map<String, Object> data,
  }) async {
    return Preferences._(data, false, null, null);
  }

  static Future<Preferences> preferences({
    @required String path,
    Encoding encoding = utf8,
  }) async {
    final file = File(path);
    var data = <String, Object>{};
    if (await file.exists()) {
      final content = await file.readAsString(encoding: encoding);
      data = json.decode(content);
    }
    return Preferences._(data, false, null, path);
  }

  static Future<Preferences> cryptedPreferences({
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
    return Preferences._(data, true, passPhrase, path);
  }

  Preferences._(this._preferenceCache, this.isCrypted, this.passPhrase, this.filePath);

  /// is the preferences file crypted
  final bool isCrypted;

  /// PassPhrase used to encrypt the file
  final String passPhrase;

  /// Path to the preferences file
  final String filePath;

  /// The cache that holds all preferences.
  ///
  /// It is instantiated to the current state of the SharedPreferences or
  /// NSUserDefaults object and then kept in sync via setter methods in this
  /// class.
  ///
  /// It is NOT guaranteed that this cache and the device prefs will remain
  /// in sync since the setter method might fail for any reason.
  final Map<String, Object> _preferenceCache;

  /// Returns all keys in the persistent storage.
  Set<String> getKeys() => Set<String>.from(_preferenceCache.keys);

  /// Reads a value of any type from persistent storage.
  T get<T>(String key, {T defaultValue: null}) => _preferenceCache[key] ?? defaultValue;

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// bool.
  bool getBool(String key, {bool defaultValue: null}) => _preferenceCache[key] ?? defaultValue;

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// WithPreferencesSerializable.
  WithPreferencesSerializable getPreferencesSerializable(String key, WithPreferencesSerializable Function(Map<String, Object>) factory, {WithPreferencesSerializable defaultValue: null}) => factory(_preferenceCache[key]) ?? defaultValue;

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// WithPreferencesSerializable.
  WithPreferencesSerializable getPreferences(WithPreferencesSerializable Function(Map<String, Object>) factory, {WithPreferencesSerializable defaultValue: null}) => factory(_preferenceCache) ?? defaultValue;

  /// Reads a value from persistent storage, throwing an exception if it's not
  /// an int.
  int getInt(String key, {int defaultValue: null}) => _preferenceCache[key] ?? defaultValue;

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// double.
  double getDouble(String key, {double defaultValue: null}) => _preferenceCache[key] ?? defaultValue;

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// String.
  String getString(String key, {String defaultValue: null}) => _preferenceCache[key] ?? defaultValue;

  /// Returns true if persistent storage the contains the given [key].
  bool containsKey(String key) => _preferenceCache.containsKey(key);

  /// Reads a set of string values from persistent storage, throwing an
  /// exception if it's not a string set.
  List<String> getStringList(String key, {List<String> defaultValue: null}) {
    List<Object> list = _preferenceCache[key];
    if (list != null && list is! List<String>) {
      list = list.cast<String>().toList();
      _preferenceCache[key] = list;
    }
    return list ?? defaultValue;
  }

  /// Write a value to persistent storage
  Future<bool> setPreferences(WithPreferencesSerializable data) => _setValue(null, data.toMap());

  /// Saves a boolean [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setBool(String key, bool value) => _setValue(key, value);

  /// Saves an integer [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setInt(String key, int value) => _setValue(key, value);

  /// Saves a double [value] to persistent storage in the background.
  ///
  /// Android doesn't support storing doubles, so it will be stored as a float.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setDouble(String key, double value) => _setValue(key, value);

  /// Saves a string [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setString(String key, String value) => _setValue(key, value);

  /// Saves a list of strings [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setStringList(String key, List<String> value) => _setValue(key, value);

  /// Removes an entry from persistent storage.
  Future<bool> remove(String key) => _setValue(key, null);

  /// Set complex object into persistent storage.
  Future<bool> setPreferencesSerializable(String key, WithPreferencesSerializable data) => _setValue(key, data.toMap());

  Future<bool> _setValue(String key, Object value) async {
    if(key == null) {
      _preferenceCache.clear();
      _preferenceCache.addAll(value);
    } else
    if (value == null) {
      _preferenceCache.remove(key);
    } else {
      _preferenceCache[key] = value;
    }

    if (filePath != null) {
      final file = File(filePath);
      if(isCrypted) {
        //TODO cryped
      }
      try {
        await file.writeAsString(json.encode(_preferenceCache));
      } catch (err) {
        return false;
      }
    }
    return true;
  }

  /// Completes with true once the user preferences for the app has been cleared.
  Future<bool> clear() async {
    _preferenceCache.clear();
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
