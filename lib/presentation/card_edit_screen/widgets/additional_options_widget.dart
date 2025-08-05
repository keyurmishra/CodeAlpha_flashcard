import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdditionalOptionsWidget extends StatefulWidget {
  final Map<String, dynamic> flashcard;
  final Function(Map<String, dynamic>) onDuplicate;
  final Function(String) onCategoryChange;
  final Function(int) onDifficultyChange;
  final VoidCallback onDelete;

  const AdditionalOptionsWidget({
    super.key,
    required this.flashcard,
    required this.onDuplicate,
    required this.onCategoryChange,
    required this.onDifficultyChange,
    required this.onDelete,
  });

  @override
  State<AdditionalOptionsWidget> createState() =>
      _AdditionalOptionsWidgetState();
}

class _AdditionalOptionsWidgetState extends State<AdditionalOptionsWidget>
    with TickerProviderStateMixin {
  late AnimationController _deleteAnimationController;
  late Animation<double> _deleteAnimation;

  String _selectedCategory = 'General';
  int _selectedDifficulty = 1;

  final List<String> _categories = [
    'General',
    'Science',
    'History',
    'Mathematics',
    'Language',
    'Geography',
    'Literature',
    'Technology',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.flashcard['category'] as String? ?? 'General';
    _selectedDifficulty = widget.flashcard['difficulty'] as int? ?? 1;

    _deleteAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _deleteAnimation = CurvedAnimation(
      parent: _deleteAnimationController,
      curve: Curves.easeInOut,
    );
  }

  void _showDeleteConfirmation() {
    _deleteAnimationController.forward();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FadeTransition(
        opacity: _deleteAnimation,
        child: AlertDialog(
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'warning',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Delete Card',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
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
              onPressed: () {
                _deleteAnimationController.reverse();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    ).then((_) {
      _deleteAnimationController.reset();
    });
  }

  void _duplicateCard() {
    final duplicatedCard = Map<String, dynamic>.from(widget.flashcard);
    duplicatedCard['question'] = '${duplicatedCard['question']} (Copy)';
    duplicatedCard['id'] = DateTime.now().millisecondsSinceEpoch;
    duplicatedCard['createdAt'] = DateTime.now();

    widget.onDuplicate(duplicatedCard);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Card duplicated successfully',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getDifficultyLabel(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      default:
        return 'Easy';
    }
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 2:
        return AppTheme.warningLight;
      case 3:
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.tertiary;
    }
  }

  @override
  void dispose() {
    _deleteAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title
          Text(
            'Additional Options',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Duplicate Card Button
          Card(
            child: ListTile(
              leading: CustomIconWidget(
                iconName: 'content_copy',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Duplicate Card',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              subtitle: Text(
                'Create a copy of this card for variations',
                style: AppTheme.lightTheme.textTheme.bodySmall,
              ),
              trailing: CustomIconWidget(
                iconName: 'arrow_forward_ios',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
              onTap: _duplicateCard,
            ),
          ),

          SizedBox(height: 2.h),

          // Category Selector
          Card(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'category',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 24,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Category',
                        style: AppTheme.lightTheme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        widget.onCategoryChange(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Difficulty Adjustment
          Card(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'tune',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 24,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Difficulty Level',
                        style: AppTheme.lightTheme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _selectedDifficulty.toDouble(),
                          min: 1,
                          max: 3,
                          divisions: 2,
                          label: _getDifficultyLabel(_selectedDifficulty),
                          onChanged: (value) {
                            setState(() {
                              _selectedDifficulty = value.round();
                            });
                            widget.onDifficultyChange(_selectedDifficulty);
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(_selectedDifficulty)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getDifficultyLabel(_selectedDifficulty),
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: _getDifficultyColor(_selectedDifficulty),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Delete Button
          Container(
            margin: EdgeInsets.symmetric(vertical: 2.h),
            child: OutlinedButton.icon(
              onPressed: _showDeleteConfirmation,
              icon: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 20,
              ),
              label: Text(
                'Delete Card',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
                padding: EdgeInsets.symmetric(vertical: 3.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
