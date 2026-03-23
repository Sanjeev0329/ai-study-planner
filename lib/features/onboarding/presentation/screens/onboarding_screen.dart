import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../onboarding_provider.dart';
import '../widgets/subject_input_widget.dart';
import '../widgets/availability_picker.dart';
import '../widgets/priority_selector.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pc = PageController();
  int _page = 0;

  void _next() {
    if (_page < 2) {
      _pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      final state = ref.read(onboardingProvider);
      if (state.subjects.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one subject')));
        return;
      }
      if (state.examDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please set your exam date')));
        return;
      }
      Navigator.pushReplacementNamed(context, '/generate');
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['Add Subjects', 'Set Availability', 'Set Priorities'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Step \${_page + 1} of 3: \${labels[_page]}'),
        leading: _page > 0 ? IconButton(icon: const Icon(Icons.arrow_back),
            onPressed: () => _pc.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)) : null,
      ),
      body: Column(children: [
        LinearProgressIndicator(value: (_page + 1) / 3, backgroundColor: Colors.grey.shade200, color: AppColors.primary),
        Expanded(child: PageView(
          controller: _pc,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) => setState(() => _page = i),
          children: const [SubjectInputWidget(), AvailabilityPicker(), PrioritySelector()],
        )),
        Padding(padding: const EdgeInsets.all(20),
            child: CustomButton(label: _page < 2 ? 'Next' : 'Generate My Plan', onPressed: _next)),
      ]),
    );
  }
}
