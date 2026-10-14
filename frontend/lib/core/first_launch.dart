import 'package:shared_preferences/shared_preferences.dart';

/// Remembers whether the user has already seen the welcome screen
/// on this device (browser localStorage on web, shared_prefs on mobile).
class FirstLaunch {
  FirstLaunch._();

  static const _key = 'dii.has_seen_welcome';

  static Future<bool> hasSeenWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
