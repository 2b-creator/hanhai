import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SurveyWidgets extends StatefulWidget {
  static bool isloading = true;
  const SurveyWidgets({super.key});

  @override
  State<SurveyWidgets> createState() => _SurveyWidgetsState();
}

class _SurveyWidgetsState extends State<SurveyWidgets> {
  final _formKey = GlobalKey<FormState>();
  var controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(NavigationDelegate())
    ..loadRequest(Uri.parse("https://www.wjx.top/vm/OKyZuqQ.aspx# "))
    ..enableZoom(false);

  @override
  Widget build(BuildContext context) {
    controller.setNavigationDelegate(NavigationDelegate(
      onProgress: (progress) => setState(() {
        SurveyWidgets.isloading = true;
      }),
      onPageFinished: (url) => setState(() {
        SurveyWidgets.isloading = false;
      }),
    ));
    return Scaffold(
        appBar: AppBar(
          title: const Text("订阅"),
        ),
        body: SurveyWidgets.isloading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : WebViewWidget(controller: controller));
  }
}
