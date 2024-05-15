import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
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
  static const navigations = [
    'https://stajbuldum.osman.tech/',
    'https://stajbuldum.osman.tech/basvurularim',
    'https://stajbuldum.osman.tech/profile',
  ];

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() {
              navigationBarIndex =
                  !navigations.contains(url) ? 0 : navigations.indexOf(url);
            });
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://stajbuldum.osman.tech'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: WebViewWidget(controller: controller),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: navigationBarIndex,
          onTap: (value) {
            controller.loadRequest(Uri.parse(navigations[value]));
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Başvurularım',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Profilim',
            ),
          ],
        ),
      ),
    );
  }
}
