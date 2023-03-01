import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fren_app/datas/user.dart' as fren;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/user_model.dart';

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
        final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();
        print (googleSignInAccount);

        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        UserCredential cred =  await _auth.signInWithCredential(credential);
        print (cred);
        //await UserModel().getUserByEmail(cred.user?.email);
        return cred;
      } on FirebaseAuthException catch (e) {
        print(e.message);
        throw e;
      }
  }

  Future<void> signOutFromGoogle() async{
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

}