import 'package:flutter/material.dart';

class CallListView extends StatefulWidget {
  const CallListView({super.key});

  @override
  State<CallListView> createState() => _CallListViewState();
}

class _CallListViewState extends State<CallListView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Text(
            "CallListView",
          )
        ],
      ),
    );
  }
}
