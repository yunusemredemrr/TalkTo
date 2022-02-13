import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:talkto/model/message.dart';
import 'package:talkto/model/talk.dart';
import 'package:talkto/model/user.dart';
import 'package:talkto/repository/user_repository.dart';
import 'package:talkto/services/auth_base.dart';

import '../locator.dart';

enum ViewState { Idle, Busy }

class UserModel with ChangeNotifier implements AuthBase {
  ViewState _state = ViewState.Idle;
  UserRepository _userRepository = locator<UserRepository>();
  Users _user;

  String emailErrorMessage, passwordErrorMessage;

  Users get user => _user;

  ViewState get state => _state;

  set state(ViewState value) {
    _state = value;
    notifyListeners();
  }

  UserModel() {
    currentUser();
  }

  @override
  Future<Users> currentUser() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.currentUser();
      if (_user != null)
        return _user;
      else
        return null;
    } catch (e) {
      debugPrint(
          "ViewModeldeki (currentuser) current user hata : " + e.toString());
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<bool> signOut(String userID) async {
    try {
      state = ViewState.Busy;
      bool result = await _userRepository.signOut(userID);
      _user = null;
      return result;
    } catch (e) {
      debugPrint("ViewModeldeki (signout) current user hata : " + e.toString());
      return false;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<Users> signInAnonymously() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.signInAnonymously();
      return _user;
    } catch (e) {
      debugPrint(
          "ViewModeldeki (signInAnonymously) user hata : " + e.toString());
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<Users> signInWithGoogle() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.signInWithGoogle();
      if (_user != null)
        return _user;
      else
        return null;
    } catch (e) {
      debugPrint(
          "Viewmodeldeki (signInWithGoogle) current user hata:" + e.toString());
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<Users> createUserWithEmailAndPassword(
      String email, String password) async {
    if (_emailPasswordControl(email, password) == true) {
      try {
        state = ViewState.Busy;
        _user = await _userRepository.createUserWithEmailAndPassword(
            email, password);

        return _user;
      } finally {
        state = ViewState.Idle;
      }
    } else {
      return null;
    }
  }

  @override
  Future<Users> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      if (_emailPasswordControl(email, password) == true) {
        state = ViewState.Busy;
        _user =
            await _userRepository.signInWithEmailAndPassword(email, password);
        return _user;
      } else
        return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  bool _emailPasswordControl(String email, String password) {
    var sonuc = true;

    if (password.length < 6) {
      passwordErrorMessage = "En az 6 karakter olmalı";
      sonuc = false;
    } else {
      passwordErrorMessage = null;
    }

    if (validateEmail(email) == false) {
      emailErrorMessage = "Geçersiz E-mail adresi";
      sonuc = false;
    } else {
      emailErrorMessage = null;
    }

    return sonuc;
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  Future<bool> updateUserName(String userID, String newUserName) async {
    var result = await _userRepository.updateUserName(userID, newUserName);
    if (result == true) {
      _user.userName = newUserName;
    }
    return result;
  }

  Future<String> uploadFile(
      String userID, String fileType, File profilPhoto) async {
    var downloadLink =
        await _userRepository.uploadFile(userID, fileType, profilPhoto);
    return downloadLink;
  }

  Stream<List<Message>> getMessages(
      String currentUserID, String oppositeUserID) {
    return _userRepository.getMessages(currentUserID, oppositeUserID);
  }

  Future<List<Talk>> getAllConversations(String userID) async {
    return await _userRepository.getAllConversations(userID);
  }

  Future<List<Users>> getUserWithPagination(
      Users enSonGetirilenUser, int getirilecekElemanSayisi) async {
    return await _userRepository.getUserWithPagination(
        enSonGetirilenUser, getirilecekElemanSayisi);
  }
}
