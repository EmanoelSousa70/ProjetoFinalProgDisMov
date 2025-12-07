import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:revise_car/database/database_helper.dart';
import 'package:revise_car/models/contact.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controladorMapa;
  final DatabaseHelper _ajudanteBanco = DatabaseHelper.instance;
  
  Position? _posicaoAtual;
  Set<Marker> _marcadores = {};
  List<Contact> _contatos = [];
  bool _carregando = true;
  bool _mostrarLocalizacaoUsuario = true;
  BitmapDescriptor? _iconePessoa; // Ícone de pessoa para localização do usuário

  @override
  void initState() {
    super.initState();
    _inicializarMapa();
  }

  Future<void> _inicializarMapa() async {
    await _criarIconePessoa(); // Criar ícone de pessoa primeiro
    await _obterLocalizacaoAtual();
    await _carregarContatos();
    setState(() => _carregando = false);
  }

  // Substituir _criarIconePessoa para usar assets/icons/local.ico
  Future<void> _criarIconePessoa() async {
    final icone = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(24, 24)),
      'assets/icons/local.png',
    );
    setState(() {
      _iconePessoa = icone;
    });
  }

  Future<void> _obterLocalizacaoAtual() async {
    bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicoHabilitado) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Serviços de localização estão desabilitados'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissão de localização negada'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão de localização negada permanentemente'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      Position posicao = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _posicaoAtual = posicao);
      
      if (_controladorMapa != null && _mostrarLocalizacaoUsuario) {
        _controladorMapa!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(posicao.latitude, posicao.longitude),
          ),
        );
      }
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao obter localização: $erro'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _carregarContatos() async {
    final contatos = await _ajudanteBanco.obterTodosContatos();
    setState(() => _contatos = contatos);
    await _adicionarMarcadoresContatos();
  }

  Future<void> _adicionarMarcadoresContatos() async {
    Set<Marker> marcadores = {};
    
    // Adicionar marcador da localização do usuário com ícone de pessoa
    if (_posicaoAtual != null && _mostrarLocalizacaoUsuario && _iconePessoa != null) {
      marcadores.add(
        Marker(
          markerId: const MarkerId('localizacao_usuario'),
          position: LatLng(_posicaoAtual!.latitude, _posicaoAtual!.longitude),
          icon: _iconePessoa!,
          infoWindow: const InfoWindow(
            title: 'Sua Localização',
            snippet: 'Você está aqui',
          ),
        ),
      );
    }

    // Adicionar marcadores dos contatos (sempre com ícone de engrenagem)
    for (var contato in _contatos) {
      try {
        List<Location> localizacoes = await locationFromAddress(contato.address);
        if (localizacoes.isNotEmpty) {
          final localizacao = localizacoes.first;
          final posicao = LatLng(localizacao.latitude, localizacao.longitude);
          
          // Sempre usar ícone de chave de fenda para as lojas
          final icone = await _criarIconeChaveFenda();
          
          marcadores.add(
            Marker(
              markerId: MarkerId('contato_${contato.id}'),
              position: posicao,
              icon: icone,
              infoWindow: InfoWindow(
                title: contato.name,
                snippet: 'Toque para ver detalhes',
              ),
              onTap: () => _mostrarDetalhesContato(contato, posicao),
            ),
          );
        }
      } catch (erro) {
        // Se não conseguir geocodificar o endereço, não adiciona o marcador
        debugPrint('Erro ao geocodificar endereço de ${contato.name}: $erro');
      }
    }

    setState(() => _marcadores = marcadores);
  }

  // Substituir _criarIconeChaveFenda para usar assets/icons/loja.ico
  Future<BitmapDescriptor> _criarIconeChaveFenda() async {
    return await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(24, 24)),
      'assets/icons/loja.png',
    );
  }

  void _mostrarDetalhesContato(Contact contato, LatLng posicao) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  contato.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(22, 72, 107, 1),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _construirLinhaDetalhe(Icons.phone, 'Telefone', contato.phone),
            const SizedBox(height: 12),
            _construirLinhaDetalhe(Icons.location_on, 'Endereço', contato.address),
            const SizedBox(height: 12),
            _construirLinhaDetalhe(Icons.access_time, 'Horário de Funcionamento', contato.workingHours),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _abrirRota(contato.address, posicao),
                    icon: const Icon(Icons.directions),
                    label: const Text('Traçar Rota'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(22, 72, 107, 1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _ligarContato(contato.phone),
                    icon: const Icon(Icons.call),
                    label: const Text('Ligar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirLinhaDetalhe(IconData icone, String rotulo, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, size: 20, color: const Color.fromRGBO(22, 72, 107, 1)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rotulo,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _abrirRota(String endereco, LatLng destino) async {
    String url = '';
    if (_posicaoAtual != null) {
      url = 'https://www.google.com/maps/dir/?api=1&origin=${_posicaoAtual!.latitude},${_posicaoAtual!.longitude}&destination=${destino.latitude},${destino.longitude}&travelmode=driving';
    } else {
      url = 'https://www.google.com/maps/search/?api=1&query=${destino.latitude},${destino.longitude}';
    }
    
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o Google Maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _ligarContato(String telefone) async {
    final uri = Uri.parse('tel:$telefone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível fazer a ligação'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _alternarLocalizacaoUsuario() {
    setState(() => _mostrarLocalizacaoUsuario = !_mostrarLocalizacaoUsuario);
    _adicionarMarcadoresContatos();
    if (_mostrarLocalizacaoUsuario && _posicaoAtual != null && _controladorMapa != null) {
      _controladorMapa!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_posicaoAtual!.latitude, _posicaoAtual!.longitude),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mapa de Contatos',
          style: TextStyle(
            fontFamily: 'Cookie',
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color.fromRGBO(22, 72, 107, 1),
        foregroundColor: Colors.white,
        actions: [
          // Botão para mostrar/ocultar localização
          IconButton(
            icon: Icon(_mostrarLocalizacaoUsuario ? Icons.my_location : Icons.location_off),
            tooltip: _mostrarLocalizacaoUsuario ? 'Ocultar Localização' : 'Mostrar Localização',
            onPressed: _alternarLocalizacaoUsuario,
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _posicaoAtual != null
                    ? LatLng(_posicaoAtual!.latitude, _posicaoAtual!.longitude)
                    : const LatLng(-23.5505, -46.6333), // São Paulo como padrão
                zoom: 12,
              ),
              markers: _marcadores,
              myLocationEnabled: _mostrarLocalizacaoUsuario,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controlador) {
                _controladorMapa = controlador;
              },
            ),
      floatingActionButton: _mostrarLocalizacaoUsuario && _posicaoAtual != null
          ? FloatingActionButton(
              onPressed: () {
                _controladorMapa?.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(_posicaoAtual!.latitude, _posicaoAtual!.longitude),
                  ),
                );
              },
              backgroundColor: const Color.fromRGBO(22, 72, 107, 1),
              child: const Icon(Icons.my_location, color: Colors.white),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _controladorMapa?.dispose();
    super.dispose();
  }
}

