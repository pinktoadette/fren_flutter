import 'package:fren_app/api/machi/story_api.dart';
import 'package:fren_app/datas/storyboard.dart';
import 'package:fren_app/helpers/date_now.dart';
import 'package:fren_app/models/user_model.dart';
import 'package:get/get.dart';

class StoryboardController extends GetxController {
  RxList<Storyboard> _stories = [
    Storyboard(
        title: '',
        createdBy: StoryUser(
            photoUrl: UserModel().user.userProfilePhoto,
            userId: UserModel().user.userId,
            username: UserModel().user.username),
        messages: [],
        createdAt: getDateTimeEpoch(),
        updatedAt: getDateTimeEpoch())
  ].obs;

  List<Storyboard> get stories => _stories;
  set stories(List<Storyboard> value) => _stories.value = value;

  @override
  void onInit() async {
    fetchMyStories();
    super.onInit();
  }

  Future<void> fetchMyStories() async {
    final storyApi = StoryApi();
    final List<Storyboard> stories = await storyApi.getMyStories();
    _stories = stories.obs;
  }
}
