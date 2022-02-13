import 'package:talkto/model/user.dart';

import 'auth_base.dart';

class FakeAuthenticationService implements AuthBase {
  String userID = "123465789";

  Future<Users> currentUser() async {
    return await Future.value(Users(userID: userID,email: "fakeuser@fake.com"));
  }

  @override
  Future<bool> signOut(String userID) {
    return Future.value(true);
  }

  @override
  Future<Users> signInAnonymously() async {
    return await Future.delayed(
        Duration(seconds: 2), () => Users(userID: userID,email: "fakeuser@fake.com"));
  }

  @override
  Future<Users> signInWithGoogle() async {
    return await Future.delayed(
        Duration(seconds: 2), () => Users(userID: "Google_user_id_123456789",email: "fakeuser@fake.com"));
  }

  @override
  Future<Users> signInWithFacebook() async {
    return await Future.delayed(
        Duration(seconds: 2), () => Users(userID: "Facebook_user_id_123456789",email: "fakeuser@fake.com"));
  }

  @override
  Future<Users> createUserWithEmailAndPassword(
      String email, String password) async {
    return await Future.delayed(
        Duration(seconds: 2), () => Users(userID: "Created_user_id_123456789",email: "fakeuser@fake.com"));
  }

  @override
  Future<Users> signInWithEmailAndPassword(String email, String password) async {
    return await Future.delayed(
        Duration(seconds: 2), () => Users(userID: "SignIn_user_id_123456789",email: "fakeuser@fake.com"));
  }
}
