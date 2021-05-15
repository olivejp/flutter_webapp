import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_webapp/service/storage.service.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc {
  final StorageService storage = StorageService.getInstance();

  User _user;
  BehaviorSubject<User> _streamUser;

  Observable<User> get userObservable => _streamUser.stream;

  static LoginBloc _instance;

  // Private constructor with the ._()
  LoginBloc._() {
    _streamUser = BehaviorSubject(seedValue: null);

    // Listen for user update.
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User user) => updateUser(user));
  }

  static LoginBloc getInstance() {
    if (_instance == null) {
      _instance = LoginBloc._();
    }
    return _instance;
  }

  Future<UserCredential> recordUserCredentialToStorage(
      UserCredential userCredential) {
    return Future<UserCredential>(() {
      if (userCredential.user.uid != null) {
        storage.setItem('userId', userCredential.user.uid);
      }
      if (userCredential.user.email != null) {
        storage.setItem('userEmail', userCredential.user.email);
      }
      if (userCredential.user.displayName != null) {
        storage.setItem('userName', userCredential.user.displayName);
      }
      if (userCredential.user.photoURL != null) {
        storage.setItem('userPhotoURL', userCredential.user.photoURL);
      }
      if (userCredential.user.phoneNumber != null) {
        storage.setItem('userPhoneNumber', userCredential.user.phoneNumber);
      }
      return userCredential;
    });
  }

  void updateUser(User user) {
    _user = user;
    _streamUser.sink.add(_user);
  }

  Future<bool> isConnected() {
    Completer completer = Completer();
    completer.complete(FirebaseAuth.instance.currentUser != null);
    return completer.future;
  }

  Future<bool> disconnect() {
    Completer<bool> completer = Completer<bool>();
    FirebaseAuth.instance.signOut().then((value) {
      updateUser(null);
      completer.complete(true);
    }).catchError((error) => completer.completeError(false));
    return completer.future;
  }

  dispose() {
    _streamUser.close();
  }
}
