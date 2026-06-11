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

    return Dismissible(
      key: Key(habit.key.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.accent),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: done
                ? AppTheme.secondary.withOpacity(0.12)
                : AppTheme.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: done
                  ? AppTheme.secondary.withOpacity(0.4)
                  : AppTheme.textSecondary.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Text(habit.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: TextStyle(
                        color: done
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        decoration:
                            done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (streak > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '🔥 $streak day streak',
                          style: const TextStyle(
                            color: AppTheme.warning,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: done
                      ? AppTheme.secondary
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done
                        ? AppTheme.secondary
                        : AppTheme.textSecondary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check,
                        color: Colors.white, size: 16)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
