import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/learning_content.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/charts.dart';
import '../../providers/learning_provider.dart';
import 'course_detail_screen.dart';
import '../../core/widgets/ui_kit.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final learning = context.watch<LearningProvider>();
    final overall = learning.overallProgress;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            Text(loc.t('learning_title'), style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 16),
            GlassCard(
              child: Row(
                children: [
                  RingProgress(
                    progress: overall,
                    size: 96,
                    strokeWidth: 10,
                    center: Text(
                      '${(overall * 100).round()}%',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.t('learning_overall'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${learning.totalLessonsDone} / ${CourseCatalog.totalLessons} ${loc.t('learning_lessons').toLowerCase()}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${loc.t('learning_hours_total')}: ${formatDuration(learning.totalMinutes, loc)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            for (final course in CourseCatalog.courses) ...[
              _CourseCard(course: course),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

String formatDuration(int minutes, AppLocalizations loc) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h <= 0) return '$m ${loc.t('minutes_suffix')}';
  if (m == 0) return '$h ${loc.t('hours_suffix')}';
  return '$h ${loc.t('hours_suffix')} $m ${loc.t('minutes_suffix')}';
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final CourseDef course;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final learning = context.watch<LearningProvider>();
    final done = learning.lessonsDoneForCourse(course.key);
    final total = course.lessons.length;
    final minutes = learning.minutesForCourse(course.key);

    return GlassCard(
      blur: false,
      radius: 20,
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => CourseDetailScreen(courseKey: course.key)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [course.color.withOpacity(0.35), course.color.withOpacity(0.12)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: course.color.withOpacity(0.35)),
            ),
            child: Icon(course.icon, color: course.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.t('course_${course.key}'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '$done / $total ${loc.t('learning_lessons').toLowerCase()} · $minutes ${loc.t('minutes_suffix')}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                ProgressBar(
                  value: total == 0 ? 0 : done / total,
                  colors: [course.color, course.color.withOpacity(0.5)],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
