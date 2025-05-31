import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  final Map<String, dynamic> _interests = {
    '52': {'name': 'Ciências Exatas e da Terra', 'selected': false},
    '295': {'name': 'Ciências Biológicas', 'selected': false},
    '398': {'name': 'Engenharias', 'selected': false},
    '704': {'name': 'Ciências da Saúde', 'selected': false},
    '780': {'name': 'Ciências Agrárias', 'selected': false},
    '937': {'name': 'Ciências Sociais Aplicadas', 'selected': false},
    '1124': {'name': 'Ciências Humanas', 'selected': false},
    '1288': {'name': 'Linguística, Letras e Artes', 'selected': false},
  };

  Future<bool> register(String nome, String email, String senha, List<String> areaIds) async {
    const String url = 'http://192.168.100.15:8080';

    var res = await http.post(
        Uri.parse('$url/auth/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'nome': nome,
          'email': email,
          'senha': senha,
          'areaIds': areaIds
        })
    );
    if(res.statusCode == 200) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            const Text('Selecione de 1 a 3 áreas de interesse:'),
            ..._interests.entries.map((entry) {
              return CheckboxListTile(
                title: Text(entry.value['name']),
                value: entry.value['selected'],
                onChanged: (bool? value) {
                  if (value != null && entry.value['selected'] != value) {
                    int selectedCount = _interests.values.where((interest) => interest['selected']).length;
                    if (selectedCount < 3 || !value) {
                      setState(() {
                        _interests[entry.key]['selected'] = value;
                      });
                    } else {
                      _showErrorSnackbar(context, 'Você pode selecionar no máximo 3 áreas de interesse.');
                    }
                  }
                },
              );
            }).toList(),
            ElevatedButton(
              onPressed: () async {
                // Implementar lógica de cadastro
                String nome = _nomeController.text;
                String email = _emailController.text;
                String senha = _senhaController.text;
                List<String> areaIds = _interests.entries
                    .where((entry) => entry.value['selected'])
                    .map((entry) => entry.key)
                    .toList();

                if (nome.isNotEmpty && email.isNotEmpty && senha.isNotEmpty) {
                  var response = register(nome, email, senha, areaIds);
                  if (await response) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                } else {
                  _showErrorSnackbar(context, 'Por favor, preencha os campos.');
                }
              },
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }
}