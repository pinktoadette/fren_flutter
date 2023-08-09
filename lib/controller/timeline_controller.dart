import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:machi_app/api/machi/timeline_api.dart';
import 'package:machi_app/constants/constants.dart';
import 'package:machi_app/controller/storyboard_controller.dart';
import 'package:machi_app/datas/bot.dart';
import 'package:machi_app/datas/gallery.dart';
import 'package:machi_app/datas/story.dart';
import 'package:machi_app/datas/storyboard.dart';
import 'package:get/get.dart';

class TimelineController extends GetxController {
  StoryboardController storyboardController = Get.find(tag: 'storyboard');
  PagingController<int, Storyboard> pagingController =
      PagingController(firstPageKey: 0);
  Rx<Story?> _currentStory = (null).obs;

  /// top part of the timeline
  RxList<Bot> machiList = <Bot>[].obs;
  RxList<Gallery> galleryList = <Gallery>[].obs;

  final _timelineApi = TimelineApi();
  static const int _pageSize = ALL_PAGE_SIZE;

  Story get currentStory => _currentStory.value ?? intialStory;
  set currentStory(Story value) => _currentStory.value = value;

  @override
  void onInit() {
    super.onInit();
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey, false);
    });
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  Future<void> fetchHomepageItems(bool isLoggedIn) async {
    Map<String, dynamic> items = {};
    if (isLoggedIn) {
      items = await _timelineApi.getHomepage();
    } else {
      items = await _timelineApi.getPublicHomepage();
    }
    machiList.value = items['machi'];
    galleryList.value = items['gallery'];
  }

  /// clear any items when user signs in from public view
  clear() {
    machiList.value = [];
    galleryList.value = [];
    pagingController.itemList?.clear();
  }

  Future<void> fetchPage(int pageKey, bool? refresh) async {
    if (refresh == true) {
      pagingController.itemList?.clear();
    }
    try {
      List<Storyboard> newItems =
          await _timelineApi.getTimeline(_pageSize, pageKey, refresh);
      var isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        var nextPageKey = pageKey + newItems.length;
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  void insertPublishStoryboard(Storyboard storyboard) {
    pagingController.appendPage([storyboard], 0);
  }

  void setStoryTimelineControllerCurrent(Story story) {
    _currentStory = story.obs;
    storyboardController.setCurrentStory(story);
  }

  /// need to update likes
  void updateStoryboard(
      {required Storyboard storyboard, required Story updateStory}) {
    List<Storyboard> stories = pagingController.itemList!;
    int storyboardIndex = stories.indexWhere(
        (element) => element.storyboardId == storyboard.storyboardId);

    // update the details of page
    pagingController.itemList![storyboardIndex].story =
        pagingController.itemList![storyboardIndex].story!.map((e) {
      if (e.storyId == updateStory.storyId) {
        return updateStory;
      }
      return e;
    }).toList();
    _currentStory = updateStory.obs;

    pagingController.itemList;
    update();
  }
}
