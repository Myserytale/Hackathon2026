import 'package:flutter/material.dart';
import '../theme/roeid_theme.dart';

class RoeidAuthLayout extends StatelessWidget {
  const RoeidAuthLayout({
    super.key,
    required this.child,
    this.footer,
  });

  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final brand = context.roeid.config;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      body: Row(
        children: [
          if (wide) Expanded(flex: 5, child: _BrandPanel(config: brand)),
          Expanded(
            flex: wide ? 4 : 1,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!wide) ...[
                        _MobileBrandHeader(config: brand),
                        const SizedBox(height: 24),
                      ],
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: child,
                        ),
                      ),
                      if (footer != null) ...[
                        const SizedBox(height: 16),
                        footer!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.config});

  final RoeidPortalConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [config.primaryDark, config.primary],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RoeidWordmark(light: true),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  config.badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Icon(config.icon, size: 56, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                config.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                config.subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Digital Romania · Unified Agriculture Registry',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 13,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileBrandHeader extends StatelessWidget {
  const _MobileBrandHeader({required this.config});

  final RoeidPortalConfig config;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _RoeidWordmark(light: false),
        const SizedBox(height: 16),
        Icon(config.icon, size: 48, color: config.primary),
        const SizedBox(height: 8),
        Text(
          config.title,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          config.subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RoeidWordmark extends StatelessWidget {
  const _RoeidWordmark({required this.light});

  final bool light;

  @override
  Widget build(BuildContext context) {
    final color = light ? Colors.white : RoeidTheme.textPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.verified_user_rounded, color: color, size: 22),
        const SizedBox(width: 8),
        Text(
          'ROeID',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class RoeidPortalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RoeidPortalAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final brand = context.roeid.config;
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 8,
            height: 24,
            decoration: BoxDecoration(
              color: brand.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      actions: actions,
    );
  }
}

class RoeidActionTile extends StatelessWidget {
  const RoeidActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.accent,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? context.roeid.primary;
    return Material(
      color: surfaceWithAlpha(color, 0.08),
      borderRadius: BorderRadius.circular(RoeidTheme.radiusCard),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(RoeidTheme.radiusCard),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RoeidTheme.radiusCard),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: color),
              const SizedBox(width: 14),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color surfaceWithAlpha(Color c, double opacity) {
    return Color.alphaBlend(c.withValues(alpha: opacity), RoeidTheme.surface);
  }
}

class RoeidStatusBadge extends StatelessWidget {
  const RoeidStatusBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final brand = context.roeid.config;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: brand.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brand.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: brand.primaryDark,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
