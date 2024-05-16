// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:matrix/matrix.dart';
import '../core/storage.dart';
import '../utils/dialogs.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.client});
  final Client client;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? user = "default";

  logout() async {
    questionDialog(
      context: context,
      title: "Logout",
      content: "Are you sure want to logout from your account?",
      func: () async {
        final client = widget.client;
        await client.logout();
        Navigator.of(context).pushNamedAndRemoveUntil(
          "/welcome",
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
    var user = await widget.client.getDisplayName(widget.client.userID!);
    if (user == null) {
      user = "defalut";
    }
    setState(() {
      this.user = user;
    });
  }

  // Screen'imiz yuklendiginde auth fonksiyonumuzu calistiriyoruz.
  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      backgroundColor: Colors.black,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SvgPicture.asset(
                          "assets/images/profile-avatar.svg",
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(20),
              const Divider(thickness: 2, endIndent: 15, indent: 15),
              const Gap(20),
              Text(
                "${this.user!}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                "@${this.user!}",
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
                        style: TextStyle(color: Colors.black, fontSize: 24),
                      ),
                      Text(
                        "messages",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ],
                  ),
                  const Column(
                    children: [
                      Text(
                        "12 hours",
                        style: TextStyle(color: Colors.black, fontSize: 24),
                      ),
                      Text(
                        "online time",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        widget.client.userID!.isValidMatrixId ? "Yes" : "No",
                        style:
                            const TextStyle(color: Colors.black, fontSize: 24),
                      ),
                      const Text(
                        "is Validated?",
                        style: TextStyle(color: Colors.black, fontSize: 14),
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
    );
  }
}
