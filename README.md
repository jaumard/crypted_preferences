# crypted_preferences
Flutter preferences management with crypto capabilities  

For now preferences are not crypted, I'm waiting for FFI to land :) 

But you can still use this package to have multiple preferences files in Desktop, mobile and web.

## Usage 

```
final preferences = await Preferences.preferences({path: 'pathToPrefs'});

preferences.getBool('boolKey');
await preferences.setBool('boolKey', false);
```

## API

### Get and set preference: 

Getter have an optional param `defaultValue` if the preference if not set.

`dynamic get(key)`

`bool getBool(key)`

`Future<bool> setBool(key, value)`

`int getInt(key)`

`Future<bool> setInt(key, value)`

`double getDouble(key)`

`Future<bool> setDouble(key, value)`

`String getString(key)`

`Future<bool> setString(key, value)`

`List<String> getStringList(key)`

`Future<bool> setStringList(key, value)`

### Custom object save as preferences

You can use save custom object using the mixin `WithPreferencesSerializable` on your class, it will serialize your object into a map to save it.

Retrieve an object from a preference key:
`WithPreferencesSerializable getPreferencesSerializable(String key, WithPreferencesSerializable Function(Map<String, Object>))`

Retrieve an object from a preference file
`WithPreferencesSerializable getPreferences(String key, WithPreferencesSerializable Function(Map<String, Object>))` 

### Remove preference:
Future<bool> remove(key)

### Clear all preference:
Future<bool> clear()
