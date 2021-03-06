import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_webapp/service/auth.service.dart';
import 'package:flutter_webapp/service/storage.service.dart';
import 'package:rxdart/rxdart.dart';

class MainBloc {
  static MainBloc _instance;

  final StorageService storageService = StorageService.getInstance();
  final AuthService userService = AuthService.getInstance();

  // Private constructor with the ._()
  MainBloc._();

  static MainBloc getInstance() {
    if (_instance == null) {
      _instance = MainBloc._();
    }
    return _instance;
  }

  // Future builder wich initiate the Firebase framework.
  Future<dynamic> initThridParty() {
    return Firebase.initializeApp()
        .then((value) => storageService.initStorage().catchError((error) =>
            print('Erreur lors de l' 'initialisation du Storage : ' +
                error.toString())))
        .catchError((error) => print(
            'Erreur lors de l' 'initialisation de Firebase : ' +
                error.toString()));
  }

  Future<dynamic> isConnected() {
    return userService.isConnected();
  }

  Observable<User> streamUser() {
    return userService.userObservable;
  }
}
