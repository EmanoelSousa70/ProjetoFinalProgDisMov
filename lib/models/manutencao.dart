class Manutencao {
  final int? id;
  final String data; // formato string 'yyyy-MM-dd'
  final String local;
  final String descricao;
  final double valor;

  Manutencao({
    this.id,
    required this.data,
    required this.local,
    required this.descricao,
    required this.valor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data,
      'local': local,
      'descricao': descricao,
      'valor': valor,
    };
  }

  factory Manutencao.fromMap(Map<String, dynamic> map) {
    return Manutencao(
      id: map['id'] as int?,
      data: map['data'] as String,
      local: map['local'] as String,
      descricao: map['descricao'] as String,
      valor: map['valor'] is int ? (map['valor'] as int).toDouble() : map['valor'] as double,
    );
  }
}
