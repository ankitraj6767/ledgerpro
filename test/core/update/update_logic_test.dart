import 'package:flutter_test/flutter_test.dart';
import 'package:ledgerpro_mobile/core/update/update_manifest.dart';
import 'package:ledgerpro_mobile/core/update/update_service.dart';

void main() {
  group('AppVersion.tryParse', () {
    test('parses plain semver', () {
      final v = AppVersion.tryParse('1.2.3');
      expect(v, isNotNull);
      expect(v!.major, 1);
      expect(v.minor, 2);
      expect(v.patch, 3);
      expect(v.build, isNull);
    });

    test('strips leading v and parses build suffix', () {
      final v = AppVersion.tryParse('v1.0.1+3');
      expect(v, isNotNull);
      expect(v!.shortLabel, '1.0.1');
      expect(v.build, 3);
    });

    test('ignores pre-release metadata', () {
      final v = AppVersion.tryParse('2.0.0-beta.1');
      expect(v!.major, 2);
      expect(v.minor, 0);
      expect(v.patch, 0);
    });

    test('returns null for blank or invalid input', () {
      expect(AppVersion.tryParse(null), isNull);
      expect(AppVersion.tryParse(''), isNull);
      expect(AppVersion.tryParse('not-a-version'), isNull);
    });

    test('treats missing minor/patch as zero', () {
      final v = AppVersion.tryParse('3');
      expect(v!.major, 3);
      expect(v.minor, 0);
      expect(v.patch, 0);
    });
  });

  group('AppVersion comparison', () {
    test('orders by major, minor, patch', () {
      expect(AppVersion.tryParse('1.0.0')! < AppVersion.tryParse('1.0.1')!,
          isTrue);
      expect(AppVersion.tryParse('1.2.0')! > AppVersion.tryParse('1.1.9')!,
          isTrue);
      expect(AppVersion.tryParse('2.0.0')! > AppVersion.tryParse('1.9.9')!,
          isTrue);
    });

    test('uses build number as tie-breaker', () {
      final a = AppVersion.from('1.0.1', build: 3)!;
      final b = AppVersion.from('1.0.1', build: 4)!;
      expect(a < b, isTrue);
      expect(b > a, isTrue);
    });

    test('equal versions are not greater than each other', () {
      final a = AppVersion.from('1.0.1', build: 3)!;
      final b = AppVersion.from('1.0.1', build: 3)!;
      expect(a == b, isTrue);
      expect(a > b, isFalse);
      expect(a < b, isFalse);
    });
  });

  group('UpdateService.evaluate', () {
    PlatformRelease release({
      String version = '1.0.2',
      int? build,
      bool mandatory = false,
      String? minSupported,
    }) {
      return PlatformRelease(
        version: version,
        url: 'https://example.com/app.apk',
        buildNumber: build,
        mandatory: mandatory,
        minSupportedVersion: minSupported,
      );
    }

    test('no release means up to date', () {
      final result = UpdateService.evaluate(
        current: AppVersion.from('1.0.1', build: 3)!,
        release: null,
      );
      expect(result.status, UpdateStatus.upToDate);
      expect(result.hasUpdate, isFalse);
    });

    test('older or equal remote means up to date', () {
      final current = AppVersion.from('1.0.2', build: 5)!;
      expect(
        UpdateService.evaluate(current: current, release: release(build: 5))
            .status,
        UpdateStatus.upToDate,
      );
      expect(
        UpdateService.evaluate(
          current: current,
          release: release(version: '1.0.1', build: 4),
        ).status,
        UpdateStatus.upToDate,
      );
    });

    test('newer remote is an optional update by default', () {
      final result = UpdateService.evaluate(
        current: AppVersion.from('1.0.1', build: 3)!,
        release: release(version: '1.0.2', build: 4),
      );
      expect(result.status, UpdateStatus.optional);
      expect(result.hasUpdate, isTrue);
      expect(result.isMandatory, isFalse);
    });

    test('mandatory flag forces a mandatory update', () {
      final result = UpdateService.evaluate(
        current: AppVersion.from('1.0.1', build: 3)!,
        release: release(version: '1.0.2', build: 4, mandatory: true),
      );
      expect(result.status, UpdateStatus.mandatory);
      expect(result.isMandatory, isTrue);
    });

    test('current below minSupportedVersion forces a mandatory update', () {
      final result = UpdateService.evaluate(
        current: AppVersion.from('1.0.0', build: 1)!,
        release: release(version: '1.2.0', build: 9, minSupported: '1.1.0'),
      );
      expect(result.status, UpdateStatus.mandatory);
    });

    test('current at/above minSupportedVersion stays optional', () {
      final result = UpdateService.evaluate(
        current: AppVersion.from('1.1.0', build: 5)!,
        release: release(version: '1.2.0', build: 9, minSupported: '1.1.0'),
      );
      expect(result.status, UpdateStatus.optional);
    });
  });

  group('UpdateManifest.fromJson', () {
    test('parses per-platform releases', () {
      final manifest = UpdateManifest.fromJson({
        'android': {
          'version': '1.0.2',
          'buildNumber': 4,
          'url': 'https://example.com/app.apk',
          'sha256': 'abc123',
          'notes': 'Bug fixes',
        },
        'windows': {
          'version': '1.0.2',
          'url': 'https://example.com/app.zip',
        },
      });

      expect(manifest.forPlatform(UpdatePlatform.android), isNotNull);
      expect(manifest.android!.buildNumber, 4);
      expect(manifest.android!.sha256, 'abc123');
      expect(manifest.windows!.version, '1.0.2');
      expect(manifest.forPlatform(UpdatePlatform.macos), isNull);
    });

    test('ignores entries missing version or url', () {
      final manifest = UpdateManifest.fromJson({
        'android': {'version': '1.0.2'},
        'windows': {'url': 'https://example.com/app.zip'},
      });
      expect(manifest.android, isNull);
      expect(manifest.windows, isNull);
    });
  });
}
