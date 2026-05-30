package com.ledgerpro.ledgerpro_mobile

import io.flutter.embedding.android.FlutterFragmentActivity

// local_auth requires the host activity to be a FragmentActivity so the
// AndroidX BiometricPrompt can attach. Using the plain FlutterActivity causes
// authenticate() to throw `no_fragment_activity` and the prompt never shows.
class MainActivity : FlutterFragmentActivity()
