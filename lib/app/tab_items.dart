import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum TabItem {Users,MySpeeches,Profil}

class TabItemData{
  final String title;
  final IconData icon;

  TabItemData(this.title, this.icon);

  static Map<TabItem,TabItemData> tumTablar = {
    TabItem.Users : TabItemData("Kullanıcılar",Icons.supervised_user_circle),
    TabItem.MySpeeches : TabItemData("Sohbetler",Icons.chat,),
    TabItem.Profil : TabItemData("Profil",Icons.person),
  };
}