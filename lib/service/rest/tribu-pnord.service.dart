import 'dart:convert';

import 'package:flutter_webapp/domain/gouv-data-record-wrapper.domain.dart';
import 'package:flutter_webapp/domain/gouv-data-wrapper.domain.dart';
import 'package:flutter_webapp/service/rest/abstract-rest-domain.service.dart';
import 'package:http/src/response.dart';

class TribuProvinceNordService
    extends RestDomainService<GouvDataRecordWrapper> {
  static TribuProvinceNordService _instance;

  TribuProvinceNordService._()
      : super('api/records/1.0/search',
            isHttps: true, authority: 'data.gouv.nc');

  static TribuProvinceNordService get getInstance =>
      _instance ??= TribuProvinceNordService._();

  @override
  GouvDataRecordWrapper mapResponseToDomain(Response response) {
    // TODO: implement mapResponseToDomain
    throw UnimplementedError();
  }

  @override
  List<GouvDataRecordWrapper> mapResponseToListDomain(Response response) {
    GouvDataWrapper gouvDataWrapper =
        GouvDataWrapper.fromJson(jsonDecode(response.body));

    List<GouvDataRecordWrapper> listTribus = [];

    gouvDataWrapper.records.forEach((element) {
      GouvDataRecordWrapper recordWrapper =
          GouvDataRecordWrapper.fromJson(element);

      listTribus.add(recordWrapper);
    });

    return listTribus;
  }
}
