import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResponsiveAppFrame extends StatelessWidget {
  const ResponsiveAppFrame({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return child;
    }
    return AnimatedBuilder(
      animation: router.routeInformationProvider,
      child: child,
      builder: (context, child) {
        final routePath = router.routeInformationProvider.value.uri.path;
        final delegatePath =
            router.routerDelegate.currentConfiguration.uri.path;
        final path = routePath == '/' ? delegatePath : routePath;
        if (path.startsWith('/admin')) {
          return child!;
        }
        final colors = Theme.of(context).colorScheme;
        return LayoutBuilder(
          builder: (context, constraints) {
            final viewportHeight = MediaQuery.sizeOf(context).height;
            final heightDrivenWidth = (viewportHeight * .62).clamp(
              420.0,
              560.0,
            );
            final availableWidth = math.max(0, constraints.maxWidth - 32);
            final frameWidth = math
                .min(availableWidth, heightDrivenWidth)
                .toDouble();
            return ColoredBox(
              color: colors.surfaceContainerHighest,
              child: Center(
                child: SizedBox(
                  width: frameWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 28),
                      ],
                    ),
                    child: child,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
