import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fintech_session_guard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fintech_session_guard/features/auth/presentation/bloc/auth_state.dart';
import 'package:fintech_session_guard/features/auth/presentation/pages/login_page.dart';
import 'package:fintech_session_guard/features/auth/presentation/pages/register_page.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_bloc.dart';
import 'package:fintech_session_guard/features/home/presentation/pages/home_page.dart';
import 'package:fintech_session_guard/features/home/presentation/widgets/dashboard_view.dart';
import 'package:fintech_session_guard/features/home/presentation/widgets/transaction_history_view.dart';
import 'package:fintech_session_guard/features/market/domain/entities/instrument_entity.dart';
import 'package:fintech_session_guard/features/market/presentation/pages/instrument_detail_page.dart';
import 'package:fintech_session_guard/features/market/presentation/widgets/market_search_view.dart';

/// Application router with auth-based redirection.
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(AuthBloc authBloc) => GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      // All states that require an authenticated user
      final isAuthenticated =
          authState is AuthAuthenticated ||
          authState is AuthPinStatusLoaded ||
          authState is AuthPinSetSuccess ||
          authState is AuthPinSetFailure;
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/register';

      // Redirect root URL to home
      if (location == '/') return '/home';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/home';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              bool? hasPin;
              String name = '';
              if (authState is AuthAuthenticated) {
                name = authState.user.name.trim().split(' ').first;
              } else if (authState is AuthPinStatusLoaded) {
                hasPin = authState.hasPinConfigured;
              } else if (authState is AuthPinSetSuccess) {
                hasPin = true;
              }
              return HomePage(
                navigationShell: navigationShell,
                hasPinConfigured: hasPin,
                userName: name,
              );
            },
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) {
                  return BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      bool hasPin = true;
                      String name = '';
                      if (authState is AuthAuthenticated) {
                        name = authState.user.name.trim().split(' ').first;
                      } else if (authState is AuthPinStatusLoaded) {
                        hasPin = authState.hasPinConfigured;
                      } else if (authState is AuthPinSetSuccess) {
                        hasPin = true;
                      }
                      return DashboardView(
                        userName: name,
                        hasPinConfigured: hasPin,
                        onHistoryTapped: () => context.go('/history'),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) {
                  return BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      bool hasPin = true;
                      if (authState is AuthPinStatusLoaded) {
                        hasPin = authState.hasPinConfigured;
                      } else if (authState is AuthPinSetSuccess) {
                        hasPin = true;
                      }
                      return MarketSearchView(
                        portfolioBloc: context.read<PortfolioBloc>(),
                        hasPinConfigured: hasPin,
                      );
                    },
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const TransactionHistoryView(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/instrument/:id',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          final instrument = extras?['instrument'] as InstrumentEntity?;
          final hasPinConfigured = extras?['hasPinConfigured'] as bool? ?? true;
          final portfolioBloc = extras?['portfolioBloc'] as PortfolioBloc?;
          if (instrument == null) return const HomePageRedirect();
          final page = InstrumentDetailPage(
            instrument: instrument,
            hasPinConfigured: hasPinConfigured,
          );
          if (portfolioBloc != null) {
            return BlocProvider<PortfolioBloc>.value(
              value: portfolioBloc,
              child: page,
            );
          }
          return page;
        },
      ),
    ],
  );
}

/// Helper widget to redirect to home if data is missing
class HomePageRedirect extends StatelessWidget {
  const HomePageRedirect({super.key});
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/home'));
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// Converts a Stream into a Listenable for GoRouter refresh.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
