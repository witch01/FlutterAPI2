import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesControl {
  static String nameKey = '_key_name';

  static Future<bool> saveData(String someText) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(nameKey, someText);
  }

  static Future<String> loadData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(nameKey) ?? '';
  }
}
