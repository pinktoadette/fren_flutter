import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machi_app/widgets/like_widget.dart';
import 'package:like_button/like_button.dart';

void main() {
  testWidgets('LikeItemWidget should trigger onLike callback',
      (WidgetTester tester) async {
    int initialLikes = 10;
    int initialMyLikes = 0;
    bool onLikeCallbackCalled = false;

    // Function to be called when the LikeButton is tapped
    void handleLike(bool isLiked) {
      onLikeCallbackCalled = true;
      // Simulate the behavior of updating likes
      if (isLiked) {
        initialLikes++;
        initialMyLikes = 1;
      } else {
        initialLikes--;
        initialMyLikes = 0;
      }
    }

    // Build the LikeItemWidget
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: LikeItemWidget(
            onLike: (like) {
              handleLike(like);
            },
            likes: initialLikes,
            mylikes: initialMyLikes,
          ),
        ),
      ),
    );

    // Verify the initial state of the LikeItemWidget
    expect(find.text(initialLikes.toString()), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    // Tap the LikeButton
    await tester.tap(find.byType(LikeButton));

    // Wait for the widget tree to update after the tap and settle
    await tester.pumpAndSettle();

    // Verify that the onLike callback is triggered and likes are updated
    expect(onLikeCallbackCalled, true);
    // expect(find.text((initialLikes + 1).toString()), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
