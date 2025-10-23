import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_paint/features/auth/login_screen.dart';
import 'package:simple_paint/features/auth/register_screen.dart';
import 'package:simple_paint/features/home/screens/home_screen.dart';
import 'package:simple_paint/features/splash/splash_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: <RouteBase>[
    GoRoute(
      path: '/splash',
      builder: (BuildContext context, GoRouterState state) => SplashScreen(),
      parentNavigatorKey: _rootNavigatorKey,
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) =>
          const LoginScreen(),
      parentNavigatorKey: _rootNavigatorKey,
      routes: <RouteBase>[
        GoRoute(
          path: 'register',
          builder: (BuildContext context, GoRouterState state) =>
              RegisterScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) => HomeScreen(),
      parentNavigatorKey: _rootNavigatorKey,
    ),
  ],
);
