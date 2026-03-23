import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../progress/progress_provider.dart';

class SubjectPerformanceChart extends ConsumerWidget {
  const SubjectPerformanceChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressMap = ref.watch(derivedProgressProvider);
    if (progressMap.isEmpty) return const Text('No data yet', style: TextStyle(color: AppColors.textGrey));
    final colors = [AppColors.primary, AppColors.easy, AppColors.medium, AppColors.accent, AppColors.secondary];
    final entries = progressMap.entries.toList();
    return Column(children: entries.asMap().entries.map((e) {
      final color = colors[e.key % colors.length];
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          SizedBox(width: 90, child: Text(e.value.key, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: e.value.value, minHeight: 14,
                backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation(color)),
          )),
          const SizedBox(width: 8),
          Text('\${(e.value.value * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
        ]),
      );
    }).toList());
  }
}
