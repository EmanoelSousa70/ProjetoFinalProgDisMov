import 'package:flutter/material.dart';
import 'package:revise_car/database/database_helper.dart';
import 'package:revise_car/models/contact.dart';

class ContactsPage extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  
  const ContactsPage({super.key, this.arguments});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final _ajudanteBanco = DatabaseHelper.instance;
  List<Contact> _contatos = [];
  List<Contact> _contatosFiltrados = [];
  bool _carregando = true;
  String _acaoAtual = 'list'; // list, add, edit, delete, search, favorites

  @override
  void initState() {
    super.initState();
    if (widget.arguments != null) {
      _acaoAtual = widget.arguments!['action'] ?? 'list';
    }
    _carregarContatos();
  }

  Future<void> _carregarContatos() async {
    setState(() => _carregando = true);
    
    if (_acaoAtual == 'favorites') {
      _contatos = await _ajudanteBanco.obterContatosFavoritos();
    } else {
      _contatos = await _ajudanteBanco.obterTodosContatos();
    }
    
    _contatosFiltrados = _contatos;
    setState(() => _carregando = false);
  }

  void _buscarContatos(String busca) {
    setState(() {
      if (busca.isEmpty) {
        _contatosFiltrados = _contatos;
      } else {
        _contatosFiltrados = _contatos.where((contato) {
          return contato.name.toLowerCase().contains(busca.toLowerCase()) ||
                 contato.phone.contains(busca) ||
                 contato.address.toLowerCase().contains(busca.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _mostrarDialogoAdicionarEditar({Contact? contato}) async {
    final controladorNome = TextEditingController(text: contato?.name ?? '');
    final controladorTelefone = TextEditingController(text: contato?.phone ?? '');
    final controladorEndereco = TextEditingController(text: contato?.address ?? '');
    final controladorHorario = TextEditingController(text: contato?.workingHours ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(contato == null ? 'Cadastrar Contato' : 'Alterar Contato'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controladorNome,
                decoration: const InputDecoration(
                  labelText: 'Nome da Loja',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controladorTelefone,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controladorEndereco,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controladorHorario,
                decoration: const InputDecoration(
                  labelText: 'Horário de Funcionamento',
                  hintText: 'Ex: Seg-Sex: 8h-18h',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controladorNome.text.isEmpty ||
                  controladorTelefone.text.isEmpty ||
                  controladorEndereco.text.isEmpty ||
                  controladorHorario.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha todos os campos!')),
                );
                return;
              }

              if (contato == null) {
                await _ajudanteBanco.inserirContato(Contact(
                  name: controladorNome.text,
                  phone: controladorTelefone.text,
                  address: controladorEndereco.text,
                  workingHours: controladorHorario.text,
                ));
              } else {
                await _ajudanteBanco.atualizarContato(contato.copyWith(
                  name: controladorNome.text,
                  phone: controladorTelefone.text,
                  address: controladorEndereco.text,
                  workingHours: controladorHorario.text,
                ));
              }

              if (mounted) {
                Navigator.pop(context);
                _carregarContatos();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(contato == null
                        ? 'Contato cadastrado com sucesso!'
                        : 'Contato alterado com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(contato == null ? 'Cadastrar' : 'Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirContato(Contact contato) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir ${contato.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true && contato.id != null) {
      await _ajudanteBanco.excluirContato(contato.id!);
      if (mounted) {
        _carregarContatos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contato excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _alternarFavorito(Contact contato) async {
    if (contato.id != null) {
      await _ajudanteBanco.alternarFavorito(contato.id!, !contato.isFavorite);
      _carregarContatos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_obterTitulo()),
        backgroundColor: const Color.fromRGBO(22, 72, 107, 1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (_acaoAtual == 'search' || _acaoAtual == 'list')
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: _buscarContatos,
                decoration: InputDecoration(
                  labelText: 'Buscar contatos',
                  hintText: 'Digite nome, telefone ou endereço',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _contatosFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.contacts_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _obterMensagemVazia(),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _contatosFiltrados.length,
                        itemBuilder: (context, indice) {
                          final contato = _contatosFiltrados[indice];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color.fromRGBO(22, 72, 107, 1),
                                child: Text(
                                  contato.name[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      contato.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (contato.isFavorite)
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 16),
                                      const SizedBox(width: 4),
                                      Text(contato.phone),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text(contato.address)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16),
                                      const SizedBox(width: 4),
                                      Text(contato.workingHours),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Alterar'),
                                      ],
                                    ),
                                    onTap: () => Future.delayed(
                                      const Duration(milliseconds: 100),
                                      () => _mostrarDialogoAdicionarEditar(contato: contato),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(
                                          contato.isFavorite
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(contato.isFavorite
                                            ? 'Remover dos Favoritos'
                                            : 'Adicionar aos Favoritos'),
                                      ],
                                    ),
                                    onTap: () => Future.delayed(
                                      const Duration(milliseconds: 100),
                                      () => _alternarFavorito(contato),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    child: const Row(
                                      children: [
                                        Icon(Icons.delete, size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Excluir', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                    onTap: () => Future.delayed(
                                      const Duration(milliseconds: 100),
                                      () => _excluirContato(contato),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _acaoAtual == 'add' || _acaoAtual == 'list'
          ? FloatingActionButton(
              onPressed: () => _mostrarDialogoAdicionarEditar(),
              backgroundColor: const Color.fromRGBO(22, 72, 107, 1),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  String _obterTitulo() {
    switch (_acaoAtual) {
      case 'add':
        return 'Cadastrar Contato';
      case 'edit':
        return 'Alterar Contato';
      case 'delete':
        return 'Excluir Contato';
      case 'search':
        return 'Buscar Contatos';
      case 'favorites':
        return 'Favoritos';
      default:
        return 'Lista de Contatos';
    }
  }

  String _obterMensagemVazia() {
    switch (_acaoAtual) {
      case 'search':
        return 'Nenhum contato encontrado';
      case 'favorites':
        return 'Nenhum favorito cadastrado';
      default:
        return 'Nenhum contato cadastrado';
    }
  }
}

