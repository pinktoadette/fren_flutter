import 'package:fren_app/api/machi/timeline_api.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/datas/timeline.dart';
import 'package:fren_app/helpers/date_format.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:get/get.dart';

Timeline initial = Timeline(
    id: '',
    postType: 'text',
    text: '',
    subText: '',
    user: StoryUser(
        photoUrl: UserModel().user.userProfilePhoto,
        userId: UserModel().user.userId,
        username: UserModel().user.username),
    photoUrl: '',
    likes: 0,
    mylikes: 0,
    mymachi: false,
    createdAt: getDateTimeEpoch(),
    updatedAt: getDateTimeEpoch());

class TimelineController extends GetxController {
  // ignore: prefer_final_fields
  RxList<Timeline> feedList = <Timeline>[].obs;
  int offset = 0;
  int limit = 30;

  Stream<List<Timeline>> get streamFeed async* {
    yield feedList;
  }

  void fetchMyTimeline(Timeline item) {
    feedList.add(item);
    feedList.refresh();
  }
}
