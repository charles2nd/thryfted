import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';

import '../config/clerk_config.dart';

/// Wrapper that initializes Clerk and provides authentication context
class ClerkAuthWrapper extends StatelessWidget {
  final Widget child;

  const ClerkAuthWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClerkAuth(
      config: ClerkAuthConfig(
        publishableKey: ClerkConfig.publishableKey,
      ),
      child: child,
    );
  }
}

