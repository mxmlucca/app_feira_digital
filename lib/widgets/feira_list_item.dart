import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/feira_evento.dart'; // Importe o seu modelo FeiraEvento

class FeiraListItem extends StatelessWidget {
  final FeiraEvento feiraEvento;
  final VoidCallback? onTap;

  const FeiraListItem({super.key, required this.feiraEvento, this.onTap});

  // Função helper para obter a cor e o ícone com base no status da feira
  ({IconData icon, Color color}) _getStatusIconAndColor(
    StatusFeira status,
    BuildContext context,
  ) {
    switch (status) {
      case StatusFeira.planejada:
        return (
          icon: Icons.calendar_today_outlined,
          color: Colors.blue.shade700,
        );
      case StatusFeira.proxima:
        return (
          icon: Icons.notifications_active_outlined,
          color: Theme.of(context).colorScheme.secondary,
        );
      case StatusFeira.realizada:
        return (icon: Icons.check_circle_outline, color: Colors.green.shade700);
      case StatusFeira.cancelada:
        return (
          icon: Icons.cancel_outlined,
          color: Theme.of(context).colorScheme.error,
        );
      default:
        return (icon: Icons.help_outline, color: Colors.grey);
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
      // O estilo do Card virá do ThemeData
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          10.0,
        ), // Deve corresponder ao CardTheme
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Ícone de Status
              Icon(statusStyle.icon, color: statusStyle.color, size: 40),
              const SizedBox(width: 16.0),
              // Coluna com Título e Data/Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feiraEvento.titulo,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Data: ${DateFormat('dd/MM/yyyy').format(feiraEvento.data)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'Status: ${_statusParaStringLegivel(feiraEvento.status)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            statusStyle
                                .color, // Usa a mesma cor do ícone para o texto do status
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              // Ícone para indicar que é clicável
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
