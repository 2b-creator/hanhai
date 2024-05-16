// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:matrix/matrix.dart';
import 'dart:math';

import '../core/storage.dart';
import '../core/variables.dart';
import '../widgets/message_item.dart';
import '../models/people.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key, required this.client});
  final Client client;

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  int _count = 0;
  var messageController = TextEditingController();
  late final Future<Timeline> _timelineFuture;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final GlobalKey<AnimatedListState> _avatarKey =
      GlobalKey<AnimatedListState>();
  int room_index = 0;
  bool _sender = true;

  // Kullanicinin bu sayfaya erisimi yoksa welcomeScreen'e gonderiyoruz.
  getUser() async {
    Storage storage = Storage();

    var user = await storage.loadUser();
    // if (user == null) {
    //   Navigator.of(context)
    //       .pushNamedAndRemoveUntil("/welcome", (route) => false);
    // }
  }

  // Screen'imiz yuklendiginde auth fonksiyonumuzu calistiriyoruz.
  @override
  void initState() {
    super.initState();
    getUser();
  }

  sendMessage(_, index, func) {
    dynamic currentTime = DateFormat('hh:mm a')
        .format(DateTime.now().add(const Duration(hours: 3)));
    widget.client.rooms[room_index]
        .sendTextEvent(messageController.text.trim());
    _listKey.currentState?.setState(() {
      messages[index].add(
        MessageItem(
          message: messageController.text,
          time: currentTime,
          isMe: false,
        ),
      );

      peopleList[index].lastMessage = messageController.text;
      peopleList[index].unreadCount = -1;
      peopleList[index].dateTime = currentTime;
    });
    func();
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as List<dynamic>;

    final People people = arguments[0];
    final int index = arguments[1];
    final Function func = arguments[2];
    room_index = index;
    _timelineFuture = widget.client.rooms[index].getTimeline(
      onInsert: (insertID) {
        _listKey.currentState?.setState(() {});
      },
      onUpdate: () {
        _listKey.currentState?.setState(
          () {},
        );
      },
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 100.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30.0),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(people.avatarUrl),
                  radius: 25,
                ),
                const Gap(10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      people.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    getOnlineOrOffline()
                  ],
                ),
              ],
            ),
            const Row(
              children: [
                Icon(Icons.videocam),
                Gap(25),
                Icon(Icons.phone),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 241, 241, 241),
        ),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 140),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  //child: SingleChildScrollView(
                  child: FutureBuilder<Timeline>(
                    future: _timelineFuture,
                    builder: (context, snapshot) {
                      var timeline = snapshot.data;
                      if (timeline == null) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }
                      _count = timeline.events.length;
                      DateTime time = DateTime.now();
                      DateFormat indateFormat = DateFormat("HH:mm");
                      DateFormat overdateFormat = DateFormat("MM-dd");

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
                                  : timeline.events[i].body.startsWith("m.")
                                      // &&
                                      //         timeline.events[i].body !=
                                      //             "m.room.avatar" &&
                                      //         timeline.events[i].body !=
                                      //             "m.room.member"
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
                                              leading:
                                                  timeline.events[i].senderId ==
                                                          widget.client.userID
                                                      ? Container(
                                                          width: 20,
                                                          height: 20,
                                                        )
                                                      : CircleAvatar(
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
                                                                    widget
                                                                        .client,
                                                                    width: 56,
                                                                    height: 56,
                                                                  )
                                                                  .toString()),
                                                        ),
                                              title: Row(
                                                children: [
                                                  Expanded(
                                                    child: timeline.events[i]
                                                                .senderId ==
                                                            widget.client.userID
                                                        ? Container()
                                                        : Text(
                                                            timeline.events[i]
                                                                .sender
                                                                .calcDisplayname(),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        10),
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
                                              subtitle: MessageItem(
                                                  message: timeline.events[i]
                                                      .getDisplayEvent(timeline)
                                                      .body,
                                                  time: timeline.events[i]
                                                              .originServerTs
                                                              .difference(time)
                                                              .inDays >=
                                                          1
                                                      ? overdateFormat.format(
                                                          timeline.events[i]
                                                              .originServerTs)
                                                      : indateFormat.format(
                                                          timeline.events[i]
                                                              .originServerTs),
                                                  isMe: !(timeline
                                                          .events[i].senderId ==
                                                      widget.client.userID)),
                                            ),
                                          ),
                                        ),
                            ),
                          ),
                          SizedBox(
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
                                            child: timeline
                                                    .events[0].receipts.isEmpty
                                                ? null
                                                : CircleAvatar(
                                                    foregroundImage:
                                                        NetworkImage(timeline
                                                                    .events[0]
                                                                    .receipts[
                                                                        index]
                                                                    .user
                                                                    .avatarUrl ==
                                                                null
                                                            ? "https://s2.loli.net/2024/05/09/8LuOcAs6tIdUial.png"
                                                            : timeline
                                                                .events[0]
                                                                .receipts[index]
                                                                .user
                                                                .avatarUrl!
                                                                .getThumbnail(
                                                                  widget.client,
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
                  //),
                ),
              ),
              Container(
                width: double.infinity,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 241, 241, 241),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 25,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onSubmitted: (value) => sendMessage(
                              value,
                              index,
                              func,
                            ),
                            controller: messageController,
                            decoration: InputDecoration.collapsed(
                              hintText: 'Type here...',
                              hintStyle: TextStyle(
                                fontSize: 17,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(color: Colors.black.withOpacity(0.2)),
                        const Gap(15),
                        Row(
                          children: [
                            Icon(
                              Icons.mood,
                              size: 25,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            const Gap(17),
                            Icon(
                              Icons.photo_camera,
                              size: 25,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getOnlineOrOffline() {
    int rand = Random().nextInt(2) + 1;
    switch (rand) {
      case 1:
        {
          return const Text(
            "Online",
            style: TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 58, 158, 62),
            ),
          );
        }
      default:
        {
          return const Text(
            "Offline",
            style: TextStyle(
              fontSize: 16,
              color: Colors.red,
            ),
          );
        }
    }
  }
}
