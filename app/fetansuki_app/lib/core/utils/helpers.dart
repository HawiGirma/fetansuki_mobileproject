import 'package:flutter/foundation.dart';

class Helpers {
  // Add global helper functions here
  static void printLog(String message) {
    if (kDebugMode) {
      debugPrint('[LOG]: $message');
    }
  }
}