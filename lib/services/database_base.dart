
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talkto/model/message.dart';
import 'package:talkto/model/talk.dart';
import 'package:talkto/model/user.dart';

abstract class DBBase {
  Future<bool> saveUser(Users user);

  Future<Users> readUser(String userID);

  Future<bool> updateUserName(String userID, String newUserName);

  Future<bool> updateProfilPhoto(String userID, String profilPhotoUrl);

  Future<List<Users>> getUserWithPagination(
      Users enSonGetirilenUser, int getirilecekElemanSayisi);

  Future<List<Talk>> getAllConversations(String userID);

  Stream<List<Message>> getMessages(String currentUserID, konusulanUserID);

  Future<bool> saveMessage(Message tobeRecordedMessage);

  Future<DateTime> timeShow(String userID);
}
