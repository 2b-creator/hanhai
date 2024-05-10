//import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';

class RoomInterface extends StatefulWidget {
  const RoomInterface({super.key, required this.client});
  final Client client;
  @override
  State<RoomInterface> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomInterface> {
  bool isLogged = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      isLogged = widget.client.isLogged();
    });
  }

  void updateIsLogged(bool value) {
    setState(() {
      isLogged = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLogged
            ? const RoomlistPage()
            : LoginPageWidget(
                onLoginSuccess: updateIsLogged,
              ));
  }
}

class LoginPageWidget extends StatefulWidget {
  final Function(bool) onLoginSuccess;
  const LoginPageWidget({super.key, required this.onLoginSuccess});
  @override
  State<LoginPageWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPageWidget> {
  final double buttonPadding = 12;
  bool isLogged = false;

  void _navReg() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const RegisterPage()));
  }

  void _navLog() {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => const LoginPage()))
        .then((value) {
      widget.onLoginSuccess(value);
      setState(() {
        isLogged = value;
      });
    });
  }

  //const WidgetHome({super.key});
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(buttonPadding),
              child: const Text("您尚未登录瀚海"),
            ),
            Padding(
              padding: EdgeInsets.all(buttonPadding),
              child: const Text("你可以选择登录或注册一个新的瀚海账号"),
            ),
            Padding(
              padding: EdgeInsets.all(buttonPadding),
              child: TextButton(
                onPressed: _navLog,
                child: Text(
                  "登录",
                  style: GoogleFonts.notoSansSc(
                      textStyle: const TextStyle(fontSize: 20)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(buttonPadding),
              child: TextButton(
                onPressed: _navReg,
                child: Text(
                  "注册",
                  style: GoogleFonts.notoSansSc(
                      textStyle: const TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterWidget();
}

class _RegisterWidget extends State<RegisterPage> {
  final double textPadding = 12;

  void _regEvent() {
    //TODO
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Registration"),
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Center(
        child: Container(
          width: 350,
          height: 600,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: const Color.fromARGB(255, 243, 237, 247),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3))
              ]),
          child: DecoratedBox(
              decoration: const BoxDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(textPadding),
                    child: const Text("Username"),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(left: textPadding, right: textPadding),
                    child: const TextField(
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Enter your username"),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(textPadding),
                    child: const Text("Email"),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(left: textPadding, right: textPadding),
                    child: const TextField(
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Enter your email"),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(textPadding),
                    child: const Text("Password"),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(left: textPadding, right: textPadding),
                    child: const TextField(
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "Enter your password"),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(textPadding),
                    child: const Text("Password confirm"),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(left: textPadding, right: textPadding),
                    child: const TextField(
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "reEnter your password"),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(textPadding),
                    child: Center(
                      child: TextButton(
                          onPressed: _regEvent,
                          child: Text(
                            "register",
                            style: GoogleFonts.notoSansSc(
                                textStyle: const TextStyle(fontSize: 20)),
                          )),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginWidget();
}

bool _loading = false;

class _LoginWidget extends State<LoginPage> {
  final double textPadding = 12;
  final TextEditingController _usernameTextField = TextEditingController();
  final TextEditingController _passwordTextField = TextEditingController();
  String? usernameS;
  void _loginEvent() async {
    //TODO
    setState(() {
      _loading = true;
    });
    try {
      final client = Provider.of<Client>(context, listen: false);
      await client.checkHomeserver(Uri.parse("https://matrix.phosphorus.top"));
      await client.login(LoginType.mLoginPassword,
          password: _passwordTextField.text,
          identifier:
              AuthenticationUserIdentifier(user: _usernameTextField.text));

      Navigator.of(context).pop(client.isLogged());
      await client.joinRoom("!FUzFXJqgOVDbpiBYwZ:matrix.phosphorus.top");
      setState(() {
        _loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
      print(e.toString());
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Login"),
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Center(
        child: Container(
          width: 350,
          height: 600,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: const Color.fromARGB(255, 243, 237, 247),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3))
              ]),
          child: DecoratedBox(
              decoration: const BoxDecoration(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(textPadding),
                    child: const Text("用户名"),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(left: textPadding, right: textPadding),
                    child: TextField(
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "请输入你的用户名"),
                      controller: _usernameTextField,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(textPadding),
                    child: const Text("密码"),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(left: textPadding, right: textPadding),
                    child: TextField(
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "请输入你的密码"),
                      obscureText: true,
                      controller: _passwordTextField,
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(textPadding),
                      child: Center(
                        child: ElevatedButton(
                            onPressed: _loading ? null : _loginEvent,
                            child: _loading
                                ? const LinearProgressIndicator()
                                : TextButton(
                                    onPressed: _loginEvent,
                                    child: Text(
                                      "登录",
                                      style: GoogleFonts.notoSansSc(
                                          textStyle:
                                              const TextStyle(fontSize: 20)),
                                    ))),
                      ))
                ],
              )),
        ),
      ),
    );
  }
}

class RoomlistPage extends StatefulWidget {
  const RoomlistPage({super.key});

  @override
  _RoomlistPageState createState() => _RoomlistPageState();
}

class _RoomlistPageState extends State<RoomlistPage> {
  void _logout() async {
    final client = Provider.of<Client>(context, listen: false);
    await client.logout();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      //(route) => false,
    );

    //TODO
  }

  void _join(Room room) async {
    if (room.membership != Membership.join) {
      await room.join();
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoomPage(room: room),
      ),
    );
    _addRoom("!FUzFXJqgOVDbpiBYwZ:matrix.phosphorus.top");
  }

  void _addRoom(String roomIdOrAlias) async {
    final client = Provider.of<Client>(context, listen: false);
    await client.joinRoom(roomIdOrAlias);
  }

  @override
  Widget build(BuildContext context) {
    final client = Provider.of<Client>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('社区'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: client.onSync.stream,
        builder: (context, _) => ListView.builder(
          itemCount: client.rooms.length,
          itemBuilder: (context, i) => ListTile(
            leading: CircleAvatar(
              foregroundImage: client.rooms[i].avatar == null
                  ? const NetworkImage(
                      "https://s2.loli.net/2024/05/09/8LuOcAs6tIdUial.png")
                  : NetworkImage(client.rooms[i].avatar!
                      .getThumbnail(
                        client,
                        width: 56,
                        height: 56,
                      )
                      .toString()),
            ),
            title: Row(
              children: [
                Expanded(child: Text(client.rooms[i].displayname)),
                if (client.rooms[i].notificationCount > 0)
                  Material(
                      borderRadius: BorderRadius.circular(99),
                      color: Colors.red,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child:
                            Text(client.rooms[i].notificationCount.toString()),
                      ))
              ],
            ),
            subtitle: Text(
              client.rooms[i].lastEvent?.body ?? 'No messages',
              maxLines: 1,
            ),
            onTap: () => _join(client.rooms[i]),
          ),
        ),
      ),
      floatingActionButton: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => _addRoom(""),
      ),
    );
  }
}

class RoomPage extends StatefulWidget {
  final Room room;
  const RoomPage({required this.room, super.key});

  @override
  _SendRoomPageState createState() => _SendRoomPageState();
}

class _SendRoomPageState extends State<RoomPage> {
  late final Future<Timeline> _timelineFuture;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  int _count = 0;

  @override
  void initState() {
    _timelineFuture = widget.room.getTimeline(onChange: (i) {
      print('on change! $i');
      _listKey.currentState?.setState(() {});
    }, onInsert: (i) {
      print('on insert! $i');
      _listKey.currentState?.insertItem(i);
      _count++;
    }, onRemove: (i) {
      print('On remove $i');
      _count--;
      _listKey.currentState?.removeItem(i, (_, __) => const ListTile());
    }, onUpdate: () {
      print('On update');
    });
    super.initState();
  }

  final TextEditingController _sendController = TextEditingController();

  void _send() {
    widget.room.sendTextEvent(_sendController.text.trim());
    _sendController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.displayname),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<Timeline>(
                future: _timelineFuture,
                builder: (context, snapshot) {
                  final timeline = snapshot.data;
                  if (timeline == null) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  _count = timeline.events.length;
                  return Column(
                    children: [
                      // Center(
                      //   child: TextButton(
                      //       onPressed: timeline.requestHistory,
                      //       child: const Text('获取之前的信息')),
                      // ),
                      const Divider(height: 1),
                      Expanded(
                        child: AnimatedList(
                          key: _listKey,
                          reverse: true,
                          initialItemCount: timeline.events.length,
                          itemBuilder: (context, i, animation) => timeline
                                      .events[i].relationshipEventId !=
                                  null
                              ? Container()
                              : timeline.events[i].body.startsWith("m.") &&
                                      timeline.events[i].body != "m.room.avatar"&&
                                      timeline.events[i].body != "m.room.member"
                                  ? Container()
                                  : ScaleTransition(
                                      scale: animation,
                                      child: Opacity(
                                        opacity:
                                            timeline.events[i].status.isSent
                                                ? 1
                                                : 0.5,
                                        child: ListTile(
                                            leading: CircleAvatar(
                                              foregroundImage: timeline
                                                          .events[i]
                                                          .sender
                                                          .avatarUrl ==
                                                      null
                                                  ? const NetworkImage(
                                                      "https://s2.loli.net/2024/05/09/8LuOcAs6tIdUial.png")
                                                  : NetworkImage(timeline
                                                      .events[i]
                                                      .sender
                                                      .avatarUrl!
                                                      .getThumbnail(
                                                        widget.room.client,
                                                        width: 56,
                                                        height: 56,
                                                      )
                                                      .toString()),
                                            ),
                                            title: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(timeline
                                                      .events[i].sender
                                                      .calcDisplayname()),
                                                ),
                                                // Text(
                                                //   timeline
                                                //       .events[i].originServerTs
                                                //       .toIso8601String(),
                                                //   style: const TextStyle(
                                                //       fontSize: 10),
                                                // ),
                                              ],
                                            ),
                                            subtitle: timeline.events[i]
                                                    .getDisplayEvent(timeline)
                                                    .content
                                                    .containsKey("displayname")
                                                ? Text("名称更改为${timeline.events[i]
                                                        .getDisplayEvent(
                                                            timeline)
                                                        .content["displayname"]}")
                                                : timeline.events[i]
                                                            .getDisplayEvent(
                                                                timeline)
                                                            .body ==
                                                        "m.room.avatar"
                                                    ? const Text("更新了头像")
                                                    : Text(timeline.events[i]
                                                        .getDisplayEvent(
                                                            timeline)
                                                        .body)),
                                      ),
                                    ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: _sendController,
                    decoration: const InputDecoration(
                      hintText: '发送消息',
                    ),
                  )),
                  IconButton(
                    icon: const Icon(Icons.send_outlined),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
