import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
}

class MessagingService {
  final FirebaseMessaging _fm = FirebaseMessaging.instance;

  Future<bool> requestPermission() async {
    final settings = await _fm.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<String?> getToken() => _fm.getToken();

  Stream<RemoteMessage> onForegroundMessages() => FirebaseMessaging.onMessage;

  Stream<RemoteMessage> onOpenedApp() => FirebaseMessaging.onMessageOpenedApp;

  Future<void> subscribe(String topic) => _fm.subscribeToTopic(topic);

  Future<void> unsubscribe(String topic) => _fm.unsubscribeFromTopic(topic);

  static void configureBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
}
