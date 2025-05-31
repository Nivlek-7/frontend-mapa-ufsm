import 'package:app_tcc/app/data/repositories/pessoa_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_tcc/app/data/http/http_client.dart';
import 'package:app_tcc/app/data/repositories/local_repository.dart';
import 'package:app_tcc/app/stores/local_store.dart';

import '../data/dto/resultado.dart';
import '../data/models/local.dart';
import '../data/persistence/databaseHelper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const googlePlex = LatLng(-29.7211761, -53.7179799);
  final storage = const FlutterSecureStorage();
  int _selectedIndex = 0;
  GoogleMapController? _mapController;

  final LocalStore store = LocalStore(
      repository: LocalRepository(
          client: HttpClient()
      )
  );

  final LocalRepository repository = LocalRepository(
      client: HttpClient()
  );

  final PessoaRepository pessoaRepository = PessoaRepository(
      client: HttpClient()
  );

  final TextEditingController _nomeAreaController = TextEditingController();
  Set<Marker> _markers = {}; // Set para armazenar os markers
  LatLng? _currentLocation;

  void _markersFromLocals(List<Local> locals) {
    WidgetsBinding.instance.addPostFrameCallback((_){
      setState(() {
        _markers = locals.map((local) {
          return Marker(
              markerId: MarkerId(local.id.toString()),
              position: LatLng(local.lat, local.longi),
              onTap: () {
                _onMarkerTapped(local);
              }
            // Outros atributos do marcador, se necessário
          );
        }).toSet();
      });
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Serviço de localização está desabilitado.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissão de localização recusado.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permissão de localização permanentemente recusado');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _markers.add(
          Marker(
              markerId: const MarkerId('currentLocation'),
              position: _currentLocation!,
              infoWindow: const InfoWindow(
                title: 'Minha Localização',
              )
          )
      );
    });

  }

  @override
  void initState() {
    super.initState();
    store.getLocals();
    _getCurrentLocation();
    _showRecommendationsDialog();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Visualização de mapa'),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([store.isLoading, store.erro, store.state]),
        builder: (context, child) {
          if (store.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator()
            );
          }

          if (store.erro.value.isNotEmpty) {
            return Center(
              child: Text(
                store.erro.value,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (store.state.value.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum item na lista',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            _markersFromLocals(store.state.value);
            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: googlePlex,
                    zoom: 13,
                  ),
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _nomeAreaController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'Filtrar por nome da área',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          String nomeArea = _nomeAreaController.text;
                          store.getLocalsByArea(nomeArea);
                          _markersFromLocals(store.state.value);
                          //if (_currentLocation != null) {
                          resultadoFiltro(_currentLocation!.latitude,
                              _currentLocation!.longitude, nomeArea);
                          //}
                        },
                        child: const Text('Filtrar'),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            );
          }
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
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/favorites');
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

  void _onMarkerTapped(Local local) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                local.nome,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Informações do local:'),
              const SizedBox(height: 8),
              Text('Possíveis rótulos: ${local.rotulos}, ${local.rotulos2}'),
              Text('Sigla: ${local.sigla}'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Lógica para favoritar
                      String? id = await storage.read(key: 'id');
                      await pessoaRepository.createLocal(int.parse(id!), local.id);
                      await DatabaseHelper().insertFavorite(local);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Favoritar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> resultadoFiltro(double lat, double longi, String nomeArea) async {
    String titulo = "Local mais próximo";
    String descricao = "";

    Resultado resultado = await repository.getNearestLocalAndPonto(lat, longi, nomeArea);

    descricao = "Local mais próximo: ${resultado.localMaisProximo.nome}\n"
        "Ponto mais próximo: ${resultado.pontoMaisProximo.nome}";

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(descricao),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRecommendationsDialog() async {
    String? id = await storage.read(key: 'id');
    List<Local> recommendations = await repository.getLocalsByRecomendacao(int.parse(id!));

    // Show dialog if there are recommendations
    if (recommendations.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Recomendações de Locais'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: recommendations.map((local) {
                  return GestureDetector(
                    onTap: () async {
                      Navigator.of(context).pop(); // Fecha o diálogo

                      if (_mapController != null) {
                        // Atualiza o marcador no local selecionado e remove os outros marcadores
                        setState(() {
                          _markers = {
                            Marker(
                              markerId: MarkerId(local.id.toString()),
                              position: LatLng(local.lat, local.longi),
                              infoWindow: InfoWindow(
                                title: local.nome,
                                snippet: 'Rótulos: ${local.rotulos}, ${local.rotulos2}\nSigla: ${local.sigla}',
                              ),
                            ),
                          };
                        });

                        // Centraliza o mapa no local selecionado e ajusta o zoom
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLngZoom(LatLng(local.lat, local.longi), 18.0), // Ajuste o zoom conforme necessário
                        );

                        // Aguarda a animação da câmera terminar
                        await Future.delayed(Duration(milliseconds: 300));

                        // Mostra o InfoWindow do marcador selecionado
                        _mapController!.showMarkerInfoWindow(MarkerId(local.id.toString()));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8.0),
                        title: Text(
                          local.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rótulos: ${local.rotulos}'),
                            Text('Rótulos 2: ${local.rotulos2}'),
                            Text('Sigla: ${local.sigla}'),
                          ],
                        ),
                        tileColor: Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Fechar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}