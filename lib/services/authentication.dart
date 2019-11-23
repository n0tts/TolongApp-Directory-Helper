import 'dart:async';

import 'package:TolongApp/services/workers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  WorkerService workerService = new WorkerService();

  Auth();

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<String> signIn(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return user.uid;
  }

  Future<String> signInAnonymous() async {
    FirebaseUser user = await _firebaseAuth.signInAnonymously();
    return user.uid;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> signUp(String email, String password, String displayName) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    UserUpdateInfo info = new UserUpdateInfo();
    info.displayName = displayName;
    await user.updateProfile(info).whenComplete(() {});
  }
}

Auth auth = Auth();

abstract class BaseAuth {
  Future<FirebaseUser> getCurrentUser();

  Future<bool> isEmailVerified();

  Future<void> sendEmailVerification();

  Future<String> signIn(String email, String password);

  Future<String> signInAnonymous();

  Future<void> signOut();

  Future<void> signUp(String email, String password, String displayName);
}
