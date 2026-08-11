import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'sidebar_nav.dart';
import 'notifications_panel.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const AppShell({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  OverlayEntry? _overlayEntry;

  void _toggleNotificationsPanel() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    } else {
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: 40,
          right: 24,
          child: Material(
            color: Colors.transparent,
            child: TapRegion(
              onTapOutside: (_) => _toggleNotificationsPanel(),
              child: const NotificationsPanel(),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Row(
            children: [
              SidebarNav(currentRoute: widget.currentRoute),
              Container(
                width: 1,
                color: AppColors.border,
              ),
              Expanded(
                child: widget.child,
              ),
            ],
          ),
          Positioned(
            top: 12,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textMuted, size: 22),
              tooltip: 'Notificações',
              onPressed: _toggleNotificationsPanel,
            ),
          ),
        ],
      ),
    );
  }
}
