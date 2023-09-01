import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/storyboard/create_new/quick_create.dart';
import 'package:machi_app/widgets/signin/signin_widget.dart';
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
          if (user.getFirebaseUser != null) ..._isSignedIn(),
          if (user.getFirebaseUser == null)
            TextButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (context) => FractionallySizedBox(
                      heightFactor: 0.45,
                      widthFactor: 1,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: const SignInWidget(),
                      ),
                    ),
                  );
                },
                child: const Text("Login"))
        ],
      ),
      body: const TimelineWidget(),
    );
  }

  List<Widget> _isSignedIn() {
    return [
      IconButton(
          onPressed: () {
            Get.to(() => const QuickCreateNewBoard());
          },
          icon: const Icon(
            Iconsax.book,
            size: 14,
          )),
      const SubscribeTokenCounter(),
    ];
  }
}
