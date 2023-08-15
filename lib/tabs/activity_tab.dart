import 'package:flutter/material.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/subscribe/subscribe_token_counter.dart';
import 'package:machi_app/widgets/timeline/timeline_widget.dart';

class ActivityTab extends StatefulWidget {
  const ActivityTab({Key? key}) : super(key: key);

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = UserModel();
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "machi",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        automaticallyImplyLeading: false,
        actions: [
          if (user.getFirebaseUser != null) const SubscribeTokenCounter()
        ],
      ),
      body: const TimelineWidget(),
    );
  }
}
