// lib/models/configuracao_feira.dart

class ConfiguracaoFeira {
  final String? idFeiraAtual;
  final double latitudePadrao;
  final double longitudePadrao;
  final double raioPadraoMetros;

  ConfiguracaoFeira({
    this.idFeiraAtual,
    this.latitudePadrao = 0.0,
    this.longitudePadrao = 0.0,
    this.raioPadraoMetros = 0.0,
  });

  factory ConfiguracaoFeira.fromMap(Map<String, dynamic> map) {
    return ConfiguracaoFeira(
      idFeiraAtual: map['idFeiraAtual'],
      latitudePadrao: (map['latitude_padrao'] as num?)?.toDouble() ?? 0.0,
      longitudePadrao: (map['longitude_padrao'] as num?)?.toDouble() ?? 0.0,
      raioPadraoMetros: (map['raio_padrao_metros'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
