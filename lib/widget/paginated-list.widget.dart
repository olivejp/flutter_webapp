import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class PaginatedListBloc<T> {
  BehaviorSubject<List<T>> _streamList;
  BehaviorSubject<int> _streamPageSize;
  BehaviorSubject<int> _streamPageNumber;
  BehaviorSubject<bool> _streamIsLoading;
  BehaviorSubject<Map<String, int>> _streamLaunchSearch;
  List<T> _list = [];
  int _rowCount = 0;
  int _pageSize = 0;
  int _pageNumber = 0;

  PaginatedListBloc() {
    _streamList = BehaviorSubject(seedValue: []);
    _streamPageSize = BehaviorSubject(seedValue: 0);
    _streamPageNumber = BehaviorSubject(seedValue: 0);
    _streamIsLoading = BehaviorSubject(seedValue: false);
    _streamLaunchSearch =
        BehaviorSubject(seedValue: {'pageNumber': 0, 'pageSize': 10});
  }

  Observable<bool> isLoading() {
    return _streamIsLoading;
  }

  Observable<List<T>> getListStream() {
    return _streamList;
  }

  Observable<int> getPageSizeStream() {
    return _streamPageSize;
  }

  Observable<int> getPageNumberStream() {
    return _streamPageNumber;
  }

  Observable<Map<String, int>> getLaunchSearchStream() {
    return _streamLaunchSearch;
  }

  void addPage(List<T> newPage) {
    _list.addAll(newPage);
    _streamList.sink.add(_list);
  }

  void clearListAndPageNumber() {
    // updatePageNumber(0, 0);
    // changeTotalPage(0);
    clearList();
  }

  void clearList() {
    _list = [];
    _streamList.sink.add(_list);
  }

  void changeTotalPage(int newTotalPage) {
    _rowCount = newTotalPage;
  }

  void changePageSize(int newPageSize) {
    clearList();
    _pageSize = newPageSize;
    _streamPageNumber.sink.add(0);
    _streamPageSize.sink.add(_pageSize);
    _streamLaunchSearch.sink
        .add({'pageNumber': getPageNumber(), 'pageSize': getPageSize()});
  }

  void updatePageNumber(int pageIndex, int newPageNumber) {
    _pageNumber = newPageNumber;
    _streamPageNumber.sink.add(_pageNumber);
  }

  void changePageNumber(int pageIndex, int newPageNumber) {
    updatePageNumber(pageIndex, newPageNumber);
    int size = _list.length - 1;
    if (pageIndex > size) {
      _streamLaunchSearch.sink
          .add({'pageNumber': getPageNumber(), 'pageSize': getPageSize()});
    }
  }

  List<T> getList() {
    return _list;
  }

  int getRowCount() {
    return _rowCount;
  }

  int getPageSize() {
    return _pageSize;
  }

  int getPageNumber() {
    return _pageNumber;
  }

  void setLoading(bool loading) {
    _streamIsLoading.sink.add(loading);
  }
}

class PaginatedListDataSource<T> extends DataTableSource {
  final DataRow Function(T source) displayRow;
  final PaginatedListBloc<T> bloc;
  final int countColumns;
  DataRow dataRowEmpty;
  StreamSubscription streamListSubscription;

  PaginatedListDataSource(this.displayRow, this.bloc, this.countColumns) {
    PaginatedListDataSource me = this;
    streamListSubscription = bloc.getListStream().listen((newList) {
      me.notifyListeners();
    });

    List<DataCell> dataCells = [];
    DataCell cell = DataCell.empty;
    for (int i = 0; i < countColumns; i++) {
      dataCells.add(cell);
    }
    dataRowEmpty = DataRow(cells: dataCells);
  }

  @override
  DataRow getRow(int index) {
    if (bloc.getList().isNotEmpty) {
      if (index < bloc.getList().length) {
        T element = bloc.getList().elementAt(index);
        return displayRow(element);
      } else {
        return dataRowEmpty;
      }
    } else {
      return dataRowEmpty;
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => bloc.getRowCount();

  @override
  int get selectedRowCount => 0;

  @override
  void dispose() {
    streamListSubscription.cancel();
    super.dispose();
  }
}

class PaginatedList<T> extends StatelessWidget {
  final Future<Tuple2<List<T>, int>> Function(int pageNumber, int pageSize)
      onLoad;
  final DataRow Function(T) displayRow;
  final List<DataColumn> displayColumns;
  final List<int> availableRowPerPage;
  final Observable<bool> reloadStream;
  final List<Widget> actions;
  final Widget header;
  PaginatedListDataSource source;
  PaginatedListBloc<T> bloc;

  PaginatedList(
    this.onLoad, {
    Key key,
    this.displayRow,
    this.displayColumns,
    this.availableRowPerPage,
    this.reloadStream,
    this.actions,
    this.header,
  }) : super(key: key) {
    // Bloc creation
    bloc = PaginatedListBloc();

    // Datasource creation
    source =
        PaginatedListDataSource<T>(displayRow, bloc, displayColumns.length);

    // Change page size.
    bloc.changePageSize(10);

    // Listen to change.
    bloc.getLaunchSearchStream().listen((Map<String, int> map) {
      _load(map['pageNumber'], map['pageSize']);
    });

    // Listen to reload.
    if (reloadStream != null) {
      reloadStream.listen((event) {
        if (event) {
          bloc.clearListAndPageNumber();
          _load(bloc.getPageNumber(), bloc.getPageSize());
        }
      });
    }
  }

  void _load(int pageNumber, int pageSize) {
    bloc.setLoading(true);
    onLoad(pageNumber, pageSize).then((tuple) {
      bloc.changeTotalPage(tuple.item2);
      bloc.addPage(tuple.item1);
      bloc.setLoading(false);
    }).catchError((onError) {
      bloc.setLoading(false);
      print(onError.toString());
    });
  }

  Widget build(BuildContext context) {
    return Expanded(
        child: Stack(
      fit: StackFit.expand,
      children: [
        SingleChildScrollView(
          child: StreamBuilder<int>(
              stream: bloc.getPageSizeStream(),
              builder: (context, snapshot) {
                return PaginatedDataTable(
                  header: header,
                  actions: actions,
                  columns: displayColumns,
                  source: source,
                  rowsPerPage: snapshot.hasData ? snapshot.data : 10,
                  availableRowsPerPage: availableRowPerPage,
                  onRowsPerPageChanged: (newPageSize) =>
                      bloc.changePageSize(newPageSize),
                  onPageChanged: (firstIndex) {
                    double pageNumber = firstIndex / bloc.getPageSize();
                    bloc.changePageNumber(firstIndex, pageNumber.ceil());
                  },
                );
              }),
        ),
        StreamBuilder(
          stream: bloc.isLoading(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data) {
              return Container(
                color: Colors.grey.shade100.withAlpha(200),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(child: LoadingFadingLine.square()),
                    Text('Veuillez patienter'),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        )
      ],
    ));
  }
}
