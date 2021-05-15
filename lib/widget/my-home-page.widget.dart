import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webapp/bloc/my-home-page.bloc.dart';
import 'package:flutter_webapp/domain/tribu-province-nord.domain.dart';
import 'package:flutter_webapp/widget/paginated-list.widget.dart';
import 'package:loading_animations/loading_animations.dart';

class MyHomePage extends StatelessWidget {
  final MyHomePageBloc bloc = MyHomePageBloc.getInstance();
  final String title;

  MyHomePage(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          PaginatedList<TribuProvinceNord>(
            availableRowPerPage: [10, 20, 30],
            onLoad: (int pageNumber, int pageSize) =>
                this.bloc.getListTribu(pageNumber, pageSize),
            displayRow: (TribuProvinceNord tribu) {
              return DataRow(cells: [
                DataCell(Text(tribu.nom_tribu != null ? tribu.nom_tribu : "")),
                DataCell(
                    Text(tribu.nom_vernac != null ? tribu.nom_vernac : "")),
                DataCell(Text(tribu.district != null ? tribu.district : "")),
                DataCell(Text(tribu.commune != null ? tribu.commune : "")),
              ]);
            },
            displayColumns: [
              DataColumn(label: Text('Nom')),
              DataColumn(label: Text('Nom vernaculaire')),
              DataColumn(label: Text('District')),
              DataColumn(label: Text('Commune')),
            ],
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: bloc.incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ),
    );
  }
}
