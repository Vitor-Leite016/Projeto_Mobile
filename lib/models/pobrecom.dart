class Despesa {
  final int id;
  final double valor;
  final bool pago;
  final String descricao;
  final DateTime data;
  final int userId;

  Despesa({
    required this.id,
    required this.valor,
    required this.pago,
    required this.descricao,
    required this.data,
    required this.userId,
  });

  factory Despesa.fromJson(Map<String, dynamic> json) {
    return Despesa(
      id: json['id'] as int,
      valor: json['valor'] as double,
      pago: json['pago'] as bool,
      descricao: json['descricao'] as String,
      data: DateTime.parse(json['data'] as String),
      userId: json['userId'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'valor': valor,
      'pago': pago,
      'descricao': descricao,
      'data': data,
      'userId': userId,
    };
  }

  Despesa copyWith({
    int? id,
    double? valor,
    bool? pago,
    String? descricao,
    DateTime? data,
    int? userId,
  }) {
    return Despesa(
      id: id ?? this.id,
      valor: valor ?? this.valor,
      pago: pago ?? this.pago,
      descricao: descricao ?? this.descricao,
      data: data ?? this.data,
      userId: userId ?? this.userId,
    );
  }
}
