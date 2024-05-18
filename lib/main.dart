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
  ThemeMode themeMode = ThemeMode.system;

  initController() async {
    controller = WebViewController();

    await controller.addJavaScriptChannel("FlutterRegisterToken",
        onMessageReceived: (message) async {
      final apnsToken = await FirebaseMessaging.instance.getToken();
      await controller.runJavaScript('registerToken("$apnsToken")');
    });
    await controller.addJavaScriptChannel("FlutterChangeTheme",
        onMessageReceived: (message) async {
      if (message.message == "dark") {
        themeMode = ThemeMode.dark;
      }
      if (message.message == "system") {
        themeMode = ThemeMode.system;
      } else {
        themeMode = ThemeMode.light;
      }
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
    await controller.loadRequest(Uri.parse('https://stajbuldum.osman.tech'));

    var apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    print("apnsToken: ${apnsToken}");
  }

  @override
  void initState() {
    super.initState();
    initController();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: themeMode,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color.fromRGBO(2, 8, 23, 1),
      ),
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
