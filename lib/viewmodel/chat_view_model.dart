import 'dart:async';
import 'package:flutter/material.dart';
import 'package:talkto/model/message.dart';
import 'package:talkto/model/user.dart';
import 'package:talkto/repository/user_repository.dart';

import '../locator.dart';
enum ChatViewState { Idle, Loaded, Bussy }

class ChatViewModel with ChangeNotifier {
  List<Message> _allMessage;
  ChatViewState _state = ChatViewState.Idle;
  static final sayfaBasinaGonderiSayisi = 100;
  UserRepository _userRepository = locator<UserRepository>();
  Message _lastBroughtMessage;
  Message _firstMessageAddedToTheList;
  bool _hasMore = true;
  bool _newMessageListenListener = false;

  bool get hasMoreLoading => _hasMore;

  StreamSubscription _streamSubscription;

  final Users currentUser;
  final Users oppositeUser;

  ChatViewModel({this.currentUser, this.oppositeUser}) {
    _allMessage = [];
    getMessageWithPagination(false);
  }

  List<Message> get messageList => _allMessage;

  ChatViewState get state => _state;

  set state(ChatViewState value) {
    _state = value;
    notifyListeners();
  }

  @override
  dispose(){
    _streamSubscription.cancel();
    super.dispose();
  }

  Future<bool> saveMessage(Message tobeRecordedMessage, Users currentUser) async {
    return await _userRepository.saveMessage(tobeRecordedMessage,currentUser);
  }

  void getMessageWithPagination(bool newMessageFetching) async {
    if (_allMessage.length > 0) {
      _lastBroughtMessage = _allMessage.last;
    }
    if (!newMessageFetching) state = ChatViewState.Bussy;
    var broughtMessage = await _userRepository.getMessageWithPagination(
        currentUser.userID,
        oppositeUser.userID,
        _lastBroughtMessage,
        sayfaBasinaGonderiSayisi);

    if (broughtMessage.length < sayfaBasinaGonderiSayisi) {
      _hasMore = false;
    }
    _allMessage.addAll(broughtMessage);

    if (_allMessage.length > 0) {
      _firstMessageAddedToTheList = _allMessage.first;
    }

    state = ChatViewState.Loaded;

    if (_newMessageListenListener == false) {
      _newMessageListenListener = true;
      newMessageListenerAssign();
    }
  }

  Future<void> bringMoreMessages() async {
    //print("Daha fazla mesaj getir tetiklendi - view modeldeyiz - ");
    if (_hasMore = true) {
      getMessageWithPagination(true);
    }
    await Future.delayed(Duration(seconds: 1));
  }

  void newMessageListenerAssign() {
    _streamSubscription = _userRepository
        .getMessages(currentUser.userID, oppositeUser.userID)
        .listen((anlikData) {
      if (anlikData.isNotEmpty) {
        if (anlikData[0].date != null) {
          if (_firstMessageAddedToTheList == null) {
            _allMessage.insert(0, anlikData[0]);
          } else if (_firstMessageAddedToTheList.date.millisecondsSinceEpoch !=
              anlikData[0].date.millisecondsSinceEpoch)
            _allMessage.insert(0, anlikData[0]);
        }
        state = ChatViewState.Loaded;
      }
    });
  }
}
