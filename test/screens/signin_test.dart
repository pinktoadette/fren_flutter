import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

void main() {
  testWidgets('SignInButton should trigger the sign-in process',
      (WidgetTester tester) async {
    bool isSignInTriggered = false;

    // Function to simulate the sign-in process
    void mockSignIn() {
      isSignInTriggered = true;
    }

    // Build the SignInButton inside a testbed
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: SignInButton(
            Buttons.Google,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onPressed: mockSignIn,
          ),
        ),
      ),
    );

    // Verify that isSignInTriggered is initially false
    expect(isSignInTriggered, false);

    // Tap the SignInButton
    await tester.tap(find.byType(SignInButton));

    // Wait for the testbed to rebuild the widget tree
    await tester.pump();

    // Verify that isSignInTriggered becomes true after tapping the button
    expect(isSignInTriggered, true);
  });
}
