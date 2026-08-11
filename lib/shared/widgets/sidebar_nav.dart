import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/cdn/cdn_resolver.dart';
import '../../features/auth/auth_notifier.dart';
import 'studicon_avatar.dart';
import 'flames_badge.dart';

class SidebarNavItemData {
  final String title;
  final String route;
  final IconData fallbackIcon;
  final String? svgAsset;

  const SidebarNavItemData({
    required this.title,
    required this.route,
    required this.fallbackIcon,
    this.svgAsset,
  });
}

class SidebarNav extends ConsumerWidget {
  final String currentRoute;

  const SidebarNav({
    super.key,
    required this.currentRoute,
  });

  static const items = [
    SidebarNavItemData(
      title: 'Cronômetro',
      route: '/home',
      fallbackIcon: Icons.timer,
      svgAsset: 'assets/icons/bottom_home_fill.svg',
    ),
    SidebarNavItemData(
      title: 'Grupos',
      route: '/groups',
      fallbackIcon: Icons.group,
      svgAsset: 'assets/icons/bottom_group_fill.svg',
    ),
    SidebarNavItemData(
      title: 'Planner',
      route: '/planner',
      fallbackIcon: Icons.calendar_today,
      svgAsset: 'assets/icons/bottom_calendar.svg',
    ),
    SidebarNavItemData(
      title: 'Rankings',
      route: '/ranks',
      fallbackIcon: Icons.leaderboard,
    ),
    SidebarNavItemData(
      title: 'Loja Studicons',
      route: '/store',
      fallbackIcon: Icons.storefront,
    ),
    SidebarNavItemData(
      title: 'Ruído Branco',
      route: '/music',
      fallbackIcon: Icons.graphic_eq,
    ),
    SidebarNavItemData(
      title: 'Desafios',
      route: '/challenges',
      fallbackIcon: Icons.emoji_events_outlined,
    ),
    SidebarNavItemData(
      title: 'Perfil',
      route: '/profile',
      fallbackIcon: Icons.person_outline,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;

    return Container(
      width: 240,
      color: AppColors.surface,
      child: Column(
        children: [
          // Header: Logo & User Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/icons/splash_logo.png',
                      height: 28,
                      errorBuilder: (_, __, ___) => const Text(
                        'DeskYPT',
                        style: AppTextStyles.titleMedium,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'DeskYPT',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontPretendard,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    StudiconAvatar(
                      studiconId: user?.studiconId ?? -1,
                      pose: StudiconPose.mini,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Estudante',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Online',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Middle: Nav Links List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = currentRoute == item.route;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => context.go(item.route),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.5))
                              : null,
                        ),
                        child: Row(
                          children: [
                            if (item.svgAsset != null)
                              SvgPicture.asset(
                                item.svgAsset!,
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  BlendMode.srcIn,
                                ),
                              )
                            else
                              Icon(
                                item.fallbackIcon,
                                size: 20,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                            const SizedBox(width: 14),
                            Text(
                              item.title,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer: Flames Badge & Logout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const FlamesBadge(count: 100),
                IconButton(
                  icon: const Icon(Icons.logout_rounded,
                      color: AppColors.textMuted, size: 20),
                  tooltip: 'Sair',
                  onPressed: () {
                    ref.read(authStateProvider.notifier).logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
