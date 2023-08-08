import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:machi_app/controller/chatroom_controller.dart';
import 'package:machi_app/controller/subscription_controller.dart';
import 'package:machi_app/widgets/ads/inline_ads.dart';
import 'package:machi_app/widgets/subscribe/subscribe_card.dart';

class SuggestionWidget extends StatefulWidget {
  const SuggestionWidget({super.key});

  @override
  _SuggestionWidgetState createState() => _SuggestionWidgetState();
}

class _SuggestionWidgetState extends State<SuggestionWidget> {
  ChatController chatController = Get.find(tag: 'chatroom');
  SubscribeController subscriptionController = Get.find(tag: 'subscribe');

  final List<Map<String, dynamic>> topics = [
    {
      'topic': "meme",
      "items": [
        {"title": "hi"},
        {"title": "hi2"},
        {"title": "hi3"},
        {"title": "hi4"},
        {"title": "hi5"},
      ],
    },
    {
      'topic': "animals",
      "items": [
        {"title": "bye"},
        {"title": "bye2"},
        {"title": "bye3"},
        {"title": "bi4"},
        {"title": "bi5"},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
            child: Column(
          children: [
            const InlineAdaptiveAds(),
            Column(
                children: topics.map((topicData) {
              return Column(
                children: [
                  Text(topicData['topic']),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: topicData['items'].map<Widget>((item) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey,
                          child: Center(child: Text(item['title'])),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }).toList()),
            const SubscriptionCard(),
            subscriptionController.customer == null
                ? const SizedBox.shrink()
                : subscriptionController.customer!.allPurchaseDates.isEmpty
                    ? const SubscriptionCard()
                    : const SizedBox.shrink(),

            // 3x3 grid of image placeholders
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.grey,
                  margin: const EdgeInsets.all(1),
                );
              },
            ),

            const SizedBox(height: 20),

            // Two cards side by side
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: ListTile(
                      title: Text('Card 1'),
                      subtitle: Text('Card 1 Subtitle'),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Card(
                    child: ListTile(
                      title: Text('Card 2'),
                      subtitle: Text('Card 2 Subtitle'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        )));
  }
}
