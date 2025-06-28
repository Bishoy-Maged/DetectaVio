import 'package:detectavio/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔕 Background message received: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request permission & setup listeners
  await _initFCM();

  runApp(const MyApp());
}

Future<void> _initFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission (for Android 13+ and iOS)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('✅ Notification permission granted');
  } else {
    print('❌ Notification permission declined');
  }

  // Get FCM token (for backend to send notifications)
  String? token = await messaging.getToken();
  print('🔑 FCM Token: $token');

  // Send FCM token to your PHP backend
  if (token != null) {
    await _sendFcmTokenToBackend(token);
  }

  // Foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('🔔 Foreground message: ${message.notification?.title}');
  });

  // When the app is opened from background via a notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📲 Notification opened the app');
    // You can navigate to a specific screen here
  });
}

Future<void> _sendFcmTokenToBackend(String token) async {
  // Get the current Firebase user
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    print('⚠ User not logged in. FCM token will be sent after login.');
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('https://eed2-2c0f-fc89-8090-bc7c-8440-5205-f15d-b3d4.ngrok-free.app/Graduation%20project/Backend/Login/register_token.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'firebase_uid': user.uid,
        'fcm_token': token,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        // FCM token successfully sent to backend
      } else {
        // Failed to send FCM token to backend
      }
    } else {
      print('❌ Failed to send FCM token to backend. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error sending FCM token to backend: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
        );
    }
}
