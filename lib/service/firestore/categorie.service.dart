import 'package:flutter_webapp/domain/firestore/categorie.domain.dart';
import 'package:flutter_webapp/service/rest/firestore/firestore.interfaces.dart';

class CategorieService extends FirestoreDomainService<Categorie> {
  Categorie _modelInstance = Categorie();

  static CategorieService _instance;

  CategorieService._()
      : super(
            '/v1/projects/venteenligne-87d39/databases/(default)/documents/categories',
            isHttps: true,
            authority: 'firestore.googleapis.com');

  static CategorieService get getInstance => _instance ??= CategorieService._();

  @override
  Categorie getModelInstance() {
    return _modelInstance;
  }
}
