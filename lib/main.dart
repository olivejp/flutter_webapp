import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webapp/bloc/main.bloc.dart';
import 'package:flutter_webapp/widget/data-table-page.widget.dart';
import 'package:flutter_webapp/widget/login.page.dart';
import 'package:loading_animations/loading_animations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final MainBloc bloc = MainBloc.getInstance();
  final appTitle = 'Les tribus de la Province Nord de la Nouvelle Calédonie';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: appTitle,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: FutureBuilder(
            future: bloc.initThridParty(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  !snapshot.hasError) {
                return StreamBuilder(
                    stream: bloc.streamUser(),
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        // return MyHomePage('Tribus de la Province Nord');
                        return DataTablePage();
                      } else {
                        return LoginPage(namePage: 'Se connecter');
                      }
                    });
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                      'Erreur lors de l' 'initialisation de l' 'application.'),
                );
              }
              return LoadingBouncingGrid.circle();
            }));
  }
}
