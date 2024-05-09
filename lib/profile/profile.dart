import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import './../chater/room_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.client});
  final Client client;
  @override
  State<ProfilePage> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfilePage> {
  bool _isLogged = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      _isLogged = widget.client.isLogged();
    });
  }

  void updateIsLogged(bool value) {
    setState(() {
      _isLogged = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLogged ? ProfileEditorPage(client: widget.client) : LoginPageWidget(onLoginSuccess: updateIsLogged),
    );
  }
}

class ProfileEditorPage extends StatefulWidget {
  const ProfileEditorPage({super.key, required this.client});
  final Client client;
  @override
  State<ProfileEditorPage> createState() => _ProfileEditorWidgetState();
}

class _ProfileEditorWidgetState extends State<ProfileEditorPage> {
  Uri? _userid;
  void _getUserid() async {
    _userid = await widget.client.getAvatarUrl(widget.client.userID!);
  }

  @override
  Widget build(BuildContext context) {
    _getUserid();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              foregroundImage: _userid == null
                  ? const NetworkImage(
                      "https://s2.loli.net/2024/05/09/8LuOcAs6tIdUial.png")
                  : NetworkImage(_userid.toString()),
            ),
            const Text("data"),
          ],
        ),
      ],
    );
  }
}
