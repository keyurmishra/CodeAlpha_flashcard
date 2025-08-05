import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/additional_options_widget.dart';
import './widgets/edit_form_widget.dart';

class CardEditScreen extends StatefulWidget {
  const CardEditScreen({super.key});

  @override
  State<CardEditScreen> createState() => _CardEditScreenState();
}

class _CardEditScreenState extends State<CardEditScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _successAnimationController;
  late Animation<double> _successAnimation;

  Map<String, dynamic> _currentFlashcard = {};
  bool _isLoading = false;

  // Mock flashcard data
  final Map<String, dynamic> _mockFlashcard = {
    'id': 1,
    'question': 'What is the capital of France?',
    'answer': 'Paris is the capital and most populous city of France.',
    'category': 'Geography',
    'difficulty': 2,
    'createdAt': DateTime.now().subtract(const Duration(days: 5)),
    'lastReviewed': DateTime.now().subtract(const Duration(days: 1)),
    'reviewCount': 3,
  };

  @override
  void initState() {
    super.initState();
    _currentFlashcard = Map<String, dynamic>.from(_mockFlashcard);

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));

    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _successAnimation = CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    );

    // Start slide-in animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideAnimationController.forward();
    });
  }

  void _handleUpdate(String question, String answer) async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Update flashcard data
    _currentFlashcard['question'] = question;
    _currentFlashcard['answer'] = answer;
    _currentFlashcard['lastModified'] = DateTime.now();

    // Trigger success animation
    _successAnimationController.forward();

    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = false;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Card updated successfully!',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back after delay
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/flashcard-study-screen');
    }
  }

  void _handleCancel() {
    HapticFeedback.selectionClick();
    Navigator.pushReplacementNamed(context, '/flashcard-study-screen');
  }

  void _handleDuplicate(Map<String, dynamic> duplicatedCard) {
    // In a real app, this would save to database
    HapticFeedback.lightImpact();
  }

  void _handleCategoryChange(String category) {
    setState(() {
      _currentFlashcard['category'] = category;
    });
  }

  void _handleDifficultyChange(int difficulty) {
    setState(() {
      _currentFlashcard['difficulty'] = difficulty;
    });
    HapticFeedback.selectionClick();
  }

  void _handleDelete() async {
    // Haptic warning feedback
    HapticFeedback.heavyImpact();

    setState(() {
      _isLoading = true;
    });

    // Simulate deletion delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'delete',
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Card deleted successfully',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back to study screen
      Navigator.pushReplacementNamed(context, '/flashcard-study-screen');
    }
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Card',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: _handleCancel,
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          if (_isLoading)
            Container(
              margin: EdgeInsets.only(right: 4.w),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Updating card...',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card Info Header
                      Container(
                        margin: EdgeInsets.all(4.w),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.lightTheme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'edit',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 24,
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Editing Flashcard',
                                    style: AppTheme
                                        .lightTheme.textTheme.titleMedium
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Category: ${_currentFlashcard['category']} • Difficulty: ${_getDifficultyLabel(_currentFlashcard['difficulty'] as int)}',
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Edit Form
                      ScaleTransition(
                        scale: _successAnimation,
                        child: EditFormWidget(
                          flashcard: _currentFlashcard,
                          onUpdate: _handleUpdate,
                          onCancel: _handleCancel,
                        ),
                      ),

                      SizedBox(height: 2.h),

                      // Additional Options
                      AdditionalOptionsWidget(
                        flashcard: _currentFlashcard,
                        onDuplicate: _handleDuplicate,
                        onCategoryChange: _handleCategoryChange,
                        onDifficultyChange: _handleDifficultyChange,
                        onDelete: _handleDelete,
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
        ),
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
}
