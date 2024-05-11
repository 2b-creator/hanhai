import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import './../chater/room_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

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
      body: _isLogged
          ? ProfileEditorPage(client: widget.client)
          : LoginPageWidget(onLoginSuccess: updateIsLogged),
    );
  }
}

class ProfileEditorPage extends StatefulWidget {
  const ProfileEditorPage({super.key, required this.client});
  final Client client;
  @override
  State<ProfileEditorPage> createState() => _changeAvatar();
}

class _changeAvatar extends State<ProfileEditorPage> {
  int i = 0;
  final double paddingWidgets = 20.0;
  Uri? _userid;
  String? _usernick;
  final TextEditingController _nicknameController = TextEditingController();
  void _getUserid() async {
    _userid = await widget.client.getAvatarUrl(widget.client.userID!);
    _usernick = await widget.client.getDisplayName(widget.client.userID!);
    if (i == 0) {
      i++;
      setState(() {});
    }
  }

  void _setNickname(String displayname, String userId) async {
    await widget.client.setDisplayName(userId, displayname);
  }

  void _changeAvatarChoser() async {
    final ImagePicker picker = ImagePicker();
    final LostDataResponse response = await picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    final List<XFile>? files = response.files;
    String filePath = files![0].path;
    Uint8List uint8list = await File(filePath).readAsBytes();
    widget.client.setAvatar(MatrixImageFile(bytes: uint8list, name: widget.client.clientName.toString()));
  }

  void _changePasswd(){
    //TODO
    
  }

  @override
  Widget build(BuildContext context) {
    _getUserid();
    return Scaffold(
      appBar: AppBar(
        title: const Text("用户中心"),
        backgroundColor: const Color.fromARGB(255, 233, 222, 248),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 233, 222, 248),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  foregroundImage: _userid?.path == null
                      ? const NetworkImage(
                          "https://s2.loli.net/2024/05/09/8LuOcAs6tIdUial.png")
                      : NetworkImage(
                          "https://matrix.phosphorus.top/_matrix/media/r0/thumbnail/${_userid!.host}${_userid!.path}?width=2448&height=2448"),
                ),
                Padding(
                  padding: EdgeInsets.all(paddingWidgets),
                  child: SizedBox(
                    width: 225,
                    child: TextField(
                      decoration: InputDecoration(
                          labelText: "更改昵称", hintText: _usernick),
                      controller: _nicknameController,
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      _setNickname(_nicknameController.text ?? "defualt",
                          widget.client.userID.toString());
                    },
                    icon: const Icon(Icons.save)),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.all(paddingWidgets),
                    child: const Text("更改头像"),
                  ),
                ),
                onTap: () {},
              ),
              IconButton(
                  onPressed: _changeAvatarChoser,
                  icon: const Icon(Icons.arrow_right))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.all(paddingWidgets),
                    child: const Text("修改密码"),
                  ),
                ),
              ),
              IconButton(
                  onPressed: _changePasswd,
                  icon: const Icon(Icons.arrow_right))
            ],
          )
        ],
      ),
    );
  }
}
