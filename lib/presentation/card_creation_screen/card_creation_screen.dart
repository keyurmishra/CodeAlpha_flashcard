import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/answer_input_widget.dart';
import './widgets/category_selector_widget.dart';
import './widgets/difficulty_picker_widget.dart';
import './widgets/preview_card_widget.dart';
import './widgets/question_input_widget.dart';
import './widgets/tags_input_widget.dart';

class CardCreationScreen extends StatefulWidget {
  const CardCreationScreen({super.key});

  @override
  State<CardCreationScreen> createState() => _CardCreationScreenState();
}

class _CardCreationScreenState extends State<CardCreationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _saveAnimationController;
  late Animation<double> _saveScaleAnimation;
  late Animation<Color?> _saveColorAnimation;

  String _selectedCategory = "General";
  String _selectedDifficulty = "Easy";
  List<String> _tags = [];
  bool _isKeyboardVisible = false;

  // Mock flashcard data storage
  final List<Map<String, dynamic>> _flashcards = [
    {
      "id": 1,
      "question": "What is the capital of France?",
      "answer": "Paris is the capital and largest city of France.",
      "category": "Geography",
      "difficulty": "Easy",
      "tags": ["europe", "capitals"],
      "createdAt": DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      "id": 2,
      "question": "What is photosynthesis?",
      "answer":
          "Photosynthesis is the process by which plants use sunlight, water, and carbon dioxide to produce oxygen and energy in the form of sugar.",
      "category": "Science",
      "difficulty": "Medium",
      "tags": ["biology", "plants"],
      "createdAt": DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      "id": 3,
      "question": "Who wrote Romeo and Juliet?",
      "answer":
          "William Shakespeare wrote Romeo and Juliet, one of his most famous tragedies.",
      "category": "Language",
      "difficulty": "Easy",
      "tags": ["literature", "shakespeare"],
      "createdAt": DateTime.now().subtract(const Duration(days: 1)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupKeyboardListener();
    _questionController.addListener(_updatePreview);
    _answerController.addListener(_updatePreview);
  }

  void _setupAnimations() {
    _saveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _saveScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _saveAnimationController,
      curve: Curves.easeInOut,
    ));

    _saveColorAnimation = ColorTween(
      begin: AppTheme.lightTheme.colorScheme.primary,
      end: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.8),
    ).animate(CurvedAnimation(
      parent: _saveAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupKeyboardListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaQuery = MediaQuery.of(context);
      setState(() {
        _isKeyboardVisible = mediaQuery.viewInsets.bottom > 0;
      });
    });
  }

  void _updatePreview() {
    setState(() {});
  }

  bool get _canSave {
    return _questionController.text.trim().isNotEmpty &&
        _answerController.text.trim().isNotEmpty;
  }

  void _handleSave() async {
    if (!_canSave) return;

    // Trigger save animation
    await _saveAnimationController.forward();
    await _saveAnimationController.reverse();

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Create new flashcard
    final newCard = {
      "id": _flashcards.length + 1,
      "question": _questionController.text.trim(),
      "answer": _answerController.text.trim(),
      "category": _selectedCategory,
      "difficulty": _selectedDifficulty,
      "tags": List<String>.from(_tags),
      "createdAt": DateTime.now(),
    };

    // Add to mock data
    _flashcards.insert(0, newCard);

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Flashcard created successfully!',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(4.w),
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back to study screen
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/flashcard-study-screen');
      }
    }
  }

  void _handleCancel() {
    if (_questionController.text.isNotEmpty ||
        _answerController.text.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Discard Changes?',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            content: Text(
              'You have unsaved changes. Are you sure you want to discard them?',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Keep Editing',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(
                  'Discard',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _scrollController.dispose();
    _saveAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: _handleCancel,
          icon: CustomIconWidget(
            iconName: 'close',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        title: Text(
          'Create Flashcard',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: AnimatedBuilder(
              animation: _saveAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _saveScaleAnimation.value,
                  child: TextButton(
                    onPressed: _canSave ? _handleSave : null,
                    style: TextButton.styleFrom(
                      backgroundColor: _canSave
                          ? _saveColorAnimation.value
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.1),
                      foregroundColor: _canSave
                          ? Colors.white
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _canSave
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 2.h),

                // Question Input
                QuestionInputWidget(
                  controller: _questionController,
                  onChanged: (value) => _updatePreview(),
                ),

                SizedBox(height: 3.h),

                // Answer Input
                AnswerInputWidget(
                  controller: _answerController,
                  onChanged: (value) => _updatePreview(),
                ),

                SizedBox(height: 3.h),

                // Preview Card
                PreviewCardWidget(
                  question: _questionController.text,
                  answer: _answerController.text,
                ),

                SizedBox(height: 3.h),

                // Category Selector
                CategorySelectorWidget(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),

                SizedBox(height: 3.h),

                // Difficulty Picker
                DifficultyPickerWidget(
                  selectedDifficulty: _selectedDifficulty,
                  onDifficultySelected: (difficulty) {
                    setState(() {
                      _selectedDifficulty = difficulty;
                    });
                  },
                ),

                SizedBox(height: 3.h),

                // Tags Input
                TagsInputWidget(
                  tags: _tags,
                  onTagsChanged: (tags) {
                    setState(() {
                      _tags = tags;
                    });
                  },
                ),

                SizedBox(height: 5.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
