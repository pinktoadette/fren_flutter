import 'package:flutter/material.dart';
import 'package:machi_app/api/machi/chatroom_api.dart';
import 'package:machi_app/api/machi/friend_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/datas/user.dart';
import 'package:machi_app/helpers/app_localizations.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:machi_app/screens/user/profile_screen.dart';
import 'package:machi_app/widgets/avatar_initials.dart';
import 'package:get/get.dart';

class FriendListWidget extends StatefulWidget {
  final int roomIdx;
  const FriendListWidget({Key? key, required this.roomIdx}) : super(key: key);

  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendListWidget> {
  final _friendApi = FriendApi();
  final _chatroomApi = ChatroomMachiApi();
  ChatController chatController = Get.find(tag: 'chatroom');
  late AppLocalizations _i18n;

  Future<List<dynamic>> _getFriends() async {
    return await _friendApi.getAllFriends();
  }

  Future<void> _inviteFriend(String friendId) async {
    await _chatroomApi.inviteUserRoom(
        widget.roomIdx, friendId, chatController.currentRoom);
    setState(() {});
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
                child: FutureBuilder(
                    future: _getFriends(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return Align(
                          alignment: Alignment.center,
                          child: Text(
                            _i18n.translate("friend_none"),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return ListView.separated(
                        separatorBuilder: (context, index) =>
                            const Divider(height: 10),
                        itemCount: snapshot.data.length,
                        itemBuilder: ((context, index) {
                          final isUserAdded =
                              chatController.currentRoom.users.where(
                            (element) =>
                                element.id == snapshot.data[index][USER_ID],
                          );
                          return ListTile(
                            leading: InkWell(
                                onTap: () async {
                                  final User user = await UserModel()
                                      .getUserObject(
                                          snapshot.data[index][USER_ID]);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          ProfileScreen(user: user)));
                                },
                                child: AvatarInitials(
                                  radius: 20,
                                  userId: snapshot.data[index][USER_ID],
                                  photoUrl: snapshot.data[index]
                                      [USER_PROFILE_PHOTO],
                                  username: snapshot.data[index][USER_USERNAME],
                                )),
                            title: Row(children: [
                              Text(snapshot.data[index][USER_USERNAME]),
                              const Spacer(),
                            ]),
                            subtitle: Text(snapshot.data[index][USER_USERNAME]),
                            trailing: isUserAdded.isNotEmpty
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
                                      _inviteFriend(
                                          snapshot.data[index][USER_ID]);
                                    },
                                    child: Text(
                                      _i18n.translate("add_to_chat"),
                                      style: const TextStyle(fontSize: 10),
                                    )),
                            onTap: () async {
                              final User user = await UserModel()
                                  .getUserObject(snapshot.data[index][USER_ID]);
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileScreen(user: user)));
                            },
                          );
                        }),
                      );
                    }))));
  }
}
