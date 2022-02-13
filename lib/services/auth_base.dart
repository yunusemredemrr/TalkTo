import 'package:talkto/model/user.dart';

abstract class AuthBase {
  Future<Users> currentUser();

  Future<Users> signInAnonymously();

  Future<bool> signOut(String userID);

  Future<Users> signInWithGoogle();

  Future<Users> signInWithEmailAndPassword(String email, String password);

  Future<Users> createUserWithEmailAndPassword(String email, String password);
}
