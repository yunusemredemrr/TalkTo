import 'package:cloud_firestore/cloud_firestore.dart';

class Talk {
  final String speaker;
  final String who_is_talking;
  final bool seen;
  final Timestamp creation_date;
  final String last_message_sent;
  final Timestamp seen_date;
  String konusulanUserName;
  String konusulanUserProfilURL;
  DateTime sonOkumaZamani;
  String aradakiFark;

  Talk({this.speaker, this.who_is_talking, this.seen, this.creation_date, this.last_message_sent, this.seen_date,this.konusulanUserProfilURL});

  Map<String,dynamic> toMap(){

    return {
      'konusma_sahibi' : speaker,
      'kimle_konusuyor' : who_is_talking,
      'goruldu' : seen,
      'olusturulma_tarihi' : creation_date ?? FieldValue.serverTimestamp(),
      'son_yollanan_mesaj' : last_message_sent,
      'gorulme_tarihi' :seen_date ?? FieldValue.serverTimestamp(),
    };
  }



  Talk.fromMap(Map<String, dynamic> map)
      : speaker = map["konusma_sahibi"],
        who_is_talking = map["kimle_konusuyor"],
        seen = map["goruldu"],
        creation_date = map["olusturulma_tarihi"],
        last_message_sent = map["son_yollanan_mesaj"] ,
        seen_date = map["gorulme_tarihi"] ;


  @override
  String toString() {
    return 'Talk{konusma_sahibi: $speaker, kimle_konusuyor: $who_is_talking, goruldu: $seen, olusturulma_tarihi: $creation_date, son_yollanan_mesaj: $last_message_sent, gorulme_tarihi: $seen_date}';
  }
}