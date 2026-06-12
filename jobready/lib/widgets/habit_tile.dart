import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../theme/app_theme.dart';

class HabitTile extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const HabitTile({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final done = habit.isCompletedToday();
    final streak = habit.currentStreak;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(habit.key.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(isDark ? 0.2 : 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.delete_outline, color: AppTheme.error),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: done
                ? AppTheme.primary.withOpacity(isDark ? 0.12 : 0.06)
                : AppTheme.cardColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: done
                  ? AppTheme.primary.withOpacity(0.3)
                  : AppTheme.dividerColor(context),
              width: 1,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Text(habit.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: TextStyle(
                        color: done
                            ? AppTheme.textSecondary(context)
                            : AppTheme.textPrimary(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: AppTheme.textSecondary(context),
                      ),
                    ),
                    if (streak > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          '🔥 $streak day streak',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: done ? AppGradientCheckbox.gradient : null,
                  color: done ? null : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done
                        ? Colors.transparent
                        : AppTheme.textSecondary(context).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppGradientCheckbox {
  static const LinearGradient gradient = LinearGradient(
    colors: [AppTheme.primary, AppTheme.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
