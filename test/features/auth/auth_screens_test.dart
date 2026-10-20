import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ledgerpro_mobile/app/theme/infra_theme.dart';
import 'package:ledgerpro_mobile/core/security/app_lock_service.dart';
import 'package:ledgerpro_mobile/core/security/app_session_controller.dart';
import 'package:ledgerpro_mobile/features/app_lock/presentation/unlock_screen.dart';
import 'package:ledgerpro_mobile/features/auth/data/auth_repository.dart';
import 'package:ledgerpro_mobile/features/auth/presentation/login_screen.dart';
import 'package:ledgerpro_mobile/shared/components/navdream_logo.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _Auth extends Mock implements AuthRepository {}

class _Lock extends Mock implements AppLockService {}

class _Session extends AppSessionController {
  _Session({super.lockService});

  int unlocks = 0;
  int signOuts = 0;

  @override
  void markUnlocked() => unlocks++;

  @override
  Future<void> signOut() async => signOuts++;
}

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  AuthRepository? auth,
  AppSessionController? session,
  Size size = const Size(390, 844),
  double textScale = 1,
  double keyboard = 0,
  GoRouter? router,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  Widget builder(BuildContext context, Widget? child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(textScale),
      viewInsets: EdgeInsets.only(bottom: keyboard),
    ),
    child: child!,
  );
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        if (auth != null) authRepositoryProvider.overrideWithValue(auth),
        if (session != null)
          appSessionControllerProvider.overrideWithValue(session),
      ],
      child: router == null
          ? MaterialApp(
              theme: InfraTheme.light(),
              builder: builder,
              home: screen,
            )
          : MaterialApp.router(
              theme: InfraTheme.light(),
              builder: builder,
              routerConfig: router,
            ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late _Auth auth;
  late _Lock lock;
  late _Session session;

  setUp(() {
    auth = _Auth();
    lock = _Lock();
    when(() => lock.biometricEnabled).thenAnswer((_) async => false);
    session = _Session(lockService: lock);
  });

  tearDown(() => session.dispose());

  testWidgets(
    'switching sign-in methods preserves drafts and password privacy',
    (tester) async {
      await _pump(tester, const LoginScreen());
      expect(tester.widget<NavdreamLogo>(find.byType(NavdreamLogo)).size, 54);
      expect(tester.getSize(find.byType(NavdreamLogo)), const Size(54, 54));
      await tester.enterText(find.byType(TextField), '+919876543210');
      await tester.tap(find.text('Email'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'owner@example.com');
      await tester.enterText(find.byType(TextField).last, 'private-password');
      expect(
        tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isTrue,
      );
      await tester.ensureVisible(find.byTooltip('Show password'));
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isFalse,
      );
      await tester.ensureVisible(find.text('Phone OTP'));
      await tester.tap(find.text('Phone OTP'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '+919876543210',
      );
      await tester.tap(find.text('Email'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'owner@example.com',
      );
    },
  );

  testWidgets(
    'phone OTP still sends the number and navigates to verification',
    (tester) async {
      when(() => auth.sendPhoneOtp(any())).thenAnswer((_) async {});
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
          GoRoute(
            path: '/otp',
            builder: (_, state) =>
                Scaffold(body: Text('Verify ${state.extra}')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await _pump(tester, const LoginScreen(), auth: auth, router: router);
      await tester.enterText(find.byType(TextField), '+919876543210');
      await tester.ensureVisible(find.text('Send OTP'));
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();
      verify(() => auth.sendPhoneOtp('+919876543210')).called(1);
      expect(find.text('Verify +919876543210'), findsOneWidget);
    },
  );

  testWidgets('unavailable SMS falls back to email sign-in', (tester) async {
    when(
      () => auth.sendPhoneOtp(any()),
    ).thenThrow(const AuthException('Phone OTP is not configured'));
    await _pump(tester, const LoginScreen(), auth: auth);
    await tester.ensureVisible(find.text('Send OTP'));
    await tester.tap(find.text('Send OTP'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));
    expect(
      find.text(
        'Phone OTP is not enabled for this project. Please use email sign-in.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('email keyboard submission preserves credential error handling', (
    tester,
  ) async {
    when(
      () => auth.signInWithEmailPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const AuthException('Invalid login credentials'));
    await _pump(tester, const LoginScreen(), auth: auth);
    await tester.tap(find.text('Email'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, ' owner@example.com ');
    await tester.enterText(find.byType(TextField).last, 'secret');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    verify(
      () => auth.signInWithEmailPassword(
        email: 'owner@example.com',
        password: 'secret',
      ),
    ).called(1);
    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });

  testWidgets('pending sign-in prevents duplicate requests and mode changes', (
    tester,
  ) async {
    final pending = Completer<void>();
    when(() => auth.sendPhoneOtp(any())).thenAnswer((_) => pending.future);
    await _pump(tester, const LoginScreen(), auth: auth);
    await tester.ensureVisible(find.text('Send OTP'));
    await tester.tap(find.text('Send OTP'));
    await tester.pump();
    expect(find.text('Sending code…'), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Email'))
          .onPressed,
      isNull,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    verify(() => auth.sendPhoneOtp(any())).called(1);
    pending.completeError(const AuthException('Phone OTP is not configured'));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'wrong PIN clears entry; correct PIN unlocks through the session',
    (tester) async {
      when(() => lock.verifyPin(any())).thenAnswer(
        (invocation) async => invocation.positionalArguments.first == '123456',
      );
      await _pump(tester, const UnlockScreen(), session: session);
      await tester.enterText(find.byType(TextField), '9999');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Incorrect PIN. Please try again.'), findsOneWidget);
      expect(session.unlocks, 0);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await tester.enterText(find.byType(TextField), '123456');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(session.unlocks, 1);
      verify(() => lock.verifyPin('123456')).called(1);
    },
  );

  testWidgets('PIN remains masked, numeric, and limited to eight digits', (
    tester,
  ) async {
    await _pump(tester, const UnlockScreen(), session: session);
    await tester.enterText(find.byType(TextField), '12ab34567890');
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.obscureText, isTrue);
    expect(field.controller!.text, '12345678');
    expect(find.text('Use biometrics'), findsNothing);
  });

  testWidgets('cancelled automatic biometrics can be retried from the button', (
    tester,
  ) async {
    when(() => lock.biometricEnabled).thenAnswer((_) async => true);
    when(() => lock.canUseBiometrics()).thenAnswer((_) async => true);
    var attempts = 0;
    when(
      () => lock.authenticateWithBiometrics(),
    ).thenAnswer((_) async => ++attempts > 1);
    await _pump(tester, const UnlockScreen(), session: session);
    expect(session.unlocks, 0);
    await tester.ensureVisible(find.text('Use biometrics'));
    await tester.tap(find.text('Use biometrics'));
    await tester.pumpAndSettle();
    expect(session.unlocks, 1);
    expect(attempts, 2);
  });

  testWidgets('different account signs out and returns to login', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/unlock',
      routes: [
        GoRoute(path: '/unlock', builder: (_, _) => const UnlockScreen()),
        GoRoute(
          path: '/login',
          builder: (_, _) => const Scaffold(body: Text('Account sign-in')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await _pump(tester, const UnlockScreen(), session: session, router: router);
    await tester.ensureVisible(find.text('Sign in with a different account'));
    await tester.tap(find.text('Sign in with a different account'));
    await tester.pumpAndSettle();
    expect(session.signOuts, 1);
    expect(find.text('Account sign-in'), findsOneWidget);
  });

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(1280, 800),
  ]) {
    testWidgets('entry screens fit $size with large text and keyboard', (
      tester,
    ) async {
      await _pump(
        tester,
        const LoginScreen(),
        size: size,
        textScale: 1.8,
        keyboard: 280,
      );
      await tester.ensureVisible(find.text('Email'));
      await tester.tap(find.text('Email'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Sign in'));
      expect(tester.takeException(), isNull);
      await _pump(
        tester,
        const UnlockScreen(),
        session: session,
        size: size,
        textScale: 1.8,
        keyboard: 280,
      );
      await tester.ensureVisible(find.text('Unlock workspace'));
      expect(tester.takeException(), isNull);
    });
  }
}
