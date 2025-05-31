import 'dart:convert';

import 'package:app_tcc/app/data/http/exceptions.dart';
import 'package:app_tcc/app/data/http/http_client.dart';
import 'package:app_tcc/app/data/models/local.dart';

import '../dto/resultado.dart';
import '../models/pessoa.dart';

abstract class ILocalRepository{
  Future<List<Local>> getLocals();
  Future<List<Local>> getLocalsByArea(String nome);
  //Future<Resultado> getNearestLocalAndPonto(double lat, double longi, String nomeArea);
}

class LocalRepository implements ILocalRepository {

  final IHttpClient client;

  LocalRepository({required this.client});

  final url = 'http://192.168.100.15:8080'; // http://10.0.2.2:8080

  @override
  Future<List<Local>> getLocals() async {
    final response = await client.get(url: '$url/local');

    if (response.statusCode == 200) {
      final List<Local> locals = [];

      final bodyBytes = response.bodyBytes;
      final bodyString = utf8.decode(bodyBytes);
      final body = jsonDecode(bodyString);

      body.map((item) {
        final Local local = Local.fromMap(item);
        locals.add(local);
      }).toList();

      return locals;
    } else if (response.statusCode == 404) {
      throw NotFoundException('A url informada não é válida');
    } else {
      throw Exception('Não foi possível carregar os locais');
    }
  }

  @override
  Future<List<Local>> getLocalsByArea(String nome) async {
    final response = await client.get(
        url: '$url/local/area?nome=$nome'
    );

    if (response.statusCode == 200) {
      final List<Local> locals = [];

      final bodyBytes = response.bodyBytes;
      final bodyString = utf8.decode(bodyBytes);
      final body = jsonDecode(bodyString);

      body.map((item) {
        final Local local = Local.fromMap(item);
        locals.add(local);
      }).toList();

      return locals;
    } else if (response.statusCode == 404) {
      throw NotFoundException('A url informada não é válida');
    } else {
      throw Exception('Não foi possível carregar os locais');
    }
  }

  Future<Resultado> getNearestLocalAndPonto(double lat, double longi, String nomeArea) async {
    final response = await client.get(
        url: '$url/local/localMaisProximo?lat=$lat&longi=$longi&nomeArea=$nomeArea'
    );

    if (response.statusCode == 200) {
      final bodyBytes = response.bodyBytes;
      final bodyString = utf8.decode(bodyBytes);
      final body = jsonDecode(bodyString);

      final Resultado resultado = Resultado.fromMap(body);
      return resultado;

    } else if (response.statusCode == 404) {
      throw NotFoundException('A url informada não é válida');
    } else {
      throw Exception('Não foi possível carregar carregar o local mais próximo');
    }
  }

  Future<List<Local>> getLocalsByPessoaId(int pessoaId) async {
    final response = await client.get(
        url: '$url/pessoa/$pessoaId'
    );

    if (response.statusCode == 200) {
      final bodyBytes = response.bodyBytes;
      final bodyString = utf8.decode(bodyBytes);
      final body = jsonDecode(bodyString);

      final Pessoa pessoa = Pessoa.fromMap(body);
      return pessoa.locaisFavoritos;

    } else if (response.statusCode == 404) {
      throw NotFoundException('A url informada não é válida');
    } else {
      throw Exception('Não foi possível carregar os locais');
    }
  }

  Future<List<Local>> getLocalsByRecomendacao(int pessoaId) async {
    final response = await client.get(
        url: '$url/pessoa/$pessoaId/recomendacoesLocais'
    );

    if (response.statusCode == 200) {
      final List<Local> locals = [];

      final bodyBytes = response.bodyBytes;
      final bodyString = utf8.decode(bodyBytes);
      final body = jsonDecode(bodyString);

      body.map((item) {
        final Local local = Local.fromMap(item);
        locals.add(local);
      }).toList();

      return locals;
    } else if (response.statusCode == 404) {
      throw NotFoundException('A url informada não é válida');
    } else {
      throw Exception('Não foi possível carregar os locais');
    }
  }

}