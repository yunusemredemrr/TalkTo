import 'package:cloud_firestore_platform_interface/src/timestamp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:talkto/model/message.dart';
import 'package:talkto/viewmodel/chat_view_model.dart';

class TalkPage extends StatefulWidget {
  @override
  _TalkPageState createState() => _TalkPageState();
}

class _TalkPageState extends State<TalkPage> {
  var _messageControler = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    final _chatModel = Provider.of<ChatViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 67, 60, 93),
        elevation: 0,
        toolbarHeight: 100,
        leadingWidth: 50,
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 5,
            ),
            CircleAvatar(
              backgroundImage:
                  _chatModel.oppositeUser.profilURL == "images/unknown.jpg"
                      ? ExactAssetImage(_chatModel.oppositeUser.profilURL)
                      : NetworkImage(_chatModel.oppositeUser.profilURL),
              backgroundColor: Colors.grey.withAlpha(40),
              radius: 30,
            ),
            SizedBox(
              width: 20,
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _chatModel.oppositeUser.userName.length < 20
                  ? Text(
                _chatModel.oppositeUser.userName,
                style: TextStyle(fontSize: 20,color: Colors.white),
              )
                  : Text(
                userNameAbbreviation(_chatModel.oppositeUser.userName),
                style: TextStyle(fontSize: 18,color: Colors.white),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
      body: _chatModel.state == ChatViewState.Bussy
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.green,
              ),
            )
          : Center(
              child: Container(
                color: Color.fromARGB(255, 67, 60, 93),
                child: Column(
                  children: <Widget>[
                    _buildMessageList(),
                    _buildNewMessageEnter(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMessageList() {
    return Consumer<ChatViewModel>(
      builder: (context, chatModel, child) {
        return Expanded(
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            itemCount: chatModel.hasMoreLoading
                ? chatModel.messageList.length + 1
                : chatModel.messageList.length,
            itemBuilder: (context, index) {
              if (chatModel.hasMoreLoading &&
                  chatModel.messageList.length == index) {
                return _newMessageLoadingIndicator();
              } else
                return _createSpeechBubble(chatModel.messageList[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildNewMessageEnter() {
    final _chatModel = Provider.of<ChatViewModel>(context);
    return Card(
      elevation: 10,
      child: Container(
        color: Color.fromARGB(255, 67, 60, 93),
        padding: EdgeInsets.only(bottom: 8, left: 8, top: 10),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageControler,
                    cursorColor: Colors.green.shade900,
                    style: new TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade50,
                      contentPadding: EdgeInsets.all(10),
                      filled: true,
                      hintText: "Mesajınızı Yazınız",
                      hintStyle: TextStyle(fontSize: 18, color: Colors.blueGrey),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(15.0),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 0,
                  ),
                  child: FloatingActionButton(
                    mini: true,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.send,
                      size: 25,
                      color: Colors.black87,
                    ),
                    onPressed: () async {
                      if (_messageControler.text.trim().length > 0) {
                        Message _tobeRecordedMessage = Message(
                          fromWho: _chatModel.currentUser.userID,
                          toWho: _chatModel.oppositeUser.userID,
                          isMe: true,
                          message: _messageControler.text,
                        );
                        _messageControler.clear();
                        var result = await _chatModel.saveMessage(
                            _tobeRecordedMessage, _chatModel.currentUser);
                        if (result) {}
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _createSpeechBubble(Message currentMessage) {
    Color _incomingMessageColor = Color.fromARGB(255, 250, 200, 243);
    Color _outgoingMessageColor = Color.fromARGB(255, 0, 243, 249);
    final _chatModel = Provider.of<ChatViewModel>(context);

    var _hourMinuteValue = "";

    try {
      _hourMinuteValue =
          _hourMinuteShow(currentMessage.date) ?? Timestamp(1, 1);
    } catch (e) {
      print("hata " + e.toString());
    }

    var _isMeMessage = currentMessage.isMe;
    if (_isMeMessage) {
      return Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 300, minWidth: 40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                        bottomLeft: Radius.circular(6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8.0,
                          offset: Offset(3, 2),
                          color: Colors.black,
                        ),
                      ],
                      color: _outgoingMessageColor,
                    ),
                    padding:
                        EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 2),
                    margin: EdgeInsets.all(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          currentMessage.message,
                          style: TextStyle(
                            color: Colors.black,
                            //fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          _hourMinuteValue,
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 1.0,
                          offset: Offset(3, 2),
                          color: Colors.black,
                        ),
                      ],
                      color: _incomingMessageColor,
                    ),
                    padding: EdgeInsets.only(
                        top: 10, left: 15, right: 10, bottom: 2),
                    margin: EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          currentMessage.message,
                          style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          _hourMinuteValue,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  String _hourMinuteShow(Timestamp date) {
    var _formatter = DateFormat.Hm();
    var _formattedDate = _formatter.format(date.toDate());
    return _formattedDate;
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      bringOldMessages();
    }
  }

  void bringOldMessages() async {
    final _chatModel = Provider.of<ChatViewModel>(context, listen: false);
    if (isLoading == false) {
      isLoading = true;
      await _chatModel.bringMoreMessages();
      isLoading = false;
    }
  }

  _newMessageLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  String userNameAbbreviation(String userNameAbbreviation) {
    String shortUserName;
    shortUserName = userNameAbbreviation.substring(0, 20) + "...";
    return shortUserName;
  }
}
