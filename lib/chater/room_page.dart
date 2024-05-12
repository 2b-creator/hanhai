//import 'dart:js_interop';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:matrix/matrix.dart';
import 'package:provider/provider.dart';
import 'auth.dart';
import 'package:dio/dio.dart';

class HttpHandlerIm {
  static String host = "https://matrix.phosphorus.top";
  static String emailRec = "/_matrix/client/v3/register/email/requestToken";
  static String reg = "/_matrix/client/v3/register";
}

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
  final double buttonPadding = 5;
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
  final double textPadding = 5;
  final TextEditingController _usernameTextField = TextEditingController();
  bool _usernameInvalid = false;
  bool _emailFormatValitation = true;
  bool _passwdStrong = true;
  final TextEditingController _passwordTextField = TextEditingController();
  bool _twoPwdMatch = false;
  bool _waitingForCallback = false;
  final TextEditingController _emailTextField = TextEditingController();
  int attempt = 0;

  void _regEvent(String emailAddr) async {
    setState(() {
      _waitingForCallback = true;
    });
    attempt++;
    var dio = Dio();
    var data = {
      "client_secret": "onZR8j57RKTTU8wM",
      "email": emailAddr,
      "send_attempt": attempt
    };
    var resp =
        await dio.post(HttpHandlerIm.host + HttpHandlerIm.emailRec, data: data);
    String serverSid = resp.data["sid"];
    _waitingForCallback = false;
    if (resp.statusCode == 200) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (build) => RegEmailAuthWidget(
                    sid: serverSid,
                    username: _usernameTextField.text,
                    password: _passwordTextField.text,
                  )));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp.data.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("注册"),
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Center(
        child: Container(
          width: 350,
          height: 500,
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
                      decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: "请输入您的用户名",
                          errorText: _usernameInvalid
                              ? "非法用户名，必须以小写字母开头，后面均为小写字母\n或数字"
                              : null),
                      controller: _usernameTextField,
                      onChanged: (value) {
                        AuthUsernameOrPasswd authUsernameOrPasswd =
                            AuthUsernameOrPasswd();
                        setState(() {
                          _usernameInvalid =
                              !authUsernameOrPasswd.isValidUsername(value);
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(textPadding),
                    child: const Text("电子邮件"),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(left: textPadding, right: textPadding),
                    child: TextField(
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: "输入你的电子邮箱地址",
                          errorText:
                              _emailFormatValitation ? null : "错误的电子邮箱地址"),
                      controller: _emailTextField,
                      onChanged: (value) {
                        AuthUsernameOrPasswd authUsernameOrPasswd =
                            AuthUsernameOrPasswd();
                        setState(() {
                          _emailFormatValitation =
                              authUsernameOrPasswd.isValidEmail(value);
                        });
                      },
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
                          border: UnderlineInputBorder(), labelText: "输入你的密码"),
                      obscureText: true,
                      controller: _passwordTextField,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(textPadding),
                    child: const Text("确认密码"),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(left: textPadding, right: textPadding),
                    child: TextField(
                      decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: "重新输入你的密码",
                          errorText: _twoPwdMatch ? null : "两次密码不匹配"),
                      obscureText: true,
                      onChanged: (value) {
                        if (_passwordTextField.text != value) {
                          setState(() {
                            _twoPwdMatch = false;
                          });
                        }
                        _twoPwdMatch = true;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(textPadding),
                    child: Center(
                      child: TextButton(
                          onPressed: () {
                            _regEvent(_emailTextField.text);
                          },
                          child: Text(
                            "注册",
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
      setState(() {
        _loading = false;
      });
      Navigator.of(context).pop(client.isLogged());
      await client.joinRoom("!BJiNaszkjLhKvKhNhR:matrix.phosphorus.top");
      var spaceProperty = await client
          .getSpaceHierarchy(("!BJiNaszkjLhKvKhNhR:matrix.phosphorus.top"));
      var rls = spaceProperty.rooms;
      for (int i = 0; i < rls.length; i++) {
        await client.joinRoom(rls[i].roomId);
      }
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
                          border: UnderlineInputBorder(), labelText: "请输入你的密码"),
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
  int _hasreadedCounts = 0;

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
    //_addRoom("!FUzFXJqgOVDbpiBYwZ:matrix.phosphorus.top");
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
            onTap: () async {
              _join(client.rooms[i]);
            },
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

class StaticTimeline {
  static Timeline? timeline;
}

class _SendRoomPageState extends State<RoomPage> {
  late final Future<Timeline> _timelineFuture;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _avatarKey =
      GlobalKey<AnimatedListState>();
  int _count = 0;
  bool _sender = true;

  @override
  void initState() {
    _timelineFuture = widget.room.getTimeline(onChange: (i) {
      print('on change! $i');
      _listKey.currentState?.setState(() {});
    }, onInsert: (i) {
      print('on insert! $i');
      _listKey.currentState?.insertItem(i);
      _avatarKey.currentState?.setState(() {});
      _count++;
    }, onRemove: (i) {
      print('On remove $i');
      _count--;
      _listKey.currentState?.removeItem(i, (_, __) => const ListTile());
    }, onUpdate: () {
      //_listKey.currentState?.setState(() {});
      print('On update');
    });
    super.initState();
  }

  final TextEditingController _sendController = TextEditingController();

  void _send() {
    widget.room.sendTextEvent(_sendController.text.trim());
    _sendController.clear();
    setState(() {
      _sender = false;
    });
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
                  var timeline = snapshot.data;
                  StaticTimeline.timeline = timeline;
                  if (timeline == null) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  _count = timeline.events.length;
                  return Column(
                    children: [
                      Center(
                        child: TextButton(
                            onPressed: () {
                              //timeline.requestHistory;
                              timeline.setReadMarker();
                            },
                            child: const Text('标为已读')),
                      ),
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
                                      timeline.events[i].body !=
                                          "m.room.avatar" &&
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
                                          onTap: () {},
                                          leading: CircleAvatar(
                                            foregroundImage: timeline.events[i]
                                                        .sender.avatarUrl ==
                                                    null
                                                ? const NetworkImage(
                                                    "https://s2.loli.net/2024/05/09/8LuOcAs6tIdUial.png")
                                                : NetworkImage(timeline
                                                    .events[i].sender.avatarUrl!
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
                                                child: Text(
                                                  timeline.events[i].sender
                                                      .calcDisplayname(),
                                                  style: const TextStyle(
                                                      fontSize: 10),
                                                ),
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
                                              ? Text(
                                                  "名称更改为${timeline.events[i].getDisplayEvent(timeline).content["displayname"]}",
                                                  style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 156, 220, 240)),
                                                )
                                              : timeline.events[i]
                                                          .getDisplayEvent(
                                                              timeline)
                                                          .body ==
                                                      "m.room.avatar"
                                                  ? const Text("更新了头像")
                                                  // : Markdown(
                                                  //     data: timeline.events[i]
                                                  //         .getDisplayEvent(
                                                  //             timeline)
                                                  //         .body,
                                                  //     physics:
                                                  //         const NeverScrollableScrollPhysics(),
                                                  //     shrinkWrap: true,
                                                  //   )
                                                  : timeline.events[i]
                                                          .getDisplayEvent(
                                                              timeline)
                                                          .body
                                                          .startsWith(".")
                                                      ? Markdown(
                                                          data: timeline
                                                              .events[i]
                                                              .getDisplayEvent(
                                                                  timeline)
                                                              .body,
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          shrinkWrap: true,
                                                        )
                                                      : Text(timeline.events[i]
                                                          .getDisplayEvent(
                                                              timeline)
                                                          .body),
                                        ),
                                      ),
                                    ),
                        ),
                      ),
                      Container(
                        key: _avatarKey,
                        height: 20,
                        child: _sender
                            ? AnimatedList(
                                initialItemCount:
                                    timeline.events[0].receipts.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: ((context, index, animation) =>
                                    ScaleTransition(
                                        scale: animation,
                                        child: timeline.events[0].receipts
                                                    .length ==
                                                0
                                            ? null
                                            : CircleAvatar(
                                                foregroundImage: NetworkImage(
                                                    timeline
                                                        .events[0]
                                                        .receipts[index]
                                                        .user
                                                        .avatarUrl!
                                                        .getThumbnail(
                                                          widget.room.client,
                                                          width: 100,
                                                          height: 100,
                                                        )
                                                        .toString())))))
                            : null,
                      )
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
                    maxLines: null,
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
