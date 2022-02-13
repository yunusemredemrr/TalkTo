import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talkto/app/talk_page.dart';
import 'package:talkto/model/talk.dart';
import 'package:talkto/model/user.dart';
import 'package:talkto/viewmodel/chat_view_model.dart';
import 'package:talkto/viewmodel/user_model.dart';

class MySpeechesPage extends StatefulWidget {
  @override
  _MySpeechesPageState createState() => _MySpeechesPageState();
}

class _MySpeechesPageState extends State<MySpeechesPage> {
  @override
  Widget build(BuildContext context) {
    UserModel _userModel = Provider.of<UserModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Sohbetler")),
      ),
      body: FutureBuilder<List<Talk>>(
        future: _userModel.getAllConversations(_userModel.user.userID),
        builder: (context, talkList) {
          if (talkList.hasData) {
            var allSpech = talkList.data;
            if (allSpech.length > 0) {
              return RefreshIndicator(
                onRefresh: _konusmalarinListesiniYenile,
                child: ListView.builder(
                  itemCount: allSpech.length,
                  addAutomaticKeepAlives: true,
                  itemBuilder: (context, index) {
                    var currentSpech = allSpech[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ChangeNotifierProvider<ChatViewModel>(
                              create: (context) => ChatViewModel(
                                currentUser: _userModel.user,
                                oppositeUser: Users.idVeResim(
                                  userID: currentSpech.who_is_talking,
                                  profilURL:currentSpech.konusulanUserProfilURL,
                                  userName: currentSpech.konusulanUserName,
                                ),
                              ),
                              child: TalkPage(),
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            child: ListTile(
                              title: currentSpech.last_message_sent.length < 10
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          currentSpech.last_message_sent,
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          currentSpech.aradakiFark,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          wordAbbreviation(
                                              currentSpech.last_message_sent),
                                          style: TextStyle(
                                              fontSize: 19,
                                              color: Colors.black),
                                        ),
                                        Expanded(
                                          child: Text(
                                            currentSpech.aradakiFark,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.blue.shade700,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                              subtitle: Text(
                                currentSpech.konusulanUserName,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey.withAlpha(40),
                                backgroundImage: currentSpech
                                            .konusulanUserProfilURL ==
                                        "images/unknown.jpg"
                                    ? ExactAssetImage(
                                        currentSpech.konusulanUserProfilURL)
                                    : NetworkImage(
                                        currentSpech.konusulanUserProfilURL),
                                radius: 34,
                              ),
                            ),
                          ),
                          Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width * 1,
                            margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width * 0.23),
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            } else {
              return RefreshIndicator(
                onRefresh: _konusmalarinListesiniYenile,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.chat,
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
                ),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  /*
  void _mySpeechesIncomign() async {
    final _userModel = Provider.of<UserModel>(context);
    var mySpeeches = await FirebaseFirestore.instance
        .collection("speeches")
        .where("konusma_sahibi", isEqualTo: _userModel.user.userID)
        .orderBy("olusturulma_tarihi", descending: true)
        .get();

    for (var speak in mySpeeches.docs) {
      print("Konuşma : " + speak.data.toString());
    }
  }

   */

  Future<Null> _konusmalarinListesiniYenile() async {
    setState(() {});
    await Future.delayed(Duration(milliseconds: 10));
    return null;
  }

  String wordAbbreviation(String last_message_sent) {
    String lastMessage;
    lastMessage = last_message_sent.substring(0, 10) + "...";
    return lastMessage;
  }
}
