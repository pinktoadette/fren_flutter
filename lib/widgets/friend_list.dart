import 'package:flutter/material.dart';
import 'package:fren_app/api/machi/chatroom_api.dart';
import 'package:fren_app/api/machi/friend_api.dart';
import 'package:fren_app/constants/constants.dart';
import 'package:fren_app/datas/chatroom.dart';
import 'package:fren_app/datas/user.dart';
import 'package:fren_app/helpers/app_localizations.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:fren_app/screens/user/profile_screen.dart';
import 'package:fren_app/widgets/avatar_initials.dart';

class FriendListWidget extends StatefulWidget {
  final Chatroom chatroom;
  final int roomIdx;
  const FriendListWidget(
      {Key? key, required this.chatroom, required this.roomIdx})
      : super(key: key);

  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendListWidget> {
  final _friendApi = FriendApi();
  final _chatroomApi = ChatroomMachiApi();
  late AppLocalizations _i18n;
  List<dynamic> _listFriends = [];

  Future<void> _getFriends() async {
    final listFriends = await _friendApi.getAllFriends();
    setState(() {
      _listFriends = listFriends;
    });
  }

  Future<void> _inviteFriend(String friendId) async {
    await _chatroomApi.inviteUserRoom(
        widget.roomIdx, friendId, widget.chatroom);
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
        child: SizedBox(
      height: height * 0.88,
      child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: ListView.separated(
            separatorBuilder: (context, index) => const Divider(height: 10),
            itemCount: _listFriends.length,
            itemBuilder: ((context, index) {
              final isUserAdded = widget.chatroom.users.firstWhere(
                (element) => element.id == _listFriends[index][USER_ID],
              );
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
                subtitle: Text(_listFriends[index][USER_USERNAME]),
                trailing: isUserAdded.id.isNotEmpty
                    ? OutlinedButton(
                        onPressed: () {
                          null;
                        },
                        child: Text(
                          _i18n.translate("added_to_chat"),
                          style: const TextStyle(fontSize: 10),
                        ))
                    : ElevatedButton(
                        onPressed: () {
                          _inviteFriend(_listFriends[index][USER_ID]);
                        },
                        child: Text(
                          _i18n.translate("add_to_chat"),
                          style: const TextStyle(fontSize: 10),
                        )),
                onTap: () {},
              );
            }),
          )),
    ));
  }
}
