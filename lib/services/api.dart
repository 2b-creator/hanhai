//import 'dart:html';

import 'package:dio/dio.dart';
import 'package:matrix/matrix.dart';

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
  }) async {
    try {
      String url = "$baseUrl/auth/register";

      final data = {
        "email": username,
        "password": password,
        "passwordConfirm": password,
      };

      final response = await dio.post(url, data: data);

      return response.data;
    } catch (e) {
      return e;
    }
  }
}
