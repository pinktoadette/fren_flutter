import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:machi_app/api/bot_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/widgets/discover_card.dart';

class HowToMachi extends StatefulWidget {
  const HowToMachi({Key? key}) : super(key: key);

  @override
  _HowToMachiState createState() => _HowToMachiState();
}

class _HowToMachiState extends State<HowToMachi> {
  final _botApi = BotApi();
  List _listFeatures = [];
  int _currentStep = 0;
  bool _visible = true;

  Future<void> _fetchInitialFrankie() async {
    List steps = await _botApi.getInitialFrankie();
    setState(() => _listFeatures = steps);
  }

  @override
  void initState() {
    super.initState();
    _fetchInitialFrankie();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          "assets/images/logo_white.png",
          width: max(150, width * 0.3),
        ),
      ),
      body: SingleChildScrollView(
        controller: ScrollController(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ActivityWidget()
            if (_currentStep < _listFeatures.length) _onCardClick()
          ],
        ),
      ),
    );
  }

  Widget _onCardClick() {
    if ((_currentStep == _listFeatures.length - 1) & (_visible == false)) {
      /// update user isFrankieInitaited false
      _updateUser();
      Get.back();
    }

    return NotificationListener<ButtonChanged>(
        child: AnimatedOpacity(
          // If the widget is visible, animate to 0.0 (invisible).
          // If the widget is hidden, animate to 1.0 (fully visible).
          opacity: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          // The green box must be a child of the AnimatedOpacity widget.
          child: DiscoverCard(
            image: _listFeatures[_currentStep]['image'],
            title: _listFeatures[_currentStep]['title'],
            subtitle: _listFeatures[_currentStep]['subtitle'],
            btnText: _listFeatures[_currentStep]['btn_text'],
          ),
        ),
        onNotification: (n) {
          if (_currentStep <= _listFeatures.length) {
            Future.delayed(const Duration(milliseconds: 100), () {
              setState(() {
                _visible = false;
              });
            });

            Future.delayed(const Duration(seconds: 1), () {
              setState(() {
                _currentStep = _currentStep + 1;
                _visible = true;
              });
            });
          } else {
            setState(() {
              _currentStep = _currentStep + 1;
              _visible = false;
            });
          }
          return true;
        });
  }

  void _updateUser() async {
    Map<String, bool> data = {USER_INITIATED_FRANK: true};
    await UserModel()
        .updateUserData(userId: UserModel().user.userId, data: data);
  }
}
