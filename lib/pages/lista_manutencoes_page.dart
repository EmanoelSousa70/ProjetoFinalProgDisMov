import 'package:flutter/material.dart';
import 'package:revise_car/database/database_helper.dart';
import 'package:revise_car/models/manutencao.dart';

class ListaManutencoesPage extends StatelessWidget {
  const ListaManutencoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Manutenções')),
      body: FutureBuilder<List<Manutencao>>(
        future: DatabaseHelper.instance.obterTodasManutencoes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma manutenção registrada.'));
          }
          final manutencoes = snapshot.data!;
          return ListView.builder(
            itemCount: manutencoes.length,
            itemBuilder: (context, i) {
              final m = manutencoes[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(m.local + " - " + m.data),
                  subtitle: Text(m.descricao),
                  trailing: Text("R\$ "+m.valor.toStringAsFixed(2)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
