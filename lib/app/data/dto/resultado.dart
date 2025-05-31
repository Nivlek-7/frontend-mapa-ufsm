import 'package:app_tcc/app/data/models/local.dart';
import 'package:app_tcc/app/data/models/ponto.dart';

class Resultado {
  late final Local localMaisProximo;
  late final Ponto pontoMaisProximo;

  Resultado({
    required this.localMaisProximo,
    required this.pontoMaisProximo
  });


  factory Resultado.fromMap(Map<String, dynamic> map) {
    return Resultado(
      localMaisProximo: Local.fromMap(map['localMaisProximo'] as Map<String, dynamic>),
      pontoMaisProximo: Ponto.fromMap(map['pontoMaisProximo'] as Map<String, dynamic>),
    );
  }
}