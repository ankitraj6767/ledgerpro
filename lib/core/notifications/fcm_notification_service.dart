import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../platform/platform_capabilities.dart';

class FcmNotificationService {
  const FcmNotificationService();

  Future<String?> configure() async {
    if (!PlatformCapabilities.supportsPushNotifications) return null;
    try {
      await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      return messaging.getToken();
    } catch (_) {
      return null;
    }
  }
}
