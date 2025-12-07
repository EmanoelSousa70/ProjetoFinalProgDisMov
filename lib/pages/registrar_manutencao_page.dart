import 'package:flutter/material.dart';
import 'package:revise_car/database/database_helper.dart';
import 'package:revise_car/models/manutencao.dart';

class RegistrarManutencaoPage extends StatefulWidget {
  @override
  _RegistrarManutencaoPageState createState() => _RegistrarManutencaoPageState();
}

class _RegistrarManutencaoPageState extends State<RegistrarManutencaoPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _data;
  final _localController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  Future<void> _selecionarData() async {
    DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (dataEscolhida != null) {
      setState(() {
        _data = dataEscolhida;
      });
    }
  }

  @override
  void dispose() {
    _localController.dispose();
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  void _salvar() async {
    if (_formKey.currentState!.validate() && _data != null) {
      final manutencao = Manutencao(
        data: _data!.toString().substring(0,10),
        local: _localController.text,
        descricao: _descricaoController.text,
        valor: double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0,
      );
      await DatabaseHelper.instance.inserirManutencao(manutencao);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Manutenção salva com sucesso!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Manutenção')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text(_data == null ? 'Selecione a data' : _data.toString().substring(0,10)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selecionarData,
              ),
              TextFormField(
                controller: _localController,
                decoration: const InputDecoration(labelText: 'Local'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o local' : null,
              ),
              TextFormField(
                controller: _descricaoController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Descrição do serviço'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o que foi realizado' : null,
              ),
              TextFormField(
                controller: _valorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor (Reais)'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o valor' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
