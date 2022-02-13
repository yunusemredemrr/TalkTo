import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talkto/app/profil_page.dart';
import 'package:talkto/app/tab_items.dart';
import 'package:talkto/app/users_page.dart';
import 'package:talkto/common_widget/platform_responsive_alert_dialog.dart';
import 'package:talkto/notification_handler.dart';
import 'package:talkto/viewmodel/all_users_view_model.dart';

import '../model/user.dart';
import 'my_custom_bottom_navi.dart';
import 'my_speeches.dart';

class HomePage extends StatefulWidget {
  final Users user;

  HomePage({Key key, @required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  TabItem _currentTab = TabItem.MySpeeches;

  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.Users: GlobalKey<NavigatorState>(),
    TabItem.MySpeeches: GlobalKey<NavigatorState>(),
    TabItem.Profil: GlobalKey<NavigatorState>(),
  };

  Map<TabItem, Widget> allPages() {
    return {
      TabItem.Users: ChangeNotifierProvider(
        create: (context) => AllUserViewModel(),
        child: UsersPage(),
      ),
      TabItem.MySpeeches: MySpeechesPage(),
      TabItem.Profil: ProfilPage(),
    };
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    NotificationHandler().initializeFCMNotification(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !await navigatorKeys[_currentTab].currentState.maybePop(),
      child: MyCustomBottomNavigaiton(
        navigatorKeys: navigatorKeys,
        pageBuilder: allPages(),
        currentTab: _currentTab,
        onSelectedTab: (secilenTab) {
          if (secilenTab == _currentTab) {
            navigatorKeys[secilenTab]
                .currentState
                .popUntil((route) => route.isFirst);
          } else {
            setState(() {
              _currentTab = secilenTab;
            });
          }
        },
      ),
    );
  }
}
