import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expositor.dart';
import '../models/feira_evento.dart';
import '../models/usuario.dart';

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

  /// Cria ou atualiza os dados de um Expositor com um ID específico.
  Future<void> setExpositor(Expositor expositor) async {
    // O ID do expositor DEVE ser o UID do Firebase Auth.
    if (expositor.id == null) {
      throw Exception(
        'ID do expositor (UID) não pode ser nulo ao usar setExpositor.',
      );
    }
    try {
      await _db
          .collection('expositores')
          .doc(expositor.id)
          .set(expositor.toMap());
      print(
        'Dados do expositor salvos com sucesso para o UID: ${expositor.id}',
      );
    } catch (e) {
      print("Erro ao definir dados do expositor: $e");
      rethrow;
    }
  }

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

  // --- Operações para Usuários ---

  /// Busca os dados de um utilizador no Firestore a partir do seu UID.
  /// Retorna um objeto [Usuario] se encontrado, senão retorna null.
  Future<Usuario?> getUsuario(String uid) async {
    try {
      final docSnapshot = await _db.collection('usuario').doc(uid).get();
      if (docSnapshot.exists) {
        return Usuario.fromMap(docSnapshot.data()!, docSnapshot.id);
      }
    } catch (e) {
      print("Erro ao buscar dados do utilizador: $e");
    }
    return null;
  }

  /// Cria ou atualiza os dados de um utilizador no Firestore.
  Future<void> setUsuario(Usuario usuario) async {
    try {
      await _db.collection('usuario').doc(usuario.uid).set(usuario.toMap());
    } catch (e) {
      print("Erro ao definir dados do utilizador: $e");
      rethrow;
    }
  }

  /// Aprovação de novos expositores.
  /// Busca todos os expositores com um status específico (ex: 'aguardando_aprovacao').
  Stream<List<Expositor>> getExpositoresPorStatus(String status) {
    return _expositoresRef.where('status', isEqualTo: status).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Atualiza apenas o status de um expositor específico.
  Future<void> atualizarStatusExpositor(
    String id,
    String novoStatus, {
    String? motivo,
  }) {
    try {
      final dadosParaAtualizar = {'status': novoStatus};
      if (motivo != null) {
        dadosParaAtualizar['motivoReprovacao'] = motivo;
      }
      return _expositoresRef.doc(id).update(dadosParaAtualizar);
    } catch (e) {
      print("Erro ao atualizar status do expositor: $e");
      rethrow;
    }
  }
}
