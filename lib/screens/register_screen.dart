// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:matrix/matrix.dart';

import '../core/storage.dart';
import '../services/api.dart';
import '../utils/dialogs.dart';
import '../widgets/loading_indicator.dart';
import '../chater/auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.client});
  final Client client;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool loading = false;
  bool _usernameInvalid = true;
  bool _emailFormatValitation = true;
  bool _passwdMatch = true;

  var usernameController = TextEditingController();
  var passwordController = TextEditingController();
  var passwordConfirmController = TextEditingController();
  var emailControlller = TextEditingController();
  AuthUsernameOrPasswd authUsernameOrPasswd = AuthUsernameOrPasswd();
  registerUser() async {
    setState(() {
      loading = true;
    });

    Storage storage = Storage();
    API api = API();

    var data = await api.registerUserService(
      username: usernameController.text.trim(),
      password: passwordController.text.trim(),
      email: emailControlller.text.trim(),
    );

    if (data is DioException) {
      //errorDialog(context: context, content: );
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: data.response?.data["data"]));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("一封确认邮件已经发往你的邮箱，请查收后继续"),
          backgroundColor: Colors.green,
        ),
      );
      // await storage.saveUser(
      //   username: data["data"]["email"],
      //   admin: data["data"]["admin"],
      // );
      // Navigator.of(context).pushAndRemoveUntil(
      //     MaterialPageRoute(
      //         builder: (context) =>
      //             MyHomePage(title: "瀚海", client: widget.client)),
      //     (route) => false);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => RegEmailAuthWidget(
              sid: data,
              username: usernameController.text.trim(),
              password: passwordController.text.trim(),client: widget.client,)));
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
                      height: 440,
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
                              //   onTap: () => Navigator.pushNamedAndRemoveUntil(
                              //     context,
                              //     "/welcome",
                              //     (route) => false,
                              //   ),
                              //   child: const Icon(Icons.arrow_back, size: 30),
                              // ),
                              Text(
                                "注册一个瀚海账号",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const Gap(10),
                          TextField(
                            controller: usernameController,
                            onChanged: (value) {
                              setState(() {
                                _usernameInvalid =
                                    authUsernameOrPasswd.isValidUsername(value);
                              });
                            },
                            decoration: InputDecoration(
                                hintText: "用户名",
                                errorText: _usernameInvalid
                                    ? null
                                    : "用户名应当以小写字母开头，且只能包含数字，下\n划线和小写字母"),
                          ),
                          const Gap(10),
                          TextField(
                            controller: emailControlller,
                            onChanged: (value) {
                              setState(() {
                                _emailFormatValitation =
                                    authUsernameOrPasswd.isValidEmail(value);
                              });
                            },
                            decoration: InputDecoration(
                                hintText: "邮箱",
                                errorText:
                                    _emailFormatValitation ? null : "不正确的邮箱地址"),
                          ),
                          const Gap(10),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: "密码",
                            ),
                          ),
                          const Gap(10),
                          TextField(
                            controller: passwordConfirmController,
                            obscureText: true,
                            onChanged: (value) {
                              setState(() {
                                _passwdMatch =
                                    (passwordController.text == value);
                              });
                            },
                            decoration: InputDecoration(
                                hintText: "确认密码",
                                errorText: _passwdMatch ? null : "两次密码不匹配"),
                          ),
                          const Gap(15),
                          ElevatedButton(
                            onPressed: () {
                              if (passwordController.text !=
                                  passwordConfirmController.text) {
                                errorDialog(
                                  context: context,
                                  content: "两次密码不匹配",
                                );
                              } else if (usernameController.text
                                      .trim()
                                      .isEmpty ||
                                  passwordController.text.trim().isEmpty ||
                                  passwordConfirmController.text
                                      .trim()
                                      .isEmpty) {
                                errorDialog(
                                  context: context,
                                  content: "请填写该字段",
                                );
                              } else {
                                registerUser();
                              }
                            },
                            child: const Text("注册"),
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
