import 'package:talkto/model/message.dart';
import 'package:talkto/model/user.dart';
import 'package:http/http.dart' as http;

class NotificationSendingService {
  Future<bool> notificationSend(
      Message notificationToBeSend, Users oppositeUser, String token) async {
    String endURL = "https://fcm.googleapis.com/fcm/send";
    String firebaseKey =
        "AAAAI0Z9NPQ:APA91bH1IZz8R-h-LGirkijqvn2NNMjhm4LMx10kZ2PZjaxe2YIyICt3dgvZDEpttEiTA5R4DiIPqJnBcORF67_qFw6unE46Gi-8LhjnooQKjVt1VNWwpofpuC5KLRUKIs57inhpixHV";
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "key=$firebaseKey",
    };

    String json =
        '{ '
          '"to" : "$token",'
          '"data" : '
          '{ '
            '"message" : "${notificationToBeSend.message}" , '
            '"title" : "${oppositeUser.userName}", '
            '"profilURL": "${oppositeUser.profilURL}",'
            '"oppositeUserID": "${oppositeUser.userID}"'
          '}'
        '}';

    http.Response response =
        await http.post(endURL, headers: headers, body: json);

    if (response.statusCode == 200) {
      //print("İşlem başarılı");
    } else {
      //print("İşlem başarısız");
    }
  }
}
