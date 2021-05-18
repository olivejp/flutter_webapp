import 'package:flutter_webapp/domain/tribu-province-nord.domain.dart';

class Geometry {
  final List<dynamic> coordinates;
  final String type;

  Geometry({this.coordinates, this.type});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return new Geometry(coordinates: json['coordinates'], type: json['type']);
  }
}

class GouvDataRecordWrapper {
  final String datasetid;
  final String recordid;
  final TribuProvinceNord fields;
  final String record_timestamp;
  final Geometry geometry;

  GouvDataRecordWrapper(
      {this.datasetid,
      this.recordid,
      this.fields,
      this.record_timestamp,
      this.geometry});

  factory GouvDataRecordWrapper.fromJson(Map<String, dynamic> json) {
    return new GouvDataRecordWrapper(
        datasetid: json['datasetid'],
        recordid: json['recordid'],
        fields: TribuProvinceNord.fromJson(json['fields']),
        record_timestamp: json['record_timestamp'],
        geometry: Geometry.fromJson(json['geometry']));
  }
}
