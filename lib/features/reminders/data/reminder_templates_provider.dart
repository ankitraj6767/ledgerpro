import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/ledger_models.dart';

/// Built-in reminder message templates. These are app-provided message presets
/// (not user data), available in English, Hindi, and Hinglish.
final reminderTemplatesProvider = Provider<List<ReminderTemplate>>((ref) {
  return const [
    ReminderTemplate(
      id: 'polite-en',
      name: 'Polite English',
      languageCode: 'en',
      body:
          'Hello {{name}}, {{amount}} is pending. Please make the payment when convenient. - {{business_name}}',
    ),
    ReminderTemplate(
      id: 'polite-hi',
      name: 'Polite Hindi',
      languageCode: 'hi',
      body:
          'Namaste {{name}}, {{amount}} pending hai. Kripya payment kar dein. - {{business_name}}',
    ),
    ReminderTemplate(
      id: 'hinglish',
      name: 'Hinglish',
      languageCode: 'hi-IN',
      body:
          'Hi {{name}}, aapka {{amount}} balance pending hai. Payment update kar dein. - {{business_name}}',
    ),
    ReminderTemplate(
      id: 'firm',
      name: 'Firm reminder',
      languageCode: 'en',
      body:
          'Reminder: {{amount}} is overdue. Please clear this payment today. - {{business_name}}',
      firmTone: true,
    ),
  ];
});
