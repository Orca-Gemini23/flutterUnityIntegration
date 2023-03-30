import 'package:shared_preferences/shared_preferences.dart';

String wifiKey = "isWifiCredsSaved";
String showCaseKey = "isShowCaseDone";

///This class is used to store different data in the local storage . Different methods are used to store/retrieve different data type.
class PreferenceController {
  static late SharedPreferences _prefs;

  static saveboolData(String key, bool value) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool(key, value);
  }

  static Future<bool> getboolData(String key) async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.getBool(key) ?? false;
  }

  static saveStringData(String key, String value) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(key, value);
  }

  static Future<String> getstringData(String key) async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.getString(key) ?? "";
  }
}
