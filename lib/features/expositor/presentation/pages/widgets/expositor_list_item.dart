import 'package:flutter/material.dart';
import '../../../domain/entities/expositor.dart';

// Supondo que kCoresCategorias está definido aqui ou importado
const Map<String, Color> kCoresCategorias = {
  'Artesanato': Colors.brown,
  'Alimentação': Colors.orange,
  'Bebidas': Colors.blue,
  'Vestuário': Colors.purple,
  'Serviços': Colors.teal,
  'Outros': Colors.grey,
};

class ExpositorListItem extends StatelessWidget {
  final Expositor expositor;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpositorListItem({
    super.key,
    required this.expositor,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final Color corDaCategoria =
        kCoresCategorias[expositor.tipoProdutoServico] ?? Colors.grey;
    final theme = Theme.of(context);
    final Color corTextoPrincipalNoCard =
        theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87;

    // Ajustes para diminuir o tamanho
    const double paddingInternoCard = 8.0; // Diminuir o padding geral
    const double raioAvatar = 22.0; // Diminuir o raio do avatar
    const double fontSizeNumeroEstande = 12.0; // Diminuir fonte do estande
    const double fontSizeNome = 15.0; // Diminuir fonte do nome
    const double fontSizeCategoriaSituacao =
        12.0; // Diminuir fonte da categoria/situação
    const double fontSizeDescricao = 11.0; // Diminuir fonte da descrição
    const int maxLinesDescricao = 1; // Mostrar menos linhas da descrição
    const double espacamentoVerticalPequeno =
        2.0; // Diminuir espaçamentos verticais
    const double larguraColunaAvatar =
        50.0; // Diminuir largura da coluna do avatar
    const double larguraColunaAcoes =
        70.0; // Diminuir largura da coluna de ações
    const double iconButtonSize = 20.0; // Diminuir tamanho dos ícones de ação

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: paddingInternoCard,
            vertical: paddingInternoCard - 2,
          ), // Padding ajustado
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Coluna 1: Círculo com Número do Estande
              SizedBox(
                width: larguraColunaAvatar,
                child: Center(
                  child: CircleAvatar(
                    radius: raioAvatar,
                    backgroundColor: corDaCategoria,
                    foregroundColor: Colors.white,
                    child: Text(
                      expositor.numeroEstande != null &&
                              expositor.numeroEstande!.isNotEmpty
                          ? expositor.numeroEstande!
                          : 'S/N',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizeNumeroEstande,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8), // Espaçamento menor
              // Coluna 2: Nome, Categoria, Situação e Descrição
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3, // Ajuste o flex conforme necessário
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            expositor.nome,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizeNome, // Aplicando novo tamanho
                              color: corTextoPrincipalNoCard,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: espacamentoVerticalPequeno),
                          Text(
                            'Categoria: ${expositor.tipoProdutoServico}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: corTextoPrincipalNoCard.withOpacity(0.7),
                              fontSize:
                                  fontSizeCategoriaSituacao, // Aplicando novo tamanho
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (expositor.situacao != null &&
                              expositor.situacao!.isNotEmpty) ...[
                            const SizedBox(
                              height: espacamentoVerticalPequeno / 2,
                            ),
                            Text(
                              'Situação: ${expositor.situacao}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: corTextoPrincipalNoCard.withOpacity(0.6),
                                fontSize:
                                    fontSizeCategoriaSituacao -
                                    1, // Um pouco menor
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Sub-Coluna para Descrição (se houver)
                    if (expositor.descricao.isNotEmpty)
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 1.0,
                          ), // Ajuste fino para alinhar com o nome
                          child: Text(
                            expositor.descricao,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: corTextoPrincipalNoCard.withOpacity(0.8),
                              fontSize:
                                  fontSizeDescricao, // Aplicando novo tamanho
                            ),
                            maxLines: maxLinesDescricao,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Coluna 3: Botões de Ação
              if (onEdit != null || onDelete != null)
                SizedBox(
                  width: larguraColunaAcoes,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: Icon(
                            Icons.edit_note,
                            color: theme.colorScheme.primary,
                          ),
                          tooltip: 'Editar',
                          iconSize: iconButtonSize,
                          padding: const EdgeInsets.all(2), // Padding mínimo
                          constraints: const BoxConstraints(),
                          onPressed: onEdit,
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: theme.colorScheme.error,
                          ),
                          tooltip: 'Remover',
                          iconSize: iconButtonSize,
                          padding: const EdgeInsets.all(2), // Padding mínimo
                          constraints: const BoxConstraints(),
                          onPressed: onDelete,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
