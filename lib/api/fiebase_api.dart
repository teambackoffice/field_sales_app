import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    // Request permission
    final settings = await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Try to get APNs token (iOS only), but don't block app startup
      final apnsToken = await firebaseMessaging.getAPNSToken();
      if (apnsToken != null) {
        print("APNs Token: $apnsToken");
      }

      // Get FCM token
      final fcmToken = await firebaseMessaging.getToken();
      print("FCM Token: $fcmToken");

      // Optional: listen for token refresh
      firebaseMessaging.onTokenRefresh.listen((newToken) {
        print("Refreshed FCM Token: $newToken");
      });
    } else {
      print("Notifications are not allowed by the user");
    }
  }
}
