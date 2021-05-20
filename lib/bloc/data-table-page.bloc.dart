import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter_webapp/domain/gouv-data-record-wrapper.domain.dart';
import 'package:flutter_webapp/domain/gouv-data-wrapper.domain.dart';
import 'package:flutter_webapp/service/rest/tribu-pnord.service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class DataTablePageBloc {

  static DataTablePageBloc _instance;

  final TribuProvinceNordService tribuProvinceNordService =
      TribuProvinceNordService.getInstance;

  GoogleMapController googleMapController;

  int pageNumber = 0;

  int pageSize = 30;

  int totalNumber = 0;

  String query = '';

  String sort = '';

  List<GouvDataRecordWrapper> listTribus = [];

  BehaviorSubject<List<GouvDataRecordWrapper>> streamListTribus =
      BehaviorSubject(seedValue: []);

  BehaviorSubject<bool> streamIsLoading = BehaviorSubject(seedValue: false);

  BehaviorSubject<int> streamTotalNumber = BehaviorSubject(seedValue: 0);

  BehaviorSubject<String> streamQuery = BehaviorSubject(seedValue: "");

  BehaviorSubject<GouvDataRecordWrapper> streamTribuSelected =
      BehaviorSubject(seedValue: null);

  DataTablePageBloc._() {
    streamQuery.debounce(Duration(milliseconds: 500)).listen((query) {
      this.query = query;
      this.pageNumber = 0;
      this.initList();
      this.launchSearch();
    });
  }

  static DataTablePageBloc getInstance() {
    if (_instance == null) {
      _instance = DataTablePageBloc._();
    }
    return _instance;
  }

  setMapController(GoogleMapController controller) {
    this.googleMapController = controller;
  }

  void launchSearch() {
    Map<String, dynamic> queryParameters = new HashMap();
    queryParameters.putIfAbsent('dataset', () => 'tribus-en-province-nord');

    String sortingField;
    if (sort != null && sort.isNotEmpty) {
      sortingField = sort;
    } else {
      sortingField = 'nom_tribu';
    }
    queryParameters.putIfAbsent('sort', () => sortingField);

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

    this.isLoading(true);

    tribuProvinceNordService
        .findAll(queryParameters: queryParameters)
        .then((tuple) {
      this.listTribus.addAll(tuple.item1);
      streamListTribus.sink.add(this.listTribus);

      GouvDataWrapper wrapper =
          GouvDataWrapper.fromJson(jsonDecode(tuple.item2.body));
      streamTotalNumber.sink.add(wrapper.nhits);

      this.isLoading(false);
    }).onError((error, stackTrace) {
      this.isLoading(false);
    });
  }

  void isLoading(bool isLoading) {
    streamIsLoading.sink.add(isLoading);
  }

  void incrementPageNumber() {
    this.pageNumber++;
  }

  void changePageSize(int pageSize) {
    this.pageSize = pageSize;
  }

  void changeQuery(String query) {
    this.streamQuery.sink.add(query);
  }

  void initList() {
    this.listTribus = [];
    streamListTribus.sink.add(this.listTribus);
  }

  void changeSort(String sort) {
    if (this.sort == sort) {
      if (this.sort.startsWith('-')) {
        this.sort = sort;
      } else {
        this.sort = '-' + sort;
      }
    } else {
      this.sort = sort;
    }
    this.pageNumber = 0;
    this.initList();
    this.launchSearch();
  }

  void changeTribuSelected(
      GouvDataRecordWrapper tribu) {
    streamTribuSelected.sink.add(tribu);
    if (this.googleMapController != null) {
      changeCameraPosition(tribu);
    }
  }

  bool changeCameraPosition(
      GouvDataRecordWrapper tribu) {
    if (googleMapController != null) {
      CameraPosition position = CameraPosition(
        target: LatLng(
            tribu.geometry.coordinates[1], tribu.geometry.coordinates[0]),
        zoom: 14.4746,
      );
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(position));
      return true;
    }
    return false;
  }
}
