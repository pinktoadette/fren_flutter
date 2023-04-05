import 'package:flutter/material.dart';
import 'package:fren_app/api/machi/friend_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/user/profile_screen.dart';
import 'package:fren_app/widgets/avatar_initials.dart';

class FriendListWidget extends StatefulWidget {
  const FriendListWidget({Key? key}) : super(key: key);

  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendListWidget> {
  final _friendApi = FriendApi();
  late AppLocalizations _i18n;
  List<dynamic> _listFriends = [];

  Future<void> _getFriends() async {
    final listFriends = await _friendApi.getAllFriends();
    setState(() {
      _listFriends = listFriends;
    });
  }

  @override
  void initState() {
    _getFriends();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _i18n = AppLocalizations.of(context);
    double height = MediaQuery.of(context).size.height;
    // need container for the top padding, then add back the scroll
    return SingleChildScrollView(
        child: Container(
      height: height * 0.88,
      child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: ListView.separated(
            separatorBuilder: (context, index) => const Divider(height: 10),
            itemCount: _listFriends.length,
            itemBuilder: ((context, index) {
              /// Show notification
              return ListTile(
                leading: InkWell(
                    onTap: () async {
                      final User user = await UserModel()
                          .getUserObject(_listFriends[index][USER_ID]);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProfileScreen(user: user)));
                    },
                    child: AvatarInitials(
                      radius: 20,
                      photoUrl: _listFriends[index][USER_PROFILE_PHOTO],
                      username: _listFriends[index][USER_USERNAME],
                    )),
                title: Row(children: [
                  Text(_listFriends[index][USER_USERNAME]),
                  const Spacer(),
                ]),
                trailing: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      _i18n.translate("add_to_chat"),
                      style: const TextStyle(fontSize: 10),
                    )),
                onTap: () async {},
              );
            }),
          )),
    ));
  }
}
