import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expositor.dart';
import '../models/feira_evento.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late final CollectionReference<Expositor> _expositoresRef;
  late final CollectionReference<FeiraEvento> _feiraEventosRef;

  FirestoreService() {
    _expositoresRef = _db
        .collection('expositores')
        .withConverter<Expositor>(
          fromFirestore:
              (snapshots, _) =>
                  Expositor.fromMap(snapshots.data()!, snapshots.id),
          toFirestore: (expositor, _) => expositor.toMap(),
        );

    _feiraEventosRef = _db
        .collection('feira_eventos')
        .withConverter<FeiraEvento>(
          fromFirestore:
              (snapshots, _) =>
                  FeiraEvento.fromMap(snapshots.data()!, snapshots.id),
          toFirestore: (evento, _) => evento.toMap(),
        );
  }

  // Expositor
  Future<void> adicionarExpositor(Expositor expositor) async {
    try {
      await _expositoresRef.add(expositor);
      print('Expositor adicionado com sucesso!');
    } catch (e) {
      print('Erro ao adicionar expositor: $e');
      rethrow;
    }
  }

  Stream<List<Expositor>> getExpositores() {
    return _expositoresRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<Expositor?> getExpositorPorId(String id) async {
    try {
      final docSnapshot = await _expositoresRef.doc(id).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
    } catch (e) {
      print('Erro ao obter expositor por ID: $e');
    }
    return null;
  }

  Future<void> atualizarExpositor(Expositor expositor) async {
    if (expositor.id == null) {
      print('Erro: ID do expositor é nulo. Não é possível atualizar.');
      return;
    }
    try {
      await _expositoresRef.doc(expositor.id).update(expositor.toMap());
      print('Expositor atualizado com sucesso!');
    } catch (e) {
      print('Erro ao atualizar expositor: $e');
      rethrow;
    }
  }

  Future<void> removerExpositor(String id) async {
    try {
      await _expositoresRef.doc(id).delete();
      print('Expositor removido com sucesso!');
    } catch (e) {
      print('Erro ao remover expositor: $e');
      rethrow;
    }
  }

  // Feira

  Future<void> adicionarFeiraEvento(FeiraEvento evento) async {
    try {
      await _feiraEventosRef.add(evento);
      print('Evento da feira adicionado com sucesso!');
    } catch (e) {
      print('Erro ao adicionar evento da feira: $e');
      rethrow;
    }
  }

  Stream<List<FeiraEvento>> getFeiraEventos() {
    return _feiraEventosRef.orderBy('data', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<FeiraEvento?> getFeiraEventoPorId(String id) async {
    try {
      final docSnapshot = await _feiraEventosRef.doc(id).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
    } catch (e) {
      print('Erro ao obter evento da feira por ID: $e');
    }
    return null;
  }

  Future<void> atualizarFeiraEvento(FeiraEvento evento) async {
    if (evento.id == null) {
      print('Erro: ID do evento da feira é nulo. Não é possível atualizar.');
      return;
    }
    try {
      await _feiraEventosRef.doc(evento.id).update(evento.toMap());
      print('Evento da feira atualizado com sucesso!');
    } catch (e) {
      print('Erro ao atualizar evento da feira: $e');
      rethrow;
    }
  }

  Future<void> removerFeiraEvento(String id) async {
    try {
      await _feiraEventosRef.doc(id).delete();
      print('Evento da feira removido com sucesso!');
    } catch (e) {
      print('Erro ao remover evento da feira: $e');
      rethrow;
    }
  }
}
