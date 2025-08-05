import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NavigationControlsWidget extends StatefulWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final bool canGoPrevious;
  final bool canGoNext;

  const NavigationControlsWidget({
    super.key,
    this.onPrevious,
    this.onNext,
    required this.canGoPrevious,
    required this.canGoNext,
  });

  @override
  State<NavigationControlsWidget> createState() =>
      _NavigationControlsWidgetState();
}

class _NavigationControlsWidgetState extends State<NavigationControlsWidget>
    with TickerProviderStateMixin {
  late AnimationController _previousButtonController;
  late AnimationController _nextButtonController;
  late Animation<double> _previousButtonAnimation;
  late Animation<double> _nextButtonAnimation;

  @override
  void initState() {
    super.initState();
    _previousButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _nextButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _previousButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _previousButtonController,
      curve: Curves.easeInOut,
    ));

    _nextButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _nextButtonController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _previousButtonController.dispose();
    _nextButtonController.dispose();
    super.dispose();
  }

  void _onPreviousPressed() async {
    if (widget.canGoPrevious) {
      await _previousButtonController.forward();
      await _previousButtonController.reverse();
      widget.onPrevious?.call();
    }
  }

  void _onNextPressed() async {
    if (widget.canGoNext) {
      await _nextButtonController.forward();
      await _nextButtonController.reverse();
      widget.onNext?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AnimatedBuilder(
              animation: _previousButtonAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _previousButtonAnimation.value,
                  child: _buildNavigationButton(
                    onPressed: widget.canGoPrevious ? _onPreviousPressed : null,
                    icon: 'arrow_back_ios',
                    label: 'Previous',
                    isEnabled: widget.canGoPrevious,
                  ),
                );
              },
            ),
            Container(
              width: 1,
              height: 6.h,
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
            AnimatedBuilder(
              animation: _nextButtonAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _nextButtonAnimation.value,
                  child: _buildNavigationButton(
                    onPressed: widget.canGoNext ? _onNextPressed : null,
                    icon: 'arrow_forward_ios',
                    label: 'Next',
                    isEnabled: widget.canGoNext,
                    isNext: true,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required VoidCallback? onPressed,
    required String icon,
    required String label,
    required bool isEnabled,
    bool isNext = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: isEnabled
                ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEnabled
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3)
                  : AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: icon,
                color: isEnabled
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline,
                size: 28,
              ),
              SizedBox(height: 1.h),
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: isEnabled
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
