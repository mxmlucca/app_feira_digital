import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../features/expositor/domain/entities/expositor.dart';
import '../features/feira_evento/domain/entities/feira.dart';
import '../features/auth/domain/entities/usuario.dart';
import '../features/feira_evento/domain/entities/configuracao_feira.dart';
import '../features/feira_evento/domain/entities/registro_presenca.dart';

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

  Future<void> registrarInteresseExpositor({
    required String feiraId,
    required Expositor expositor, // Passamos o objeto completo do expositor
    required StatusInteresse novoStatus,
  }) async {
    try {
      // Pega a referência para o documento da feira
      final feiraRef = _db.collection('feiras').doc(feiraId);

      // Cria um novo objeto de registro de presença com os dados do expositor
      // e o novo status de interesse.
      final novoRegistro = RegistroPresenca(
        nomeExpositor: expositor.nome,
        categoria: expositor.tipoProdutoServico,
        interesse: novoStatus,
      );

      // Usa a notação de ponto para criar/atualizar o campo específico
      // do expositor dentro do mapa 'presencaExpositores'.
      // Ex: presencaExpositores.ID_DO_EXPOSITOR = { ...dados... }
      await feiraRef.update({
        'presencaExpositores.${expositor.id}': novoRegistro.toMap(),
      });

      print(
        'Interesse do expositor ${expositor.id} atualizado para $novoStatus na feira $feiraId.',
      );
    } catch (e) {
      print('Erro ao registrar interesse: $e');
      rethrow;
    }
  }

  /// Funções de Feiras

  // --- MÉTODO ATUALIZADO ---
  /// Adiciona um novo evento de feira e automaticamente pré-popula a lista de
  /// presença com todos os expositores ativos no momento da criação.
  Future<void> adicionarFeiraEvento(Feira evento) async {
    try {
      // 1. Buscar todos os expositores com status 'ativo'
      final querySnapshot =
          await _expositoresRef.where('status', isEqualTo: 'ativo').get();
      final todosExpositoresAtivos =
          querySnapshot.docs.map((doc) => doc.data()).toList();

      // 2. Criar o mapa de presença inicial
      final mapaDePresencaInicial = <String, RegistroPresenca>{};
      for (var expositor in todosExpositoresAtivos) {
        if (expositor.id != null) {
          mapaDePresencaInicial[expositor.id!] = RegistroPresenca(
            nomeExpositor: expositor.nome,
            categoria: expositor.tipoProdutoServico,
            // O status de interesse de todos começa como 'pendente'
            interesse: StatusInteresse.pendente,
          );
        }
      }

      // 3. Criar uma nova instância da Feira com a lista de presença pré-populada
      final feiraComPresenca = Feira(
        titulo: evento.titulo,
        data: evento.data,
        anotacoes: evento.anotacoes,
        mapaUrl: evento.mapaUrl,
        status: evento.status, // Será 'agendada' por defeito
        presencaExpositores: mapaDePresencaInicial,
      );

      // 4. Adicionar o novo documento completo ao Firestore
      await _feirasRef.add(feiraComPresenca);
      print(
        'Evento da feira adicionado com sucesso, com ${mapaDePresencaInicial.length} expositores na lista de presença.',
      );
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
      // CORREÇÃO: Use .update() para modificar apenas o campo, preservando os outros.
      await _db.collection('configuracoes').doc('feira_ativa').update({
        'idFeiraAtual': novoIdFeira,
      });
      print('Feira ativa atualizada com sucesso para o ID: $novoIdFeira');
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
    // 1. Escuta as mudanças no documento de configuração
    return _db.collection('configuracoes').doc('feira_ativa').snapshots()
    // 2. Usa switchMap para transformar o stream de configuração em um stream de Feira
    .switchMap((configDoc) {
      if (!configDoc.exists || configDoc.data() == null) {
        // Se não há configuração, retorna um stream que emite apenas null.
        return Stream.value(null);
      }

      final idFeira = configDoc.data()!['idFeiraAtual'] as String?;

      if (idFeira == null || idFeira.isEmpty) {
        // Se o ID for nulo ou vazio, retorna um stream que emite apenas null.
        return Stream.value(null);
      } else {
        // Se houver um ID, retorna um NOVO STREAM que observa
        // em tempo real (.snapshots()) o documento da feira específica.
        return _feirasRef.doc(idFeira).snapshots().map((feiraDoc) {
          return feiraDoc.exists ? feiraDoc.data() : null;
        });
      }
    });
  }

  Future<void> realizarCheckinExpositor({
    required String feiraId,
    required String expositorId,
  }) async {
    try {
      final feiraRef = _db.collection('feiras').doc(feiraId);

      // Usa a notação de ponto para atualizar apenas os campos de check-in
      // do registro de presença do expositor específico.
      await feiraRef.update({
        'presencaExpositores.$expositorId.checkinGps': true,
        'presencaExpositores.$expositorId.checkinTimestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Erro ao realizar check-in: $e');
      rethrow;
    }
  }

  /// Define o status final da presença de um expositor, ação realizada pelo admin.
  Future<void> confirmarPresencaFinal({
    required String feiraId,
    required String expositorId,
    required StatusPresenca statusFinal,
  }) async {
    try {
      final feiraRef = _db.collection('feiras').doc(feiraId);

      // Usa set com merge para garantir que o caminho exista e atualiza o campo.
      await feiraRef.set({
        'presencaExpositores': {
          expositorId: {'presenca_final': statusFinal.name},
        },
      }, SetOptions(merge: true));
    } catch (e) {
      print('Erro ao confirmar presença final: $e');
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

  /// Busca as configurações gerais da feira, como local padrão e ID da feira ativa.
  Future<ConfiguracaoFeira?> getConfiguracaoFeira() async {
    try {
      final doc =
          await _db.collection('configuracoes').doc('feira_ativa').get();
      if (doc.exists && doc.data() != null) {
        return ConfiguracaoFeira.fromMap(doc.data()!);
      }
    } catch (e) {
      print("Erro ao buscar configuração da feira: $e");
    }
    return null;
  }
}
