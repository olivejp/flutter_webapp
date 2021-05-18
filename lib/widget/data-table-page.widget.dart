import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webapp/bloc/data-table-page.bloc.dart';
import 'package:flutter_webapp/domain/gouv-data-record-wrapper.domain.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animations/loading_animations.dart';

class DataTablePage extends StatelessWidget {
  final DataTablePageBloc bloc = DataTablePageBloc();
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchEditingController = TextEditingController();
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController googleMapController;

  static final CameraPosition _kProvinceNord = CameraPosition(
    target: LatLng(-20.6871372842, 164.78272383),
    zoom: 8.0,
  );

  DataTablePage() {
    this.bloc.launchSearch();

    // Listen to scroll events. Launch a new search when reaching the bottom of the list.
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        this.bloc.incrementPageNumber();
        this.bloc.launchSearch();
      }
    });

    _controller.future.then((controller) => googleMapController = controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text('Liste des tribus de Province Nord')),
            Flexible(child: Icon(Icons.refresh)),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StreamBuilder(
                    stream: bloc.streamIsLoading,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data) {
                        return LoadingBouncingGrid.circle(
                          size: 25.0,
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StreamBuilder(
                      stream: bloc.streamTotalNumber,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text("Nombre d'élément ${snapshot.data}");
                        } else {
                          return Container();
                        }
                      }),
                ),
              ],
            )),
      ),
      body: Row(
        children: [
          Flexible(
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: this.searchEditingController,
                          onChanged: this.bloc.changeQuery,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  this.searchEditingController.clear();
                                  this.bloc.changeQuery('');
                                },
                                icon: Icon(Icons.clear),
                              ),
                              border: UnderlineInputBorder(),
                              hintText: 'Rechercher une tribu'),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Stack(fit: StackFit.expand, children: [
                    SingleChildScrollView(
                      controller: scrollController,
                      child: StreamBuilder<List<GouvDataRecordWrapper>>(
                          stream: bloc.streamListTribus,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return DataTable(
                                  showCheckboxColumn: false,
                                  columns: [
                                    DataColumn(
                                      label: Text('Nom'),
                                      onSort: (columnIndex, ascending) {
                                        bloc.changeSort('nom_tribu');
                                      },
                                    ),
                                    DataColumn(
                                      label: Text('Nom vernaculaire'),
                                      onSort: (columnIndex, ascending) {
                                        bloc.changeSort('nom_vernac');
                                      },
                                    ),
                                    DataColumn(
                                      label: Text('District'),
                                    ),
                                    DataColumn(
                                      label: Text('Commune'),
                                      onSort: (columnIndex, ascending) {
                                        bloc.changeSort('commune');
                                      },
                                    ),
                                  ],
                                  rows: snapshot.data.map((tribu) {
                                    return DataRow(
                                        onSelectChanged: (b) =>
                                            bloc.changeTribuSelected(
                                                tribu, googleMapController),
                                        cells: [
                                          DataCell(Text(
                                              tribu.fields.nom_tribu != null
                                                  ? tribu.fields.nom_tribu
                                                  : "")),
                                          DataCell(Text(
                                              tribu.fields.nom_vernac != null
                                                  ? tribu.fields.nom_vernac
                                                  : "")),
                                          DataCell(Text(
                                              tribu.fields.district != null
                                                  ? tribu.fields.district
                                                  : "")),
                                          DataCell(Text(
                                              tribu.fields.commune != null
                                                  ? tribu.fields.commune
                                                  : "")),
                                        ]);
                                  }).toList());
                            } else {
                              return Text('Aucune données à afficher.');
                            }
                          }),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          Flexible(
            child: Column(
              children: [
                Flexible(
                    child: GoogleMap(
                  mapType: MapType.hybrid,
                  initialCameraPosition: _kProvinceNord,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                )),
                Flexible(
                    child: StreamBuilder<GouvDataRecordWrapper>(
                        stream: bloc.streamTribuSelected,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            GouvDataRecordWrapper tribu = snapshot.data;
                            return Column(
                              children: [
                                Text(tribu.fields.nom),
                                Text(tribu.fields.nom_vernac),
                                Text(tribu.fields.district),
                                Text(tribu.fields.code_commu.toString()),
                              ],
                            );
                          } else {
                            return Text('Aucune tribu sélectionnée.');
                          }
                        }))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
