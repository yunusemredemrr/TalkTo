import 'package:get_it/get_it.dart';
import 'package:talkto/repository/user_repository.dart';
import 'package:talkto/services/fake_auth_service.dart';
import 'package:talkto/services/firebase_auth_service.dart';
import 'package:talkto/services/firebase_storage_service.dart';
import 'package:talkto/services/firestore_db_service.dart';
import 'package:talkto/services/notification_sending_service.dart';

GetIt locator = GetIt.instance;

void setupLocator(){
 locator.registerLazySingleton(() => FirebaseAuthService());
 locator.registerLazySingleton(() => FakeAuthenticationService());
 locator.registerLazySingleton(() => FirestoreDBService());
 locator.registerLazySingleton(() => FirebaseStorageService());
 locator.registerLazySingleton(() => UserRepository());
 locator.registerLazySingleton(() => NotificationSendingService());
}