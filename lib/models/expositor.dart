class Expositor {
  final String? id;
  final String? email;
  final String nome;
  final String contato;
  final String descricao;
  final String tipoProdutoServico;
  final String? numeroEstande;
  final String? situacao;
  final String status;
  final String? motivoReprovacao;

  Expositor({
    this.id,
    this.email,
    required this.nome,
    required this.contato,
    required this.descricao,
    required this.tipoProdutoServico,
    this.numeroEstande,
    this.situacao,
    this.status = 'aguardando_aprovacao',
    this.motivoReprovacao,
  });

  factory Expositor.fromMap(Map<String, dynamic> data, String documentId) {
    return Expositor(
      id: documentId,
      email: data['email'] ?? '',
      nome: data['nome'] ?? '',
      contato: data['contato'] ?? '',
      descricao: data['descricao'] ?? '',
      tipoProdutoServico: data['tipoProdutoServico'] ?? '',
      numeroEstande: data['numeroEstande'],
      situacao: data['situacao'],
      status: data['status'] ?? 'ativo',
      motivoReprovacao: data['motivoReprovacao'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nome': nome,
      'contato': contato,
      'descricao': descricao,
      'tipoProdutoServico': tipoProdutoServico,
      'numeroEstande': numeroEstande,
      'situacao': situacao,
      'status': status,
      'motivoReprovacao': motivoReprovacao,
    };
  }
}
