import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Messager extends StatefulWidget {
  const Messager({super.key, required this.child});

  final Widget child;

  @override
  State<Messager> createState() => _MessagerState();
}

class _MessagerState extends State<Messager> {
  StreamSubscription<RemoteMessage>? _subscription;

  Future<void> enableNotification() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final apnsToken = await FirebaseMessaging.instance.getToken();
      if (apnsToken != null) {
        print('APNs token: $apnsToken');

        _subscription =
            FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Got a message whilst in the foreground!');
          print('Message data: ${message.data}');

          if (message.notification != null) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(message.notification!.title!),
                content: Text(message.notification!.body!),
              ),
            );
          }
        });
      }
    } else {
      print('User declined or has not accepted permission');
    }
  }

  @override
  void initState() {
    enableNotification();
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
