import 'package:flutter/material.dart';
import 'package:fren_app/api/bot_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/widgets/discover_card.dart';
import 'package:fren_app/widgets/search_user.dart';
import 'package:fren_app/widgets/subscribe/subscribe_card.dart';
import 'package:fren_app/widgets/timeline/timeline_widget.dart';

class ActivityTab extends StatefulWidget {
  const ActivityTab({Key? key}) : super(key: key);

  @override
  _ActivityTabState createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab> {
  final _botApi = BotApi();
  List _listFeatures = [];
  int _currentStep = 0;
  bool _visible = true;
  bool _isInitiatedFrank = false;

  Future<void> _fetchInitialFrankie() async {
    List steps = await _botApi.getInitialFrankie();
    setState(() => _listFeatures = steps);
  }

  @override
  void initState() {
    super.initState();
    User user = UserModel().user;
    if (user.isFrankInitiated == false) {
      _fetchInitialFrankie();
    }
    setState(() {
      _isInitiatedFrank = user.isFrankInitiated;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Initialization
    double screenWidth = MediaQuery.of(context).size.width;

    if (_isInitiatedFrank == true) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              SizedBox(
                width: screenWidth * 0.75,
                child: const SearchBarWidget(),
              ),
              // SizedBox(
              //   width: screenWidth * 0.25,
              //   child: const InviteCard(),
              // ),
            ],
          ),
        ),
        body: const SingleChildScrollView(
            child: Column(
          children: [
            SubscriptionCard(),
            TimelineWidget(),
          ],
        )),
      );
    }
    return Scaffold(
        body: Column(children: [
      SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ActivityWidget()
            if (_currentStep < _listFeatures.length) _onCardClick(),
          ],
        ),
      ),
      const Spacer(),
    ]));
  }

  Widget _onCardClick() {
    if ((_currentStep == _listFeatures.length - 1) & (_visible == false)) {
      /// update user isFrankieInitaited false
      _updateUser();
    }
    return NotificationListener<ButtonChanged>(
        child: AnimatedOpacity(
          // If the widget is visible, animate to 0.0 (invisible).
          // If the widget is hidden, animate to 1.0 (fully visible).
          opacity: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          // The green box must be a child of the AnimatedOpacity widget.
          child: DiscoverCard(
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
    setState(() {
      _isInitiatedFrank = true;
    });
  }
}
