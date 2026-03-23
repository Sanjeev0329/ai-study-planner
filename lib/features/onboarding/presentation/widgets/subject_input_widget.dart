import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../onboarding_provider.dart';

class SubjectInputWidget extends ConsumerStatefulWidget {
  const SubjectInputWidget({super.key});
  @override ConsumerState<SubjectInputWidget> createState() => _State();
}

class _State extends ConsumerState<SubjectInputWidget> {
  final _ctrl = TextEditingController();

  void _add() {
    final val = _ctrl.text.trim();
    if (val.isEmpty) return;
    ref.read(onboardingProvider.notifier).addSubject(val);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(onboardingProvider).subjects;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('What subjects are you studying?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Add each subject for your exam.', style: TextStyle(color: AppColors.textGrey)),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: TextField(controller: _ctrl,
              decoration: const InputDecoration(hintText: 'e.g. DBMS, Maths, Physics'),
              onSubmitted: (_) => _add())),
          const SizedBox(width: 10),
          ElevatedButton(onPressed: _add,
              style: ElevatedButton.styleFrom(minimumSize: const Size(56, 52)),
              child: const Icon(Icons.add)),
        ]),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: subjects.map((s) => Chip(
          label: Text(s.name),
          backgroundColor: AppColors.primary.withOpacity(0.1),
          labelStyle: const TextStyle(color: AppColors.primary),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () => ref.read(onboardingProvider.notifier).removeSubject(s.id),
        )).toList()),
      ]),
    );
  }
}
