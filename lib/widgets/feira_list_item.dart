import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/feira.dart'; // Importe o seu modelo FeiraEvento

class FeiraListItem extends StatelessWidget {
  final Feira feiraEvento;
  final bool isAtiva;
  final VoidCallback? onTap;

  const FeiraListItem({
    super.key,
    required this.feiraEvento,
    this.isAtiva = false,
    this.onTap,
  });

  // Função helper para obter a cor e o ícone com base no status da feira
  ({IconData icon, Color color}) _getStatusIconAndColor(
    StatusFeira status,
    BuildContext context,
  ) {
    switch (status) {
      case StatusFeira.atual:
        return (
          icon: Icons.calendar_today_outlined,
          color: Colors.blue.shade700,
        );
      case StatusFeira.finalizada:
        return (icon: Icons.check_circle_outline, color: Colors.green.shade700);
    }
  }

  String _statusParaStringLegivel(StatusFeira status) {
    String name = status.toString().split('.').last;
    if (name.isEmpty) return '';
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final statusStyle = _getStatusIconAndColor(feiraEvento.status, context);
    final theme = Theme.of(context);

    return Card(
      // Adiciona uma borda colorida se a feira for ativa
      shape:
          isAtiva
              ? RoundedRectangleBorder(
                side: BorderSide(
                  color: theme.colorScheme.secondary,
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(10.0),
              )
              : null, // Usa o shape padrão do tema se não for ativa
      child: InkWell(
        // ... (resto do seu código do InkWell)
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // ... (seu ícone de status)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Adiciona um ícone e texto de "ATIVA"
                    if (isAtiva)
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'FEIRA ATIVA',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    if (isAtiva) const SizedBox(height: 4),
                    Text(
                      feiraEvento.titulo,
                      // ...
                    ),
                    // ... (resto da sua coluna de textos)
                  ],
                ),
              ),
              // ...
            ],
          ),
        ),
      ),
    );
  }
}
