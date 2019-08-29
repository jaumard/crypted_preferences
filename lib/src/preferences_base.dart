import 'dart:convert';

import 'package:crypted_preferences/src/preferences.dart';
import 'package:meta/meta.dart';

mixin WithPreferencesSerializable {
  Map<String, Object> toMap();
}

abstract class Preferences {
  Preferences();

  static Future<Preferences> getMockedPreferences({
    @required Map<String, Object> data,
  }) async {
    return createMockedPreferences(data: data);
  }

  static Future<Preferences> preferences({
    @required String path,
    Encoding encoding = utf8,
  }) async {
    return createPreferences(path: path, encoding: encoding);
  }

  static Future<Preferences> cryptedPreferences({
    @required String path,
    @required String passPhrase,
    Encoding encoding = utf8,
  }) async {
    return createCryptedPreferences(path: path, passPhrase: passPhrase, encoding: encoding);
  }

  Preferences._();

  /// The cache that holds all preferences.
  ///
  /// It is instantiated to the current state of the SharedPreferences or
  /// NSUserDefaults object and then kept in sync via setter methods in this
  /// class.
  ///
  /// It is NOT guaranteed that this cache and the device prefs will remain
  /// in sync since the setter method might fail for any reason.
  @protected
  Map<String, Object> get preferenceCache;

  /// Returns all keys in the persistent storage.
  Set<String> getKeys() => Set<String>.from(preferenceCache.keys);

  /// Reads a value of any type from persistent storage.
  T get<T>(String key, {T defaultValue: null}) => preferenceCache[key] ?? defaultValue;

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// bool.
  bool getBool(String key, {bool defaultValue: null}) => preferenceCache[key] ?? defaultValue;

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// WithPreferencesSerializable.
  WithPreferencesSerializable getPreferencesSerializable(String key, WithPreferencesSerializable Function(Map<String, Object>) factory,
          {WithPreferencesSerializable defaultValue: null}) =>
      factory(preferenceCache[key]) ?? defaultValue;

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// WithPreferencesSerializable.
  WithPreferencesSerializable getPreferences(WithPreferencesSerializable Function(Map<String, Object>) factory,
          {WithPreferencesSerializable defaultValue: null}) =>
      factory(preferenceCache) ?? defaultValue;

  /// Reads a value from persistent storage, throwing an exception if it's not
  /// an int.
  int getInt(String key, {int defaultValue: null}) => preferenceCache[key] ?? defaultValue;

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// double.
  double getDouble(String key, {double defaultValue: null}) => preferenceCache[key] ?? defaultValue;

  /// Reads a value from persistent storage, throwing an exception if it's not a
  /// String.
  String getString(String key, {String defaultValue: null}) => preferenceCache[key] ?? defaultValue;

  /// Returns true if persistent storage the contains the given [key].
  bool containsKey(String key) => preferenceCache.containsKey(key);

  /// Reads a set of string values from persistent storage, throwing an
  /// exception if it's not a string set.
  List<String> getStringList(String key, {List<String> defaultValue: null}) {
    List<Object> list = preferenceCache[key];
    if (list != null && list is! List<String>) {
      list = list.cast<String>().toList();
      preferenceCache[key] = list;
    }
    return list ?? defaultValue;
  }

  /// Write a value to persistent storage
  Future<bool> setPreferences(WithPreferencesSerializable data) => setValue(null, data.toMap());

  /// Saves a boolean [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setBool(String key, bool value) => setValue(key, value);

  /// Saves an integer [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setInt(String key, int value) => setValue(key, value);

  /// Saves a double [value] to persistent storage in the background.
  ///
  /// Android doesn't support storing doubles, so it will be stored as a float.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setDouble(String key, double value) => setValue(key, value);

  /// Saves a string [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setString(String key, String value) => setValue(key, value);

  /// Saves a list of strings [value] to persistent storage in the background.
  ///
  /// If [value] is null, this is equivalent to calling [remove()] on the [key].
  Future<bool> setStringList(String key, List<String> value) => setValue(key, value);

  /// Removes an entry from persistent storage.
  Future<bool> remove(String key) => setValue(key, null);

  /// Set complex object into persistent storage.
  Future<bool> setPreferencesSerializable(String key, WithPreferencesSerializable data) => setValue(key, data.toMap());

  Future<bool> setValue(String key, Object value);

  /// Completes with true once the user preferences for the app has been cleared.
  Future<bool> clear();
}
