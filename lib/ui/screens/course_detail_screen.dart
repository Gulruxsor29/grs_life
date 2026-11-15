import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/learning_content.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/charts.dart';
import '../../providers/learning_provider.dart';
import 'learning_screen.dart' show formatDuration;
import '../../core/widgets/ui_kit.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.courseKey});

  final String courseKey;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  Stopwatch? _stopwatch;
  Timer? _ticker;
  int _elapsedSeconds = 0;

  @override
  void dispose() {
    _ticker?.cancel();
    _stopwatch?.stop();
    super.dispose();
  }

  void _startTimer() {
    _stopwatch = Stopwatch()..start();
    _elapsedSeconds = 0;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds = _stopwatch!.elapsed.inSeconds);
    });
    setState(() {});
  }

  void _pauseTimer() {
    _stopwatch?.stop();
    setState(() {});
  }

  void _resumeTimer() {
    _stopwatch?.start();
    setState(() {});
  }

  Future<void> _finishTimer() async {
    final loc = AppLocalizations.of(context);
    final minutes = _elapsedSeconds ~/ 60;
    _ticker?.cancel();
    _stopwatch?.stop();
    _stopwatch = null;
    setState(() => _elapsedSeconds = 0);
    if (minutes >= 1) {
      await context
          .read<LearningProvider>()
          .addStudyTime(widget.courseKey, minutes, DateTime.now());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.t('learning_minutes_added')} · $minutes')),
        );
      }
    }
  }

  Future<void> _logManualTime() async {
    final loc = AppLocalizations.of(context);
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.t('learning_log_time')),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: loc.t('learning_minutes_hint'),
            suffixText: loc.t('minutes_suffix'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(loc.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(loc.t('save')),
          ),
        ],
      ),
    );
    if (result == null || !mounted) return;
    final minutes = int.tryParse(result.trim()) ?? 0;
    if (minutes <= 0) return;
    await context.read<LearningProvider>().addStudyTime(widget.courseKey, minutes, DateTime.now());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.t('learning_minutes_added')} · $minutes')),
      );
    }
  }

  String _clock(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final learning = context.watch<LearningProvider>();
    final course = CourseCatalog.byKey(widget.courseKey);
    final done = learning.lessonsDoneForCourse(course.key);
    final total = course.lessons.length;
    final minutes = learning.minutesForCourse(course.key);
    final timerRunning = _stopwatch != null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.glowGradient),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      loc.t('course_${course.key}'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Row(
                  children: [
                    RingProgress(
                      progress: total == 0 ? 0 : done / total,
                      size: 84,
                      strokeWidth: 9,
                      colors: [course.color, course.color.withOpacity(0.4)],
                      center: Text(
                        '${total == 0 ? 0 : (done / total * 100).round()}%',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$done / $total ${loc.t('learning_lessons').toLowerCase()}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${loc.t('learning_hours_total')}: ${formatDuration(minutes, loc)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (timerRunning)
                GlassCard(
                  blur: false,
                  radius: 20,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Text(
                        loc.t('learning_timer_elapsed'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _clock(_elapsedSeconds),
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _stopwatch!.isRunning ? _pauseTimer : _resumeTimer,
                              icon: Icon(
                                _stopwatch!.isRunning
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 18,
                              ),
                              label: Text(
                                _stopwatch!.isRunning
                                    ? loc.t('learning_timer_pause')
                                    : loc.t('learning_timer_resume'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GradientButton(
                              label: loc.t('learning_timer_finish'),
                              onTap: _finishTimer,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        label: loc.t('learning_start_timer'),
                        icon: Icons.play_arrow_rounded,
                        onTap: _startTimer,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _logManualTime,
                        icon: const Icon(Icons.add_alarm_rounded, size: 18),
                        label: Text(loc.t('learning_log_time')),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 22),
              SectionHeader(title: loc.t('learning_lessons')),
              if (total > 0 && done == total)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: AppColors.copper, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        loc.t('learning_all_done'),
                        style: const TextStyle(
                          color: AppColors.copper,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              for (var i = 0; i < total; i++) _lessonTile(context, course, i, learning),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lessonTile(
    BuildContext context,
    CourseDef course,
    int index,
    LearningProvider learning,
  ) {
    final loc = AppLocalizations.of(context);
    final isDone = learning.isLessonDone(course.key, index);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        blur: false,
        radius: 18,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: () => learning.toggleLesson(course.key, index, !isDone),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: isDone ? AppColors.brandGradient : null,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? Colors.transparent : course.color.withOpacity(0.6),
                  width: 1.6,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check_rounded, size: 17, color: Colors.white)
                  : Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: course.color,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                course.lessons[index][loc.isUz ? 'uz' : 'ru'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDone ? AppColors.textSecondary : AppColors.textPrimary,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
