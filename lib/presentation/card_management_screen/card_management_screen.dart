import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bulk_action_bar_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/flashcard_item_widget.dart';
import './widgets/flashcard_preview_modal_widget.dart';
import './widgets/search_bar_widget.dart';

class CardManagementScreen extends StatefulWidget {
  const CardManagementScreen({super.key});

  @override
  State<CardManagementScreen> createState() => _CardManagementScreenState();
}

class _CardManagementScreenState extends State<CardManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<int> _selectedIndices = [];
  bool _isMultiSelectMode = false;
  String _searchQuery = '';
  Map<String, dynamic> _currentFilters = {
    'difficulty': 'All',
    'category': 'All',
    'sortBy': 'Recent',
    'dateRange': null,
  };

  // Mock flashcard data
  final List<Map<String, dynamic>> _allFlashcards = [
    {
      'id': 1,
      'question': 'What is the capital of France?',
      'answer': 'Paris is the capital and most populous city of France.',
      'difficulty': 'Easy',
      'category': 'Geography',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': 2,
      'question': 'Explain the process of photosynthesis',
      'answer':
          'Photosynthesis is the process by which plants use sunlight, water, and carbon dioxide to produce oxygen and energy in the form of sugar.',
      'difficulty': 'Medium',
      'category': 'Science',
      'createdAt': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': 3,
      'question': 'What is the derivative of x²?',
      'answer':
          'The derivative of x² is 2x, using the power rule of differentiation.',
      'difficulty': 'Medium',
      'category': 'Math',
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'id': 4,
      'question': 'Who wrote "Romeo and Juliet"?',
      'answer':
          'William Shakespeare wrote the tragic play "Romeo and Juliet" in the early part of his career.',
      'difficulty': 'Easy',
      'category': 'Literature',
      'createdAt': DateTime.now().subtract(const Duration(days: 7)),
    },
    {
      'id': 5,
      'question': 'What is quantum entanglement?',
      'answer':
          'Quantum entanglement is a physical phenomenon where pairs of particles become interconnected and instantly affect each other regardless of distance.',
      'difficulty': 'Hard',
      'category': 'Science',
      'createdAt': DateTime.now().subtract(const Duration(days: 10)),
    },
    {
      'id': 6,
      'question': 'Conjugate the verb "être" in French',
      'answer':
          'Je suis, tu es, il/elle est, nous sommes, vous êtes, ils/elles sont',
      'difficulty': 'Medium',
      'category': 'Language',
      'createdAt': DateTime.now().subtract(const Duration(days: 12)),
    },
    {
      'id': 7,
      'question': 'What year did World War II end?',
      'answer':
          '1945 - World War II ended on September 2, 1945, with Japan\'s formal surrender.',
      'difficulty': 'Easy',
      'category': 'History',
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
    },
    {
      'id': 8,
      'question': 'Explain the concept of machine learning',
      'answer':
          'Machine learning is a subset of artificial intelligence that enables computers to learn and improve from experience without being explicitly programmed.',
      'difficulty': 'Hard',
      'category': 'Technology',
      'createdAt': DateTime.now().subtract(const Duration(days: 18)),
    },
  ];

  List<Map<String, dynamic>> _filteredFlashcards = [];

  @override
  void initState() {
    super.initState();
    _filteredFlashcards = List.from(_allFlashcards);
    _applyFiltersAndSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFiltersAndSearch() {
    setState(() {
      _filteredFlashcards = _allFlashcards.where((flashcard) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final question = (flashcard['question'] as String).toLowerCase();
          final answer = (flashcard['answer'] as String).toLowerCase();
          final category = (flashcard['category'] as String).toLowerCase();
          final searchLower = _searchQuery.toLowerCase();

          if (!question.contains(searchLower) &&
              !answer.contains(searchLower) &&
              !category.contains(searchLower)) {
            return false;
          }
        }

        // Difficulty filter
        if (_currentFilters['difficulty'] != 'All' &&
            flashcard['difficulty'] != _currentFilters['difficulty']) {
          return false;
        }

        // Category filter
        if (_currentFilters['category'] != 'All' &&
            flashcard['category'] != _currentFilters['category']) {
          return false;
        }

        // Date range filter
        if (_currentFilters['dateRange'] != null) {
          final dateRange = _currentFilters['dateRange'] as DateTimeRange;
          final cardDate = flashcard['createdAt'] as DateTime;
          if (cardDate.isBefore(dateRange.start) ||
              cardDate.isAfter(dateRange.end)) {
            return false;
          }
        }

        return true;
      }).toList();

      // Apply sorting
      _filteredFlashcards.sort((a, b) {
        switch (_currentFilters['sortBy']) {
          case 'Recent':
            return (b['createdAt'] as DateTime)
                .compareTo(a['createdAt'] as DateTime);
          case 'Oldest':
            return (a['createdAt'] as DateTime)
                .compareTo(b['createdAt'] as DateTime);
          case 'A-Z':
            return (a['question'] as String).compareTo(b['question'] as String);
          case 'Z-A':
            return (b['question'] as String).compareTo(a['question'] as String);
          case 'Difficulty':
            final difficultyOrder = {'Easy': 1, 'Medium': 2, 'Hard': 3};
            return (difficultyOrder[a['difficulty']] ?? 0)
                .compareTo(difficultyOrder[b['difficulty']] ?? 0);
          default:
            return 0;
        }
      });
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFiltersAndSearch();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _currentFilters,
        onFiltersApplied: (filters) {
          setState(() {
            _currentFilters = filters;
          });
          _applyFiltersAndSearch();
        },
      ),
    );
  }

  void _toggleMultiSelectMode(int index) {
    setState(() {
      if (!_isMultiSelectMode) {
        _isMultiSelectMode = true;
        _selectedIndices.add(index);
      } else {
        if (_selectedIndices.contains(index)) {
          _selectedIndices.remove(index);
        } else {
          _selectedIndices.add(index);
        }

        if (_selectedIndices.isEmpty) {
          _isMultiSelectMode = false;
        }
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIndices.clear();
      _isMultiSelectMode = false;
    });
  }

  void _deleteSelected() {
    final selectedIds = _selectedIndices
        .map((index) => _filteredFlashcards[index]['id'] as int)
        .toList();

    setState(() {
      _allFlashcards.removeWhere((card) => selectedIds.contains(card['id']));
      _selectedIndices.clear();
      _isMultiSelectMode = false;
    });

    _applyFiltersAndSearch();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${selectedIds.length} flashcard${selectedIds.length > 1 ? 's' : ''} deleted'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
      ),
    );
  }

  void _exportSelected() {
    final selectedCards =
        _selectedIndices.map((index) => _filteredFlashcards[index]).toList();

    final exportData = {
      'flashcards': selectedCards,
      'exportDate': DateTime.now().toIso8601String(),
      'totalCount': selectedCards.length,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

    // In a real app, this would trigger a file download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${selectedCards.length} flashcard${selectedCards.length > 1 ? 's' : ''} exported'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );

    _clearSelection();
  }

  void _showFlashcardPreview(Map<String, dynamic> flashcard) {
    showDialog(
      context: context,
      builder: (context) => FlashcardPreviewModalWidget(
        flashcard: flashcard,
        onEdit: () => _editFlashcard(flashcard),
        onDelete: () => _deleteFlashcard(flashcard),
      ),
    );
  }

  void _editFlashcard(Map<String, dynamic> flashcard) {
    Navigator.pushNamed(context, '/card-edit-screen', arguments: flashcard);
  }

  void _deleteFlashcard(Map<String, dynamic> flashcard) {
    setState(() {
      _allFlashcards.removeWhere((card) => card['id'] == flashcard['id']);
    });
    _applyFiltersAndSearch();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Flashcard deleted'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _allFlashcards.add(flashcard);
            });
            _applyFiltersAndSearch();
          },
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _applyFiltersAndSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isMultiSelectMode ? 'Select Flashcards' : 'Card Management',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: _isMultiSelectMode
            ? IconButton(
                onPressed: _clearSelection,
                icon: CustomIconWidget(
                  iconName: 'close',
                  size: 24,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              )
            : IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'arrow_back',
                  size: 24,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
        actions: [
          if (!_isMultiSelectMode)
            IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/flashcard-study-screen'),
              icon: CustomIconWidget(
                iconName: 'school',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              tooltip: 'Study Mode',
            ),
        ],
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          if (!_isMultiSelectMode)
            SearchBarWidget(
              onSearchChanged: _onSearchChanged,
              onFilterTap: _showFilterBottomSheet,
              searchController: _searchController,
            ),
          Expanded(
            child: _filteredFlashcards.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _refreshData,
                    color: AppTheme.lightTheme.colorScheme.primary,
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        top: 1.h,
                        bottom: _isMultiSelectMode ? 12.h : 2.h,
                      ),
                      itemCount: _filteredFlashcards.length,
                      itemBuilder: (context, index) {
                        final flashcard = _filteredFlashcards[index];
                        final isSelected = _selectedIndices.contains(index);

                        return FlashcardItemWidget(
                          flashcard: flashcard,
                          isSelected: isSelected,
                          onTap: () {
                            if (_isMultiSelectMode) {
                              _toggleMultiSelectMode(index);
                            } else {
                              _showFlashcardPreview(flashcard);
                            }
                          },
                          onEdit: () => _editFlashcard(flashcard),
                          onDelete: () => _deleteFlashcard(flashcard),
                          onSelectionToggle: _isMultiSelectMode
                              ? () => _toggleMultiSelectMode(index)
                              : () => _toggleMultiSelectMode(index),
                        );
                      },
                    ),
                  ),
          ),
          if (_isMultiSelectMode)
            BulkActionBarWidget(
              selectedCount: _selectedIndices.length,
              onDeleteSelected: _deleteSelected,
              onExportSelected: _exportSelected,
              onClearSelection: _clearSelection,
            ),
        ],
      ),
      floatingActionButton: _isMultiSelectMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.pushNamed(context, '/card-creation-screen'),
              icon: CustomIconWidget(
                iconName: 'add',
                size: 24,
                color: Colors.white,
              ),
              label: Text(
                'New Card',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty ||
        _currentFilters['difficulty'] != 'All' ||
        _currentFilters['category'] != 'All' ||
        _currentFilters['dateRange'] != null) {
      return EmptyStateWidget(
        title: 'No Results Found',
        subtitle: 'Try adjusting your search or filters to find flashcards.',
        iconName: 'search_off',
        buttonText: 'Clear Filters',
        onButtonPressed: () {
          setState(() {
            _searchController.clear();
            _searchQuery = '';
            _currentFilters = {
              'difficulty': 'All',
              'category': 'All',
              'sortBy': 'Recent',
              'dateRange': null,
            };
          });
          _applyFiltersAndSearch();
        },
      );
    } else {
      return EmptyStateWidget(
        title: 'No Flashcards Yet',
        subtitle:
            'Create your first flashcard to start studying and boost your learning experience.',
        iconName: 'quiz',
        buttonText: 'Create Flashcard',
        onButtonPressed: () =>
            Navigator.pushNamed(context, '/card-creation-screen'),
      );
    }
  }
}
