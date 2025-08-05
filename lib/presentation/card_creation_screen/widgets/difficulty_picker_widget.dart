import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DifficultyPickerWidget extends StatelessWidget {
  final String selectedDifficulty;
  final Function(String) onDifficultySelected;

  const DifficultyPickerWidget({
    super.key,
    required this.selectedDifficulty,
    required this.onDifficultySelected,
  });

  final List<Map<String, dynamic>> difficultyLevels = const [
    {"name": "Easy", "color": Color(0xFF10B981), "icon": "sentiment_satisfied"},
    {"name": "Medium", "color": Color(0xFFF59E0B), "icon": "sentiment_neutral"},
    {
      "name": "Hard",
      "color": Color(0xFFDC2626),
      "icon": "sentiment_dissatisfied"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Difficulty Level',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: difficultyLevels.map((difficulty) {
              final isSelected = selectedDifficulty == difficulty["name"];
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      onDifficultySelected(difficulty["name"] as String),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: difficulty == difficultyLevels.last ? 0 : 2.w,
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 3.h, horizontal: 2.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (difficulty["color"] as Color)
                              .withValues(alpha: 0.1)
                          : AppTheme.lightTheme.colorScheme.surface,
                      border: Border.all(
                        color: isSelected
                            ? difficulty["color"] as Color
                            : AppTheme.lightTheme.colorScheme.outline,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        CustomIconWidget(
                          iconName: difficulty["icon"] as String,
                          color: isSelected
                              ? difficulty["color"] as Color
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          size: 6.w,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          difficulty["name"] as String,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? difficulty["color"] as Color
                                : AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
