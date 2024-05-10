import 'package:flutter/material.dart';
import 'package:device_uuid/device_uuid.dart';
import 'dart:math';

class RegEmailAuthWidget extends StatefulWidget {
  const RegEmailAuthWidget({super.key});
  @override
  State<RegEmailAuthWidget> createState() => _RegEmailAuthState();
}

class _RegEmailAuthState extends State<RegEmailAuthWidget> {
  final uuid = DeviceUuid().getUUID();
  @override
  Widget build(BuildContext context) {
    //TODO
    return Container();
  }
}

class AuthEmailDevice {
  int genCaptcha(int min, int max) {
    int res = min + Random().nextInt(max - min);
    return res;
  }
  void sendEmail(){

  }
}
