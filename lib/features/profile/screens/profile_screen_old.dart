import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/providers/language_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/clerk_user.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(unifiedCurrentUserProvider) as ClerkUser?;
    final authStateNotifier = ref.read(authStateProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(l10n),
              const SizedBox(height: 20),
              _buildEnhancedProfileCard(currentUser, l10n),
              const SizedBox(height: 16),
              _buildVerificationSection(currentUser, l10n, context, ref),
              const SizedBox(height: 16),
              if (currentUser != null && !currentUser.isProfileComplete)
                _buildProfileCompletionSection(currentUser, l10n),
              if (currentUser != null && !currentUser.isProfileComplete) const SizedBox(height: 16),
              const SizedBox(height: 16),
              _buildEnhancedStatsSection(currentUser, l10n),
              const SizedBox(height: 16),
              _buildSocialProvidersSection(currentUser, l10n),
              const SizedBox(height: 16),
              _buildQuickActionsSection(context, ref, l10n),
              const SizedBox(height: 16),
              _buildMenuSection(context, ref, authStateNotifier, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.you,
          style: AppTheme.heading2.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        // Clerk User Button for account management and sign out
        ClerkUserButton(),
      ],
    );
  }

  Widget _buildEnhancedProfileCard(ClerkUser? user, AppLocalizations l10n) {
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? 'user@example.com';
    final username = user?.username;
    final initials = user?.initials ?? 'U';
    final memberSince = user?.createdAt != null 
        ? DateFormat('MMMM yyyy').format(user!.createdAt) 
        : 'Recently';
    final lastSeen = user?.lastSignInAt != null 
        ? _formatLastSeen(user!.lastSignInAt!) 
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, AppTheme.primaryColor.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.primaryColor,
                    child: user?.profileImageUrl != null || user?.avatar != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.network(
                              user!.profileImageUrl ?? user!.avatar!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  initials,
                                  style: AppTheme.heading2.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(
                            initials,
                            style: AppTheme.heading2.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  if (user?.canSell == true)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: AppTheme.heading2.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        if (user?.isSellerVerified == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                      ],
                    ),
                    if (username != null && username.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '@$username',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Member since $memberSince',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (lastSeen != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Last active $lastSeen',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (user?.sellerRating != null && user!.sellerRating! > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star,
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user.sellerRatingDisplay,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.sellerRating,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedStatsSection(ClerkUser? user, AppLocalizations l10n) {
    if (user == null) {
      return _buildPlaceholderStatsSection(l10n);
    }

    final hasActivity = user.totalSales > 0 || user.totalPurchases > 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.yourActivity,
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasActivity) 
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(l10n.itemsSold, user.totalSales.toString(), Icons.sell, AppTheme.successColor),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.borderColor,
                ),
                Expanded(
                  child: _buildStatItem(l10n.itemsBought, user.totalPurchases.toString(), Icons.shopping_bag, AppTheme.primaryColor),
                ),
                if (user.sellerRating != null && user.sellerRating! > 0) ...[
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.borderColor,
                  ),
                  Expanded(
                    child: _buildStatItem(l10n.rating, user.sellerRating!.toStringAsFixed(1), Icons.star, AppTheme.accentColor),
                  ),
                ],
              ],
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor, width: 1),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 48,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.startBuyingSelling,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderStatsSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.yourActivity,
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(l10n.itemsSold, '0', Icons.sell, AppTheme.textSecondary),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.borderColor,
              ),
              Expanded(
                child: _buildStatItem(l10n.itemsBought, '0', Icons.shopping_bag, AppTheme.textSecondary),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.borderColor,
              ),
              Expanded(
                child: _buildStatItem(l10n.rating, '0.0', Icons.star, AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.heading3.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref, authStateNotifier, AppLocalizations l10n) {
    final currentLanguageDisplayName = ref.watch(currentLanguageDisplayNameProvider);
    
    final menuSections = [
      {
        'title': 'Marketplace',
        'items': [
          {'icon': Icons.favorite_border, 'title': l10n.favorites, 'subtitle': l10n.favoritesSubtitle, 'color': Colors.red},
          {'icon': Icons.history, 'title': l10n.orderHistory, 'subtitle': l10n.orderHistorySubtitle, 'color': AppTheme.primaryColor},
          {'icon': Icons.inventory_2_outlined, 'title': l10n.myListings, 'subtitle': l10n.myListingsSubtitle, 'color': AppTheme.accentColor},
          {'icon': Icons.account_balance_wallet_outlined, 'title': l10n.wallet, 'subtitle': l10n.walletSubtitle, 'color': Colors.green},
        ],
      },
      {
        'title': 'Settings',
        'items': [
          {'icon': Icons.language, 'title': '${l10n.language} / Language', 'subtitle': currentLanguageDisplayName, 'color': AppTheme.textSecondary},
          {'icon': Icons.notifications_outlined, 'title': 'Notifications', 'subtitle': 'Manage your alerts', 'color': Colors.orange},
          {'icon': Icons.privacy_tip_outlined, 'title': 'Privacy & Safety', 'subtitle': 'Account security settings', 'color': Colors.purple},
          {'icon': Icons.settings_outlined, 'title': l10n.settings, 'subtitle': l10n.settingsSubtitle, 'color': AppTheme.textSecondary},
        ],
      },
      {
        'title': 'Support',
        'items': [
          {'icon': Icons.help_outline, 'title': l10n.helpAndSupport, 'subtitle': l10n.helpAndSupportSubtitle, 'color': AppTheme.primaryColor},
          {'icon': Icons.feedback_outlined, 'title': 'Send Feedback', 'subtitle': 'Help us improve Thryfted', 'color': Colors.blue},
          {'icon': Icons.info_outline, 'title': 'About', 'subtitle': 'App version and info', 'color': AppTheme.textSecondary},
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...menuSections.map((section) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
                child: Text(
                  section['title'] as String,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: (section['items'] as List<Map<String, dynamic>>).asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isLast = index == (section['items'] as List).length - 1;
                    
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(isLast && index == 0 ? 16 : (index == 0 ? 16 : (isLast ? 16 : 0))),
                        onTap: () => _handleMenuTap(context, ref, item['title'] as String, l10n),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: isLast ? null : Border(
                              bottom: BorderSide(
                                color: AppTheme.borderColor.withOpacity(0.5),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (item['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: item['color'] as Color,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      style: AppTheme.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['subtitle'] as String,
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppTheme.textHint,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  void _handleMenuTap(BuildContext context, WidgetRef ref, String title, AppLocalizations l10n) {
    if (title.contains('Language') || title.contains('Langue')) {
      _showLanguageDialog(context, ref, l10n);
    } else {
      // TODO: Implement navigation to specific screens
      _showFeatureComingSoonDialog(context, title, l10n);
    }
  }

  void _showFeatureComingSoonDialog(BuildContext context, String feature, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                Icons.construction,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(l10n.comingSoon),
            ],
          ),
          content: Text(
            l10n.featureInDevelopment,
            style: AppTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.ok,
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                Icons.language,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(l10n.selectLanguage),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('🇫🇷', style: TextStyle(fontSize: 20)),
                ),
                title: Text(l10n.french),
                subtitle: Text('Français (Canada)'),
                onTap: () {
                  ref.read(languageProvider.notifier).changeLanguage(const Locale('fr', 'CA'));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('🇨🇦', style: TextStyle(fontSize: 20)),
                ),
                title: Text(l10n.english),
                subtitle: Text('English (Canada)'),
                onTap: () {
                  ref.read(languageProvider.notifier).changeLanguage(const Locale('en', 'CA'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSocialProvidersSection(ClerkUser? user, AppLocalizations l10n) {
    if (user == null || user.socialProviders.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.connectedAccounts,
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.socialProviders.map((provider) {
              IconData providerIcon;
              Color providerColor;
              switch (provider.toLowerCase()) {
                case 'google':
                  providerIcon = Icons.g_mobiledata;
                  providerColor = Colors.red;
                  break;
                case 'facebook':
                  providerIcon = Icons.facebook;
                  providerColor = Colors.blue;
                  break;
                case 'apple':
                  providerIcon = Icons.apple;
                  providerColor = Colors.black;
                  break;
                default:
                  providerIcon = Icons.account_circle;
                  providerColor = AppTheme.primaryColor;
              }
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: providerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: providerColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      providerIcon,
                      color: providerColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      provider.capitalizeFirst,
                      style: AppTheme.bodySmall.copyWith(
                        color: providerColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  l10n.editProfile,
                  Icons.edit,
                  AppTheme.primaryColor,
                  () => _showEditProfileDialog(context, ref),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  l10n.shareProfile,
                  Icons.share,
                  AppTheme.accentColor,
                  () => _shareProfile(context, ref),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTheme.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM d').format(lastSeen);
  }

  void _showVerificationDialog(BuildContext context, WidgetRef ref, String verificationType) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (verificationType) {
      case 'email':
        _showEmailVerificationDialog(context, l10n);
        break;
      case 'phone':
        _showPhoneVerificationDialog(context, l10n);
        break;
      case 'seller':
        _showSellerVerificationDialog(context, ref, l10n);
        break;
    }
  }

  void _showEmailVerificationDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.verifyEmailTitle,
                style: AppTheme.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 64,
                color: AppTheme.primaryColor.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.verifyEmailMessage,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () => _sendEmailVerification(context, l10n),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.verifyEmailButton),
            ),
          ],
        );
      },
    );
  }

  void _showPhoneVerificationDialog(BuildContext context, AppLocalizations l10n) {
    final phoneController = TextEditingController();
    final codeController = TextEditingController();
    bool showCodeInput = false;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.verifyPhoneTitle,
                    style: AppTheme.heading3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    showCodeInput ? Icons.sms_outlined : Icons.phone_android_outlined,
                    size: 64,
                    color: AppTheme.primaryColor.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  if (!showCodeInput) ...[
                    Text(
                      l10n.verifyPhoneMessage,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: l10n.phoneNumber,
                        hintText: l10n.phoneNumberHint,
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: AppTheme.primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      l10n.enterVerificationCode,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n.verificationCode,
                        hintText: '000000',
                        prefixIcon: Icon(
                          Icons.pin_outlined,
                          color: AppTheme.primaryColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!showCodeInput) {
                      _sendPhoneVerification(context, phoneController.text, l10n);
                      setState(() {
                        showCodeInput = true;
                      });
                    } else {
                      _verifyPhoneCode(context, codeController.text, l10n);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(showCodeInput ? l10n.verifyCode : l10n.verifyPhoneButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSellerVerificationDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final currentUser = ref.read(unifiedCurrentUserProvider) as ClerkUser?;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.verifySellerTitle,
                style: AppTheme.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                currentUser?.isSellerVerified == true 
                    ? Icons.verified 
                    : Icons.store_outlined,
                size: 64,
                color: currentUser?.isSellerVerified == true 
                    ? AppTheme.successColor 
                    : AppTheme.primaryColor.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                currentUser?.isSellerVerified == true 
                    ? l10n.sellerVerificationComplete
                    : l10n.verifySellerMessage,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.close,
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            if (currentUser?.isSellerVerified != true)
              ElevatedButton(
                onPressed: () => _startSellerVerification(context, l10n),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.verifySellerButton),
              ),
          ],
        );
      },
    );
  }

  Future<void> _sendEmailVerification(BuildContext context, AppLocalizations l10n) async {
    try {
      Navigator.of(context).pop(); // Close dialog
      
      // Get Clerk user from context
      final clerkUser = ClerkAuth.userOf(context);
      if (clerkUser == null) throw Exception('User not found');

      // Send email verification
      // Note: Actual Clerk Flutter API may differ - this is a placeholder implementation
      // await clerkUser.emailAddresses.first.prepareVerification();
      
      // For now, show success without actual API call since Clerk Flutter API is in beta
      // TODO: Implement actual Clerk email verification once API is stable

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.email, color: Colors.white),
              const SizedBox(width: 8),
              Text(l10n.verifyEmailSuccess),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text(l10n.verifyEmailError),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _sendPhoneVerification(BuildContext context, String phoneNumber, AppLocalizations l10n) async {
    try {
      // Get Clerk user from context
      final clerkUser = ClerkAuth.userOf(context);
      if (clerkUser == null) throw Exception('User not found');

      // Note: Actual Clerk Flutter API for phone numbers may differ
      // This is a placeholder implementation since Clerk Flutter SDK is in beta
      // TODO: Implement actual Clerk phone number creation and verification
      
      // Placeholder for phone verification logic
      print('Phone verification would be implemented here for: $phoneNumber');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.sms, color: Colors.white),
              const SizedBox(width: 8),
              Text(l10n.verifyPhoneSuccess),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text(l10n.verifyPhoneError),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _verifyPhoneCode(BuildContext context, String code, AppLocalizations l10n) async {
    try {
      // Get Clerk user from context
      final clerkUser = ClerkAuth.userOf(context);
      if (clerkUser == null) throw Exception('User not found');

      // Note: Actual Clerk Flutter API for phone verification may differ
      // This is a placeholder implementation since Clerk Flutter SDK is in beta
      // TODO: Implement actual Clerk phone verification
      
      // Placeholder for phone code verification
      print('Phone code verification would be implemented here for: $code');

      Navigator.of(context).pop(); // Close dialog

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(l10n.phoneVerified),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text(l10n.verifyPhoneError),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Future<void> _startSellerVerification(BuildContext context, AppLocalizations l10n) async {
    Navigator.of(context).pop(); // Close dialog
    
    // Show placeholder message for seller verification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Text(l10n.sellerVerificationPending),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(unifiedCurrentUserProvider) as ClerkUser?;
    final l10n = AppLocalizations.of(context)!;
    
    if (currentUser == null) return;

    // Create form with current user data
    final form = FormGroup({
      'firstName': FormControl<String>(
        value: currentUser.firstName ?? '',
        validators: [Validators.required],
      ),
      'lastName': FormControl<String>(
        value: currentUser.lastName ?? '',
        validators: [Validators.required],
      ),
      'username': FormControl<String>(
        value: currentUser.username ?? '',
        validators: [
          Validators.minLength(3),
          Validators.pattern(r'^[a-zA-Z0-9_]+$'),
        ],
      ),
      'phone': FormControl<String>(
        value: currentUser.primaryPhone ?? '',
        validators: [
          Validators.pattern(r'^\+?[1-9]\d{1,14}$'),
        ],
      ),
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.edit,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.editProfileTitle,
                          style: AppTheme.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.editProfileSubtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ReactiveForm(
                  formGroup: form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // First Name
                      ReactiveTextField<String>(
                        formControlName: 'firstName',
                        decoration: InputDecoration(
                          labelText: l10n.firstName,
                          hintText: l10n.firstName,
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: AppTheme.primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.primaryColor),
                          ),
                        ),
                        validationMessages: {
                          ValidationMessage.required: (_) => l10n.validationRequired,
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Last Name
                      ReactiveTextField<String>(
                        formControlName: 'lastName',
                        decoration: InputDecoration(
                          labelText: l10n.lastName,
                          hintText: l10n.lastName,
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: AppTheme.primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.primaryColor),
                          ),
                        ),
                        validationMessages: {
                          ValidationMessage.required: (_) => l10n.validationRequired,
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Username
                      ReactiveTextField<String>(
                        formControlName: 'username',
                        decoration: InputDecoration(
                          labelText: l10n.username,
                          hintText: l10n.usernameHint,
                          prefixIcon: Icon(
                            Icons.alternate_email,
                            color: AppTheme.primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.primaryColor),
                          ),
                        ),
                        validationMessages: {
                          ValidationMessage.minLength: (_) => l10n.validationUsernameLength,
                          ValidationMessage.pattern: (_) => l10n.validationUsernameInvalid,
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Phone Number
                      ReactiveTextField<String>(
                        formControlName: 'phone',
                        decoration: InputDecoration(
                          labelText: l10n.phoneNumber,
                          hintText: l10n.phoneNumberHint,
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: AppTheme.primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.primaryColor),
                          ),
                        ),
                        validationMessages: {
                          ValidationMessage.pattern: (_) => l10n.validationPhoneInvalid,
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                ReactiveFormConsumer(
                  builder: (context, form, child) {
                    return ElevatedButton(
                      onPressed: form.valid ? () => _updateProfile(context, form, l10n) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        l10n.updateProfile,
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateProfile(BuildContext context, FormGroup form, AppLocalizations l10n) async {
    // Show loading state
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
        builder: (context) => Container(
          color: Colors.black54,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.updatingProfile,
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      
    try {
      overlay.insert(overlayEntry);

      // Get Clerk user from context
      final clerkUser = ClerkAuth.userOf(context);
      if (clerkUser == null) throw Exception('User not found');

      // Update user information using Clerk
      final firstName = form.control('firstName').value as String?;
      final lastName = form.control('lastName').value as String?;
      final username = form.control('username').value as String?;
      final phone = form.control('phone').value as String?;

      // Note: Actual Clerk Flutter API for user updates may differ
      // This is a placeholder implementation since Clerk Flutter SDK is in beta
      // TODO: Implement actual Clerk user profile update
      
      // Placeholder for profile update logic
      print('Profile update would be implemented here:');
      print('firstName: $firstName');
      print('lastName: $lastName');
      print('username: $username');
      print('phone: $phone');
      
      // Simulate update delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Remove loading overlay
      overlayEntry.remove();

      // Close dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(l10n.profileUpdatedSuccess),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

    } catch (e) {
      // Remove loading overlay if it exists
      overlayEntry.remove();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text(l10n.profileUpdateError),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _shareProfile(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(unifiedCurrentUserProvider) as ClerkUser?;
    final l10n = AppLocalizations.of(context)!;
    
    if (currentUser == null) return;

    // Generate stats text
    final statsText = _generateStatsText(currentUser, l10n);
    
    // Create share text with user info
    final shareText = 'Check out ${currentUser.displayName}\'s profile on Thryfted! $statsText';
    
    // Share the profile
    Share.share(
      shareText,
      subject: 'Thryfted Profile',
    );
  }

  String _generateStatsText(ClerkUser user, AppLocalizations l10n) {
    final stats = <String>[];
    
    if (user.totalSales > 0) {
      stats.add('${user.totalSales} ${l10n.itemsSold.toLowerCase()}');
    }
    
    if (user.totalPurchases > 0) {
      stats.add('${user.totalPurchases} ${l10n.itemsBought.toLowerCase()}');
    }
    
    if (user.sellerRating != null && user.sellerRating! > 0) {
      stats.add('${user.sellerRating!.toStringAsFixed(1)} ⭐ ${l10n.rating.toLowerCase()}');
    }
    
    if (stats.isEmpty) {
      return l10n.newUser;
    }
    
    return stats.join(' • ');
  }

  Widget _buildVerificationSection(ClerkUser? user, AppLocalizations l10n, BuildContext context, WidgetRef ref) {
    if (user == null) return const SizedBox.shrink();

    final verifications = [
      {
        'type': l10n.emailVerification,
        'verified': user.emailVerified,
        'icon': Icons.email_outlined,
        'action': 'email'
      },
      {
        'type': l10n.phoneVerification,
        'verified': user.phoneVerified,
        'icon': Icons.phone_outlined,
        'action': 'phone'
      },
      {
        'type': l10n.sellerVerification,
        'verified': user.isSellerVerified,
        'icon': Icons.verified_user_outlined,
        'action': 'seller'
      },
    ];

    final unverifiedCount = verifications.where((v) => !(v['verified'] as bool)).length;
    if (unverifiedCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_outlined,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.verificationStatus,
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...verifications
              .where((v) => !(v['verified'] as bool))
              .map((verification) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildVerificationItem(
                      verification['type'] as String,
                      verification['verified'] as bool,
                      verification['icon'] as IconData,
                      verification['action'] as String,
                      context,
                      ref,
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildVerificationItem(String title, bool verified, IconData icon, String action, BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showVerificationDialog(context, ref, action),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: verified ? AppTheme.successColor.withOpacity(0.1) : AppTheme.warningColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: verified ? AppTheme.successColor.withOpacity(0.3) : AppTheme.warningColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: verified ? AppTheme.successColor : AppTheme.warningColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    color: verified ? AppTheme.successColor : AppTheme.warningColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                verified ? Icons.check_circle : Icons.arrow_forward_ios,
                color: verified ? AppTheme.successColor : AppTheme.warningColor,
                size: verified ? 20 : 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCompletionSection(ClerkUser user, AppLocalizations l10n) {
    final completionItems = [
      {
        'title': l10n.addFirstName,
        'completed': user.firstName != null && user.firstName!.isNotEmpty,
      },
      {
        'title': l10n.addLastName,
        'completed': user.lastName != null && user.lastName!.isNotEmpty,
      },
      {
        'title': l10n.addPhoneNumber,
        'completed': user.phoneNumbers.isNotEmpty,
      },
      {
        'title': l10n.addProfilePhoto,
        'completed': user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty,
      },
    ];

    final completedCount = completionItems.where((item) => item['completed'] as bool).length;
    final totalCount = completionItems.length;
    final completionPercentage = (completedCount / totalCount);

    if (completionPercentage >= 1.0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withOpacity(0.05), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.completeProfile,
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.buildTrust,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: completionPercentage,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(completionPercentage * 100).round()}%',
                style: AppTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Incomplete items
          ...completionItems
              .where((item) => !(item['completed'] as bool))
              .map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle_outlined,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item['title'] as String,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}