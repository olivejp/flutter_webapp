
import 'package:flutter_webapp/service/rest/firestore/firestore.interfaces.dart';
import 'package:flutter_webapp/service/rest/firestore/firestore.utils.dart';

class Categorie implements FirestoreSerializable<Categorie> {
  final String uid;
  final String name;
  final String uidParent;
  final bool transiant;

  Categorie({this.uid, this.name, this.uidParent, this.transiant});

  @override
  Categorie fromFirestoreJson(Map<String, dynamic> json) {
    return new Categorie(
        uid: FirestoreFieldConverter.convert(
            'uid', json, FirestoreEnumType.STRING),
        uidParent: FirestoreFieldConverter.convert(
            'uidParent', json, FirestoreEnumType.STRING),
        name: FirestoreFieldConverter.convert(
            'name', json, FirestoreEnumType.STRING),
        transiant: FirestoreFieldConverter.convert(
            'transiant', json, FirestoreEnumType.BOOLEAN));
  }
}
