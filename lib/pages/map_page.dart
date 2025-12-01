import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  GoogleMapController? _mapController;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  Position? _currentPosition;
  Set<Marker> _markers = {};
  List<Contact> _contacts = [];
  bool _isLoading = true;
  bool _showUserLocation = true;
  BitmapDescriptor? _personIcon; // Ícone de pessoa para localização do usuário

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _createPersonIcon(); // Criar ícone de pessoa primeiro
    await _getCurrentLocation();
    await _loadContacts();
    setState(() => _isLoading = false);
  }

  // Criar ícone customizado de pessoa para a localização do usuário
  Future<void> _createPersonIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = 120.0;
    final centerX = size / 2;
    
    // Fundo branco para melhor visibilidade
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, size / 2), size / 2, backgroundPaint);
    
    // Borda azul
    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(centerX, size / 2), size / 2 - 2, borderPaint);
    
    // Desenhar cabeça (círculo)
    final headPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(centerX, size / 2 - 25),
      18,
      headPaint,
    );
    
    // Desenhar corpo (formato de pessoa - triângulo/trapezóide)
    final bodyPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    // Corpo em formato de losango/trapézio
    final bodyPath = Path();
    bodyPath.moveTo(centerX, size / 2 - 5); // Topo do corpo
    bodyPath.lineTo(centerX - 25, size / 2 + 30); // Esquerda
    bodyPath.lineTo(centerX + 25, size / 2 + 30); // Direita
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);
    
    // Converter para imagem
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();
    
    _personIcon = BitmapDescriptor.fromBytes(uint8List);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
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

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
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

    if (permission == LocationPermission.deniedForever) {
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
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _currentPosition = position);
      
      if (_mapController != null && _showUserLocation) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao obter localização: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadContacts() async {
    final contacts = await _dbHelper.getAllContacts();
    setState(() => _contacts = contacts);
    await _addContactMarkers();
  }

  Future<void> _addContactMarkers() async {
    Set<Marker> markers = {};
    
    // Adicionar marcador da localização do usuário com ícone de pessoa
    if (_currentPosition != null && _showUserLocation && _personIcon != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: _personIcon!,
          infoWindow: const InfoWindow(
            title: 'Sua Localização',
            snippet: 'Você está aqui',
          ),
        ),
      );
    }

    // Adicionar marcadores dos contatos (sempre com ícone de engrenagem)
    for (var contact in _contacts) {
      try {
        List<Location> locations = await locationFromAddress(contact.address);
        if (locations.isNotEmpty) {
          final location = locations.first;
          final position = LatLng(location.latitude, location.longitude);
          
          // Sempre usar ícone de chave de fenda para as lojas
          final icon = await _createWrenchIcon();
          
          markers.add(
            Marker(
              markerId: MarkerId('contact_${contact.id}'),
              position: position,
              icon: icon,
              infoWindow: InfoWindow(
                title: contact.name,
                snippet: 'Toque para ver detalhes',
              ),
              onTap: () => _showContactDetails(contact, position),
            ),
          );
        }
      } catch (e) {
        // Se não conseguir geocodificar o endereço, não adiciona o marcador
        debugPrint('Erro ao geocodificar endereço de ${contact.name}: $e');
      }
    }

    setState(() => _markers = markers);
  }

  // Criar ícone customizado de chave de fenda para as lojas
  Future<BitmapDescriptor> _createWrenchIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = 120.0;
    final centerX = size / 2;
    final centerY = size / 2;
    
    // Fundo branco para melhor visibilidade
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), size / 2, backgroundPaint);
    
    // Borda laranja
    final borderPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(centerX, centerY), size / 2 - 2, borderPaint);
    
    // Cor da chave de fenda
    final wrenchPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = Colors.orange.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // Desenhar chave de fenda (vertical, de cima para baixo)
    // Cabeça da chave (parte superior - formato de U aberto)
    final headWidth = 30.0;
    final headHeight = 22.0;
    final headTop = centerY - 30;
    
    // Cabeça em formato de U (aberta embaixo)
    final headPath = Path();
    // Lado esquerdo
    headPath.moveTo(centerX - headWidth / 2, headTop);
    headPath.lineTo(centerX - headWidth / 2, headTop + headHeight - 6);
    // Curva inferior
    headPath.quadraticBezierTo(
      centerX - headWidth / 2,
      headTop + headHeight,
      centerX,
      headTop + headHeight,
    );
    headPath.quadraticBezierTo(
      centerX + headWidth / 2,
      headTop + headHeight,
      centerX + headWidth / 2,
      headTop + headHeight - 6,
    );
    // Lado direito
    headPath.lineTo(centerX + headWidth / 2, headTop);
    headPath.close();
    canvas.drawPath(headPath, wrenchPaint);
    canvas.drawPath(headPath, strokePaint);
    
    // Braço/cabo da chave (parte do meio - retângulo vertical)
    final armWidth = 14.0;
    final armHeight = 32.0;
    final armTop = headTop + headHeight;
    final armRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        centerX - armWidth / 2,
        armTop,
        armWidth,
        armHeight,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(armRect, wrenchPaint);
    canvas.drawRRect(armRect, strokePaint);
    
    // Ponta da chave (parte inferior - formato de L virado)
    final tipWidth = 20.0;
    final tipHeight = 18.0;
    final tipTop = armTop + armHeight;
    
    // Desenhar ponta em formato de L (gancho)
    final tipPath = Path();
    // Parte vertical esquerda
    tipPath.moveTo(centerX - tipWidth / 2, tipTop);
    tipPath.lineTo(centerX - tipWidth / 2, tipTop + tipHeight);
    // Parte horizontal inferior
    tipPath.lineTo(centerX + tipWidth / 2, tipTop + tipHeight);
    // Parte vertical direita (mais curta)
    tipPath.lineTo(centerX + tipWidth / 2, tipTop + tipHeight - 10);
    // Parte horizontal superior
    tipPath.lineTo(centerX - tipWidth / 2 + 8, tipTop + tipHeight - 10);
    tipPath.lineTo(centerX - tipWidth / 2 + 8, tipTop);
    tipPath.close();
    canvas.drawPath(tipPath, wrenchPaint);
    canvas.drawPath(tipPath, strokePaint);
    
    // Converter para imagem
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();
    
    return BitmapDescriptor.fromBytes(uint8List);
  }

  void _showContactDetails(Contact contact, LatLng position) {
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
                  contact.name,
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
            _buildDetailRow(Icons.phone, 'Telefone', contact.phone),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.location_on, 'Endereço', contact.address),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.access_time, 'Horário de Funcionamento', contact.workingHours),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openRoute(contact.address, position),
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
                    onPressed: () => _callContact(contact.phone),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color.fromRGBO(22, 72, 107, 1)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
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

  Future<void> _openRoute(String address, LatLng destination) async {
    String url = '';
    if (_currentPosition != null) {
      url = 'https://www.google.com/maps/dir/?api=1&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=${destination.latitude},${destination.longitude}&travelmode=driving';
    } else {
      url = 'https://www.google.com/maps/search/?api=1&query=${destination.latitude},${destination.longitude}';
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

  Future<void> _callContact(String phone) async {
    final uri = Uri.parse('tel:$phone');
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

  void _toggleUserLocation() {
    setState(() => _showUserLocation = !_showUserLocation);
    _addContactMarkers();
    if (_showUserLocation && _currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
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
            icon: Icon(_showUserLocation ? Icons.my_location : Icons.location_off),
            tooltip: _showUserLocation ? 'Ocultar Localização' : 'Mostrar Localização',
            onPressed: _toggleUserLocation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition != null
                    ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                    : const LatLng(-23.5505, -46.6333), // São Paulo como padrão
                zoom: 12,
              ),
              markers: _markers,
              myLocationEnabled: _showUserLocation,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
      floatingActionButton: _showUserLocation && _currentPosition != null
          ? FloatingActionButton(
              onPressed: () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
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
    _mapController?.dispose();
    super.dispose();
  }
}

