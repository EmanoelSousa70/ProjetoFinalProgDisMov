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
  final _dbHelper = DatabaseHelper.instance;
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;
  String _currentAction = 'list'; // list, add, edit, delete, search, favorites

  @override
  void initState() {
    super.initState();
    if (widget.arguments != null) {
      _currentAction = widget.arguments!['action'] ?? 'list';
    }
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    
    if (_currentAction == 'favorites') {
      _contacts = await _dbHelper.getFavoriteContacts();
    } else {
      _contacts = await _dbHelper.getAllContacts();
    }
    
    _filteredContacts = _contacts;
    setState(() => _isLoading = false);
  }

  void _searchContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _contacts;
      } else {
        _filteredContacts = _contacts.where((contact) {
          return contact.name.toLowerCase().contains(query.toLowerCase()) ||
                 contact.phone.contains(query) ||
                 contact.address.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _showAddEditDialog({Contact? contact}) async {
    final nameController = TextEditingController(text: contact?.name ?? '');
    final phoneController = TextEditingController(text: contact?.phone ?? '');
    final addressController = TextEditingController(text: contact?.address ?? '');
    final hoursController = TextEditingController(text: contact?.workingHours ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(contact == null ? 'Cadastrar Contato' : 'Alterar Contato'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Loja',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hoursController,
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
              if (nameController.text.isEmpty ||
                  phoneController.text.isEmpty ||
                  addressController.text.isEmpty ||
                  hoursController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preencha todos os campos!')),
                );
                return;
              }

              if (contact == null) {
                await _dbHelper.insertContact(Contact(
                  name: nameController.text,
                  phone: phoneController.text,
                  address: addressController.text,
                  workingHours: hoursController.text,
                ));
              } else {
                await _dbHelper.updateContact(contact.copyWith(
                  name: nameController.text,
                  phone: phoneController.text,
                  address: addressController.text,
                  workingHours: hoursController.text,
                ));
              }

              if (mounted) {
                Navigator.pop(context);
                _loadContacts();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(contact == null
                        ? 'Contato cadastrado com sucesso!'
                        : 'Contato alterado com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(contact == null ? 'Cadastrar' : 'Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteContact(Contact contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir ${contact.name}?'),
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

    if (confirm == true && contact.id != null) {
      await _dbHelper.deleteContact(contact.id!);
      if (mounted) {
        _loadContacts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contato excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite(Contact contact) async {
    if (contact.id != null) {
      await _dbHelper.toggleFavorite(contact.id!, !contact.isFavorite);
      _loadContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: const Color.fromRGBO(22, 72, 107, 1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (_currentAction == 'search' || _currentAction == 'list')
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: _searchContacts,
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredContacts.isEmpty
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
                              _getEmptyMessage(),
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
                        itemCount: _filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = _filteredContacts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color.fromRGBO(22, 72, 107, 1),
                                child: Text(
                                  contact.name[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      contact.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (contact.isFavorite)
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
                                      Text(contact.phone),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text(contact.address)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16),
                                      const SizedBox(width: 4),
                                      Text(contact.workingHours),
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
                                      () => _showAddEditDialog(contact: contact),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(
                                          contact.isFavorite
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(contact.isFavorite
                                            ? 'Remover dos Favoritos'
                                            : 'Adicionar aos Favoritos'),
                                      ],
                                    ),
                                    onTap: () => Future.delayed(
                                      const Duration(milliseconds: 100),
                                      () => _toggleFavorite(contact),
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
                                      () => _deleteContact(contact),
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
      floatingActionButton: _currentAction == 'add' || _currentAction == 'list'
          ? FloatingActionButton(
              onPressed: () => _showAddEditDialog(),
              backgroundColor: const Color.fromRGBO(22, 72, 107, 1),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  String _getTitle() {
    switch (_currentAction) {
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

  String _getEmptyMessage() {
    switch (_currentAction) {
      case 'search':
        return 'Nenhum contato encontrado';
      case 'favorites':
        return 'Nenhum favorito cadastrado';
      default:
        return 'Nenhum contato cadastrado';
    }
  }
}

