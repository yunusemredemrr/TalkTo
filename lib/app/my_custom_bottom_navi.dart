import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:talkto/app/tab_items.dart';

class MyCustomBottomNavigaiton extends StatelessWidget {
  const MyCustomBottomNavigaiton(
      {Key key,
      @required this.currentTab,
      @required this.onSelectedTab,
      @required this.pageBuilder,
      @required this.navigatorKeys})
      : super(key: key);

  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectedTab;
  final Map<TabItem, Widget> pageBuilder;
  final Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys;

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          _navItemOlustur(TabItem.Users),
          _navItemOlustur(TabItem.MySpeeches),
          _navItemOlustur(TabItem.Profil),
        ],
        backgroundColor: Colors.grey.shade200,
        activeColor: Colors.blue.shade700,
        inactiveColor: Colors.blueGrey,
        onTap: (index) => onSelectedTab(TabItem.values[index]),
        currentIndex: 1,
      ),
      tabBuilder: (context, index) {
        final gosterilecekItem = TabItem.values[index];
        return CupertinoTabView(
          navigatorKey: navigatorKeys[gosterilecekItem],
          builder: (context) {
            return pageBuilder[gosterilecekItem];
          },
        );
      },
    );
  }

  BottomNavigationBarItem _navItemOlustur(TabItem tabItem) {
    final olusturulacakTab = TabItemData.tumTablar[tabItem];

    return BottomNavigationBarItem(
      icon: Icon(olusturulacakTab.icon),
      label: olusturulacakTab.title,
    );
  }
}
