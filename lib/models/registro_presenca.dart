// lib/models/registro_presenca.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Enum para padronizar os status de interesse e presença
enum StatusInteresse { pendente, confirmado, recusado }

enum StatusPresenca { pendente, presente, ausente, justificado }

class RegistroPresenca {
  final String nomeExpositor;
  final String categoria;
  final StatusInteresse interesse;
  final bool checkinGps;
  final Timestamp? checkinTimestamp;
  final StatusPresenca presencaFinal;

  RegistroPresenca({
    required this.nomeExpositor,
    required this.categoria,
    this.interesse = StatusInteresse.pendente,
    this.checkinGps = false,
    this.checkinTimestamp,
    this.presencaFinal = StatusPresenca.pendente,
  });

  // Converte de um Mapa (vindo do Firestore) para o nosso objeto
  factory RegistroPresenca.fromMap(Map<String, dynamic> map) {
    return RegistroPresenca(
      nomeExpositor: map['nomeExpositor'] ?? '',
      categoria: map['categoria'] ?? '',
      interesse: StatusInteresse.values.firstWhere(
        (e) => e.name == map['interesse'],
        orElse: () => StatusInteresse.pendente,
      ),
      checkinGps: map['checkinGps'] ?? false,
      checkinTimestamp: map['checkinTimestamp'],
      presencaFinal: StatusPresenca.values.firstWhere(
        (e) => e.name == map['presencaFinal'],
        orElse: () => StatusPresenca.pendente,
      ),
    );
  }

  // Converte nosso objeto para um Mapa (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nomeExpositor': nomeExpositor,
      'categoria': categoria,
      'interesse': interesse.name,
      'checkinGps': checkinGps,
      'checkinTimestamp': checkinTimestamp,
      'presencaFinal': presencaFinal.name,
    };
  }
}
