import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Tab for switch publish and unpublished story
class StoryTabController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void onInit() {
    tabController = TabController(vsync: this, length: 2);
    super.onInit();
  }
}
