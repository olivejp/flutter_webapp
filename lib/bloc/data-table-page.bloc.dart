import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter_webapp/domain/gouv-data-record-wrapper.domain.dart';
import 'package:flutter_webapp/domain/gouv-data-wrapper.domain.dart';
import 'package:flutter_webapp/service/rest/tribu-pnord.service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

class DataTablePageBloc {
  final TribuProvinceNordService tribuProvinceNordService =
      TribuProvinceNordService.getInstance;

  int pageNumber = 0;

  int pageSize = 30;

  int totalNumber = 0;

  String query = '';

  String sort = '';

  Timer _debounce;

  List<GouvDataRecordWrapper> listTribus = [];

  BehaviorSubject<List<GouvDataRecordWrapper>> streamListTribus =
      BehaviorSubject(seedValue: []);

  BehaviorSubject<bool> streamIsLoading = BehaviorSubject(seedValue: false);

  BehaviorSubject<int> streamTotalNumber = BehaviorSubject(seedValue: 0);

  BehaviorSubject<GouvDataRecordWrapper> streamTribuSelected =
      BehaviorSubject(seedValue: null);

  DataTablePageBloc();

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
    this.query = query;
    this.pageNumber = 0;
    this.initList();

    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      this.launchSearch();
    });
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
      GouvDataRecordWrapper tribu, GoogleMapController controller) {
    streamTribuSelected.sink.add(tribu);
    changeCameraPosition(tribu, controller);
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
}
