import 'package:cloud_firestore/cloud_firestore.dart';

// Modelo de Convite
enum StatusConvite { pendente, aceito, recusado }

class Convite {
  final String? id;
  final String codigo;
  final StatusConvite status;
  final Timestamp dataCriacao;
  final String? idAdmin;

  Convite({
    this.id,
    required this.codigo,
    this.status = StatusConvite.pendente,
    required this.dataCriacao,
    this.idAdmin,
  });

  String get statusToString => status.toString().split('.').last;
  static StatusConvite statusFromString(String status) {
    return StatusConvite.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => StatusConvite.pendente,
    );
  }

  // Método de fábrica para criar um objeto Convite a partir de um mapa
  factory Convite.fromMap(Map<String, dynamic> data, String id) {
    return Convite(
      id: id,
      codigo: data['codigo'] ?? '',
      status: Convite.statusFromString(data['status']),
      dataCriacao: data['dataCriacao'] ?? Timestamp.now(),
      idAdmin: data['idAdmin'],
    );
  }

  // Método para converter o objeto Convite em um mapa
  Map<String, dynamic> toMap() {
    return {
      'codigo': codigo,
      'status': statusToString,
      'dataCriacao': dataCriacao,
      'idAdmin': idAdmin,
    };
  }
}
