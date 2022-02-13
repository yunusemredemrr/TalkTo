import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talkto/model/message.dart';
import 'package:talkto/model/talk.dart';
import 'package:talkto/model/user.dart';
import 'package:talkto/services/auth_base.dart';
import 'package:talkto/services/fake_auth_service.dart';
import 'package:talkto/services/firebase_auth_service.dart';
import 'package:talkto/services/firebase_storage_service.dart';
import 'package:talkto/services/firestore_db_service.dart';
import 'package:talkto/services/notification_sending_service.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../locator.dart';

enum AppMode { DEBUG, RELEASE }

class UserRepository implements AuthBase {
  FirebaseAuthService _firebaseAuthService = locator<FirebaseAuthService>();
  FakeAuthenticationService _fakeAuthenticationService =
      locator<FakeAuthenticationService>();
  FirestoreDBService _firestoreDBService = locator<FirestoreDBService>();
  FirebaseStorageService _firebaseStorageService =
      locator<FirebaseStorageService>();
  NotificationSendingService _notificationSendingService =
      locator<NotificationSendingService>();

  AppMode appMode = AppMode.RELEASE;
  List<Users> allUserList = [];
  Map<String, String> userToken = Map<String, String>();

  @override
  Future<Users> currentUser() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.currentUser();
    } else {
      Users _user = await _firebaseAuthService.currentUser();
      if (_user != null)
        return await _firestoreDBService.readUser(_user.userID);
      else
        return null;
    }
  }

  @override
  Future<Users> signInAnonymously() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInAnonymously();
    } else {
      return await _firebaseAuthService.signInAnonymously();
    }
  }

  @override
  Future<bool> signOut(String userID) async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signOut(userID);
    } else {
      await _firestoreDBService.deleteToken(userID);
      return await _firebaseAuthService.signOut(userID);
    }
  }

  @override
  Future<Users> signInWithGoogle() async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInWithGoogle();
    } else {
      Users _user = await _firebaseAuthService.signInWithGoogle();
      if (_user != null) {
        bool _result = await _firestoreDBService.saveUser(_user);
        if (_result) {
          return await _firestoreDBService.readUser(_user.userID);
        } else {
          await _firebaseAuthService.signOut("");
          return null;
        }
      } else
        return null;
    }
  }

  @override
  Future<Users> createUserWithEmailAndPassword(
      String email, String password) async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.createUserWithEmailAndPassword(
          email, password);
    } else {
      Users _user = await _firebaseAuthService.createUserWithEmailAndPassword(
          email, password);
      bool _result = await _firestoreDBService.saveUser(_user);
      if (_result) {
        return await _firestoreDBService.readUser(_user.userID);
      } else
        return null;
    }
  }

  @override
  Future<Users> signInWithEmailAndPassword(
      String email, String password) async {
    if (appMode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInWithEmailAndPassword(
          email, password);
    } else {
      Users user = await _firebaseAuthService.signInWithEmailAndPassword(
          email, password);

      return await _firestoreDBService.readUser(user.userID);
    }
  }

  Future<bool> updateUserName(String userID, String newUserName) async {
    if (appMode == AppMode.DEBUG) {
      return false;
    } else {
      return await _firestoreDBService.updateUserName(userID, newUserName);
    }
  }

  Future<String> uploadFile(
      String userID, String fileType, File profilPhoto) async {
    if (appMode == AppMode.DEBUG) {
      return "dosya_indirme_linki";
    } else {
      var profilPhotoUrl = await _firebaseStorageService.uploadFile(
          userID, fileType, profilPhoto);
      await _firestoreDBService.updateProfilPhoto(userID, profilPhotoUrl);
      return profilPhotoUrl;
    }
  }

  Stream<List<Message>> getMessages(
      String currentUserID, String oppositeUserID) {
    if (appMode == AppMode.DEBUG) {
      return Stream.empty();
    } else {
      return _firestoreDBService.getMessages(currentUserID, oppositeUserID);
    }
  }

  Future<bool> saveMessage(
      Message tobeRecordedMessage, Users currentUser) async {
    if (appMode == AppMode.DEBUG) {
      return true;
    } else {
      var dbWriteProcess =
          await _firestoreDBService.saveMessage(tobeRecordedMessage);

      if (dbWriteProcess) {
        var token = "";
        if (userToken.containsKey(tobeRecordedMessage.toWho)) {
          token = userToken[tobeRecordedMessage.toWho];
        } else {
          token =
              await _firestoreDBService.tokenBring(tobeRecordedMessage.toWho);
          if (token != null) userToken[tobeRecordedMessage.toWho] = token;
        }
        if (token != null)
          await _notificationSendingService.notificationSend(
              tobeRecordedMessage, currentUser, token);

        return true;
      } else
        return false;
    }
  }

  Future<List<Talk>> getAllConversations(String userID) async {
    if (appMode == AppMode.DEBUG) {
      return [];
    } else {
      DateTime _zaman = await _firestoreDBService.timeShow(userID);

      var speechList = await _firestoreDBService.getAllConversations(userID);
      for (var oankiKonusma in speechList) {
        /*var userListesindekiKullanici = listedeUserBul(oankiKonusma.who_is_talking);
        if (userListesindekiKullanici != null) {
          //print("veriler local cacheden getiriliyor");
          oankiKonusma.konusulanUserName = userListesindekiKullanici.userName;
          oankiKonusma.konusulanUserProfilURL = userListesindekiKullanici.profilURL;
        } else {*/
        //print("Aranılan user daha önceden veri tabanından getirilmemiştir. o yüzden veritabanından bu veriyi okumalıyız");
        var veritabanindanOkunanUser =
            await _firestoreDBService.readUser(oankiKonusma.who_is_talking);
        oankiKonusma.konusulanUserName = veritabanindanOkunanUser.userName;
        oankiKonusma.konusulanUserProfilURL =
            veritabanindanOkunanUser.profilURL;
        //}
        timeagoHesapla(oankiKonusma, _zaman);
      }
      return speechList;
    }
  }

  Users listedeUserBul(String userID) {
    for (int i = 0; i < allUserList.length; i++) {
      if (allUserList[i].userID == userID) {
        return allUserList[i];
      }
    }
    return null;
  }

  void timeagoHesapla(Talk oankiKonusma, DateTime zaman) {
    oankiKonusma.sonOkumaZamani = zaman;
    timeago.setLocaleMessages("tr", timeago.TrMessages());
    var _duration = zaman.difference(oankiKonusma.creation_date.toDate());
    oankiKonusma.aradakiFark =
        timeago.format(zaman.subtract(_duration), locale: "tr");
  }

  Future<List<Users>> getUserWithPagination(
      Users enSonGetirilenUser, int getirilecekElemanSayisi) async {
    if (appMode == AppMode.DEBUG) {
      return [];
    } else {
      List<Users> _userList = await _firestoreDBService.getUserWithPagination(
          enSonGetirilenUser, getirilecekElemanSayisi);
      allUserList.addAll(_userList);
      return _userList;
    }
  }

  Future<List<Message>> getMessageWithPagination(
      String currentUserID,
      String oppositeUserID,
      Message lastBroughtMeesage,
      int getirilecekElemanSayisi) async {
    if (appMode == AppMode.DEBUG) {
      return [];
    } else {
      return await _firestoreDBService.getMessageWithPagination(currentUserID,
          oppositeUserID, lastBroughtMeesage, getirilecekElemanSayisi);
    }
  }
}
