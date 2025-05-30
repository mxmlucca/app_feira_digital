class Expositor {
  final String? id;
  final String nome;
  final String contato;
  final String descricao;
  final String tipoProdutoServico;
  final String? numeroEstande;
  final String? situacao;

  Expositor({
    this.id,
    required this.nome,
    required this.contato,
    required this.descricao,
    required this.tipoProdutoServico,
    this.numeroEstande,
    this.situacao,
  });

  factory Expositor.fromMap(Map<String, dynamic> data, String documentId) {
    return Expositor(
      id: documentId,
      nome: data['nome'] ?? '',
      contato: data['contato'] ?? '',
      descricao: data['descricao'] ?? '',
      tipoProdutoServico: data['tipoProdutoServico'] ?? '',
      numeroEstande: data['numeroEstande'],
      situacao: data['situacao'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'contato': contato,
      'descricao': descricao,
      'tipoProdutoServico': tipoProdutoServico,
      'numeroEstande': numeroEstande,
      'situacao': situacao,
    };
  }
}
