import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MessagingService {
  final FirebaseMessaging _fcm;
  final FirebaseFirestore _firestore;
  final FlutterLocalNotificationsPlugin _local;

  static const AndroidNotificationChannel _defaultChannel =
      AndroidNotificationChannel(
        'planapp_default_channel',
        'PlanApp Notifications',
        description: 'Thông báo mặc định của PlanApp',
        importance: Importance.defaultImportance,
      );

  MessagingService(this._fcm, this._firestore, this._local);

  Future<void> initialize() async {
    // Request permission (iOS/macOS/Web); Android 13+ also requires POST_NOTIFICATIONS permission.
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Init local notifications for foreground display
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _local.initialize(initSettings);

    // Create Android channel
    if (Platform.isAndroid) {
      final android =
          _local
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await android?.createNotificationChannel(_defaultChannel);
    }

    // Foreground message handler: show as local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      final android = message.notification?.android;
      if (notification != null) {
        await _local.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _defaultChannel.id,
              _defaultChannel.name,
              channelDescription: _defaultChannel.description,
              icon: android?.smallIcon ?? '@mipmap/ic_launcher',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          payload: message.data.isNotEmpty ? message.data.toString() : null,
        );
      }
    });

    // Khi người dùng nhấn vào thông báo để mở app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // TODO: Điều hướng tới màn hình phù hợp dựa trên message.data (taskId/projectId/type)
      // Ví dụ: navigateToTaskDetail(message.data['taskId']);
      // Tạm thời chỉ log lại để debug.
      // ignore: avoid_print
      print('onMessageOpenedApp data: ${message.data}');
    });
  }

  /// Register current device token under users/{userId}/deviceTokens/{token}
  Future<void> ensureUserToken(String userId) async {
    final token = await _fcm.getToken();
    if (token != null) {
      await _saveToken(userId, token);
    }

    _fcm.onTokenRefresh.listen((newToken) async {
      await _saveToken(userId, newToken);
    });
  }

  Future<void> _saveToken(String userId, String token) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('deviceTokens')
        .doc(token);
    await ref.set({
      'token': token,
      'platform': Platform.operatingSystem,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
