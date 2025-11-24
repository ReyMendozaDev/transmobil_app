import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/ui/login_screen.dart';
import '../../features/auth/presentation/ui/home_driver_screen.dart';
import '../../features/auth/presentation/ui/home_supervisor_screen.dart';
import '../../features/auth/presentation/ui/route_detail_screen.dart';
import '../../features/simulation/presentation/ui/bus_movement_simulation.dart';

/// Configuración del router de la aplicación usando go_router
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      // Si no está autenticado y no está en login, redirigir a login
      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }

      // Si está autenticado y está en login, redirigir a la home correspondiente
      if (isAuthenticated && isLoginRoute) {
        final role = authState.user?.role;
        if (role == 'driver') {
          return '/home-driver';
        } else if (role == 'supervisor') {
          return '/home-supervisor';
        }
      }

      // Si está autenticado y está en la ruta raíz, redirigir a la home correspondiente
      if (isAuthenticated && state.matchedLocation == '/') {
        final role = authState.user?.role;
        if (role == 'driver') {
          return '/home-driver';
        } else if (role == 'supervisor') {
          return '/home-supervisor';
        }
      }

      return null; // No redirigir
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home-driver',
        name: 'home-driver',
        builder: (context, state) => const HomeDriverScreen(),
      ),
      GoRoute(
        path: '/home-supervisor',
        name: 'home-supervisor',
        builder: (context, state) => const HomeSupervisorScreen(),
      ),
      GoRoute(
        path: '/route-detail',
        name: 'route-detail',
        builder: (context, state) => const RouteDetailScreen(),
      ),
      GoRoute(
        path: '/bus-simulation',
        name: 'bus-simulation',
        builder: (context, state) => const BusMovementSimulation(),
      ),
    ],
  );
});
