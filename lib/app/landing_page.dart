import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talkto/app/sign_in/email_pasword_login_signup.dart';
import 'package:talkto/app/sign_in/sign_in_page.dart';
import 'package:talkto/viewmodel/user_model.dart';

import 'home_page.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _userModel = Provider.of<UserModel>(context);
    if (_userModel.state == ViewState.Idle) {
      if (_userModel.user == null) {
        return SignInPage();
      } else {
        return HomePage(user: _userModel.user);
      }
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
