import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_background.dart';

/// In-app privacy policy. Host the same text on a public URL for Play Console.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String policyBody = '''
AI Study Planner ("we", "our", or "the app") respects your privacy.

Information we collect
• Account: email, display name, and authentication data when you sign in (via Firebase Authentication).
• Study data: subjects, exam dates, tasks you create, and progress you mark as complete (stored in Firebase).
• Device: basic diagnostics may be collected by Firebase/Google services as described in their policies.

How we use your information
• To provide personalized study plans, sync your data across devices, and improve app reliability.
• We do not sell your personal information.

Third-party services
• Google Firebase (Authentication, Cloud Firestore) and Google Sign-In.
• Google Gemini API for AI-generated plans and chat responses. Prompts you send may be processed by Google according to their terms.

Data retention & deletion
• You may delete individual study plans in the app (long-press a plan on the home list). Account deletion may be requested through your Google/Firebase account settings or by contacting support.

Children
• The app is not directed at children under 13. Do not use the service if you are under the age required in your region without parental consent.

Changes
• We may update this policy. Continued use after changes constitutes acceptance.

Contact
• For privacy questions, contact the developer using the support email listed on the Play Store listing.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const Text(
              'Last updated: May 2026',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              policyBody.trim(),
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 15,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
