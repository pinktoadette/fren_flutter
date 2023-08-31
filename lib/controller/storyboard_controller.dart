import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:machi_app/api/machi/storyboard_api.dart';
import 'package:machi_app/controller/comment_controller.dart';
import 'package:machi_app/datas/script.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:machi_app/helpers/date_format.dart';

Storyboard initialStoryboard = Storyboard(
    storyboardId: '',
    title: '',
    category: '',
    summary: '',
    createdBy: StoryUser(photoUrl: '', userId: '', username: ''),
    story: [],
    status: StoryStatus.UNPUBLISHED,
    createdAt: getDateTimeEpoch(),
    updatedAt: getDateTimeEpoch());

Story intialStory = Story(
    storyId: '',
    title: '',
    subtitle: '',
    createdBy: StoryUser(photoUrl: '', userId: '', username: ''),
    status: StoryStatus.UNPUBLISHED,
    category: '');

/// Unpublish will be _storyboards, that way you can add/edit
/// Publish variable is publish, cannot add/edit child
class StoryboardController extends GetxController {
  RxList<Storyboard> _storyboards = <Storyboard>[].obs;
  // ignore: prefer_final_fields
  Rx<Storyboard> _currentStoryboard = initialStoryboard.obs;
  Rx<Story?> _currentStory = (null).obs;

  // ignore: prefer_final_fields
  RxList<Storyboard> _published = <Storyboard>[].obs;

  Storyboard get currentStoryboard => _currentStoryboard.value;
  set currentStoryboard(Storyboard value) => _currentStoryboard.value = value;

  List<Storyboard> get storyboards => _storyboards;
  set storyboards(List<Storyboard> value) => _storyboards.value = value;

  Story get currentStory => _currentStory.value ?? intialStory;
  set currentStory(Story value) => _currentStory.value = value;

  List<Storyboard> get published => _published;
  set published(List<Storyboard> value) => _published.value = value;

  /// this is your own boards not timeline. Timeline has its own api call
  Future<void> getBoards(
      {StoryStatus? filter, CancelToken? cancelToken}) async {
    final storyboardApi = StoryboardApi();
    final List<Storyboard> stories = await storyboardApi.getMyStoryboards(
        statusFilter: filter?.name, cancelToken: cancelToken);
    if (filter == StoryStatus.PUBLISHED) {
      _published = stories.obs;
    } else {
      _storyboards = stories.obs;
    }
    update();
  }

  void addNewStoryboard(Storyboard story) async {
    _storyboards.insert(0, story);
    _storyboards.refresh();
    update();
  }

  void updateStoryboard(Storyboard story) async {
    // find storyboard index when there are changes
    int index = _storyboards
        .indexWhere((element) => element.storyboardId == story.storyboardId);
    if (index != -1) {
      _storyboards[index] = story;
    }
    _storyboards.refresh();
    update();
  }

  Storyboard findStoryboardByStory(Story story) {
    Storyboard storyboard = currentStoryboard.copyWith(story: [story]);
    return storyboard;
  }

  void removeStoryboardfromList(Storyboard storyboard) {
    _storyboards
        .removeWhere(((item) => item.storyboardId == storyboard.storyboardId));
    _storyboards.refresh();
    update();
  }

  void setCurrentBoard(Storyboard story) async {
    _currentStoryboard = story.obs;
  }

  /// Story
  void onGoToPageView(Story story) {
    Get.lazyPut<CommentController>(() => CommentController(), tag: "comment");
    currentStory = story;
  }

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

  void removeStory(Story story) async {
    List<Story> stories = currentStoryboard.story!;
    stories.removeWhere((element) => element.storyId == story.storyId);
    Storyboard newCurrenyStoryboard = currentStoryboard.copyWith(
      story: stories,
    );
    updateStoryboard(newCurrenyStoryboard);
  }

  /// the current story you are looking at
  void setCurrentStory(Story story) {
    _currentStory = story.obs;

    List<Story> stories = currentStoryboard.story!;
    int index =
        stories.indexWhere((element) => element.storyId == story.storyId);
    if (currentStoryboard.storyboardId != "" && index != -1) {
      currentStoryboard.story![index] = story;
    }
    _currentStory.refresh();
  }

  /// Script
  void addNewScriptToStory(StoryPages page) {
    List<Story> stories = currentStoryboard.story!;

    /// update the story
    int index = stories
        .indexWhere((element) => element.storyId == currentStory.storyId);

    if (index != -1 && currentStoryboard.story![index].pages!.isEmpty) {
      currentStoryboard.story![index].pages!.add(page);
    } else {
      currentStoryboard.story![index].pages![page.pageNum! - 1].scripts!
          .add(page.scripts![0]);
    }

    /// update the storyboard
    updateStoryboard(currentStoryboard);
  }

  void updateStory({required Story story}) {
    List<Story> stories = currentStoryboard.story!;
    int storyIndex =
        stories.indexWhere((element) => element.storyId == story.storyId);

    if (storyIndex != -1) {
      // update the details of page
      currentStoryboard.story![storyIndex] = story;
      setCurrentStory(story);
      updateStoryboard(currentStoryboard);
      _currentStory = story.obs;
      _currentStory.refresh();
      update();
    }
  }

  void updateScript({required Script script, required int pageNum}) {
    Story story = currentStory;

    if (story.pages![pageNum].scripts != null) {
      int scriptIndex = story.pages![pageNum].scripts!
          .indexWhere((element) => element.scriptId == script.scriptId);

      if (scriptIndex != -1) {
        story.pages![pageNum].scripts![scriptIndex] = script;
      }
    } else {
      story.pages?.add(StoryPages(scripts: [script], pageNum: 1));
    }

    currentStory = story;
    updateStory(story: story);
  }
}
