import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

const campusAnnouncementTopic = 'pengumuman-kampus';
const _tokenStorageKey = 'fcm_registration_token';
const _notificationChannel = AndroidNotificationChannel(
  'campus_announcements',
  'Pengumuman Kampus',
  description: 'Notifikasi pengumuman dari kampus.',
  importance: Importance.high,
);

final _apiBaseUrl = const String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);

class PushService {
  PushService({
    required this.router,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    Dio? dio,
    FlutterSecureStorage? secureStorage,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin(),
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: _apiBaseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 10),
             ),
           ),
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final GoRouter router;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  final ValueNotifier<String> status = ValueNotifier('Notifikasi belum aktif.');
  final ValueNotifier<bool> isSubscribed = ValueNotifier(false);

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _initializeLocalNotifications();
      _listenForMessages();

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _navigateToRoute(initialMessage.data['route'] as String?);
      }

      final permissionGranted = await requestPermission();
      if (!permissionGranted) {
        status.value = 'Izin notifikasi belum diberikan.';
        return;
      }

      await getToken();
    } on Object catch (error, stackTrace) {
      status.value = 'Gagal menyiapkan notifikasi: $error';
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<bool> requestPermission() async {
    // iOS: prompts for alert/badge/sound. Android 13+: requests POST_NOTIFICATIONS.
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    status.value = granted
        ? 'Izin notifikasi diberikan.'
        : 'Izin notifikasi ditolak atau belum ditentukan.';
    return granted;
  }

  Future<String?> getToken() async {
    final token = await _messaging.getToken();
    if (token == null) {
      status.value = 'FCM belum memberikan token perangkat.';
      return null;
    }

    await _registerDevice(token);
    return token;
  }

  Future<void> subscribeToAnnouncements() async {
    await _messaging.subscribeToTopic(campusAnnouncementTopic);
    isSubscribed.value = true;
    status.value = 'Berlangganan topik $campusAnnouncementTopic.';
  }

  Future<void> unsubscribeFromAnnouncements() async {
    await _messaging.unsubscribeFromTopic(campusAnnouncementTopic);
    isSubscribed.value = false;
    status.value = 'Berhenti berlangganan topik $campusAnnouncementTopic.';
  }

  Future<void> _initializeLocalNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        _navigateToRoute(response.payload);
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_notificationChannel);
  }

  void _listenForMessages() {
    _subscriptions.add(
      FirebaseMessaging.onMessage.listen(
        (message) {
          unawaited(
            _showForegroundNotification(message)
                .catchError((Object error, StackTrace stackTrace) {
                  _reportError(
                    'Gagal menampilkan notifikasi foreground',
                    error,
                    stackTrace,
                  );
                }),
          );
        },
        onError: (Object error, StackTrace stackTrace) {
          _reportError('Gagal menerima pesan foreground', error, stackTrace);
        },
      ),
    );
    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => _navigateToRoute(message.data['route'] as String?),
        onError: (Object error, StackTrace stackTrace) {
          _reportError('Gagal membuka notifikasi', error, stackTrace);
        },
      ),
    );
    _subscriptions.add(
      _messaging.onTokenRefresh.listen(
        (token) {
          unawaited(_registerRefreshedToken(token));
        },
        onError: (Object error, StackTrace stackTrace) {
          _reportError('Gagal menerima pembaruan token FCM', error, stackTrace);
        },
      ),
    );
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final androidDetails = AndroidNotificationDetails(
      _notificationChannel.id,
      _notificationChannel.name,
      channelDescription: _notificationChannel.description,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final route = message.data['route'] as String?;

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title: message.notification?.title ?? 'Pengumuman Kampus',
      body: message.notification?.body ?? 'Ada pengumuman baru.',
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: route,
    );
  }

  Future<void> _registerRefreshedToken(String token) async {
    try {
      await _registerDevice(token);
    } on DioException catch (error, stackTrace) {
      _reportError(
        'Gagal mengirim token baru ke POST /devices',
        error,
        stackTrace,
      );
    } on Object catch (error, stackTrace) {
      _reportError('Gagal menyimpan token baru', error, stackTrace);
    }
  }

  Future<void> _registerDevice(String token) async {
    await _dio.post<void>(
      '/devices',
      data: {
        'fcm_token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
      },
    );
    await _secureStorage.write(key: _tokenStorageKey, value: token);
    status.value = 'Token perangkat berhasil dikirim ke POST /devices.';
  }

  void _navigateToRoute(String? route) {
    if (route == null ||
        route.isEmpty ||
        !route.startsWith('/') ||
        route.startsWith('//')) {
      return;
    }
    router.go(route);
  }

  void _reportError(String message, Object error, StackTrace stackTrace) {
    status.value = '$message: $error';
    debugPrint('$message: $error\n$stackTrace');
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    status.dispose();
    isSubscribed.dispose();
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Pesan FCM diterima di background: ${message.messageId}');
  // Handler berjalan di isolate terpisah: jangan akses BuildContext, Widget, Riverpod, atau GoRouter.
}
