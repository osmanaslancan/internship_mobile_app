import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:internship_mobile_app/Messager.dart';
import 'package:internship_mobile_app/firebase_options.dart';
import 'package:internship_mobile_app/pdf_viewer_page.dart';
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
  ThemeMode themeMode = ThemeMode.system;

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
      home: HomePage(
        onThemeChanged: (ThemeMode theme) {
          setState(() {
            themeMode = theme;
          });
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.onThemeChanged,
  });

  final void Function(ThemeMode theme) onThemeChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WebViewController controller;
  bool canPop = false;

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
        widget.onThemeChanged(ThemeMode.dark);
      }
      if (message.message == "system") {
        widget.onThemeChanged(ThemeMode.system);
      } else {
        widget.onThemeChanged(ThemeMode.light);
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
          if (request.url.startsWith(
              "https://vzmyswxvnmseubtqgjpc.supabase.co/storage/v1/object/sign/PrivateCvs")) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PdfViewerPage(url: request.url)));
            return NavigationDecision.prevent;
          }
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
    return Scaffold(
      appBar: canPop
          ? AppBar(
              leading: BackButton(
                onPressed: () {
                  controller.goBack();
                },
              ),
            )
          : null,
      body: Messager(
        child: SafeArea(
          child: WebViewWidget(controller: controller),
        ),
      ),
    );
  }
}
