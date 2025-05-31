import 'package:app_tcc/app/data/http/http_client.dart';

import '../http/exceptions.dart';


class PessoaRepository {

  final HttpClient client;

  PessoaRepository({required this.client});

  final url = 'http://192.168.100.15:8080'; // http://10.0.2.2:8080

  Future createLocal(int pessoaId, int localId) async {
    final response = await client.post(url: '$url/pessoa/$pessoaId/locais/$localId');

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      throw NotFoundException('A url informada não é válida');
    } else {
      throw Exception('Não foi possível criar o local');
    }
  }

  Future deleteLocal(int pessoaId, int localId) async {
    final response = await client.delete(url: '$url/pessoa/$pessoaId/locais/$localId');

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      throw NotFoundException('A url informada não é válida');
    } else {
      throw Exception('Não foi possível excluir o local');
    }
  }



}