import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


abstract class IHttpClient {
  Future get({required String url});
}

class HttpClient implements IHttpClient {

  final storage = const FlutterSecureStorage();

  @override
  Future get({required String url}) async {
    String? token = await storage.read(key: 'token');

    return await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );
  }

  Future post({required String url}) async {
    String? token = await storage.read(key: 'token');

    return await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
  }

  Future delete({required String url}) async {
    String? token = await storage.read(key: 'token');

    return await http.delete(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
  }

}