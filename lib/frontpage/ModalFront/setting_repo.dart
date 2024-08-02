import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Setting {
  bool isDarkModeEnabled;
  bool isButtonEnabled;
  bool isBoxRotationEnabled;

  Setting({
    required this.isDarkModeEnabled,
    required this.isButtonEnabled,
    required this.isBoxRotationEnabled,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
        isDarkModeEnabled: json['isDarkModeEnabled'] ?? false,
        isButtonEnabled: json['isButtonEnabled'] ?? false,
        isBoxRotationEnabled: json['isBoxRotationEnabled'] ?? false);
  }

  Map<String, dynamic> toJson() => {
        'isDarkModeEnabled': isDarkModeEnabled,
        'isButtonEnabled': isButtonEnabled,
        'isBoxRotationEnabled': isBoxRotationEnabled
      };
}

Future<void> saveSetting(Setting setting) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = jsonEncode(setting.toJson());
  await prefs.setString('setting', jsonString);
}

Future<Setting?> loadSetting() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('setting');

  if (jsonString != null) {
    return Setting.fromJson(jsonDecode(jsonString));
  }
  return null;
}
