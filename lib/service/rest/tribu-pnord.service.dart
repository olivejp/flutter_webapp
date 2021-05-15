import 'dart:convert';

import 'package:flutter_webapp/domain/gouv-data-record-wrapper.domain.dart';
import 'package:flutter_webapp/domain/gouv-data-wrapper.domain.dart';
import 'package:flutter_webapp/domain/tribu-province-nord.domain.dart';
import 'package:flutter_webapp/service/rest/abstract-rest-domain.service.dart';
import 'package:http/src/response.dart';

class TribuProvinceNordService extends RestDomainService<TribuProvinceNord> {
  static TribuProvinceNordService _instance;

  TribuProvinceNordService._()
      : super('api/records/1.0/search',
            isHttps: true, authority: 'data.gouv.nc');

  static TribuProvinceNordService get getInstance => _instance ??= TribuProvinceNordService._();

  @override
  TribuProvinceNord mapResponseToDomain(Response response) {
    // TODO: implement mapResponseToDomain
    throw UnimplementedError();
  }

  @override
  List<TribuProvinceNord> mapResponseToListDomain(Response response) {
    GouvDataWrapper gouvDataWrapper =
        GouvDataWrapper.fromJson(jsonDecode(response.body));

    List<TribuProvinceNord> listTribus = [];

    gouvDataWrapper.records.forEach((element) {
      GouvDataRecordWrapper recordWrapper =
          GouvDataRecordWrapper.fromJson(element);

      TribuProvinceNord tribu =
          TribuProvinceNord.fromJson(recordWrapper.fields);
      listTribus.add(tribu);
    });

    return listTribus;
  }
}
