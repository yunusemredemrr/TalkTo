import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talkto/app/talk_page.dart';
import 'package:talkto/viewmodel/all_users_view_model.dart';
import 'package:talkto/viewmodel/chat_view_model.dart';
import 'package:talkto/viewmodel/user_model.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  bool isLoading = false;
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();
  String userName = "";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_listScrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "Kullanıcılar",
          style: TextStyle(fontSize: 30),
        )),
        backgroundColor: Color.fromARGB(255, 67, 60, 93),
        elevation: 0,
      ),
      body: Column(
          children: [
            Container(
              color: Color.fromARGB(255, 67, 60, 93),
              padding: EdgeInsets.only(bottom: 8, left: 20, top: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Center(
                      child: TextField(
                        autofocus: false,
                        controller: _searchController,
                        cursorHeight: 20,
                        style: new TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.all(10),
                          filled: true,
                          hintText: "Kullanıcı Ara",
                          hintStyle: TextStyle(
                            fontSize: 20,
                            color: Colors.blueGrey,
                          ),
                          prefixIcon: Icon(Icons.search),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(20.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: 5, bottom: 5, left: 5, top: 5),
                      child: FloatingActionButton(
                        mini: true,
                        elevation: 10,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.search,
                          size: 28,
                          color: Colors.black,
                        ),
                        onPressed: () async {
                          setState(
                            () {
                              userName = _searchController.text;
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            buildConsumer(),
          ],
        ),
    );
  }

  Consumer<AllUserViewModel> buildConsumer() {
    return Consumer<AllUserViewModel>(
      builder: (context, model, child) {
        if (model.state == AllUserViewState.Busy) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (model.state == AllUserViewState.Loaded) {
          return RefreshIndicator(
            onRefresh: model.refresh,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.30,
              child: ListView.builder(
                controller: _scrollController,
                itemBuilder: (context, index) {
                  if (model.usersList.length == 1) {
                    return _noUserUI();
                  }
                  if (model.hasMoreLoading && index == model.usersList.length) {
                    return _yeniElemanlarYukleniyorIndicator();
                  } else {
                    return _userListeElemaniOlustur(index);
                  }
                },
                itemCount: model.hasMoreLoading == true
                    ? model.usersList.length + 1
                    : model.usersList.length,
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _noUserUI() {
    final _usersModel = Provider.of<AllUserViewModel>(context);
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.supervised_user_circle,
                color: Theme.of(context).primaryColor,
                size: 120,
              ),
              Text(
                "Henüz kullanıcı yok",
                style: TextStyle(fontSize: 36),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        height: MediaQuery.of(context).size.height - 150,
      ),
    );
  }

  Widget _userListeElemaniOlustur(int index) {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    final _allUsersViewModel =
        Provider.of<AllUserViewModel>(context, listen: false);
    var _oankiUser = _allUsersViewModel.usersList[index];
    if (_oankiUser.userID == _userModel.user.userID) {
      return Container();
    }
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider<ChatViewModel>(
                  create: (context) => ChatViewModel(
                      currentUser: _userModel.user, oppositeUser: _oankiUser),
                  child: TalkPage(),
                ),
              ),
            );
          },
          child: _oankiUser.userName == userName
              ? Column(
                  children: [
                    Container(
                      height: 70,
                      padding: EdgeInsets.only(top: 15),
                      child: ListTile(
                        title: Text(
                          _oankiUser.userName,
                          style: TextStyle(
                              fontSize:
                                  _oankiUser.userName.length < 28 ? 18.5 : 15),
                        ),
                        //subtitle: Text(_oankiUser.email),
                        leading: CircleAvatar(
                          backgroundImage:
                              _oankiUser.profilURL == "images/unknown.jpg"
                                  ? ExactAssetImage(_oankiUser.profilURL)
                                  : NetworkImage(_oankiUser.profilURL),
                          radius: 34,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 1,
                      width: MediaQuery.of(context).size.width * 1,
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.23),
                      color: Colors.black45,
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: Container(),
                ),
        ),
      ],
    );
  }

  _yeniElemanlarYukleniyorIndicator() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void bringMoreUsers() async {
    if (isLoading == false) {
      isLoading = true;
      final _allUsersViewModel =
          Provider.of<AllUserViewModel>(context, listen: false);
      await _allUsersViewModel.bringMoreUsers();
      isLoading = false;
    }
  }

  void _listScrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      bringMoreUsers();
    }
  }
}
