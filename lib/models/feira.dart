import 'package:cloud_firestore/cloud_firestore.dart';

enum StatusFeira { agendada, finalizada }

class Feira {
  final String? id;
  final DateTime data;
  final String titulo;
  final String anotacoes;
  final StatusFeira status;
  final String? mapaUrl;
  final Map<String, bool?>? presencaExpositores;

  Feira({
    this.id,
    required this.data,
    required this.titulo,
    this.anotacoes = '',
    this.status = StatusFeira.agendada,
    this.mapaUrl,
    this.presencaExpositores,
  });

  // Helper para converter o enum StatusFeira para String (para guardar no Firestore)
  String get statusToString => status.toString().split('.').last;

  // Helper para converter String (do Firestore) para o enum StatusFeira
  static StatusFeira statusFromString(String? statusStr) {
    if (statusStr == 'finalizada') {
      return StatusFeira.finalizada;
    }
    return StatusFeira.agendada;
  }

  factory Feira.fromMap(Map<String, dynamic> data, String documentId) {
    return Feira(
      id: documentId,
      data: (data['data'] as Timestamp).toDate(),
      titulo: data['titulo'] ?? 'Feira Sem Título',
      anotacoes: data['anotacoes'] ?? '',
      status: statusFromString(data['status']),
      mapaUrl: data['mapaUrl'],
      presencaExpositores:
          data['presencaExpositores'] != null
              ? Map<String, bool?>.from(data['presencaExpositores'])
              : {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'data': Timestamp.fromDate(data),
      'titulo': titulo,
      'anotacoes': anotacoes,
      'status': statusToString,
      'mapaUrl': mapaUrl,
      'presencaExpositores': presencaExpositores,
    };
  }
}
