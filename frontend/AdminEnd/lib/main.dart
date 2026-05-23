import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_shell.dart';
import 'screens/subsidies_queue_screen.dart';
import 'screens/ledger_screen.dart';
import 'screens/statistics_screen.dart';

void main() {
  runApp(const AdminPortalApp());
}

class AdminPortalApp extends StatelessWidget {
  const AdminPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, DataProvider>(
          create: (_) => DataProvider(),
          update: (_, auth, data) => data!..updateToken(auth.user?.token),
        ),
      ],
      child: const AdminPortalRouter(),
    );
  }
}

class AdminPortalRouter extends StatefulWidget {
  const AdminPortalRouter({super.key});

  @override
  State<AdminPortalRouter> createState() => _AdminPortalRouterState();
}

class _AdminPortalRouterState extends State<AdminPortalRouter> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _router = GoRouter(
      initialLocation: '/login',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final auth = authProvider;
        final loggingIn = state.matchedLocation == '/login';

        if (!auth.isAuthenticated) {
          return loggingIn ? null : '/login';
        }

        if (loggingIn) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => DashboardShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const SubsidiesQueueScreen(),
            ),
            GoRoute(
              path: '/ledger',
              builder: (context, state) => const LedgerScreen(),
            ),
            GoRoute(
              path: '/analytics',
              builder: (context, state) => const StatisticsScreen(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'APIA Admin Portal',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
