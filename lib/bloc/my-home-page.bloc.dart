import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webapp/domain/gouv-data-record-wrapper.domain.dart';
import 'package:flutter_webapp/domain/gouv-data-wrapper.domain.dart';
import 'package:flutter_webapp/service/rest/tribu-pnord.service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class MyHomePageBloc {
  static MyHomePageBloc _instance;

  final TribuProvinceNordService tribuProvinceNordService =
      TribuProvinceNordService.getInstance;

  final BehaviorSubject<int> streamCount = BehaviorSubject(seedValue: 0);
  final BehaviorSubject<bool> streamReload = BehaviorSubject(seedValue: false);
  final BehaviorSubject<GouvDataRecordWrapper> streamTribuSelected =
      BehaviorSubject(seedValue: null);
  final BehaviorSubject<List<GouvDataRecordWrapper>> streamPageHasChanged =
      BehaviorSubject(seedValue: []);
  int _counter = 0;
  String query;
  Timer _debounce;
  TextEditingController searchEditingController = TextEditingController();

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

  onSearchChanged(String query) {
    this.query = query;
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      this.launchReload();
    });
  }

  launchReload() {
    this.streamReload.sink.add(true);
  }
  Future<Tuple2<List<GouvDataRecordWrapper>, int>> getListTribu(
      int pageNumber, int pageSize, String query) {
    Completer<Tuple2<List<GouvDataRecordWrapper>, int>> completer = Completer();
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
    if (query != null && query.isNotEmpty) {
      queryParameters.putIfAbsent('q', () => query);
    }
    tribuProvinceNordService
        .findAll(queryParameters: queryParameters)
        .then((tuple) {
      GouvDataWrapper wrapper =
          GouvDataWrapper.fromJson(jsonDecode(tuple.item2.body));

      this.totalPage = wrapper.nhits;

      completer.complete(Tuple2(tuple.item1, this.totalPage));

      streamPageHasChanged.sink.add(tuple.item1);
    });
    return completer.future;
  }

  incrementCounter() {
    this._counter++;
    this.streamCount.sink.add(this._counter);
  }

  bool changeTribuSelected(GouvDataRecordWrapper tribu) {
    streamTribuSelected.sink.add(tribu);
  }

  bool changeCameraPosition(
      GouvDataRecordWrapper tribu, GoogleMapController controller) {
    if (controller != null) {
      CameraPosition position = CameraPosition(
        target: LatLng(
            tribu.geometry.coordinates[1], tribu.geometry.coordinates[0]),
        zoom: 14.4746,
      );
      controller.animateCamera(CameraUpdate.newCameraPosition(position));
      return true;
    }
    return false;
  }

  Set<Marker> getMarkers(List<GouvDataRecordWrapper> data) {
    return data.map((e) {
      return Marker(
          markerId: MarkerId(e.recordid),
          position:
              LatLng(e.geometry.coordinates[1], e.geometry.coordinates[0]),
          infoWindow: InfoWindow(title: e.fields.nom_tribu));
    }).toSet();
  }
}
