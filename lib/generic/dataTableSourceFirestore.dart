import 'package:flutter/material.dart';
import 'package:flutter_webapp/generic/domainToDataRow.interface.dart';

class DataTableSourceFirestore<T extends DomainToDataRow>
    extends DataTableSource {
  final List<T> sourceList;
  final void Function(T) onSelectedChanged;

  DataTableSourceFirestore({this.sourceList, this.onSelectedChanged});

  @override
  DataRow getRow(int index) {
    final T _categorie = sourceList[index];
    return _categorie.toDataRow(this.onSelectedChanged);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => sourceList.length;

  @override
  int get selectedRowCount => 0;
}
