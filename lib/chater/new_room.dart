import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddRoomPageWidget extends StatefulWidget {
  const AddRoomPageWidget({super.key});
  @override
  State<AddRoomPageWidget> createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("添加房间"),
      ),
    );
  }
}
