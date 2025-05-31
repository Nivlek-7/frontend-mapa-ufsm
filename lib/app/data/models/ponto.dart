class Ponto {
  final String id;
  final String nome;
  final double lat;
  final double longi;

  Ponto ({
    required this.id,
    required this.nome,
    required this.lat,
    required this.longi,
  });

  factory Ponto.fromMap(Map<String, dynamic> map) {
    return Ponto(
        id: map['id'],
        nome: map['nome'],
        lat: map['lat'],
        longi: map['longi']
    );
  }
}