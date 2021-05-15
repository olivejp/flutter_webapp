import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter_webapp/domain/firestore/categorie.domain.dart';
import 'package:flutter_webapp/domain/gouv-data-wrapper.domain.dart';
import 'package:flutter_webapp/domain/tribu-province-nord.domain.dart';
import 'package:flutter_webapp/service/firestore/categorie.service.dart';
import 'package:flutter_webapp/service/rest/tribu-pnord.service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class MyHomePageBloc {
  static MyHomePageBloc _instance;

  final CategorieService categorieService = CategorieService.getInstance;
  final TribuProvinceNordService tribuProvinceNordService =
      TribuProvinceNordService.getInstance;
  final BehaviorSubject<int> streamCount = BehaviorSubject(seedValue: 0);
  int _counter = 0;

  // Private constructor with the ._()
  MyHomePageBloc._();

  Observable<int> getCount() => streamCount.stream;

  int totalPage = 0;

  static MyHomePageBloc getInstance() {
    if (_instance == null) {
      _instance = MyHomePageBloc._();
    }
    return _instance;
  }

  Future<Tuple2<List<TribuProvinceNord>, int>> getListTribu(
      int pageNumber, int pageSize) {
    Completer<Tuple2<List<TribuProvinceNord>, int>> completer = Completer();
    Map<String, dynamic> queryParameters = new HashMap();
    queryParameters.putIfAbsent('dataset', () => 'tribus-en-province-nord');
    queryParameters.putIfAbsent('sort', () => 'nom_tribu');
    if (pageSize > 0) {
      queryParameters.putIfAbsent('rows', () => pageSize.toString());
    }
    if (pageNumber * pageSize > 0) {
      queryParameters.putIfAbsent(
          'start', () => (pageNumber * pageSize).toString());
    }
    tribuProvinceNordService
        .findAll(queryParameters: queryParameters)
        .then((tuple) {
      GouvDataWrapper wrapper =
          GouvDataWrapper.fromJson(jsonDecode(tuple.item2.body));

      this.totalPage = wrapper.nhits;

      Future.delayed(Duration(seconds: 5),
          () => completer.complete(Tuple2(tuple.item1, this.totalPage)));
      // completer.complete(Tuple2(tuple.item1, this.totalPage));
    });
    return completer.future;
  }

  incrementCounter() {
    this._counter++;
    this.streamCount.sink.add(this._counter);
  }

  Future<List<Categorie>> getCategoriePage(int pageNumber, int pageSize) {
    Completer completer = Completer<List<Categorie>>();
    if (pageNumber == 0) {
      completer.complete([
        Categorie(uid: '123', name: 'Pantalon'),
        Categorie(uid: '456', name: 'Pantalon'),
        Categorie(uid: '789', name: 'Pantalon'),
        Categorie(uid: '101', name: 'Pantalon'),
        Categorie(uid: '1112', name: 'Pantalon'),
        Categorie(uid: '13', name: 'Pantalon'),
        Categorie(uid: '14', name: 'Pantalon'),
        Categorie(uid: '15', name: 'Pantalon'),
        Categorie(uid: '416', name: 'Pantalon'),
        Categorie(uid: '456', name: 'Pantalon'),
      ]);
    }
    if (pageNumber == 1) {
      completer.complete([
        Categorie(uid: '123', name: 'Corqqsdossol'),
        Categorie(uid: '456', name: 'Corqqsdossol'),
        Categorie(uid: '456', name: 'Corqqsdossol'),
        Categorie(uid: '456', name: 'Corqqsdossol dfghdf gh dfg'),
        Categorie(uid: '456', name: 'Corqqsdossol '),
        Categorie(uid: '456', name: 'Corqqsdossol'),
        Categorie(uid: '456', name: 'Corqqsdossol'),
        Categorie(uid: '456', name: 'Corqqsdossol'),
        Categorie(uid: '456', name: 'Corqqsdossol'),
        Categorie(uid: '456', name: 'Corqqsdossol fgh fgh '),
      ]);
    }

    if (pageNumber == 2) {
      completer.complete([
        Categorie(uid: '123', name: 'kimono'),
        Categorie(uid: '456', name: 'kimono'),
        Categorie(uid: '456', name: 'kimono'),
        Categorie(uid: '456', name: 'kimono dfghdf gh dfg'),
        Categorie(uid: '456', name: 'kimono '),
        Categorie(uid: '456', name: 'kimono'),
        Categorie(uid: '456', name: 'kimono'),
        Categorie(uid: '456', name: 'kimono'),
        Categorie(uid: '456', name: 'kimono'),
        Categorie(uid: '456', name: 'kimono fgh fgh '),
      ]);
    }
    return completer.future;
  }
}
