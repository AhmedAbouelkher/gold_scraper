import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PermissionNotGranted implements Exception {}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  log(message.toString());
}

class PushNotificationService {
  PushNotificationService._();

  ///Requests push notification permission from the user.
  ///
  static Future<void> requestPermission() => FirebaseMessaging.instance.requestPermission();

  ///Returns the current FCM token.
  ///
  static Future<String?> getToken() => FirebaseMessaging.instance.getToken();

  ///Initializes the FCM service.
  ///
  static Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission();
    NotificationSettings settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) throw PermissionNotGranted();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log(message.toString());
    });
  }

  ///Registers a background service which is triggered when the app is in background or terminated.
  static void registerBackgroundService() {
    return FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  ///Updates the user FCM token on the server.
  ///
  static Future<void> updateServiceFCM() async {
    final token = await FirebaseMessaging.instance.getToken();
    log("FCM Token: $token");
  }
}
