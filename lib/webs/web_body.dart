import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:hanhai/pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';
import '../main.dart';

class WebHomeWidget extends StatefulWidget {
  const WebHomeWidget({super.key});
  @override
  State<WebHomeWidget> createState() => _WebHomeState();
}

class _WebHomeState extends State<WebHomeWidget> {
  bool canPopValue = false;
  static final GlobalKey _bodyKey = GlobalKey();
  String uri = "https://hanhai.jygz.top/";

  final controller = WebViewController()
    ..loadRequest(Uri.parse("https://hanhai.jygz.top/"))
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..clearCache()
    ..enableZoom(false);

  @override
  Widget build(BuildContext context) {
    controller.setNavigationDelegate(NavigationDelegate(
      onProgress: (progress) {
        setState(() {
          AppOptions.webHomeLoading = true;
        });
      },
      onPageFinished: (url) {
        setState(() {
          AppOptions.webHomeLoading = false;
        });
      },
      onNavigationRequest: (request) async {
        if (request.url.endsWith(".pdf")) {
          var opt = AppOptions();
          if (AppOptions.theContext != null) {
            opt.changeCanPopState(true);
            Directory appDocDir = await getApplicationDocumentsDirectory();
            setState(() {
              AppOptions.webHomeLoading = true;
            });
            var response = await opt.dio.download(
                request.url, appDocDir.path + request.url.split("/")[request.url.split("/").length-1]);
            setState(() {
              AppOptions.webHomeLoading = false;
            });
            Navigator.push(
                AppOptions.theContext!,
                MaterialPageRoute(
                  builder: (context) => PDFViewerWidget(
                    url: appDocDir.path + request.url.split("/")[request.url.split("/").length-1],
                    fileName: request.url.split("/")[request.url.split("/").length-1],
                  ),
                ));
          }
          opt.changeCanPopState(false);
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    ));
    return Scaffold(
      appBar: AppBar(
        key: _bodyKey,
        title: const Text("主页"),
      ),
      body: PopScope(
        onPopInvoked: (didPop) {
          Future<bool> canBack = controller.canGoBack();
          canBack.then((value) {
            if (value) {
              controller.goBack();
            } else {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            }
          });
        },
        canPop: canPopValue,
        child: Scaffold(
          body: AppOptions.webHomeLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : WebViewWidget(
                  controller: controller,
                ),
        ),
      ),
    );
  }
}
