import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PDFViewerWidget extends StatelessWidget {
  const PDFViewerWidget({super.key, required this.url, required this.fileName});
  final String url;
  final String fileName;

  String cutFileName(String awaiturl) {
    var strs = awaiturl.split("/");
    return strs[7];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: PDFView(
        filePath: url,
        autoSpacing: false,
        pageFling: false,
        onError: (error) {
          Fluttertoast.showToast(msg: error.toString());
        },
      ),
    );
  }
}