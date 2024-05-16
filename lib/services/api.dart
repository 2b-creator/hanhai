//import 'dart:html';

import 'package:device_uuid/device_uuid.dart';
import 'package:dio/dio.dart';
import 'package:matrix/matrix.dart';
import 'package:device_info_plus/device_info_plus.dart';

class HttpHandlerIm {
  static String host = "https://matrix.phosphorus.top";
  static String emailRec = "/_matrix/client/v3/register/email/requestToken";
  static String reg = "/_matrix/client/v3/register";
  static int attempt = 0;
}

class API {
  final dio = Dio();
  final String baseUrl = "https://wordix-backend.onrender.com";

  getUsersService({required Client client}) async {
    try {
      List<Room> rooms = client.rooms;

      return rooms;
    } catch (e) {
      return e;
    }
  }

  loginUserService(
      {required String username,
      required String password,
      required Client client}) async {
    try {
      await client.checkHomeserver(Uri.parse("https://matrix.phosphorus.top"));

      await client.login(LoginType.mLoginPassword,
          password: password,
          identifier: AuthenticationUserIdentifier(user: username));
    } catch (e) {
      return e;
    }
  }

  registerUserService({
    required String username,
    required String password,
    required String email,
  }) async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      final uuid = DeviceUuid().getUUID();
      HttpHandlerIm.attempt++;
      var data = {
        "client_secret": "onZR8j57RKTTU8wM",
        "email": email,
        "send_attempt": HttpHandlerIm.attempt
      };

      var resp = await dio.post(HttpHandlerIm.host + HttpHandlerIm.emailRec,
          data: data);
      String serverSid = resp.data["sid"];
      return serverSid;
    } catch (e) {
      return e;
    }
  }
}
