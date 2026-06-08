import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/repositories/material_repository.dart';

class CapturedSchoolEvidence {
  const CapturedSchoolEvidence({
    required this.photo,
    required this.position,
    required this.capturedAt,
  });

  final XFile photo;
  final Position position;
  final DateTime capturedAt;
}

class UploadedSchoolEvidence {
  const UploadedSchoolEvidence({
    required this.photoPaths,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.capturedAt,
  });

  final List<String> photoPaths;
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime capturedAt;
}

class SchoolEvidenceCaptureException implements Exception {
  const SchoolEvidenceCaptureException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<CapturedSchoolEvidence?> captureSchoolEvidencePhoto() async {
  final permission = await _ensureLocationPermission();
  if (!permission) {
    throw const SchoolEvidenceCaptureException(
      'Location permission is required for GPS school photos.',
    );
  }

  final photo = await ImagePicker().pickImage(
    source: ImageSource.camera,
    imageQuality: 78,
    maxWidth: 1600,
  );
  if (photo == null) return null;

  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
  );
  return CapturedSchoolEvidence(
    photo: photo,
    position: position,
    capturedAt: DateTime.now().toUtc(),
  );
}

Future<UploadedSchoolEvidence?> uploadSchoolEvidencePhotos({
  required MaterialRepository repository,
  required String organizationId,
  required String schoolId,
  required List<CapturedSchoolEvidence> photos,
}) async {
  if (photos.isEmpty) return null;
  final paths = <String>[];
  for (final photo in photos) {
    final bytes = await photo.photo.readAsBytes();
    final path = await repository.uploadSchoolEvidencePhoto(
      organizationId: organizationId,
      schoolId: schoolId,
      bytes: bytes,
      capturedAt: photo.capturedAt,
      fileName: photo.photo.name,
    );
    paths.add(path);
  }

  final latest = photos.last;
  return UploadedSchoolEvidence(
    photoPaths: paths,
    latitude: latest.position.latitude,
    longitude: latest.position.longitude,
    accuracyMeters: latest.position.accuracy,
    capturedAt: latest.capturedAt,
  );
}

Future<bool> _ensureLocationPermission() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw const SchoolEvidenceCaptureException(
      'Turn on device location before taking a GPS school photo.',
    );
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  return permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse;
}
