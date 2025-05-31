import 'package:app_tcc/app/data/models/local.dart';

class Pessoa {
  final int id;
  final String nome;
  final String email;
  final String senha;
  final List<Local> locaisFavoritos;

  Pessoa ({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.locaisFavoritos
  });

  factory Pessoa.fromMap(Map<String, dynamic> map) {
    return Pessoa(
        id: map['id'],
        nome: map['nome'],
        email: map['email'],
        senha: map['senha'],
        locaisFavoritos: List<Local>.from(map['locaisFavoritos'].map((localMap) => Local.fromMap(localMap)))
    );
  }
}

