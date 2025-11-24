import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/route_provider.dart';
import '../providers/shift_timer_provider.dart';
import '../../../../shared/widgets/custom_drawer.dart';

/// Pantalla de inicio para conductores
class HomeDriverScreen extends ConsumerWidget {
  const HomeDriverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final routeNotifier = ref.watch(routeNotifierProvider.notifier);

    // Si no hay usuario, no debería llegar aquí, pero por seguridad
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Usuario no encontrado')));
    }

    // Obtener rutas asignadas al conductor
    final assignedRoutes = routeNotifier.getAssignedRoutes(user.email);

    // Escuchar cambios en auth para resetear el timer al cerrar sesión
    ref.listen(authNotifierProvider, (previous, next) {
      if (previous?.user != null && next.user == null) {
        ref.read(shiftTimerProvider.notifier).reset();
      }
    });

    final shiftState = ref.watch(shiftTimerProvider);
    final timerNotifier = ref.read(shiftTimerProvider.notifier);

    // Formatear duración a HH:MM:SS
    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    }

    void showEndShiftDialog(BuildContext context, Duration totalTime) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Jornada Finalizada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Total de tiempo de la jornada:'),
              const SizedBox(height: 16),
              Text(
                formatDuration(totalTime),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                timerNotifier.reset();
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Expanded(
            child: assignedRoutes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.route, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 24),
                          Text(
                            'No hay rutas asignadas',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tienes rutas asignadas en este momento.',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          24.0,
                          16.0,
                          16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rutas Asignadas',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Selecciona una ruta para ver sus detalles',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: assignedRoutes.length,
                          itemBuilder: (context, index) {
                            final route = assignedRoutes[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  child: Icon(
                                    Icons.route,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                ),
                                title: Text(
                                  route.code,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  route.name,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  routeNotifier.selectRoute(route);
                                  context.push('/route-detail');
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
          // Sección del temporizador y botón de jornada
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Cronómetro
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      formatDuration(shiftState.elapsed),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Botón de acción
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        if (shiftState.isRunning) {
                          final totalTime = shiftState.elapsed;
                          timerNotifier.endShift();
                          showEndShiftDialog(context, totalTime);
                        } else {
                          timerNotifier.startShift();
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: shiftState.isRunning
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      icon: Icon(
                        shiftState.isRunning
                            ? Icons.stop_circle_outlined
                            : Icons.play_circle_outline,
                      ),
                      label: Text(
                        shiftState.isRunning
                            ? 'Finalizar Jornada'
                            : 'Iniciar Jornada',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
