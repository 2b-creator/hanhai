// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../screens/welcome_screen.dart';
import 'package:matrix/matrix.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/dialogs.dart';
import 'package:hanhai/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.client});
  final Client client;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int i = 0;
  String? user = "default";
  Uri? url;
  void _changeAvatarChoser() async {
    final ImagePicker picker = ImagePicker();
    final XFile? response = await picker.pickImage(source: ImageSource.gallery);
    if (response==null) {
      return;
    }
    //final List<XFile>? files = response.files;
    String filePath = response.path;
    Uint8List uint8list = await File(filePath).readAsBytes();
    widget.client.setAvatar(MatrixImageFile(bytes: uint8list, name: widget.client.clientName.toString()));
  }

  logout() async {
    questionDialog(
      context: context,
      title: "登出",
      content: "你确定要登出你的账户吗",
      func: () async {
        
        final client = widget.client;
        await client.logout();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  MyHomePage(title: "瀚海", client: widget.client)),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("你已成功登出"),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  // Kullanicinin bu sayfaya erisimi yoksa welcomeScreen'e gonderiyoruz.
  getUser() async {
    if (!widget.client.isLogged()) {
      return;
    }
    var user = await widget.client.getDisplayName(widget.client.userID!);
    user ??= "defalut";
    setState(() {
      this.user = user;
    });
  }

  void avatarGet() async {
    if (!widget.client.isLogged()) {
      return;
    }
    var user = await widget.client.getDisplayName(widget.client.userID!);
    url = await widget.client.getAvatarUrl(widget.client.userID!);
    if (url == null) {
      url = Uri.parse("https://s2.loli.net/2024/05/09/8LuOcAs6tIdUial.png");
    } else {
      url = url!.getThumbnail(widget.client, width: 500, height: 500);
    }
    if (i == 0) {
      i++;
      setState(() {});
    }
  }

  // Screen'imiz yuklendiginde auth fonksiyonumuzu calistiriyoruz.
  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    avatarGet();
    return widget.client.isLogged()
        ? Scaffold(
            appBar: AppBar(
              title: const Center(
                child: Text(
                  "个人中心",
                ),
              ),
            ),
            body: SafeArea(
              child: Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 241, 241, 241),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(198, 255, 221, 1),
                            Color.fromRGBO(251, 215, 134, 1),
                            Color.fromRGBO(247, 121, 125, 1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 241, 241, 241),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: CircleAvatar(
                            radius: 64,
                            backgroundColor: const Color.fromARGB(255, 241, 241, 241),
                            foregroundImage: NetworkImage(url == null
                                ? "https://s2.loli.net/2024/05/09/8LuOcAs6tIdUial.png"
                                : url!.toString()),
                          ),
                        ),
                      ),
                    ),
                    Center(child: TextButton(onPressed: _changeAvatarChoser, child: const Text("更改头像")),),
                    const Gap(20),
                    const Divider(thickness: 2, endIndent: 15, indent: 15),
                    const Gap(20),
                    Center(child: SizedBox(width: 250,child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(hintText: user!),
                      onSubmitted: (value) async {
                        await widget.client.setDisplayName(widget.client.userID!, value);
                      },
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),),),
                    // Text(
                    //   "@${widget.client.userID!}",
                    //   style: const TextStyle(fontSize: 15),
                    // ),
                    const Gap(20),
                    const Divider(thickness: 2, endIndent: 15, indent: 15),
                    const Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Column(
                          children: [
                            Text(
                              "128",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 24),
                            ),
                            Text(
                              "messages",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                            ),
                          ],
                        ),
                        const Column(
                          children: [
                            Text(
                              "NaN",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 24),
                            ),
                            Text(
                              "在线时长",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              widget.client.userID!.isValidMatrixId ? "是" : "否",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 24),
                            ),
                            const Text(
                              "是否已验证?",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Gap(20),
                    const Divider(thickness: 2, endIndent: 15, indent: 15),
                    const Gap(20),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        onPressed: logout,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          foregroundColor: Colors.white,
                          elevation: 10,
                          backgroundColor: Colors.red,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.logout_outlined, size: 28),
                            Gap(10),
                            Text(
                              "登出",
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(20),
                  ],
                ),
              ),
            ),
          )
        : const WelcomeScreen();
  }
}
