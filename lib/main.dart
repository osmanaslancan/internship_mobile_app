import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:internship_mobile_app/Messager.dart';
import 'package:internship_mobile_app/firebase_options.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late WebViewController controller;
  int navigationBarIndex = 0;

  initController() async {
    controller = WebViewController();

    await controller.addJavaScriptChannel("FlutterRegisterToken",
        onMessageReceived: (message) async {
      final apnsToken = await FirebaseMessaging.instance.getToken();
      await controller.runJavaScript('registerToken("$apnsToken")');
    });
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setBackgroundColor(const Color(0x00000000));
    await controller.enableZoom(false);
    await controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {},
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          return NavigationDecision.navigate;
        },
      ),
    );
    await controller.loadRequest(Uri.parse('http://10.0.2.2:5173'));
  }

  @override
  void initState() {
    super.initState();
    initController();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            controller.reload();
          },
          child: const Icon(Icons.refresh),
        ),
        body: Messager(
          child: SafeArea(
            child: WebViewWidget(controller: controller),
          ),
        ),
      ),
    );
  }
}
