class GouvDataParametersWrapper {
  final int rows;
  final int start;
  final String timezone;
  final String dataset;
  final List<dynamic> sort;
  final String format;

  GouvDataParametersWrapper(
      {this.rows,
      this.start,
      this.timezone,
      this.dataset,
      this.sort,
      this.format});

  factory GouvDataParametersWrapper.fromJson(Map<String, dynamic> json) {
    return new GouvDataParametersWrapper(
      rows: json['rows'],
      start: json['start'],
      timezone: json['timezone'],
      dataset: json['dataset'],
      sort: json['sort'],
      format: json['format'],
    );
  }
}
