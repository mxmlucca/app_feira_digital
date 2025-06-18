import 'package:cloud_firestore/cloud_firestore.dart';

// Enum para os status da feira, para melhor controlo e clareza
enum StatusFeira { atual, finalizada }

class Feira {
  final String? id; // ID do documento no Firestore
  final DateTime data; // Data da feira
  final String
  titulo; // Um título ou nome para a edição da feira (ex: "Feira de Maio", "Edição de Natal")
  final String anotacoes; // Anotações gerais sobre a feira
  final StatusFeira status; // Status atual da feira
  final String? mapaUrl;

  // Lista de Presença:
  // Chave: ID do Expositor (String)
  // Valor: bool (true para presente, false para ausente, null se ainda não definido)
  // Usamos '?' para indicar que pode ser nulo, especialmente para feiras planejadas
  final Map<String, bool?>? presencaExpositores;

  Feira({
    this.id,
    required this.data,
    required this.titulo,
    this.anotacoes = '', // Anotações podem ser opcionais
    this.status = StatusFeira.atual, // Padrão para 'atual'
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
    // Qualquer outro caso, ou se for nulo, consideramos como 'atual'
    return StatusFeira.atual;
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
