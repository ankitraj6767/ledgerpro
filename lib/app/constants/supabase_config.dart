class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://besmkildldztpiowpiit.supabase.co',
  );

  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_tPMj99RCpPsHv68lLntUUg_FVgGR9ay',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}
