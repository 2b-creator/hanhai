import 'package:flutter/material.dart';
import 'package:device_uuid/device_uuid.dart';
import 'dart:math';
import 'package:dio/dio.dart';

class HttpHandlerIm {
  static String host = "https://matrix.phosphorus.top";
  static String emailRec = "/_matrix/client/v3/register/email/requestToken";
  static String reg = "/_matrix/client/v3/register";
}

class RegEmailAuthWidget extends StatefulWidget {
  const RegEmailAuthWidget(
      {super.key,
      required this.sid,
      required this.username,
      required this.password});
  final String sid;
  final String username;
  final String password;
  @override
  State<RegEmailAuthWidget> createState() => _RegEmailAuthState();
}

class _RegEmailAuthState extends State<RegEmailAuthWidget> {
  final uuid = DeviceUuid().getUUID();
  void _finishValid() async {
    var dataAuth = {
      "auth": {
        "type": "m.login.email.identity",
        "threepid_creds": {
          "sid": widget.sid,
          "client_secret": "onZR8j57RKTTU8wM",
          "id_server": "matrix.phosphorus.top",
        },
      },
      "device_id": "GHTYAJCE",
      "initial_device_display_name": uuid.toString(),
      "password": widget.password,
      "username": widget.username
    };

    var dio = Dio();
    try {
      var resp = await dio.post(HttpHandlerIm.host + HttpHandlerIm.reg,
          data: dataAuth);
      if (resp.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resp.data.toString()),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("注册成功！"),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //TODO
    return Scaffold(
      appBar: AppBar(
        title: const Text("邮箱验证"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("请注意查收您的验证邮箱以便完成验证，注意，请在验证完毕后点击我已完成验证！"),
            TextButton(onPressed: _finishValid, child: const Text("我已完成验证"))
          ],
        ),
      ),
    );
  }
}

class AuthEmailDevice {
  int genCaptcha(int min, int max) {
    int res = min + Random().nextInt(max - min);
    return res;
  }

  void sendEmail() {}
}

class AuthUsernameOrPasswd {
  bool isValidUsername(String username) {
    RegExp regExp = RegExp(r"[^((a-z)|(0-9))]");
    bool isMatch = regExp.hasMatch(username);
    if (isMatch) {
      return false;
    }
    return true;
  }

  bool isValidEmail(String emailAddr) {
    RegExp regExp = RegExp(
        r"^[a-z0-9A-Z]+[- | a-z0-9A-Z . _]+@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\.)+[a-z]{2,}$");
    bool isMatch = regExp.hasMatch(emailAddr);
    if (isMatch) {
      return true;
    }
    return false;
  }
}

class ChangePasswdPage extends StatefulWidget {
  const ChangePasswdPage({super.key});
  @override
  State<ChangePasswdPage> createState() => _ChangePasswdState();
}

class _ChangePasswdState extends State<ChangePasswdPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("修改密码"),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
              decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: "输入你的新密码",
          ))
        ],
      )),
    );
  }
}
