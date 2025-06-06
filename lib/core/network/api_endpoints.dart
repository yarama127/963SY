import 'dart:io' show Platform;

class ApiEndpoints {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'https://963sy.net/back/api/user'; // Android emulator
    } else if (Platform.isIOS) {
      return 'https://963sy.net/back/api/user'; // iOS simulator
    } else {
      return 'https://963sy.net/back/api/user'; // Other platforms
    }
  }

  // Auth endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String refreshToken = '/refresh-token';

  // User endpoints
  static const String userProfile = '/profile';
  static const String updateProfile = '/update-profile';
  static const String languages = '/language1/languages';
  static const String categories =
      '/category1/category/language/1'; // Updated to match your route

  // Add more endpoints as needed
}
