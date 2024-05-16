// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../screens/welcome_screen.dart';
import 'package:matrix/matrix.dart';
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

  logout() async {
    questionDialog(
      context: context,
      title: "Logout",
      content: "Are you sure want to logout from your account?",
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
            content: Text("You are successfully logged out."),
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
                  "My Profile",
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
                    const Gap(20),
                    const Divider(thickness: 2, endIndent: 15, indent: 15),
                    const Gap(20),
                    Text(
                      user!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "@${user!}",
                      style: const TextStyle(fontSize: 15),
                    ),
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
                              "Log Out",
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
