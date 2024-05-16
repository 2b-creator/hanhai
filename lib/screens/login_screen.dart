// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hanhai/chater/room_page.dart';
import 'package:hanhai/main.dart';
import 'package:matrix/matrix.dart';
//import 'package:provider/provider.dart';
import '../core/storage.dart';
import '../services/api.dart';
import '../utils/dialogs.dart';
import '../widgets/loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.client});
  final Client client;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();

  void _addRoom(String roomIdOrAlias) async {
    final client = widget.client;
    await client.joinRoom(roomIdOrAlias);
  }

  loginUser() async {
    setState(() {
      loading = true;
    });

    Storage storage = Storage();
    API api = API();
    var client = widget.client;
    var data = await api.loginUserService(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        client: client);

    if (data is DioException) {
      errorDialog(context: context, content: data.response?.data["data"]);
    } else {
      // await storage.saveUser(
      //   username: data["data"]["email"],
      //   admin: data["data"]["admin"],
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("成功登录到瀚海"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => MyHomePage(title: "瀚海", client: client)),
          (route) => false);

      var spaceProperty = await client
          .getSpaceHierarchy(("!BJiNaszkjLhKvKhNhR:matrix.phosphorus.top"));
      var rls = spaceProperty.rooms;
      for (int i = 0; i < rls.length; i++) {
        await client.joinRoom(rls[i].roomId);
      }

      
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const LoadingIndicator()
        : Scaffold(
            body: SafeArea(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage("assets/images/pattern.jpg"),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.grey.withOpacity(0.23),
                      BlendMode.srcATop,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(child: Container()),
                    Container(
                      width: double.infinity,
                      height: 330,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 35,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(55),
                          topRight: Radius.circular(55),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // InkWell(
                              //   // onTap: () => Navigator.pushNamedAndRemoveUntil(
                              //   //   context,
                              //   //   "/welcome",
                              //   //   (route) => false,
                              //   // ),
                              //   onTap: () => Navigator.pop(context),
                              //   child: const Icon(Icons.arrow_back, size: 30),
                              // ),
                              Text(
                                "登录你的瀚海账号",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const Gap(30),
                          TextField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              hintText: "用户名",
                            ),
                          ),
                          const Gap(10),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: "密码",
                            ),
                          ),
                          const Gap(30),
                          ElevatedButton(
                            onPressed: () {
                              if (usernameController.text.trim().isEmpty ||
                                  passwordController.text.trim().isEmpty) {
                                errorDialog(
                                  context: context,
                                  content: "请填充此区域",
                                );
                              } else {
                                loginUser();
                              }
                            },
                            child: const Text("登录"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
