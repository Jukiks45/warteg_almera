class AdminConstants {
  static const String adminUid =
      '3c5c71bd-4b7d-43a5-8a7f-8b1ee0b73299';

  static bool isAdmin(String? uid) {
    return uid == adminUid;
  }
}
