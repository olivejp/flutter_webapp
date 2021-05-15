class GouvDataRecordWrapper {
  final String datasetid;
  final String recordid;
  final dynamic fields;
  final String record_timestamp;

  GouvDataRecordWrapper(
      {this.datasetid, this.recordid, this.fields, this.record_timestamp});

  factory GouvDataRecordWrapper.fromJson(Map<String, dynamic> json) {
    return new GouvDataRecordWrapper(
        datasetid: json['datasetid'],
        recordid: json['recordid'],
        fields: json['fields'],
        record_timestamp: json['record_timestamp']);
  }
}
