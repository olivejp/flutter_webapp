import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_webapp/bloc/login.bloc.dart';

class LoginPageParameter {}

class LoginPage extends StatefulWidget {
  final LoginBloc bloc = LoginBloc.getInstance();

  final String namePage;
  final void Function(UserCredential) callback;
  final List<LoginPageParameter> parameters;

  LoginPage({Key key, this.namePage, this.parameters, this.callback})
      : super(key: key);

  @override
  _LoginPageState createState() {
    return new _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  _LoginPageState();

  void signInAnonymously() async {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInAnonymously();
    if (widget.callback != null) {
      widget.callback(userCredential);
    }
  }

  void signInWithGoogle() async {
    GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithPopup(googleAuthProvider);
    if (widget.callback != null) {
      widget.callback(userCredential);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Text(widget.namePage)),
            ],
          )),
        ),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 36.0, right: 20.0, left: 20.0, bottom: 36.0),
                child: RaisedButton(
                  onPressed: signInWithGoogle,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Se connecter avec Google',
                        style: TextStyle(fontWeight: FontWeight.w200),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 0.0, right: 20.0, left: 20.0, bottom: 36.0),
                child: RaisedButton(
                  onPressed: signInAnonymously,
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Se connecter anonymement',
                        style: TextStyle(
                            fontWeight: FontWeight.w200, color: Colors.white),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
