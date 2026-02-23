import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fintech_session_guard/core/di/injection.dart';
import 'package:fintech_session_guard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fintech_session_guard/features/auth/presentation/bloc/auth_event.dart';
import 'package:fintech_session_guard/features/auth/presentation/bloc/auth_state.dart';
import 'package:fintech_session_guard/features/auth/presentation/widgets/pin_setup_dialog.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_bloc.dart';
import 'package:fintech_session_guard/features/home/presentation/bloc/portfolio_event.dart';
import 'package:fintech_session_guard/core/presentation/widgets/responsive_scaffold.dart';

class HomePage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final bool? hasPinConfigured;
  final String userName;

  const HomePage({
    super.key,
    required this.navigationShell,
    this.hasPinConfigured,
    this.userName = '',
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // We keep local state for updates from AuthBloc
  bool? _localHasPinConfigured;
  String _localUserName = '';

  @override
  void initState() {
    super.initState();
    _localHasPinConfigured = widget.hasPinConfigured;
    _localUserName = widget.userName;
    // Capture name from AuthAuthenticated before PIN sub-states replace it
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && _localUserName.isEmpty) {
      _localUserName = authState.user.name.trim().split(' ').first;
    }
    // Request PIN status after first frame so AuthBloc is available in context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthPinStatusRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<PortfolioBloc>()..add(const PortfolioSummaryRequested()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            setState(
              () => _localUserName = state.user.name.trim().split(' ').first,
            );
          } else if (state is AuthPinStatusLoaded) {
            setState(() => _localHasPinConfigured = state.hasPinConfigured);
          } else if (state is AuthPinSetSuccess) {
            setState(() => _localHasPinConfigured = true);
          }
        },
        child: Builder(
          builder: (context) {
            final currentIndex = widget.navigationShell.currentIndex;
            String title = 'My Portfolio';
            if (currentIndex == 1) title = 'Market Search';
            if (currentIndex == 2) title = 'Transaction History';

            return ResponsiveScaffold(
              title: title,
              currentIndex: currentIndex,
              onIndexChanged: (index) {
                widget.navigationShell.goBranch(
                  index,
                  initialLocation: index == widget.navigationShell.currentIndex,
                );
              },
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                  },
                ),
              ],
              banner: (_localHasPinConfigured == false)
                  ? MaterialBanner(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      backgroundColor: const Color(0xFF7C4B00),
                      leading: const Icon(
                        Icons.lock_outline,
                        color: Colors.amber,
                      ),
                      content: const Text(
                        'Set up a PIN to unlock transactions.',
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => PinSetupDialog.show(context),
                          child: const Text(
                            'SET PIN',
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
              body: widget.navigationShell,
            );
          },
        ),
      ),
    );
  }
}
