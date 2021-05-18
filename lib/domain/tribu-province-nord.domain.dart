class TribuProvinceNord {
  final int objectid;
  final String point;
  final String photo;
  final double distance_parcourue_depuis_lhotel_de_la_province_nord_en_km;
  final String lieu;
  final String clas_temp;
  final String transport;
  final String fichier;
  final String district;
  final String equipement;
  final String source;
  final double c_postal;
  final double t_mairie_m;
  final String nom;
  final double d_mairie_k;
  final String commune;
  final String nom_maj;
  final double code_commu;
  final String t_hpn_trib;
  final String goudron;
  final String nom_tribu;
  final String classes_sig;
  final String nom_vernac;

  TribuProvinceNord(
      {this.objectid,
      this.point,
      this.photo,
      this.distance_parcourue_depuis_lhotel_de_la_province_nord_en_km,
      this.lieu,
      this.clas_temp,
      this.transport,
      this.fichier,
      this.district,
      this.equipement,
      this.source,
      this.c_postal,
      this.t_mairie_m,
      this.nom,
      this.d_mairie_k,
      this.commune,
      this.nom_maj,
      this.code_commu,
      this.t_hpn_trib,
      this.goudron,
      this.nom_tribu,
      this.classes_sig,
      this.nom_vernac});

  factory TribuProvinceNord.fromJson(Map<String, dynamic> json) {
    TribuProvinceNord tribu = new TribuProvinceNord(
      objectid: json['objectid'],
      point: json['point'],
      photo: json['photo'],
      distance_parcourue_depuis_lhotel_de_la_province_nord_en_km:
          json['distance_parcourue_depuis_lhotel_de_la_province_nord_en_km'],
      lieu: json['lieu'],
      clas_temp: json['clas_temp'],
      transport: json['transport'],
      fichier: json['fichier'],
      district: json['district'],
      equipement: json['equipement'],
      source: json['source'],
      c_postal: json['c_postal'],
      t_mairie_m: json['t_mairie_m'],
      nom: json['nom'],
      d_mairie_k: json['d_mairie_k'],
      commune: json['commune'],
      nom_maj: json['nom_maj'],
      code_commu: json['code_commu'],
      t_hpn_trib: json['t_hpn_trib'],
      goudron: json['goudron'],
      nom_tribu: json['nom_tribu'],
      classes_sig: json['classes_sig'],
      nom_vernac: json['nom_vernac'],
    );
    return tribu;
  }
}
