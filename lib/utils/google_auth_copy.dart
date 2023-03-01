import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:fren_app/screens/home_screen.dart';
import 'package:fren_app/widgets/show_scaffold_msg.dart';

class GoogleAuthentication {

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();

      try {
        final UserCredential userCredential =
        await auth.signInWithPopup(authProvider);
        print(userCredential);
        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
      await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
          await auth.signInWithCredential(credential);
          print (userCredential);
          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            showScaffoldMessage(
                context: context, message: 'The account already exists with a different credential',
                bgcolor: Colors.red);

          } else if (e.code == 'invalid-credential') {
            showScaffoldMessage(
                context: context, message: 'Error occurred while accessing credentials. Try again.',
                bgcolor: Colors.red);

          }
        } catch (e) {
          showScaffoldMessage(
              context: context, message: 'Error occurred using Google Sign In. Try again.',
              bgcolor: Colors.red);

        }
      }
    }

    return user;
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      showScaffoldMessage(
          context: context, message: 'Error signing out. Try again.',
          bgcolor: Colors.red);


    }
  }
}