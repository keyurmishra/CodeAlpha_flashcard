import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PreviewCardWidget extends StatefulWidget {
  final String question;
  final String answer;

  const PreviewCardWidget({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<PreviewCardWidget> createState() => _PreviewCardWidgetState();
}

class _PreviewCardWidgetState extends State<PreviewCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isShowingAnswer = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (!_isShowingAnswer) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() {
      _isShowingAnswer = !_isShowingAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      height: 20.h,
      margin: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Expanded(
            child: GestureDetector(
              onTap: widget.question.isNotEmpty && widget.answer.isNotEmpty
                  ? _flipCard
                  : null,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final isShowingFront = _flipAnimation.value < 0.5;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(_flipAnimation.value * 3.14159),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.lightTheme.colorScheme.shadow
                                .withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isShowingFront) ...[
                              CustomIconWidget(
                                iconName: 'quiz',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 6.w,
                              ),
                              SizedBox(height: 2.h),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    widget.question.isEmpty
                                        ? 'Your question will appear here'
                                        : widget.question,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodyLarge
                                        ?.copyWith(
                                      color: widget.question.isEmpty
                                          ? AppTheme.lightTheme.colorScheme
                                              .onSurfaceVariant
                                              .withValues(alpha: 0.6)
                                          : AppTheme
                                              .lightTheme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ] else ...[
                              Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(3.14159),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'lightbulb',
                                      color: AppTheme
                                          .lightTheme.colorScheme.tertiary,
                                      size: 6.w,
                                    ),
                                    SizedBox(height: 2.h),
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          widget.answer.isEmpty
                                              ? 'Your answer will appear here'
                                              : widget.answer,
                                          style: AppTheme
                                              .lightTheme.textTheme.bodyLarge
                                              ?.copyWith(
                                            color: widget.answer.isEmpty
                                                ? AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                    .withValues(alpha: 0.6)
                                                : AppTheme.lightTheme
                                                    .colorScheme.onSurface,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (widget.question.isNotEmpty &&
                                widget.answer.isNotEmpty) ...[
                              SizedBox(height: 1.h),
                              Text(
                                'Tap to ${isShowingFront ? 'reveal answer' : 'show question'}',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
