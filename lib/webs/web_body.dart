import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:flutter/services.dart'; 
import 'package:hanhai/pdf_viewer.dart';
import 'package:path_provider/path_provider.dart';
import '../main.dart';

class WebHomeWidget extends StatefulWidget{
  const WebHomeWidget({super.key});
  @override
  State<WebHomeWidget> createState() => _WebHomeState();
  
}

class _WebHomeState extends State<WebHomeWidget>{

  bool canPopValue = false;
  String uri = "https://blog.wingsfrontier.top/";

  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..clearCache()
    ..setNavigationDelegate(NavigationDelegate(
      onNavigationRequest: (request) async {
        if (request.url.endsWith(".pdf")) {
          var opt = AppOptions();
          if (AppOptions.theContext != null) {
            opt.changeCanPopState(true);
            Directory appDocDir = await getApplicationDocumentsDirectory();
            var response = await opt.dio.download(
                request.url, appDocDir.path + request.url.split("/")[7]);
            Navigator.push(
                AppOptions.theContext!,
                MaterialPageRoute(
                  builder: (context) => PDFViewerWidget(
                    url: appDocDir.path + request.url.split("/")[7],
                    fileName: request.url.split("/")[7],
                  ),
                ));
          }
          opt.changeCanPopState(false);
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    ))
    ..loadRequest(Uri.parse("https://blog.wingsfrontier.top/"));

  

  @override
  Widget build(BuildContext context){
    return PopScope(
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
        body: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}