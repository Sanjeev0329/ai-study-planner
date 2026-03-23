import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../onboarding_provider.dart';

class AvailabilityPicker extends ConsumerWidget {
  const AvailabilityPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('When is your exam?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(context: context,
                initialDate: DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now().add(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365)));
            if (picked != null) notifier.setExamDate(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.calendar_today, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(state.examDate == null ? 'Select exam date' : state.examDate.toString().split(' ')[0],
                  style: TextStyle(fontSize: 16, color: state.examDate == null ? AppColors.textGrey : AppColors.textDark)),
            ]),
          ),
        ),
        const SizedBox(height: 32),
        Text('Daily study hours: \${state.dailyHours}h', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Slider(value: state.dailyHours.toDouble(), min: 1, max: 12, divisions: 11,
            activeColor: AppColors.primary, label: '\${state.dailyHours}h',
            onChanged: (v) => notifier.setDailyHours(v.toInt())),
      ]),
    );
  }
}
