import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/set_room_bot.dart';
import 'package:machi_app/controller/user_controller.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/helpers/navigation_helper.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:machi_app/screens/storyboard/create_new/quick_create.dart';
import 'package:machi_app/widgets/subscribe/subscription_product.dart';
import 'package:iconsax/iconsax.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class CreateStoryCard extends StatefulWidget {
  const CreateStoryCard({Key? key}) : super(key: key);

  @override
  State<CreateStoryCard> createState() => _CreateStoryCardState();
}

class _CreateStoryCardState extends State<CreateStoryCard> {
  bool isUserSubscribed = false;
  UserController userController = Get.find(tag: 'user');

  late AppLocalizations _i18n;
  CustomerInfo? customer;
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
    _i18n = AppLocalizations.of(context);
    double width = MediaQuery.of(context).size.width;
    return Card(
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: Container(
            color: Colors.white,
            width: width,
            padding: const EdgeInsets.only(bottom: 20, top: 20),
            child: InkWell(
                onTap: () {
                  NavigationHelper.handleGoToPageOrLogin(
                    context: context,
                    userController: userController,
                    navigateAction: () {
                      Get.to(() => const QuickCreateNewBoard());
                    },
                  );
                },
                child: Container(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(
                              Iconsax.book,
                              color: Colors.black,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _i18n.translate(
                                    "creative_mix_quickly_create_story"),
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                  _i18n.translate(
                                      "creative_mix_quickly_create_story_info"),
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14)),
                            ],
                          )
                        ])))));
  }
}
