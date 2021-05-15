import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class PaginatedListBloc<T> {
  BehaviorSubject<List<T>> _streamList;
  BehaviorSubject<int> _streamTotalPage;
  BehaviorSubject<int> _streamPageSize;
  BehaviorSubject<int> _streamPageNumber;
  BehaviorSubject<bool> _streamIsLoading;
  BehaviorSubject<Map<String, int>> _streamLaunchSearch;
  List<T> _list = [];
  int _totalPage = 0;
  int _pageSize = 0;
  int _pageNumber = 0;

  PaginatedListBloc() {
    this._streamList = BehaviorSubject(seedValue: []);
    this._streamTotalPage = BehaviorSubject(seedValue: 0);
    this._streamPageSize = BehaviorSubject(seedValue: 0);
    this._streamPageNumber = BehaviorSubject(seedValue: 0);
    this._streamIsLoading = BehaviorSubject(seedValue: false);
    this._streamLaunchSearch =
        BehaviorSubject(seedValue: {'pageNumber': 0, 'pageSize': 10});
  }

  Observable<bool> isLoading() {
    return this._streamIsLoading;
  }

  Observable<List<T>> getListStream() {
    return this._streamList;
  }

  Observable<int> getTotalPageStream() {
    return this._streamTotalPage;
  }

  Observable<int> getPageSizeStream() {
    return this._streamPageSize;
  }

  Observable<int> getPageNumberStream() {
    return this._streamPageNumber;
  }

  Observable<Map<String, int>> getLaunchSearchStream() {
    return this._streamLaunchSearch;
  }

  void addPage(List<T> newPage) {
    this._list.addAll(newPage);
    this._streamList.sink.add(this._list);
  }

  void clearList() {
    this._list = [];
    this._streamList.sink.add(this._list);
  }

  void changeTotalPage(int newTotalPage) {
    this._totalPage = newTotalPage;
    this._streamTotalPage.sink.add(this._totalPage);
  }

  void changePageSize(int newPageSize) {
    this.clearList();
    this._pageSize = newPageSize;
    this._streamPageNumber.sink.add(0);
    this._streamPageSize.sink.add(this._pageSize);
    this._streamLaunchSearch.sink.add(
        {'pageNumber': this.getPageNumber(), 'pageSize': this.getPageSize()});
  }

  void changePageNumber(int pageIndex, int newPageNumber) {
    this._pageNumber = newPageNumber;
    this._streamPageNumber.sink.add(this._pageNumber);
    int size = this._list.length - 1;
    if (pageIndex > size) {
      this._streamLaunchSearch.sink.add(
          {'pageNumber': this.getPageNumber(), 'pageSize': this.getPageSize()});
    }
  }

  List<T> getList() {
    return this._list;
  }

  int getTotalPage() {
    return this._totalPage;
  }

  int getPageSize() {
    return this._pageSize;
  }

  int getPageNumber() {
    return this._pageNumber;
  }

  void setLoading(bool loading) {
    this._streamIsLoading.sink.add(loading);
  }
}

class PaginatedListDataSource<T> extends DataTableSource {
  final DataRow Function(T source) displayRow;
  final PaginatedListBloc<T> bloc;
  final int countColumns;
  final TickerProvider vsync;
  DataRow dataRowEmpty;
  StreamSubscription streamListSubscription;
  AnimationController _controller;
  Animation<Color> animationOne;
  Animation<Color> animationTwo;

  PaginatedListDataSource(
      this.displayRow, this.bloc, this.countColumns, this.vsync) {
    streamListSubscription =
        this.bloc.getListStream().listen((newList) => this.notifyListeners());

    _controller =
        AnimationController(vsync: this.vsync, duration: Duration(milliseconds: 500));

    this.refreshAnimationColor();

    _controller.forward();

    _controller.addListener(() {
      if (_controller.status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (_controller.status == AnimationStatus.dismissed) {
        _controller.forward();
      }
      this.refreshAnimationColor();
    });

    List<DataCell> dataCells = [];

    DataCell cell = DataCell(ShaderMask(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 10,
              color: Colors.white,
            ),
          ],
        ),
      ),
      shaderCallback: (rect) {
        return LinearGradient(
                tileMode: TileMode.mirror,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [animationOne.value, animationTwo.value])
            .createShader(rect);
      },
    ));

    for (int i = 0; i < this.countColumns; i++) {
      dataCells.add(cell);
    }
    dataRowEmpty = DataRow(cells: dataCells);
  }

  void refreshAnimationColor() {
    animationOne = ColorTween(begin: Colors.green, end: Colors.blue)
        .animate(_controller);

    animationTwo = ColorTween(begin: Colors.blue, end: Colors.green)
        .animate(_controller);
  }

  @override
  DataRow getRow(int index) {
    if (this.bloc.getList().isNotEmpty) {
      if (index < this.bloc.getList().length) {
        T element = this.bloc.getList().elementAt(index);
        return this.displayRow(element);
      } else {
        return this.dataRowEmpty;
      }
    } else {
      return this.dataRowEmpty;
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => this.bloc.getTotalPage();

  @override
  int get selectedRowCount => 0;

  @override
  void dispose() {
    this.streamListSubscription.cancel();
    super.dispose();
  }
}

class PaginatedList<T> extends StatefulWidget {
  final Future<Tuple2<List<T>, int>> Function(int pageNumber, int pageSize)
      onLoad;
  final DataRow Function(T) displayRow;
  final List<DataColumn> displayColumns;
  final List<int> availableRowPerPage;
  PaginatedListDataSource source;
  PaginatedListBloc<T> bloc;

  PaginatedList({
    Key key,
    this.onLoad,
    this.displayRow,
    this.displayColumns,
    this.availableRowPerPage,
  }) : super(key: key) {}

  void _load(int pageNumber, int pageSize) {
    this.bloc.setLoading(true);

    // First load, with initial values
    this.onLoad(pageNumber, pageSize).then((tuple) {
      this.bloc.changeTotalPage(tuple.item2);
      this.bloc.addPage(tuple.item1);
      this.bloc.setLoading(false);
    }).catchError((onError) {
      this.bloc.setLoading(false);
      print(onError.toString());
    });
  }

  @override
  State<StatefulWidget> createState() {
    _PaginatedListState state = _PaginatedListState();

    // Bloc creation
    this.bloc = PaginatedListBloc();

    // Datasource creation
    this.source = PaginatedListDataSource<T>(
        this.displayRow, this.bloc, this.displayColumns.length, state);

    // Change page size.
    this.bloc.changePageSize(10);

    // Listen to change.
    this.bloc.getLaunchSearchStream().listen((Map<String, int> map) {
      this._load(map['pageNumber'], map['pageSize']);
    });
    return state;
  }
}

class _PaginatedListState extends State<PaginatedList>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SingleChildScrollView(
      child: StreamBuilder<int>(
          stream: this.widget.bloc.getPageSizeStream(),
          builder: (context, snapshot) {
            return PaginatedDataTable(
              columns: this.widget.displayColumns,
              source: this.widget.source,
              rowsPerPage: snapshot.hasData ? snapshot.data : 10,
              availableRowsPerPage: this.widget.availableRowPerPage,
              onRowsPerPageChanged: (newPageSize) =>
                  this.widget.bloc.changePageSize(newPageSize),
              onPageChanged: (firstIndex) {
                double pageNumber = firstIndex / this.widget.bloc.getPageSize();
                this
                    .widget
                    .bloc
                    .changePageNumber(firstIndex, pageNumber.ceil());
              },
            );
          }),
    ));
  }
}
