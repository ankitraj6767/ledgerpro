import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'update_manifest.dart';
import 'update_service.dart' show UpdateException;

/// Stage of an in-progress install, used to drive progress UI.
enum InstallPhase {
  idle,
  preparing,
  downloading,
  verifying,
  extracting,
  launching,
  completed,
  failed,
}

class UpdateProgress {
  const UpdateProgress({
    required this.phase,
    this.received = 0,
    this.total = 0,
    this.message,
  });

  final InstallPhase phase;
  final int received;
  final int total;
  final String? message;

  /// Download completion in `0..1`, or null when the total size is unknown.
  double? get fraction =>
      total > 0 ? (received / total).clamp(0.0, 1.0) : null;

  const UpdateProgress.idle() : this(phase: InstallPhase.idle);
}

/// Performs the platform-specific install of a downloaded release.
///
/// Android: requests the "install unknown apps" permission, downloads the APK
/// to app storage and hands it to the system package installer (which shows the
/// usual OS confirmation — fully silent install is not possible for sideloaded
/// APKs on stock Android).
///
/// Windows: downloads + verifies the release ZIP, extracts it, then launches a
/// small detached batch script that waits for this process to exit, mirrors the
/// new files over the install directory and relaunches the app.
///
/// macOS: downloads + verifies the release ZIP, extracts the notarized `.app`
/// bundle with `ditto` (which preserves the code signature, symlinks and
/// permissions), then launches a small detached shell script that waits for
/// this process to exit, replaces the installed `.app` in place and relaunches.
///
/// unsupported: opens the download URL in the browser as a fallback.
class UpdateInstaller {
  UpdateInstaller({UpdatePlatform? platform, http.Client? client})
    : platform = platform ?? currentUpdatePlatform(),
      _client = client ?? http.Client();

  final UpdatePlatform platform;
  final http.Client _client;

  Future<void> install(
    PlatformRelease release, {
    required void Function(UpdateProgress) onProgress,
  }) async {
    try {
      switch (platform) {
        case UpdatePlatform.android:
          await _installAndroid(release, onProgress);
        case UpdatePlatform.windows:
          await _installWindows(release, onProgress);
        case UpdatePlatform.macos:
          await _installMacOS(release, onProgress);
        case UpdatePlatform.unsupported:
          await _openInBrowser(release, onProgress);
      }
    } on UpdateException {
      rethrow;
    } catch (error) {
      throw UpdateException('Update failed: $error');
    }
  }

  // ---------------------------------------------------------------------------
  // Android
  // ---------------------------------------------------------------------------
  Future<void> _installAndroid(
    PlatformRelease release,
    void Function(UpdateProgress) onProgress,
  ) async {
    onProgress(const UpdateProgress(phase: InstallPhase.preparing));

    var status = await Permission.requestInstallPackages.status;
    if (!status.isGranted) {
      status = await Permission.requestInstallPackages.request();
    }
    if (!status.isGranted) {
      throw const UpdateException(
        'To update, allow this app to install unknown apps, then try again.',
      );
    }

    final dir =
        await getExternalStorageDirectory() ?? await getTemporaryDirectory();
    final fileName = _safeFileName(release, fallback: 'ledgerpro-update.apk');
    final file = File(p.join(dir.path, fileName));

    await _download(release, file, onProgress);

    onProgress(const UpdateProgress(phase: InstallPhase.launching));
    final result = await OpenFilex.open(
      file.path,
      type: 'application/vnd.android.package-archive',
    );
    if (result.type != ResultType.done) {
      throw UpdateException(
        'Could not open the installer: ${result.message}.',
      );
    }
    onProgress(const UpdateProgress(phase: InstallPhase.completed));
  }

  // ---------------------------------------------------------------------------
  // Windows
  // ---------------------------------------------------------------------------
  Future<void> _installWindows(
    PlatformRelease release,
    void Function(UpdateProgress) onProgress,
  ) async {
    onProgress(const UpdateProgress(phase: InstallPhase.preparing));

    final tempRoot = await getTemporaryDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final workDir = Directory(p.join(tempRoot.path, 'ledgerpro_update_$stamp'));
    if (workDir.existsSync()) {
      workDir.deleteSync(recursive: true);
    }
    workDir.createSync(recursive: true);

    final zipName = _safeFileName(release, fallback: 'ledgerpro-update.zip');
    final zipFile = File(p.join(workDir.path, zipName));
    await _download(release, zipFile, onProgress);

    onProgress(const UpdateProgress(phase: InstallPhase.extracting));
    final extractDir = Directory(p.join(workDir.path, 'payload'));
    extractDir.createSync(recursive: true);
    await extractFileToDisk(zipFile.path, extractDir.path);

    final sourceDir = _resolveWindowsSourceDir(extractDir);
    final installDir = File(Platform.resolvedExecutable).parent.path;
    final exeName = p.basename(Platform.resolvedExecutable);

    onProgress(const UpdateProgress(phase: InstallPhase.launching));
    final scriptFile = File(p.join(workDir.path, 'apply_update.bat'));
    await scriptFile.writeAsString(
      _windowsUpdaterScript(
        sourceDir: sourceDir.path,
        installDir: installDir,
        exeName: exeName,
        processId: pid,
        cleanupDir: workDir.path,
      ),
    );

    // Launch detached so the script outlives this process, then exit so the
    // running executable is unlocked and can be overwritten.
    await Process.start(
      'cmd.exe',
      ['/c', 'start', '', '/min', scriptFile.path],
      mode: ProcessStartMode.detached,
      runInShell: true,
    );

    onProgress(const UpdateProgress(phase: InstallPhase.completed));
    await Future<void>.delayed(const Duration(milliseconds: 700));
    exit(0);
  }

  /// The ZIP packs everything under a single top-level folder
  /// (`LedgerPro-Windows-x64-vX.Y.Z`). Detect that folder; fall back to the
  /// extraction root if the executable sits directly inside it.
  Directory _resolveWindowsSourceDir(Directory extractDir) {
    bool hasExe(Directory d) => d.listSync().any(
      (e) => e is File && e.path.toLowerCase().endsWith('.exe'),
    );

    if (hasExe(extractDir)) return extractDir;

    final subDirs = extractDir.listSync().whereType<Directory>().toList();
    if (subDirs.length == 1) return subDirs.first;
    for (final dir in subDirs) {
      if (hasExe(dir)) return dir;
    }
    return extractDir;
  }

  String _windowsUpdaterScript({
    required String sourceDir,
    required String installDir,
    required String exeName,
    required int processId,
    required String cleanupDir,
  }) {
    // Wait for the app (by PID) to exit, mirror the new files into the install
    // directory, relaunch, then delete the temporary working directory and the
    // script itself. /MIR removes stale files for a clean upgrade; user data
    // lives under %APPDATA%, not the install dir, so it is untouched.
    return '''
@echo off
setlocal enableextensions
set "SRC=$sourceDir"
set "DST=$installDir"
set "EXE=$exeName"
set "PIDV=$processId"
set "WORK=$cleanupDir"

set /a TRIES=0
:waitloop
tasklist /FI "PID eq %PIDV%" 2>nul | find "%PIDV%" >nul
if not errorlevel 1 (
  set /a TRIES+=1
  if %TRIES% GEQ 60 goto copy
  timeout /t 1 /nobreak >nul
  goto waitloop
)

:copy
robocopy "%SRC%" "%DST%" /MIR /NFL /NDL /NJH /NJS /NP /R:2 /W:2 >nul

start "" "%DST%\\%EXE%"

cd /d "%TEMP%"
rmdir /s /q "%WORK%" >nul 2>&1
''';
  }

  // ---------------------------------------------------------------------------
  // macOS
  // ---------------------------------------------------------------------------
  Future<void> _installMacOS(
    PlatformRelease release,
    void Function(UpdateProgress) onProgress,
  ) async {
    onProgress(const UpdateProgress(phase: InstallPhase.preparing));

    // Only a real `.app` bundle install can be replaced in place. When running
    // outside a bundle (e.g. `flutter run`), fall back to a browser download.
    final exe = File(Platform.resolvedExecutable);
    final installedApp = exe.parent.parent.parent; // <name>.app
    if (!installedApp.path.toLowerCase().endsWith('.app')) {
      await _openInBrowser(release, onProgress);
      return;
    }

    final tempRoot = await getTemporaryDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final workDir = Directory(p.join(tempRoot.path, 'ledgerpro_update_$stamp'));
    if (workDir.existsSync()) {
      workDir.deleteSync(recursive: true);
    }
    workDir.createSync(recursive: true);

    final zipName = _safeFileName(release, fallback: 'ledgerpro-update.zip');
    final zipFile = File(p.join(workDir.path, zipName));
    await _download(release, zipFile, onProgress);

    onProgress(const UpdateProgress(phase: InstallPhase.extracting));
    final extractDir = Directory(p.join(workDir.path, 'payload'));
    extractDir.createSync(recursive: true);

    // Use ditto (not the Dart archive package) so the extracted bundle keeps its
    // code signature, symlinks and permissions intact; otherwise Gatekeeper
    // would reject the replaced app.
    final unzip = await Process.run('/usr/bin/ditto', [
      '-x',
      '-k',
      zipFile.path,
      extractDir.path,
    ]);
    if (unzip.exitCode != 0) {
      throw UpdateException(
        'Could not extract the update (${unzip.stderr}).',
      );
    }

    final newApp = _resolveMacAppBundle(extractDir);
    if (newApp == null) {
      throw const UpdateException(
        'The downloaded update did not contain a macOS app bundle.',
      );
    }

    onProgress(const UpdateProgress(phase: InstallPhase.launching));
    final scriptFile = File(p.join(workDir.path, 'apply_update.sh'));
    await scriptFile.writeAsString(
      _macUpdaterScript(
        newAppPath: newApp.path,
        installedAppPath: installedApp.path,
        processId: pid,
        cleanupDir: workDir.path,
      ),
    );

    // Launch detached so the script outlives this process, then exit so the
    // running bundle can be replaced.
    await Process.start(
      '/bin/bash',
      [scriptFile.path],
      mode: ProcessStartMode.detached,
    );

    onProgress(const UpdateProgress(phase: InstallPhase.completed));
    await Future<void>.delayed(const Duration(milliseconds: 700));
    exit(0);
  }

  /// Finds the `.app` bundle inside the extracted payload. The ZIP is created
  /// with `ditto --keepParent`, so the bundle sits at the extraction root; also
  /// search one level deep as a fallback.
  Directory? _resolveMacAppBundle(Directory extractDir) {
    bool isApp(FileSystemEntity e) =>
        e is Directory && e.path.toLowerCase().endsWith('.app');

    for (final entity in extractDir.listSync()) {
      if (isApp(entity)) return entity as Directory;
    }
    for (final dir in extractDir.listSync().whereType<Directory>()) {
      for (final entity in dir.listSync()) {
        if (isApp(entity)) return entity as Directory;
      }
    }
    return null;
  }

  String _macUpdaterScript({
    required String newAppPath,
    required String installedAppPath,
    required int processId,
    required String cleanupDir,
  }) {
    // Wait for the app (by PID) to exit, swap the new bundle in for the old one
    // (keeping a rollback copy), clear the download quarantine flag, relaunch,
    // then delete the temporary working directory. User data lives under
    // ~/Library, not inside the bundle, so it is untouched.
    return '''
#!/bin/bash
NEW="$newAppPath"
DST="$installedAppPath"
PIDV=$processId
WORK="$cleanupDir"

for _ in \$(seq 1 60); do
  if ! kill -0 "\$PIDV" 2>/dev/null; then break; fi
  sleep 1
done

rm -rf "\$DST.old" 2>/dev/null
if [ -d "\$DST" ]; then
  mv "\$DST" "\$DST.old" 2>/dev/null
fi

if /usr/bin/ditto "\$NEW" "\$DST"; then
  rm -rf "\$DST.old" 2>/dev/null
else
  rm -rf "\$DST" 2>/dev/null
  mv "\$DST.old" "\$DST" 2>/dev/null
fi

/usr/bin/xattr -dr com.apple.quarantine "\$DST" 2>/dev/null
/usr/bin/open "\$DST"

cd /tmp
rm -rf "\$WORK" 2>/dev/null
''';
  }

  // ---------------------------------------------------------------------------
  // Fallback (unsupported): open the download in the browser.
  // ---------------------------------------------------------------------------
  Future<void> _openInBrowser(
    PlatformRelease release,
    void Function(UpdateProgress) onProgress,
  ) async {
    onProgress(const UpdateProgress(phase: InstallPhase.launching));
    final uri = Uri.tryParse(release.url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw const UpdateException('Could not open the download link.');
    }
    onProgress(const UpdateProgress(phase: InstallPhase.completed));
  }

  // ---------------------------------------------------------------------------
  // Shared download + integrity verification
  // ---------------------------------------------------------------------------
  Future<void> _download(
    PlatformRelease release,
    File dest,
    void Function(UpdateProgress) onProgress,
  ) async {
    onProgress(const UpdateProgress(phase: InstallPhase.downloading));

    final uri = Uri.tryParse(release.url);
    if (uri == null) {
      throw const UpdateException('The update has an invalid download URL.');
    }

    final request = http.Request('GET', uri);
    final http.StreamedResponse response;
    try {
      response = await _client.send(request).timeout(
        const Duration(seconds: 60),
      );
    } on TimeoutException {
      throw const UpdateException('Timed out while downloading the update.');
    }

    if (response.statusCode != 200) {
      throw UpdateException(
        'Download failed (HTTP ${response.statusCode}).',
      );
    }

    if (dest.existsSync()) {
      dest.deleteSync();
    }

    final total = response.contentLength ?? 0;
    var received = 0;
    final sink = dest.openWrite();
    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        onProgress(
          UpdateProgress(
            phase: InstallPhase.downloading,
            received: received,
            total: total,
          ),
        );
      }
    } catch (error) {
      await sink.close();
      await _deleteQuietly(dest);
      throw UpdateException('Download interrupted: $error');
    }
    await sink.close();

    final expected = release.sha256?.trim().toLowerCase();
    if (expected != null && expected.isNotEmpty) {
      onProgress(const UpdateProgress(phase: InstallPhase.verifying));
      final actual = (await _sha256OfFile(dest)).toLowerCase();
      if (actual != expected) {
        await _deleteQuietly(dest);
        throw const UpdateException(
          'The downloaded update failed its integrity check and was discarded.',
        );
      }
    }
  }

  Future<String> _sha256OfFile(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  Future<void> _deleteQuietly(File file) async {
    try {
      if (file.existsSync()) await file.delete();
    } catch (_) {
      // best effort
    }
  }

  String _safeFileName(PlatformRelease release, {required String fallback}) {
    final raw = release.fileName?.trim();
    if (raw == null || raw.isEmpty) return fallback;
    // Strip any path separators a manifest might contain.
    final base = p.basename(raw);
    return base.isEmpty ? fallback : base;
  }

  void dispose() => _client.close();
}
