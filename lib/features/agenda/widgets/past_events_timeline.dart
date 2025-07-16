// Este arquivo contém apenas o widget PastEventsTimeline extraído de agenda_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/agenda_item.dart';
import '../providers/agenda_provider.dart';

class PastEventsTimeline extends ConsumerWidget {
  const PastEventsTimeline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(pastEventsProvider);
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('Nenhum evento passado encontrado.',
              style: Theme.of(context).textTheme.titleMedium),
        ),
      );
    }
    final year = DateTime.now().year;
    // Agrupar por mês
    final Map<int, List<AgendaItem>> eventsByMonth = {};
    for (final e in events) {
      final m = e.deadline?.month ?? 1;
      eventsByMonth.putIfAbsent(m, () => []).add(e);
    }
    // Estatísticas
    final total = events.length;
    final cancelados = events.where((e) => e.status == TaskStatus.cancelled).length;
    final concluidos = events.where((e) => e.status == TaskStatus.done).length;
    final porTipo = <String, int>{};
    for (final e in events) {
      final tipo = e.type.name;
      porTipo[tipo] = (porTipo[tipo] ?? 0) + 1;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text('Linha do Tempo $year',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  )),
        ),
        // Linha do tempo
        SizedBox(
          height: 120,
          child: Stack(
            children: [
              // Linha principal
              Positioned.fill(
                child: CustomPaint(
                  painter: _TimelinePainter(),
                ),
              ),
              // Pins dos eventos
              ...eventsByMonth.entries.expand((entry) {
                final month = entry.key;
                final items = entry.value;
                final x = (month - 1) / 11.0; // 0 a 1
                return List.generate(items.length, (i) {
                  final color = items[i].status == TaskStatus.done
                      ? AppColors.success
                      : AppColors.error;
                  return AnimatedPositioned(
                    duration: Duration(milliseconds: 600 + i * 100),
                    curve: Curves.easeOutBack,
                    left: 32 + x * (MediaQuery.of(context).size.width - 64),
                    top: 40 + (items[i].id.hashCode % 20).toDouble(),
                    child: Tooltip(
                      message:
                          '${items[i].title}\n${items[i].deadline?.day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year',
                      child: Icon(Icons.location_on,
                          color: color, size: 32),
                    ),
                  );
                });
              }),
              // Meses
              ...List.generate(12, (i) {
                final x = i / 11.0;
                return Positioned(
                  left: 32 + x * (MediaQuery.of(context).size.width - 64) - 12,
                  top: 90,
                  child: Text(
                    _mes(i + 1),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Estatísticas
        Card(
          color: AppColors.lightSurface,
          margin: const EdgeInsets.symmetric(horizontal: 32),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text('Estatísticas dos eventos passados',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        )),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _stat('Total', total, AppColors.primary),
                    _stat('Concluídos', concluidos, AppColors.success),
                    _stat('Cancelados', cancelados, AppColors.error),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  children: porTipo.entries
                      .map((e) => Chip(
                            label: Text('${e.key}: ${e.value}'),
                            backgroundColor: AppColors.primaryLight,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  String _mes(int m) {
    const nomes = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return nomes[m - 1];
  }

  Widget _stat(String label, int value, Color color) {
    return Column(
      children: [
        Text('$value',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: color)),
      ],
    );
  }
}

class _TimelinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    final start = Offset(32, 60);
    final end = Offset(size.width - 32, 60);
    canvas.drawLine(start, end, paint);
    // Pontos dos meses
    for (int i = 0; i < 12; i++) {
      final x = 32 + i / 11.0 * (size.width - 64);
      canvas.drawCircle(Offset(x, 60), 6, paint..color = AppColors.primaryDark);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 