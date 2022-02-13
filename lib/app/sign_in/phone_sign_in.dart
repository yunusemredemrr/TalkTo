import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:talkto/common_widget/platform_responsive_alert_dialog.dart';
import 'package:talkto/common_widget/social_log_in_button.dart';
import 'package:talkto/model/user.dart';
import 'package:talkto/viewmodel/user_model.dart';

import '../exception.dart';

enum FormType { Register, Login }

class PhoneNumberSiginPage extends StatefulWidget {
  @override
  _PhoneNumberSiginPageState createState() =>
      _PhoneNumberSiginPageState();
}

class _PhoneNumberSiginPageState extends State<PhoneNumberSiginPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String _butonText = "Giriş yap";
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
     body: Column(
       mainAxisAlignment: MainAxisAlignment.center,
       crossAxisAlignment: CrossAxisAlignment.center,
       children: <Widget>[
         SizedBox(
           height: size.height * 0.08,
         ),
         Text(
           "Mesajlaşma Hoşgeldiniz",
           style: TextStyle(
               fontWeight: FontWeight.bold,
               fontSize: 20,
               color: Colors.purple.shade900),
         ),
         SizedBox(
           height: size.height * 0.02,
         ),
         Padding(
           padding: const EdgeInsets.all(8.0),
           child: Image.asset(
             "images/message.jpg",
             height: size.height * 0.25,
           ),
         ),
         SizedBox(
           height: 5,
         ),
         SizedBox(
           height: 10,
         ),
         SocialLoginButton(
           buttonText: _butonText,
           buttonColor: Colors.purple.shade900,
           radius: 29,
           onPressed: () => _phoneNoLogin(),
         ),
       ],
     ),
   );
  }

  _phoneNoLogin() async{
    await _auth.verifyPhoneNumber(
      phoneNumber: '+90 546 876 8612',
      verificationCompleted: (PhoneAuthCredential credential) async{
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int resendToken) async{
        try{
          String smsCode = '123456';

          // Create a PhoneAuthCredential with the code
          PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);

          // Sign the user in (or link) with the credential
          await _auth.signInWithCredential(phoneAuthCredential);
        }catch(e){
          
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

}