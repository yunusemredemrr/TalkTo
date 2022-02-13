import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talkto/common_widget/social_log_in_button.dart';
import 'package:talkto/model/user.dart';
import 'package:talkto/viewmodel/user_model.dart';

import 'email_pasword_login_signup.dart';

class SignInPage extends StatelessWidget {
  /*void _guestLogin(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    User _user = await _userModel.signInAnonymously();
    debugPrint("kullanıcı id : " + _user.userID.toString());
  }*/

  void _emailAndPasswordLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => EmailAndPasswordLoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height*1,
          child: Card(
            shadowColor: Colors.blue,
            elevation: 100,
            margin: EdgeInsets.only(top: 50,left: 15,right: 15,bottom: 30),
            shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                /*Center(
                  child: Text(
                    "TalkTo Hoşgeldiniz",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade900,
                    ),
                  ),
                ),*/
                //SizedBox(height: size.height*0.06),
                Image.asset("images/message_icon.png", height: size.width*0.8),
                SizedBox(height: size.height*0.07),
                SocialLoginButton(
                  buttonText: "Giriş yap",
                  buttonColor: Colors.blue.shade500,
                  onPressed: () => _emailAndPasswordLogin(context),
                ),
                /*SocialLoginButton(
                    buttonText: "Misafir Girişi",
                    buttonIcon: Icon(Icons.supervised_user_circle),
                    buttonColor: Colors.teal,
                    onPressed: () => _guestLogin(context),
                  ),
                   */
              ],
            ),
          ),
        ),
      ),
    );
  }
}
