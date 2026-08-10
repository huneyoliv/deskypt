import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'sidebar_nav.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const AppShell({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Fixed Left Desktop Sidebar
          SidebarNav(currentRoute: currentRoute),

          // Divider Line
          Container(
            width: 1,
            color: AppColors.border,
          ),

          // Main View Content
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
