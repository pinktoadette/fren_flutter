import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GoogleAuthentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/userinfo.profile'],
  );

  Future<UserCredential> signInWithGoogle() async {

      try {
        print("helloooooo");
        final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();
        print (googleSignInAccount);

        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        return await _auth.signInWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        print(e.message);
        throw e;
      }
  }

  Future<void> signOutFromGoogle() async{
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  //   User? user;
  //   try {
  //     print ("hokokoko");
  //     final GoogleSignInAccount? googleSignInAccount =
  //     await _googleSignIn.signIn();
  //     print(googleSignInAccount);
  //     final GoogleSignInAuthentication googleSignInAuthentication =
  //     await googleSignInAccount!.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleSignInAuthentication.accessToken,
  //       idToken: googleSignInAuthentication.idToken,
  //     );
  //     UserCredential cred = await FirebaseAuth.instance.signInWithCredential(credential);
  //     user = cred.user;
  //     return user;
  //   } on FirebaseAuthException catch (e) {
  //     print(e.message);
  //     throw e;
  //   }
  // }
  //
  //  Future<void> signOutFromGoogle() async{
  //   await _googleSignIn.signOut();
  //   await FirebaseAuth.instance.signOut();
  // }

  // static Future<User?> signInWithGoogle({required BuildContext context}) async {
  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   User? user;
  //
  //   if (kIsWeb) {
  //     GoogleAuthProvider authProvider = GoogleAuthProvider();
  //     try {
  //       final UserCredential userCredential =
  //       await auth.signInWithPopup(authProvider);
  //       user = userCredential.user;
  //     } catch (e) {
  //       print(e);
  //     }
  //   } else {
  //     final GoogleSignIn googleSignIn = GoogleSignIn(scopes: <String>[
  //       'email',
  //       'https://www.googleapis.com/auth/contacts.readonly',
  //     ]);
  //     print ("here");
  //     print (googleSignIn);
  //     await googleSignIn.signIn();
  //
  //     print ("googleSignInAccount ");
  //     // print( googleSignInAccount);
  //     //
  //     // if (googleSignInAccount != null) {
  //     //   final GoogleSignInAuthentication googleSignInAuthentication =
  //     //   await googleSignInAccount.authentication;
  //     //
  //     //   final AuthCredential credential = GoogleAuthProvider.credential(
  //     //     accessToken: googleSignInAuthentication.accessToken,
  //     //     idToken: googleSignInAuthentication.idToken,
  //     //   );
  //     //
  //     //   try {
  //     //     final UserCredential userCredential =
  //     //     await auth.signInWithCredential(credential);
  //     //     user = userCredential.user;
  //     //   } on FirebaseAuthException catch (e) {
  //     //     if (e.code == 'account-exists-with-different-credential') {
  //     //       showScaffoldMessage(
  //     //           context: context, message: 'The account already exists with a different credential',
  //     //           bgcolor: Colors.red);
  //     //
  //     //     } else if (e.code == 'invalid-credential') {
  //     //       showScaffoldMessage(
  //     //           context: context, message: 'Error occurred while accessing credentials. Try again.',
  //     //           bgcolor: Colors.red);
  //     //
  //     //     }
  //     //   } catch (e) {
  //     //     showScaffoldMessage(
  //     //         context: context, message: 'Error occurred using Google Sign In. Try again.',
  //     //         bgcolor: Colors.red);
  //     //
  //     //   }
  //     // }
  //   }
  //
  //   return user;
  // }
  //
  // static Future<void> signOut({required BuildContext context}) async {
  //   final GoogleSignIn googleSignIn = GoogleSignIn();
  //
  //   try {
  //     if (!kIsWeb) {
  //       await googleSignIn.signOut();
  //     }
  //     await FirebaseAuth.instance.signOut();
  //   } catch (e) {
  //     showScaffoldMessage(
  //         context: context, message: 'Error signing out. Try again.',
  //         bgcolor: Colors.red);
  //
  //
  //   }
  // }
}