import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:talkto/common_widget/platform_responsive_alert_dialog.dart';
import 'package:talkto/common_widget/social_log_in_button.dart';
import 'package:talkto/model/user.dart';
import 'package:talkto/viewmodel/user_model.dart';
import 'dart:ui';

import '../exception.dart';

enum FormType { Register, Login }

class EmailAndPasswordLoginPage extends StatefulWidget {
  @override
  _EmailAndPasswordLoginPageState createState() =>
      _EmailAndPasswordLoginPageState();
}

class _EmailAndPasswordLoginPageState extends State<EmailAndPasswordLoginPage> {
  String _email, _password;
  String _butonText, _linkText;
  var _formType = FormType.Login;
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = true;

  void _googleLogin(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    Users _user = await _userModel.signInWithGoogle();
    //if (_user != null) print("Oturum açan user id:" + _user.userID.toString());
  }

  void _formSubmit() async {
    _formKey.currentState.save();
    //debugPrint("email : $_email  sifre : $_password");
    final _userModel = Provider.of<UserModel>(context, listen: false);

    if (_formType == FormType.Login) {
      try {
        Users _loginUser =
            await _userModel.signInWithEmailAndPassword(_email, _password);
        //if (_loginUser != null) debugPrint("kullanıcı id : " + _loginUser.userID.toString());

      } on FirebaseAuthException catch (e) {
        //debugPrint("Widget oturum açma hata yakalandı : " + e.code.toString());
        PlatformResponsiveAlertDialog(
          baslik: "Oturum Açma HATA!",
          icerik: Exceptions.show(e.code),
          anaButonYazisi: "Tamam",
        ).show(context);
      }
    } else {
      try {
        Users _createdUser =
            await _userModel.createUserWithEmailAndPassword(_email, _password);
        //if (_createdUser != null) debugPrint("kullanıcı id : " + _createdUser.userID.toString());
      } on FirebaseAuthException catch (e) {
        PlatformResponsiveAlertDialog(
          baslik: "Kullanıcı oluşturma HATA!",
          icerik: Exceptions.show(e.code.toString()),
          anaButonYazisi: "Tamam",
        ).show(context);
      }
    }
  }

  void _change() {
    setState(() {
      _formType =
          _formType == FormType.Login ? FormType.Register : FormType.Login;
    });
  }

  @override
  Widget build(BuildContext context) {
    _butonText = _formType == FormType.Login ? "Giriş Yap" : "Kayıt Ol";
    _linkText = _formType == FormType.Login
        ? "Hesabınız Yok Mu? Kayıt olun"
        : "Hesabınız Var Mı? Giriş Yapın";

    final _userModel = Provider.of<UserModel>(context);

    if (_userModel.user != null) {
      Future.delayed(Duration(milliseconds: 1), () {
        Navigator.of(context).popUntil(ModalRoute.withName("/"));
      });
    }
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: _userModel.state == ViewState.Idle
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: size.height * 0.08,
                      ),
                      Text(
                        "TalkTo",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.purple.shade900),
                      ),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      Image.asset(
                        "images/message.jpg",
                        height: size.height * 0.33,
                      ),
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          errorText: _userModel.emailErrorMessage != null
                              ? _userModel.emailErrorMessage
                              : null,
                          prefixIcon: Icon(
                            Icons.mail,
                            color: Colors.purple.shade900,
                          ),
                          hintText: "Email",
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(29),
                          ),
                        ),
                        onSaved: (String enteredEmail) {
                          _email = enteredEmail;
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        obscureText: _passwordVisible,
                        decoration: InputDecoration(
                          errorText: _userModel.passwordErrorMessage != null
                              ? _userModel.passwordErrorMessage
                              : null,
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.purple.shade900,
                          ),
                          hintText: "Şifre",
                          labelText: "Şifre",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(29),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.purple.shade900,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                            iconSize: 35,
                          ),
                        ),
                        onSaved: (String enteredPassword) {
                          _password = enteredPassword;
                        },
                      ),
                      SocialLoginButton(
                        buttonText: _butonText,
                        buttonColor: Colors.purple.shade900,
                        radius: 29,
                        onPressed: () => _formSubmit(),
                      ),
                      FlatButton(
                        onPressed: () => _change(),
                        child: Text(
                          _linkText,
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      OrDivider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _googleLogin(context),
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2, color: Colors.purple.shade100),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                "images/google-logo.png",
                                height: 25,
                                width: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget OrDivider() {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.height * 0.02),
      width: size.width * 0.8,
      child: Row(
        children: [
          buildDivider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "YADA",
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          buildDivider(),
        ],
      ),
    );
  }
}

class buildDivider extends StatelessWidget {
  const buildDivider({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Divider(
        color: Colors.blue,
        height: 1.5,
      ),
    );
  }
}
