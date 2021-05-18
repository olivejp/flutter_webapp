import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webapp/bloc/my-home-page.bloc.dart';
import 'package:flutter_webapp/domain/gouv-data-record-wrapper.domain.dart';
import 'package:flutter_webapp/widget/paginated-list.widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animations/loading_animations.dart';

class MyHomePage extends StatelessWidget {
  final MyHomePageBloc bloc = MyHomePageBloc.getInstance();
  final String title;
  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController googleMapController = null;

  List<GouvDataRecordWrapper> records;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-20.6871372842, 164.78272383),
    zoom: 8.0,
  );

  MyHomePage(this.title) {
    _controller.future.then((controller) => googleMapController = controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: Row(
        children: <Widget>[
          Flexible(
            child: Column(
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: this.bloc.searchEditingController,
                          onChanged: this.bloc.onSearchChanged,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () {
                                  this.bloc.searchEditingController.clear();
                                  this.bloc.query = '';
                                  this.bloc.launchReload();
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
                PaginatedList<GouvDataRecordWrapper>(
                  (int pageNumber, int pageSize) {
                    return this
                        .bloc
                        .getListTribu(pageNumber, pageSize, bloc.query);
                  },
                  header: Text('Liste des tribus de la Province Nord'),
                  actions: [
                    IconButton(
                      tooltip: 'Rafraichir',
                      onPressed: () => bloc.launchReload(),
                      icon: Icon(Icons.refresh),
                    )
                  ],
                  reloadStream: this.bloc.streamReload,
                  availableRowPerPage: [10, 20, 30],
                  displayRow: (GouvDataRecordWrapper tribu) {
                    return DataRow(
                        onSelectChanged: (value) {
                          this.bloc.changeTribuSelected(tribu);
                          this
                              .bloc
                              .changeCameraPosition(tribu, googleMapController);
                        },
                        cells: [
                          DataCell(Text(tribu.fields.nom_tribu != null
                              ? tribu.fields.nom_tribu
                              : "")),
                          DataCell(Text(tribu.fields.nom_vernac != null
                              ? tribu.fields.nom_vernac
                              : "")),
                          DataCell(Text(tribu.fields.district != null
                              ? tribu.fields.district
                              : "")),
                          DataCell(Text(tribu.fields.commune != null
                              ? tribu.fields.commune
                              : "")),
                        ]);
                  },
                  displayColumns: [
                    DataColumn(label: Text('Nom')),
                    DataColumn(label: Text('Nom vernaculaire')),
                    DataColumn(label: Text('District')),
                    DataColumn(label: Text('Commune')),
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            child: Column(
              children: [
                Flexible(
                  child: StreamBuilder<List<GouvDataRecordWrapper>>(
                      stream: this.bloc.streamPageHasChanged,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return GoogleMap(
                            mapType: MapType.hybrid,
                            initialCameraPosition: _kGooglePlex,
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                            markers: this.bloc.getMarkers(snapshot.data),
                          );
                        } else {
                          return LoadingFlipping.square();
                        }
                      }),
                ),
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
