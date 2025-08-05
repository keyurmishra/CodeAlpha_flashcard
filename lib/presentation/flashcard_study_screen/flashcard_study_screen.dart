import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/flashcard_widget.dart';
import './widgets/navigation_controls_widget.dart';
import './widgets/study_header_widget.dart';

class FlashcardStudyScreen extends StatefulWidget {
  const FlashcardStudyScreen({super.key});

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  int _currentIndex = 0;
  bool _isAnimating = false;

  // Mock flashcard data
  final List<Map<String, dynamic>> _flashcards = [
    {
      "id": 1,
      "question": "What is the capital of France?",
      "answer": "Paris is the capital and most populous city of France.",
      "difficulty": "easy",
      "category": "Geography",
      "createdAt": DateTime.now().subtract(const Duration(days: 5)),
      "lastReviewed": DateTime.now().subtract(const Duration(days: 2)),
      "isMarkedDifficult": false,
    },
    {
      "id": 2,
      "question": "What is the chemical symbol for gold?",
      "answer": "Au - derived from the Latin word 'aurum' meaning gold.",
      "difficulty": "medium",
      "category": "Chemistry",
      "createdAt": DateTime.now().subtract(const Duration(days: 3)),
      "lastReviewed": DateTime.now().subtract(const Duration(days: 1)),
      "isMarkedDifficult": true,
    },
    {
      "id": 3,
      "question": "Who wrote the novel '1984'?",
      "answer":
          "George Orwell wrote the dystopian novel '1984', published in 1949.",
      "difficulty": "medium",
      "category": "Literature",
      "createdAt": DateTime.now().subtract(const Duration(days: 7)),
      "lastReviewed": DateTime.now().subtract(const Duration(hours: 12)),
      "isMarkedDifficult": false,
    },
    {
      "id": 4,
      "question": "What is the speed of light in vacuum?",
      "answer":
          "The speed of light in vacuum is approximately 299,792,458 meters per second (c = 3.0 × 10⁸ m/s).",
      "difficulty": "hard",
      "category": "Physics",
      "createdAt": DateTime.now().subtract(const Duration(days: 1)),
      "lastReviewed": null,
      "isMarkedDifficult": false,
    },
    {
      "id": 5,
      "question": "What is the largest planet in our solar system?",
      "answer":
          "Jupiter is the largest planet in our solar system, with a mass greater than all other planets combined.",
      "difficulty": "easy",
      "category": "Astronomy",
      "createdAt": DateTime.now().subtract(const Duration(days: 4)),
      "lastReviewed": DateTime.now().subtract(const Duration(days: 3)),
      "isMarkedDifficult": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    if (_flashcards.isNotEmpty) {
      _currentIndex = 1;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _goToPrevious() async {
    if (_currentIndex > 1 && !_isAnimating) {
      setState(() {
        _isAnimating = true;
      });

      HapticFeedback.lightImpact();

      await _slideController.forward();
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      await _slideController.reverse();

      setState(() {
        _currentIndex--;
        _isAnimating = false;
      });
    }
  }

  void _goToNext() async {
    if (_currentIndex < _flashcards.length && !_isAnimating) {
      setState(() {
        _isAnimating = true;
      });

      HapticFeedback.lightImpact();

      await _slideController.forward();
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      await _slideController.reverse();

      setState(() {
        _currentIndex++;
        _isAnimating = false;
      });
    }
  }

  void _editCard() {
    if (_flashcards.isNotEmpty && _currentIndex > 0) {
      final cardId = _flashcards[_currentIndex - 1]['id'];
      Navigator.pushNamed(
        context,
        '/card-edit-screen',
        arguments: {'cardId': cardId},
      );
    }
  }

  void _deleteCard() {
    if (_flashcards.isNotEmpty && _currentIndex > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Delete Card',
            style: AppTheme.lightTheme.textTheme.titleLarge,
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
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _flashcards.removeAt(_currentIndex - 1);
                  if (_currentIndex > _flashcards.length) {
                    _currentIndex = _flashcards.length;
                  }
                  if (_flashcards.isEmpty) {
                    _currentIndex = 0;
                  }
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Flashcard deleted successfully'),
                    backgroundColor: AppTheme.lightTheme.colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }

  void _markAsDifficult() {
    if (_flashcards.isNotEmpty && _currentIndex > 0) {
      setState(() {
        final card = _flashcards[_currentIndex - 1];
        card['isMarkedDifficult'] =
            !(card['isMarkedDifficult'] as bool? ?? false);
      });

      final isMarked =
          _flashcards[_currentIndex - 1]['isMarkedDifficult'] as bool;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isMarked
                ? 'Card marked as difficult'
                : 'Card unmarked as difficult',
          ),
          backgroundColor: isMarked
              ? AppTheme.warningLight
              : AppTheme.lightTheme.colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                'Study Options',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'shuffle',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Shuffle Cards',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _flashcards.shuffle();
                  _currentIndex = 1;
                });
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'restart_alt',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Restart Session',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 1;
                });
                _pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'folder',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Manage Cards',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/card-management-screen');
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _createCard() {
    Navigator.pushNamed(context, '/card-creation-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          StudyHeaderWidget(
            currentIndex: _currentIndex,
            totalCards: _flashcards.length,
            onSettingsPressed: _openSettings,
          ),
          Expanded(
            child: _flashcards.isEmpty
                ? EmptyStateWidget(onCreateCard: _createCard)
                : SlideTransition(
                    position: _slideAnimation,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index + 1;
                        });
                      },
                      itemCount: _flashcards.length,
                      itemBuilder: (context, index) {
                        return Center(
                          child: FlashcardWidget(
                            flashcard: _flashcards[index],
                            onEdit: _editCard,
                            onDelete: _deleteCard,
                            onMarkDifficult: _markAsDifficult,
                          ),
                        );
                      },
                    ),
                  ),
          ),
          if (_flashcards.isNotEmpty)
            NavigationControlsWidget(
              onPrevious: _goToPrevious,
              onNext: _goToNext,
              canGoPrevious: _currentIndex > 1,
              canGoNext: _currentIndex < _flashcards.length,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createCard,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
