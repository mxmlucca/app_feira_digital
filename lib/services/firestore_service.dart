import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expositor.dart';
import '../models/feira.dart';
import '../models/usuario.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late final CollectionReference<Expositor> _expositoresRef;
  late final CollectionReference<Feira> _feirasRef;

  FirestoreService() {
    _expositoresRef = _db
        .collection('expositores')
        .withConverter<Expositor>(
          fromFirestore:
              (snapshots, _) =>
                  Expositor.fromMap(snapshots.data()!, snapshots.id),
          toFirestore: (expositor, _) => expositor.toMap(),
        );

    _feirasRef = _db
        .collection('feiras')
        .withConverter<Feira>(
          fromFirestore:
              (snapshots, _) => Feira.fromMap(snapshots.data()!, snapshots.id),
          toFirestore: (evento, _) => evento.toMap(),
        );
  }

  /// Funções de Expositores

  Future<void> setExpositor(Expositor expositor) async {
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

  /// Funções de Feiras

  Future<void> adicionarFeiraEvento(Feira evento) async {
    try {
      await _feirasRef.add(evento);
      print('Evento da feira adicionado com sucesso!');
    } catch (e) {
      print('Erro ao adicionar evento da feira: $e');
      rethrow;
    }
  }

  String getNewFeiraId() {
    return _feirasRef.doc().id;
  }

  Stream<List<Feira>> getFeiraEventos() {
    return _feirasRef.orderBy('data', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<Feira?> getFeiraEventoPorId(String id) async {
    try {
      final docSnapshot = await _feirasRef.doc(id).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
    } catch (e) {
      print('Erro ao obter evento da feira por ID: $e');
    }
    return null;
  }

  Future<void> atualizarFeiraEvento(Feira evento) async {
    if (evento.id == null) {
      print('Erro: ID do evento da feira é nulo. Não é possível atualizar.');
      return;
    }
    try {
      await _feirasRef.doc(evento.id).update(evento.toMap());
      print('Evento da feira atualizado com sucesso!');
    } catch (e) {
      print('Erro ao atualizar evento da feira: $e');
      rethrow;
    }
  }

  Future<void> removerFeiraEvento(String id) async {
    final feiraAtiva = await getFeiraAtual();
    if (feiraAtiva?.id == id) {
      // Se a feira a ser removida é a ativa, limpa a configuração
      await _db.collection('configuracoes').doc('feira_ativa').set({
        'idFeiraAtual': null,
      });
    }
    await _feirasRef.doc(id).delete();
  }

  Future<Feira?> getFeiraAtual() async {
    try {
      final docConfig =
          await _db.collection('configuracoes').doc('feira_ativa').get();

      if (!docConfig.exists || docConfig.data() == null) {
        print("Documento de configuração da feira ativa não encontrado.");
        return null;
      }

      final idFeira = docConfig.data()!['idFeiraAtual'] as String?;

      if (idFeira == null || idFeira.isEmpty) {
        print("Nenhum ID de feira ativa está definido na configuração.");
        return null;
      }

      return await getFeiraEventoPorId(idFeira);
    } catch (e) {
      print('Erro ao buscar feira atual: $e');
      rethrow;
    }
  }

  Future<void> setFeiraAtiva(String novoIdFeira) async {
    try {
      await _db.collection('configuracoes').doc('feira_ativa').set({
        'idFeiraAtual': novoIdFeira,
      });
    } catch (e) {
      print("Erro ao definir a feira ativa: $e");
      rethrow;
    }
  }

  Future<void> finalizarFeiraAtiva(String idFeiraFinalizada) async {
    try {
      // Usamos um WriteBatch para garantir que ambas as operações aconteçam ou nenhuma aconteça.
      final batch = _db.batch();

      // 1. Pega a referência do documento da feira específica
      final feiraRef = _db.collection('feiras').doc(idFeiraFinalizada);
      // Adiciona a operação de atualização do status no batch
      batch.update(feiraRef, {'status': 'finalizada'});

      // 2. Pega a referência do documento de configuração
      final configRef = _db.collection('configuracoes').doc('feira_ativa');
      // Adiciona a operação para limpar o campo no batch
      batch.update(configRef, {'idFeiraAtual': null});

      // Executa as duas operações atomicamente
      await batch.commit();
      print('Feira finalizada e configuração limpa com sucesso!');
    } catch (e) {
      print("Erro ao finalizar a feira de forma atômica: $e");
      rethrow;
    }
  }

  Stream<Feira?> getFeiraAtualStream() {
    return _db
        .collection('configuracoes')
        .doc('feira_ativa')
        .snapshots()
        .asyncMap((doc) async {
          if (!doc.exists || doc.data() == null) return null;
          final idFeira = doc.data()!['idFeiraAtual'] as String?;
          if (idFeira == null || idFeira.isEmpty) return null;
          return await getFeiraEventoPorId(idFeira);
        });
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
