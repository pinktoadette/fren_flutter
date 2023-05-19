import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/date_format.dart';
import 'package:machi_app/models/user_model.dart';
import 'package:get/get.dart';

Storyboard initialStoryboard = Storyboard(
    storyboardId: '',
    title: '',
    category: '',
    summary: '',
    createdBy: StoryUser(
        photoUrl: UserModel().user.userProfilePhoto,
        userId: UserModel().user.userId,
        username: UserModel().user.username),
    story: [],
    status: StoryStatus.UNPUBLISHED,
    createdAt: getDateTimeEpoch(),
    updatedAt: getDateTimeEpoch());

Story intialStory = Story(
    storyId: '',
    title: '',
    subtitle: '',
    createdBy: StoryUser(
        photoUrl: UserModel().user.userProfilePhoto,
        userId: UserModel().user.userId,
        username: UserModel().user.username),
    status: StoryStatus.UNPUBLISHED,
    category: '');

class StoryboardController extends GetxController {
  RxList<Storyboard> _storyboards = <Storyboard>[].obs;
  // ignore: prefer_final_fields
  Rx<Storyboard> _currentStoryboard = initialStoryboard.obs;
  Rx<Story?> _currentStory = (null).obs;

  Storyboard get currentStoryboard => _currentStoryboard.value;
  set currentStoryboard(Storyboard value) => _currentStoryboard.value = value;

  List<Storyboard> get storyboards => _storyboards;
  set storyboards(List<Storyboard> value) => _storyboards.value = value;

  Story get currentStory => _currentStory.value ?? intialStory;
  set currentStory(Story value) => _currentStory.value = value;

  RxList<Storyboard> unpublished = <Storyboard>[].obs;
  RxList<Storyboard> published = <Storyboard>[].obs;

  @override
  void onInit() async {
    // fetchMyStories();
    super.onInit();
  }

  Future<void> fetchMyStories() async {
    final storyboardApi = StoryboardApi();
    final List<Storyboard> stories = await storyboardApi.getMyStoryboards();
    _storyboards = stories.obs;
    _storyboards.refresh();
  }

  /// Storyboard
  Future<void> myStories(List<Storyboard> stories) async {
    _storyboards = stories.obs;
    _storyboards.refresh();
  }

  void addNewStoryboard(Storyboard story) async {
    _storyboards.insert(0, story);
    _storyboards.refresh();
  }

  void updateStoryboard(Storyboard story) async {
    // find storyboard index
    int index = _storyboards
        .indexWhere((element) => element.storyboardId == story.storyboardId);
    _storyboards[index] = story;
    _storyboards.refresh();
  }

  void setCurrentBoard(Storyboard story) async {
    currentStoryboard = story;
  }

  getUnpublised() {
    unpublished.assignAll(_storyboards
        .where((element) => element.status == StoryStatus.UNPUBLISHED)
        .toList());
  }

  getPublished() {
    published.assignAll(_storyboards
        .where((element) => element.status == StoryStatus.PUBLISHED)
        .toList());
  }

  /// Story
  clearStory() {
    _currentStory = intialStory.obs;
  }

  void addNewStory(Story story) async {
    List<Story> stories = currentStoryboard.story!;
    stories.insert(0, story);
    Storyboard newCurrenyStoryboard = currentStoryboard.copyWith(
      story: stories,
    );
    updateStoryboard(newCurrenyStoryboard);
  }

  void setCurrentStory(Story story) {
    _currentStory = story.obs;
  }

  /// Script
  void addNewScriptToStory(StoryPages page) {
    List<Story> stories = currentStoryboard.story!;

    /// update the story
    int index = stories
        .indexWhere((element) => element.storyId == currentStory.storyId);
    currentStoryboard.story![index].pages!.add(page);

    /// update the storyboard
    updateStoryboard(currentStoryboard);
  }
}
