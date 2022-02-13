

import 'package:flutter/cupertino.dart';
import 'package:talkto/model/user.dart';
import 'package:talkto/repository/user_repository.dart';

import '../locator.dart';

enum AllUserViewState { Idle, Loaded, Busy }

class AllUserViewModel with ChangeNotifier {
  AllUserViewState _state = AllUserViewState.Idle;
  List<Users> _allUsers;
  Users _lastBroughtUser;
  static final sayfaBasinaGonderiSayisi = 10;
  UserRepository _userRepository = locator<UserRepository>();
  bool _hasMore = true;

  bool get hasMoreLoading => _hasMore;

  List<Users> get usersList => _allUsers;

  AllUserViewState get state => _state;

  set state(AllUserViewState value) {
    _state = value;
    notifyListeners();
  }

  AllUserViewModel() {
    _allUsers = [];
    _lastBroughtUser = null;
    getUserWithPagination(_lastBroughtUser, false);
  }

  //refresh ve sayfalama için
  //newEmployeesBroughtIn true yapılır
  //İlk açılış için newEmployeesBroughtIn false değer verilir
  getUserWithPagination(
      Users lastBroughtUser, bool newEmployeesBroughtIn) async {
    if (_allUsers.length > 0) {
      _lastBroughtUser = _allUsers.last;
      //print("EN SON GETİRİLEN USER " + _lastBroughtUser.userName);
    }

    if (newEmployeesBroughtIn == true) {
    } else {
      state = AllUserViewState.Busy;
    }

    var newList = await _userRepository.getUserWithPagination(
        _lastBroughtUser, sayfaBasinaGonderiSayisi);

    if (newList.length < sayfaBasinaGonderiSayisi) {
      _hasMore = false;
    }

    //newList.forEach((element) => print("Getirilen userName : " + element.userName));

    _allUsers.addAll(newList);
    
    state = AllUserViewState.Loaded;
  }

  Future<void> bringMoreUsers() async {
    //print("Daha fazla user getir tetiklendi - view modeldeyiz - ");
    if (_hasMore = true) {
      getUserWithPagination(_lastBroughtUser, true);
    }
    await Future.delayed(Duration(seconds: 1));
  }

  Future<Null> refresh() async {
    _hasMore = true;
    _lastBroughtUser = null;
    _allUsers = [];
    getUserWithPagination(_lastBroughtUser, true);
  }
}
