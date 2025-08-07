import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    final l10n = AppLocalizations.of(context)!;
    
    int currentIndex = _getCurrentIndex(currentLocation);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home,
                label: l10n.navHome,
                index: 0,
                currentIndex: currentIndex,
                onTap: () => context.go('/home'),
              ),
              _buildNavItem(
                context,
                icon: Icons.search,
                label: l10n.navSearch,
                index: 1,
                currentIndex: currentIndex,
                onTap: () => context.go('/search'),
              ),
              _buildNavItem(
                context,
                icon: Icons.add_circle,
                label: l10n.navSell,
                index: 2,
                currentIndex: currentIndex,
                onTap: () => context.go('/sell'),
                isHighlighted: true,
              ),
              _buildNavItem(
                context,
                icon: Icons.chat_bubble_outline,
                label: l10n.navMessages,
                index: 3,
                currentIndex: currentIndex,
                onTap: () => context.go('/messages'),
              ),
              _buildNavItem(
                context,
                icon: Icons.person,
                label: l10n.navProfile,
                index: 4,
                currentIndex: currentIndex,
                onTap: () => context.go('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    final isSelected = index == currentIndex;
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: isSelected && isHighlighted
                    ? BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      )
                    : null,
                child: Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? isHighlighted
                          ? Colors.white
                          : AppTheme.primaryColor
                      : AppTheme.textHint,
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textHint,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getCurrentIndex(String location) {
    switch (location) {
      case '/home':
        return 0;
      case '/search':
        return 1;
      case '/sell':
        return 2;
      case '/messages':
        return 3;
      case '/profile':
        return 4;
      default:
        return 0;
    }
  }
}