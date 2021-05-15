import 'dart:convert';

import 'gouv-data-parameters-wrapper.domain.dart';

class GouvDataWrapper {
  final int nhits;
  final GouvDataParametersWrapper parameters;
  final List<dynamic> records;

  GouvDataWrapper({this.nhits, this.parameters, this.records});

  factory GouvDataWrapper.fromJson(Map<String, dynamic> json) {
    return new GouvDataWrapper(
        nhits: json['nhits'],
        parameters:
            GouvDataParametersWrapper.fromJson(json['parameters']),
        records: json['records']);
  }
}
