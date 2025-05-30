import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raintor_test/core/router/app_routes.dart';
import 'package:raintor_test/features/infinite_scroll/view/infinite_scroll.dart';
import 'package:raintor_test/features/signal_r/view/signal_r.dart';

import '../../features/app_components/scaffold/scaffold.dart';

final GoRouter goRouter = GoRouter(
  initialLocation: AppRoutes.signalrRoute,
  errorBuilder: (_, _) => const Center(child: Text('Page not found')),
  routes: <RouteBase>[
    ShellRoute(
      builder: (context, state, child) {
        final path = state.fullPath?.split('/').last.toLowerCase();
        log('ShellRoute Path: $path');
        return KScaffold(path: path, body: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.signalrRoute,
          name: SignalRView.name,
          builder: (_, _) => const SignalRView(),
        ),
        GoRoute(
          path: AppRoutes.infiniteScrollRoute,
          name: InfiniteScrollView.name,
          builder: (_, _) => const InfiniteScrollView(),
        ),
      ],
    ),
  ],
);

extension GoRouteExtension on BuildContext {
  Future goPush<T>(
    String name, {
    Map<String, String> pathParams = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
    String? fragment,
  }) async => await GoRouter.of(
    this,
  ).pushNamed(name, pathParameters: pathParams, queryParameters: queryParams, extra: extra);
}
