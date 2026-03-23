import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../onboarding_provider.dart';

class PrioritySelector extends ConsumerStatefulWidget {
  const PrioritySelector({super.key});
  @override
  ConsumerState<PrioritySelector> createState() => _PrioritySelectorState();
}

class _PrioritySelectorState extends ConsumerState<PrioritySelector> {
  final _topicCtrl = TextEditingController();

  @override
  void dispose() {
    _topicCtrl.dispose();
    super.dispose();
  }

  // Add a custom weak topic as a chip
  void _addCustomTopic() {
    final val = _topicCtrl.text.trim();
    if (val.isEmpty) return;
    ref.read(onboardingProvider.notifier).addWeakTopic(val);
    _topicCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Section 1: Toggle difficult subjects ────────
          const Text('Mark difficult subjects',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text(
            'Toggle any subject you find hard — AI will give it extra time.',
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Subject toggle cards
          ...state.subjects.map((s) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: SwitchListTile(
              value: s.isDifficult,
              activeColor: AppColors.hard,
              onChanged: (_) => notifier.toggleDifficult(s.id),
              title: Text(s.name,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(
                s.isDifficult
                    ? 'Marked difficult — extra time allocated'
                    : 'Normal priority',
                style: TextStyle(
                  fontSize: 12,
                  color: s.isDifficult ? AppColors.hard : AppColors.textGrey,
                ),
              ),
              secondary: Icon(
                Icons.book_outlined,
                color: s.isDifficult ? AppColors.hard : AppColors.primary,
              ),
            ),
          )),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // ── Section 2: Add specific weak topics ─────────
          const Text('Add specific weak topics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text(
            'Type exact topics you struggle with — e.g. "SQL Joins", "Normalization", "Recursion".',
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 14),

          // Text field + Add button
          Row(children: [
            Expanded(
              child: CustomTextField(
                hint: 'e.g. SQL Joins, Recursion...',
                controller: _topicCtrl,
                icon: Icons.edit_outlined,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _addCustomTopic,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(56, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ]),

          const SizedBox(height: 14),

          // Weak topic chips
          if (state.weakTopics.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Text(
                'No weak topics added yet. Type above and tap +',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.weakTopics.map((topic) => Chip(
                label: Text(topic,
                    style: const TextStyle(
                        color: AppColors.hard, fontSize: 13)),
                backgroundColor: AppColors.hard.withOpacity(0.08),
                side: const BorderSide(color: AppColors.hard, width: 0.5),
                deleteIcon:
                const Icon(Icons.close, size: 15, color: AppColors.hard),
                onDeleted: () => notifier.removeWeakTopic(topic),
              )).toList(),
            ),

          const SizedBox(height: 12),

          if (state.weakTopics.isNotEmpty)
            Text(
              '${state.weakTopics.length} weak topic(s) added — Gemini will prioritize these.',
              style: const TextStyle(
                  color: AppColors.easy,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
        ],
      ),
    );
  }
}