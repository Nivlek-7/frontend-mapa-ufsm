import 'package:app_tcc/app/data/repositories/pessoa_repository.dart';
import 'package:flutter/material.dart';
import 'package:app_tcc/app/data/models/local.dart';
import 'package:app_tcc/app/data/repositories/local_repository.dart';
import 'package:app_tcc/app/data/http/http_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/persistence/databaseHelper.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Local> favorites = [];
  bool isLoading = true;
  final storage = const FlutterSecureStorage();
  int _selectedIndex = 1;

  PessoaRepository pessoaRepository = PessoaRepository(client: HttpClient());

  @override
  void initState() {
    super.initState();
    _initializeFavorites();
  }

  Future<void> _initializeFavorites() async {
    String? id = await storage.read(key: 'id');
    // Pegando dados da API
    LocalRepository repository = LocalRepository(client: HttpClient());
    List<Local> apiFavorites = await repository.getLocalsByPessoaId(int.parse(id!));

    // Salvando dados no SQLite
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.insertFavorites(apiFavorites);


    // Carregando dados do SQLite
    List<Local> dbFavorites = await dbHelper.getFavorites();
    setState(() {
      favorites = dbFavorites;
      isLoading = false;
    });
  }

  Future<void> _deleteFavorite(String id) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.deleteFavorite(id);
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Local> dbFavorites = await dbHelper.getFavorites();
    setState(() {
      favorites = dbFavorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locais favoritos'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          Local local = favorites[index];
          return ListTile(
            title: Text(local.nome),
            subtitle: Text('Sigla: ${local.sigla}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                String? id = await storage.read(key: 'id');
                await pessoaRepository.deleteLocal(int.parse(id!), local.id);
                await _deleteFavorite(local.id.toString());
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Página Inicial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Usuário',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          break;
        case 2:
          showMenu<String>(
            context: context,
            position: const RelativeRect.fromLTRB(1000.0, 1000.0, 0.0, 0.0),
            items: <PopupMenuItem<String>>[
              const PopupMenuItem<String>(
                  value: 'sair',
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('Sair'),
                  )
              ),
            ],
            elevation: 8.0,
          ).then((value) async {
            if (value == 'sair') {
              await storage.deleteAll();
              DatabaseHelper dbHelper = DatabaseHelper();
              await dbHelper.clearDatabase();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            }
          });
          break;
      }
    });
  }
}
