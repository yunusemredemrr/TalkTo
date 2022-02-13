import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:talkto/common_widget/platform_responsive_alert_dialog.dart';
import 'package:talkto/common_widget/social_log_in_button.dart';
import 'package:talkto/viewmodel/user_model.dart';

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  TextEditingController _controlerUserName;
  File _profilPhoto;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controlerUserName = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controlerUserName.dispose();
    super.dispose();
  }

  void _takePhotoFromCamera() async {
    var newPhoto = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _profilPhoto = newPhoto;
      Navigator.of(context).pop();
    });
  }

  void _chosePhotoFromGallery() async {
    var newPhoto = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _profilPhoto = newPhoto;
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    UserModel _userModel = Provider.of<UserModel>(context);
    _controlerUserName.text = _userModel.user.userName;

    //print("Profil sayfasındaki değerleri" + _userModel.user.toString());

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Text("Profil"),
        ),
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () => _cikisIcinOnayIste(context),
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
              size: 30,
            ),
            label: Text(""),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 160,
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  leading: Icon(Icons.camera),
                                  title: Text("Kameradan Çek"),
                                  onTap: () {
                                    _takePhotoFromCamera();
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.image),
                                  title: Text("Galeriden Seç"),
                                  onTap: () {
                                    _chosePhotoFromGallery();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      radius: 75,
                      backgroundImage: _profilPhoto == null &&
                              _userModel.user.profilURL == "images/unknown.jpg"
                          ? ExactAssetImage(_userModel.user.profilURL)
                          : _profilPhoto == null &&
                                  _userModel.user.profilURL !=
                                      "images/unknown.jpg"
                              ? NetworkImage(_userModel.user.profilURL)
                              : FileImage(_profilPhoto),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: _userModel.user.email,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _controlerUserName,
                    readOnly: false,
                    decoration: InputDecoration(
                      labelText: "Kullanıcı Adınız",
                      hintText: "Kullanıcı Adı",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SocialLoginButton(
                    buttonText: "Değişiklikleri Kaydet",
                    buttonColor: Colors.blueAccent,
                    onPressed: () {
                      _usernameUpdate(context);
                      _profilPhotoUpdate(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _cikisYap(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    bool result = await _userModel.signOut(_userModel.user.userID);
    return result;
  }

  Future _cikisIcinOnayIste(BuildContext context) async {
    final _result = await PlatformResponsiveAlertDialog(
      baslik: "Emin Misiniz?",
      icerik: "Çıkmak istediğinizden Emin Misiniz?",
      anaButonYazisi: "Evet",
      iptalButonYazisi: "Vazgeç",
    ).show(context);
    if (_result == true) {
      _cikisYap(context);
    }
  }

  void _usernameUpdate(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    if (_userModel.user.userName != _controlerUserName.text) {
      var updateResult = await _userModel.updateUserName(
          _userModel.user.userID, _controlerUserName.text);

      if (updateResult == true) {
        PlatformResponsiveAlertDialog(
          baslik: "Başarılı",
          icerik: "Kullanıcı adınız değiştirildi",
          anaButonYazisi: "Tamam",
        ).show(context);
      } else {
        _controlerUserName.text = _userModel.user.userName;
        PlatformResponsiveAlertDialog(
          baslik: "Hata",
          icerik:
              "Kullanıcı adı zaten kullanılıyor. Farklı bir kullanıcı adı deneyiniz!",
          anaButonYazisi: "Tamam",
        ).show(context);
      }
    }
  }

  void _profilPhotoUpdate(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    if (_profilPhoto != null) {
      var url = await _userModel.uploadFile(
          _userModel.user.userID, "profil_foto", _profilPhoto);
      if (url != null) {
        PlatformResponsiveAlertDialog(
          baslik: "Başarılı",
          icerik: "Profil fotoğrafınız güncellendi",
          anaButonYazisi: "Tamam",
        ).show(context);
      }
    }
  }
}
