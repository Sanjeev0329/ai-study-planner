# Google Play — release checklist (AI Study Planner)

## Done in this project
- Dark native splash (`launch_background` + `#0F172A`) aligned with Flutter splash
- `INTERNET` + `ACCESS_NETWORK_STATE` in main `AndroidManifest.xml`
- Adaptive launcher icon config in `pubspec.yaml` (`flutter_launcher_icons`)
- In-app **Privacy Policy** screen + link from login; route `/privacy`
- Offline banner via `connectivity_plus` (no interface = offline)
- Global error logging hooks in `main.dart` (debug)
- Chat assistant bubbles use dark surfaces (readable contrast)
- Long-press plan → confirm → delete from Firestore

## Before you upload
1. **Regenerate icons** (after any asset change):  
   `dart run flutter_launcher_icons`
2. **Play Console — Privacy policy URL**  
   Host the same policy text on `https://yourdomain.com/privacy` and paste that URL in Play Console (required). The in-app screen is for users inside the app.
3. **Data safety form**  
   Declare: account data, user-generated content (study plans), Firebase + Google AI processing.
4. **Signing**  
   Use Play App Signing with an upload key; do not commit keystore passwords.
5. **Firestore rules**  
   Ensure `users/{uid}/plans/{planId}` is readable/writable only by `request.auth.uid == uid`, and deletes are allowed for the owner.
6. **API keys**  
   Move Gemini key to remote config or server proxy for production; restrict key by Android package + SHA-1 in Google Cloud Console.
7. **Testing**  
   Run on small/large phones, tablet if you support it, airplane mode, slow network, cold start after kill.

## Suggested next features
- Export plan to PDF or calendar (.ics)
- Reminder notifications for “next session”
- Optional Terms of Use screen
- In-app “Report a problem” with logs (Firebase Crashlytics)
