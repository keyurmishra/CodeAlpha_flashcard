import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FlashcardPreviewModalWidget extends StatefulWidget {
  final Map<String, dynamic> flashcard;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FlashcardPreviewModalWidget({
    super.key,
    required this.flashcard,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<FlashcardPreviewModalWidget> createState() =>
      _FlashcardPreviewModalWidgetState();
}

class _FlashcardPreviewModalWidgetState
    extends State<FlashcardPreviewModalWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;
  bool _isShowingAnswer = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (!_isShowingAnswer) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {
      _isShowingAnswer = !_isShowingAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 70.h,
          maxWidth: 90.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Flashcard Preview',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      size: 24,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _flipCard,
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
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: isShowingFront
                                      ? AppTheme.lightTheme.colorScheme.surface
                                      : AppTheme.lightTheme.colorScheme
                                          .tertiaryContainer,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme
                                        .lightTheme.colorScheme.outline
                                        .withValues(alpha: 0.2),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme
                                          .lightTheme.colorScheme.shadow
                                          .withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      isShowingFront ? 'Question' : 'Answer',
                                      style: AppTheme
                                          .lightTheme.textTheme.labelLarge
                                          ?.copyWith(
                                        color: isShowingFront
                                            ? AppTheme
                                                .lightTheme.colorScheme.primary
                                            : AppTheme.lightTheme.colorScheme
                                                .tertiary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 3.h),
                                    Expanded(
                                      child: Center(
                                        child: Transform(
                                          alignment: Alignment.center,
                                          transform: Matrix4.identity()
                                            ..rotateY(
                                                isShowingFront ? 0 : 3.14159),
                                          child: Text(
                                            isShowingFront
                                                ? widget.flashcard['question']
                                                    as String
                                                : widget.flashcard['answer']
                                                    as String,
                                            style: AppTheme.lightTheme.textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              height: 1.4,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (isShowingFront)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4.w, vertical: 1.h),
                                        decoration: BoxDecoration(
                                          color: AppTheme.lightTheme.colorScheme
                                              .primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CustomIconWidget(
                                              iconName: 'touch_app',
                                              size: 16,
                                              color: AppTheme.lightTheme
                                                  .colorScheme.primary,
                                            ),
                                            SizedBox(width: 1.w),
                                            Text(
                                              'Tap to reveal answer',
                                              style: AppTheme.lightTheme
                                                  .textTheme.bodySmall
                                                  ?.copyWith(
                                                color: AppTheme.lightTheme
                                                    .colorScheme.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme
                            .lightTheme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'category',
                                      size: 16,
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      widget.flashcard['category'] as String? ??
                                          'General',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'calendar_today',
                                      size: 16,
                                      color: AppTheme.lightTheme.colorScheme
                                          .onSurfaceVariant,
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      _formatDate(widget.flashcard['createdAt']
                                          as DateTime),
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(
                                  widget.flashcard['difficulty'] as String),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.flashcard['difficulty'] as String,
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onEdit();
                            },
                            icon: CustomIconWidget(
                              iconName: 'edit',
                              size: 18,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                            label: Text('Edit'),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showDeleteConfirmation(context),
                            icon: CustomIconWidget(
                              iconName: 'delete',
                              size: 18,
                              color: Colors.white,
                            ),
                            label: Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppTheme.lightTheme.colorScheme.error,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'hard':
        return const Color(0xFFDC2626);
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.error,
              ),
              SizedBox(width: 2.w),
              Text(
                'Delete Flashcard',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this flashcard? This action cannot be undone.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                widget.onDelete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
