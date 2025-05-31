class Local {
  final int id;
  final String nome;
  final String sigla;
  final String rotulos;
  final String rotulos2;
  final double lat;
  final double longi;

  Local ({
    required this.id,
    required this.nome,
    required this.sigla,
    required this.rotulos,
    required this.rotulos2,
    required this.lat,
    required this.longi,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'lat': lat,
      'longi': longi,
      'rotulos': rotulos,
      'rotulos2': rotulos2,
      'sigla': sigla,
    };
  }

  factory Local.fromMap(Map<String, dynamic> map) {
    return Local(
        id: map['id'],
        nome: map['nome'],
        sigla: map['sigla'],
        rotulos: map['rotulos'],
        rotulos2: map['rotulos2'],
        lat: map['lat'],
        longi: map['longi']
    );
  }
}

