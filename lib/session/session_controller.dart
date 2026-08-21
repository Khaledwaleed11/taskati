import 'package:hive/hive.dart';

class SessionController {
  static final Box sessionBox = Hive.box("session");

  static bool get isLoggedIn {
    return sessionBox.get("isLoggedIn", defaultValue: false) ?? false;
  }

  static Future<void> login({
    required String name,
    required String email,
  }) async {
    await sessionBox.put("isLoggedIn", true);

    await sessionBox.put("userName", name);

    await sessionBox.put("userEmail", email);
  }

  static String get userName {
    return sessionBox.get("userName", defaultValue: "User") ?? "User";
  }

  static String get userEmail {
    return sessionBox.get("userEmail", defaultValue: "") ?? "";
  }

  static Future<void> logout() async {
    await sessionBox.put("isLoggedIn", false);

    await sessionBox.delete("userName");
    await sessionBox.delete("userEmail");
  }
}
