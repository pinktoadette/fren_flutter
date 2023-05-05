import 'package:fren_app/api/machi/story_api.dart';
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
  RxList<Timeline> _feed = [initial].obs;
  int offset = 0;
  int limit = 30;

  List<Timeline> get feed => _feed;
  set feed(List<Timeline> value) => _feed.value = value;

  @override
  void onInit() async {
    fetchMyTimeline();
    super.onInit();
  }

  Future<void> fetchMyTimeline() async {
    final timelineApi = TimelineApi();
    final List<Timeline> stories = await timelineApi.getTimeline(limit, offset);
    _feed = stories.obs;
    _feed.refresh();
  }
}
