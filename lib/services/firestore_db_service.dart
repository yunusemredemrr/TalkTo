import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talkto/model/message.dart';
import 'package:talkto/model/talk.dart';
import 'package:talkto/model/user.dart';

import 'database_base.dart';

class FirestoreDBService implements DBBase {
  final FirebaseFirestore _firebaseDB = FirebaseFirestore.instance;

  @override
  Future<bool> saveUser(Users user) async {
    DocumentSnapshot _readUser =
        await FirebaseFirestore.instance.doc("users/${user.userID}").get();

    if (_readUser.data() == null) {
      await _firebaseDB.collection("users").doc(user.userID).set(user.toMap());
      return true;
    } else {
      return true;
    }
  }

  @override
  Future<Users> readUser(String userID) async {
    DocumentSnapshot _readUser =
        await _firebaseDB.collection("users").doc(userID).get();
    Map<String, dynamic> readUserInformationMap = _readUser.data();

    Users readUserObject = Users.fromMap(readUserInformationMap);
    //print("okunan user nesnesi" + readUserObject.toString());
    return readUserObject;
  }



  @override
  Future<bool> updateUserName(String userID, String newUserName) async {
    var users = await _firebaseDB
        .collection("users")
        .where("userName", isEqualTo: newUserName)
        .get();
    if (users.docs.length >= 1) {
      return false;
    } else {
      await _firebaseDB
          .collection("users")
          .doc(userID)
          .update({'userName': newUserName});
      return true;
    }
  }

  @override
  Future<bool> updateProfilPhoto(String userID, String profilPhotoUrl) async {
    await _firebaseDB
        .collection("users")
        .doc(userID)
        .update({'profilURL': profilPhotoUrl});
    return true;
  }

  @override
  Future<List<Talk>> getAllConversations(String userID) async {
    QuerySnapshot _querySnapshot = await _firebaseDB
        .collection("speeches")
        .where("konusma_sahibi", isEqualTo: userID)
        .orderBy("olusturulma_tarihi", descending: true)
        .get();

    List<Talk> allSpeeches = [];
    for (DocumentSnapshot onlySpeech in _querySnapshot.docs) {
      Talk _onlySpeech = Talk.fromMap(onlySpeech.data());
      allSpeeches.add(_onlySpeech);
    }

    return allSpeeches;
  }

  @override
  Stream<List<Message>> getMessages(String currentUserID, oppositeUserID) {
    var snapShot = _firebaseDB
        .collection("speeches")
        .doc(currentUserID + "--" + oppositeUserID)
        .collection("messages")
        .orderBy("date", descending: true)
        .limit(1)
        .snapshots();

    return snapShot.map((messagesList) => messagesList.docs
        .map((message) => Message.fromMap(message.data()))
        .toList());
  }

  Future<bool> saveMessage(Message tobeRecordedMessage) async {
    var _messageID = _firebaseDB.collection("speeches").doc().id;
    var _myDocumentID =
        tobeRecordedMessage.fromWho + "--" + tobeRecordedMessage.toWho;
    var oppositeDocumentID =
        tobeRecordedMessage.toWho + "--" + tobeRecordedMessage.fromWho;
    var _tobeRecordedMessageMapStructure = tobeRecordedMessage.toMap();

    await _firebaseDB
        .collection("speeches")
        .doc(_myDocumentID)
        .collection("messages")
        .doc(_messageID)
        .set(_tobeRecordedMessageMapStructure);

    await _firebaseDB.collection("speeches").doc(_myDocumentID).set(
      {
        "konusma_sahibi": tobeRecordedMessage.fromWho,
        "kimle_konusuyor": tobeRecordedMessage.toWho,
        "son_yollanan_mesaj": tobeRecordedMessage.message,
        "konusma_goruldu": false,
        "olusturulma_tarihi": FieldValue.serverTimestamp(),
      },
    );

    _tobeRecordedMessageMapStructure.update("isMe", (value) => false);

    await _firebaseDB
        .collection("speeches")
        .doc(oppositeDocumentID)
        .collection("messages")
        .doc(_messageID)
        .set(_tobeRecordedMessageMapStructure);

    await _firebaseDB.collection("speeches").doc(oppositeDocumentID).set(
      {
        "konusma_sahibi": tobeRecordedMessage.toWho,
        "kimle_konusuyor": tobeRecordedMessage.fromWho,
        "son_yollanan_mesaj": tobeRecordedMessage.message,
        "konusma_goruldu": false,
        "olusturulma_tarihi": FieldValue.serverTimestamp(),
      },
    );

    return true;
  }

  @override
  Future<DateTime> timeShow(String userID) async {
    await _firebaseDB.collection("server").doc(userID).set(
      {
        "saat": FieldValue.serverTimestamp(),
      },
    );
    var okunanMap = await _firebaseDB.collection("server").doc(userID).get();
    Timestamp okunanTarih = okunanMap.data()["saat"];
    return okunanTarih.toDate();
  }

  @override
  Future<List<Users>> getUserWithPagination(
      Users enSonGetirilenUser, int getirilecekElemanSayisi) async {
    QuerySnapshot _querySnapshot;
    List<Users> _tumKullanicilar = [];
    if (enSonGetirilenUser == null) {
      //print("İlk defa kullanıcılar getiriliyor");
      _querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .orderBy("userName")
          .get();
    }/* else {
     // print("son kullanıcılar getiriliyor");
      _querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .orderBy("userName")
          .startAfter([enSonGetirilenUser.userName])
          .limit(getirilecekElemanSayisi)
          .get();
      await Future.delayed(Duration(seconds: 1));
    }*/

    for (DocumentSnapshot snap in _querySnapshot.docs) {
      Users _tekUser = Users.fromMap(snap.data());
      _tumKullanicilar.add(_tekUser);
    }

    return _tumKullanicilar;
  }

  Future<List<Message>> getMessageWithPagination(
      String currentUserID,
      String oppositeUserID,
      Message lastBroughtMessage,
      int getirilecekElemanSayisi) async {
    QuerySnapshot _querySnapshot;
    List<Message> _allMessage = [];

    if (lastBroughtMessage == null) {
      //print("İlk defa kullanıcılar getiriliyor");
      _querySnapshot = await FirebaseFirestore.instance
          .collection("speeches")
          .doc(currentUserID + "--" + oppositeUserID)
          .collection("messages")
          .orderBy("date", descending: true)
          .limit(getirilecekElemanSayisi)
          .get();
    } else {
      //print("son kullanıcılar getiriliyor");
      _querySnapshot = await FirebaseFirestore.instance
          .collection("speeches")
          .doc(currentUserID + "--" + oppositeUserID)
          .collection("messages")
          .orderBy("date", descending: true)
          .startAfter([lastBroughtMessage.date])
          .limit(getirilecekElemanSayisi)
          .get();
      await Future.delayed(Duration(seconds: 1));
    }

    for (DocumentSnapshot snap in _querySnapshot.docs) {
      Message _tekMessage = Message.fromMap(snap.data());
      _allMessage.add(_tekMessage);
    }

    return _allMessage;
  }

  Future<String> tokenBring(String toWho) async {
    DocumentSnapshot _token = await _firebaseDB.doc("tokens/" + toWho).get();
    if (_token != null)
      return _token.data()["token"];
    else
      return null;
  }
  Future deleteToken(String toWho) async{
    await _firebaseDB.collection("tokens").doc(toWho).set({});
  }


}
