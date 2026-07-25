// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challan_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CapturedPortalPayload {

 String? get challanNumber; String? get uidNumber; DateTime? get challanDate; DateTime? get validUntil; String? get consignorName; String? get consigneeName; String? get generatedFrom; String? get sourceLocation; String? get destination; String? get vehicleType; String? get vehicleNumber; String? get mineralName;/// Parsed for validation and display only.
 double? get quantity;/// The exact decimal text as printed by the portal. This is what gets sent
/// to Postgres `numeric(14,3)` so no binary-float rounding is introduced on
/// the write path.
 String? get quantityText;/// Null when the portal did not print a unit. Never assume MT here — the
/// assumption (and the fact that it *is* an assumption) is applied at save
/// time instead.
 String? get quantityUnit; int? get royaltyAmountPaise;/// Raw label/value pairs exactly as normalized off the page, including
/// fields this app version does not model yet. Persisted to
/// `portal_payload` so a future release can backfill without re-capturing.
 Map<String, String> get rawFields;/// SHA-256 of the normalized payload. Lets support confirm two devices read
/// the same page without ever storing the page itself.
 String? get responseHash; DateTime? get capturedAt;
/// Create a copy of CapturedPortalPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CapturedPortalPayloadCopyWith<CapturedPortalPayload> get copyWith => _$CapturedPortalPayloadCopyWithImpl<CapturedPortalPayload>(this as CapturedPortalPayload, _$identity);

  /// Serializes this CapturedPortalPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CapturedPortalPayload&&(identical(other.challanNumber, challanNumber) || other.challanNumber == challanNumber)&&(identical(other.uidNumber, uidNumber) || other.uidNumber == uidNumber)&&(identical(other.challanDate, challanDate) || other.challanDate == challanDate)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.consignorName, consignorName) || other.consignorName == consignorName)&&(identical(other.consigneeName, consigneeName) || other.consigneeName == consigneeName)&&(identical(other.generatedFrom, generatedFrom) || other.generatedFrom == generatedFrom)&&(identical(other.sourceLocation, sourceLocation) || other.sourceLocation == sourceLocation)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.mineralName, mineralName) || other.mineralName == mineralName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityText, quantityText) || other.quantityText == quantityText)&&(identical(other.quantityUnit, quantityUnit) || other.quantityUnit == quantityUnit)&&(identical(other.royaltyAmountPaise, royaltyAmountPaise) || other.royaltyAmountPaise == royaltyAmountPaise)&&const DeepCollectionEquality().equals(other.rawFields, rawFields)&&(identical(other.responseHash, responseHash) || other.responseHash == responseHash)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,challanNumber,uidNumber,challanDate,validUntil,consignorName,consigneeName,generatedFrom,sourceLocation,destination,vehicleType,vehicleNumber,mineralName,quantity,quantityText,quantityUnit,royaltyAmountPaise,const DeepCollectionEquality().hash(rawFields),responseHash,capturedAt]);

@override
String toString() {
  return 'CapturedPortalPayload(challanNumber: $challanNumber, uidNumber: $uidNumber, challanDate: $challanDate, validUntil: $validUntil, consignorName: $consignorName, consigneeName: $consigneeName, generatedFrom: $generatedFrom, sourceLocation: $sourceLocation, destination: $destination, vehicleType: $vehicleType, vehicleNumber: $vehicleNumber, mineralName: $mineralName, quantity: $quantity, quantityText: $quantityText, quantityUnit: $quantityUnit, royaltyAmountPaise: $royaltyAmountPaise, rawFields: $rawFields, responseHash: $responseHash, capturedAt: $capturedAt)';
}


}

/// @nodoc
abstract mixin class $CapturedPortalPayloadCopyWith<$Res>  {
  factory $CapturedPortalPayloadCopyWith(CapturedPortalPayload value, $Res Function(CapturedPortalPayload) _then) = _$CapturedPortalPayloadCopyWithImpl;
@useResult
$Res call({
 String? challanNumber, String? uidNumber, DateTime? challanDate, DateTime? validUntil, String? consignorName, String? consigneeName, String? generatedFrom, String? sourceLocation, String? destination, String? vehicleType, String? vehicleNumber, String? mineralName, double? quantity, String? quantityText, String? quantityUnit, int? royaltyAmountPaise, Map<String, String> rawFields, String? responseHash, DateTime? capturedAt
});




}
/// @nodoc
class _$CapturedPortalPayloadCopyWithImpl<$Res>
    implements $CapturedPortalPayloadCopyWith<$Res> {
  _$CapturedPortalPayloadCopyWithImpl(this._self, this._then);

  final CapturedPortalPayload _self;
  final $Res Function(CapturedPortalPayload) _then;

/// Create a copy of CapturedPortalPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? challanNumber = freezed,Object? uidNumber = freezed,Object? challanDate = freezed,Object? validUntil = freezed,Object? consignorName = freezed,Object? consigneeName = freezed,Object? generatedFrom = freezed,Object? sourceLocation = freezed,Object? destination = freezed,Object? vehicleType = freezed,Object? vehicleNumber = freezed,Object? mineralName = freezed,Object? quantity = freezed,Object? quantityText = freezed,Object? quantityUnit = freezed,Object? royaltyAmountPaise = freezed,Object? rawFields = null,Object? responseHash = freezed,Object? capturedAt = freezed,}) {
  return _then(_self.copyWith(
challanNumber: freezed == challanNumber ? _self.challanNumber : challanNumber // ignore: cast_nullable_to_non_nullable
as String?,uidNumber: freezed == uidNumber ? _self.uidNumber : uidNumber // ignore: cast_nullable_to_non_nullable
as String?,challanDate: freezed == challanDate ? _self.challanDate : challanDate // ignore: cast_nullable_to_non_nullable
as DateTime?,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,consignorName: freezed == consignorName ? _self.consignorName : consignorName // ignore: cast_nullable_to_non_nullable
as String?,consigneeName: freezed == consigneeName ? _self.consigneeName : consigneeName // ignore: cast_nullable_to_non_nullable
as String?,generatedFrom: freezed == generatedFrom ? _self.generatedFrom : generatedFrom // ignore: cast_nullable_to_non_nullable
as String?,sourceLocation: freezed == sourceLocation ? _self.sourceLocation : sourceLocation // ignore: cast_nullable_to_non_nullable
as String?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,mineralName: freezed == mineralName ? _self.mineralName : mineralName // ignore: cast_nullable_to_non_nullable
as String?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double?,quantityText: freezed == quantityText ? _self.quantityText : quantityText // ignore: cast_nullable_to_non_nullable
as String?,quantityUnit: freezed == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as String?,royaltyAmountPaise: freezed == royaltyAmountPaise ? _self.royaltyAmountPaise : royaltyAmountPaise // ignore: cast_nullable_to_non_nullable
as int?,rawFields: null == rawFields ? _self.rawFields : rawFields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,responseHash: freezed == responseHash ? _self.responseHash : responseHash // ignore: cast_nullable_to_non_nullable
as String?,capturedAt: freezed == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CapturedPortalPayload].
extension CapturedPortalPayloadPatterns on CapturedPortalPayload {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CapturedPortalPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CapturedPortalPayload() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CapturedPortalPayload value)  $default,){
final _that = this;
switch (_that) {
case _CapturedPortalPayload():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CapturedPortalPayload value)?  $default,){
final _that = this;
switch (_that) {
case _CapturedPortalPayload() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? challanNumber,  String? uidNumber,  DateTime? challanDate,  DateTime? validUntil,  String? consignorName,  String? consigneeName,  String? generatedFrom,  String? sourceLocation,  String? destination,  String? vehicleType,  String? vehicleNumber,  String? mineralName,  double? quantity,  String? quantityText,  String? quantityUnit,  int? royaltyAmountPaise,  Map<String, String> rawFields,  String? responseHash,  DateTime? capturedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CapturedPortalPayload() when $default != null:
return $default(_that.challanNumber,_that.uidNumber,_that.challanDate,_that.validUntil,_that.consignorName,_that.consigneeName,_that.generatedFrom,_that.sourceLocation,_that.destination,_that.vehicleType,_that.vehicleNumber,_that.mineralName,_that.quantity,_that.quantityText,_that.quantityUnit,_that.royaltyAmountPaise,_that.rawFields,_that.responseHash,_that.capturedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? challanNumber,  String? uidNumber,  DateTime? challanDate,  DateTime? validUntil,  String? consignorName,  String? consigneeName,  String? generatedFrom,  String? sourceLocation,  String? destination,  String? vehicleType,  String? vehicleNumber,  String? mineralName,  double? quantity,  String? quantityText,  String? quantityUnit,  int? royaltyAmountPaise,  Map<String, String> rawFields,  String? responseHash,  DateTime? capturedAt)  $default,) {final _that = this;
switch (_that) {
case _CapturedPortalPayload():
return $default(_that.challanNumber,_that.uidNumber,_that.challanDate,_that.validUntil,_that.consignorName,_that.consigneeName,_that.generatedFrom,_that.sourceLocation,_that.destination,_that.vehicleType,_that.vehicleNumber,_that.mineralName,_that.quantity,_that.quantityText,_that.quantityUnit,_that.royaltyAmountPaise,_that.rawFields,_that.responseHash,_that.capturedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? challanNumber,  String? uidNumber,  DateTime? challanDate,  DateTime? validUntil,  String? consignorName,  String? consigneeName,  String? generatedFrom,  String? sourceLocation,  String? destination,  String? vehicleType,  String? vehicleNumber,  String? mineralName,  double? quantity,  String? quantityText,  String? quantityUnit,  int? royaltyAmountPaise,  Map<String, String> rawFields,  String? responseHash,  DateTime? capturedAt)?  $default,) {final _that = this;
switch (_that) {
case _CapturedPortalPayload() when $default != null:
return $default(_that.challanNumber,_that.uidNumber,_that.challanDate,_that.validUntil,_that.consignorName,_that.consigneeName,_that.generatedFrom,_that.sourceLocation,_that.destination,_that.vehicleType,_that.vehicleNumber,_that.mineralName,_that.quantity,_that.quantityText,_that.quantityUnit,_that.royaltyAmountPaise,_that.rawFields,_that.responseHash,_that.capturedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CapturedPortalPayload extends CapturedPortalPayload {
  const _CapturedPortalPayload({this.challanNumber, this.uidNumber, this.challanDate, this.validUntil, this.consignorName, this.consigneeName, this.generatedFrom, this.sourceLocation, this.destination, this.vehicleType, this.vehicleNumber, this.mineralName, this.quantity, this.quantityText, this.quantityUnit, this.royaltyAmountPaise, final  Map<String, String> rawFields = const <String, String>{}, this.responseHash, this.capturedAt}): _rawFields = rawFields,super._();
  factory _CapturedPortalPayload.fromJson(Map<String, dynamic> json) => _$CapturedPortalPayloadFromJson(json);

@override final  String? challanNumber;
@override final  String? uidNumber;
@override final  DateTime? challanDate;
@override final  DateTime? validUntil;
@override final  String? consignorName;
@override final  String? consigneeName;
@override final  String? generatedFrom;
@override final  String? sourceLocation;
@override final  String? destination;
@override final  String? vehicleType;
@override final  String? vehicleNumber;
@override final  String? mineralName;
/// Parsed for validation and display only.
@override final  double? quantity;
/// The exact decimal text as printed by the portal. This is what gets sent
/// to Postgres `numeric(14,3)` so no binary-float rounding is introduced on
/// the write path.
@override final  String? quantityText;
/// Null when the portal did not print a unit. Never assume MT here — the
/// assumption (and the fact that it *is* an assumption) is applied at save
/// time instead.
@override final  String? quantityUnit;
@override final  int? royaltyAmountPaise;
/// Raw label/value pairs exactly as normalized off the page, including
/// fields this app version does not model yet. Persisted to
/// `portal_payload` so a future release can backfill without re-capturing.
 final  Map<String, String> _rawFields;
/// Raw label/value pairs exactly as normalized off the page, including
/// fields this app version does not model yet. Persisted to
/// `portal_payload` so a future release can backfill without re-capturing.
@override@JsonKey() Map<String, String> get rawFields {
  if (_rawFields is EqualUnmodifiableMapView) return _rawFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rawFields);
}

/// SHA-256 of the normalized payload. Lets support confirm two devices read
/// the same page without ever storing the page itself.
@override final  String? responseHash;
@override final  DateTime? capturedAt;

/// Create a copy of CapturedPortalPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CapturedPortalPayloadCopyWith<_CapturedPortalPayload> get copyWith => __$CapturedPortalPayloadCopyWithImpl<_CapturedPortalPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CapturedPortalPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CapturedPortalPayload&&(identical(other.challanNumber, challanNumber) || other.challanNumber == challanNumber)&&(identical(other.uidNumber, uidNumber) || other.uidNumber == uidNumber)&&(identical(other.challanDate, challanDate) || other.challanDate == challanDate)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.consignorName, consignorName) || other.consignorName == consignorName)&&(identical(other.consigneeName, consigneeName) || other.consigneeName == consigneeName)&&(identical(other.generatedFrom, generatedFrom) || other.generatedFrom == generatedFrom)&&(identical(other.sourceLocation, sourceLocation) || other.sourceLocation == sourceLocation)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.mineralName, mineralName) || other.mineralName == mineralName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityText, quantityText) || other.quantityText == quantityText)&&(identical(other.quantityUnit, quantityUnit) || other.quantityUnit == quantityUnit)&&(identical(other.royaltyAmountPaise, royaltyAmountPaise) || other.royaltyAmountPaise == royaltyAmountPaise)&&const DeepCollectionEquality().equals(other._rawFields, _rawFields)&&(identical(other.responseHash, responseHash) || other.responseHash == responseHash)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,challanNumber,uidNumber,challanDate,validUntil,consignorName,consigneeName,generatedFrom,sourceLocation,destination,vehicleType,vehicleNumber,mineralName,quantity,quantityText,quantityUnit,royaltyAmountPaise,const DeepCollectionEquality().hash(_rawFields),responseHash,capturedAt]);

@override
String toString() {
  return 'CapturedPortalPayload(challanNumber: $challanNumber, uidNumber: $uidNumber, challanDate: $challanDate, validUntil: $validUntil, consignorName: $consignorName, consigneeName: $consigneeName, generatedFrom: $generatedFrom, sourceLocation: $sourceLocation, destination: $destination, vehicleType: $vehicleType, vehicleNumber: $vehicleNumber, mineralName: $mineralName, quantity: $quantity, quantityText: $quantityText, quantityUnit: $quantityUnit, royaltyAmountPaise: $royaltyAmountPaise, rawFields: $rawFields, responseHash: $responseHash, capturedAt: $capturedAt)';
}


}

/// @nodoc
abstract mixin class _$CapturedPortalPayloadCopyWith<$Res> implements $CapturedPortalPayloadCopyWith<$Res> {
  factory _$CapturedPortalPayloadCopyWith(_CapturedPortalPayload value, $Res Function(_CapturedPortalPayload) _then) = __$CapturedPortalPayloadCopyWithImpl;
@override @useResult
$Res call({
 String? challanNumber, String? uidNumber, DateTime? challanDate, DateTime? validUntil, String? consignorName, String? consigneeName, String? generatedFrom, String? sourceLocation, String? destination, String? vehicleType, String? vehicleNumber, String? mineralName, double? quantity, String? quantityText, String? quantityUnit, int? royaltyAmountPaise, Map<String, String> rawFields, String? responseHash, DateTime? capturedAt
});




}
/// @nodoc
class __$CapturedPortalPayloadCopyWithImpl<$Res>
    implements _$CapturedPortalPayloadCopyWith<$Res> {
  __$CapturedPortalPayloadCopyWithImpl(this._self, this._then);

  final _CapturedPortalPayload _self;
  final $Res Function(_CapturedPortalPayload) _then;

/// Create a copy of CapturedPortalPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? challanNumber = freezed,Object? uidNumber = freezed,Object? challanDate = freezed,Object? validUntil = freezed,Object? consignorName = freezed,Object? consigneeName = freezed,Object? generatedFrom = freezed,Object? sourceLocation = freezed,Object? destination = freezed,Object? vehicleType = freezed,Object? vehicleNumber = freezed,Object? mineralName = freezed,Object? quantity = freezed,Object? quantityText = freezed,Object? quantityUnit = freezed,Object? royaltyAmountPaise = freezed,Object? rawFields = null,Object? responseHash = freezed,Object? capturedAt = freezed,}) {
  return _then(_CapturedPortalPayload(
challanNumber: freezed == challanNumber ? _self.challanNumber : challanNumber // ignore: cast_nullable_to_non_nullable
as String?,uidNumber: freezed == uidNumber ? _self.uidNumber : uidNumber // ignore: cast_nullable_to_non_nullable
as String?,challanDate: freezed == challanDate ? _self.challanDate : challanDate // ignore: cast_nullable_to_non_nullable
as DateTime?,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,consignorName: freezed == consignorName ? _self.consignorName : consignorName // ignore: cast_nullable_to_non_nullable
as String?,consigneeName: freezed == consigneeName ? _self.consigneeName : consigneeName // ignore: cast_nullable_to_non_nullable
as String?,generatedFrom: freezed == generatedFrom ? _self.generatedFrom : generatedFrom // ignore: cast_nullable_to_non_nullable
as String?,sourceLocation: freezed == sourceLocation ? _self.sourceLocation : sourceLocation // ignore: cast_nullable_to_non_nullable
as String?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String?,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,vehicleNumber: freezed == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String?,mineralName: freezed == mineralName ? _self.mineralName : mineralName // ignore: cast_nullable_to_non_nullable
as String?,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double?,quantityText: freezed == quantityText ? _self.quantityText : quantityText // ignore: cast_nullable_to_non_nullable
as String?,quantityUnit: freezed == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as String?,royaltyAmountPaise: freezed == royaltyAmountPaise ? _self.royaltyAmountPaise : royaltyAmountPaise // ignore: cast_nullable_to_non_nullable
as int?,rawFields: null == rawFields ? _self._rawFields : rawFields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,responseHash: freezed == responseHash ? _self.responseHash : responseHash // ignore: cast_nullable_to_non_nullable
as String?,capturedAt: freezed == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ChallanCaptureResult {

 bool get success; CapturedPortalPayload? get payload;/// Populated when [success] is false. Uses the module's error taxonomy.
 String? get errorKind; String? get errorMessage; String? get portalUrl; ChallanVerificationStatus get status; ChallanVerificationMethod get method;
/// Create a copy of ChallanCaptureResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChallanCaptureResultCopyWith<ChallanCaptureResult> get copyWith => _$ChallanCaptureResultCopyWithImpl<ChallanCaptureResult>(this as ChallanCaptureResult, _$identity);

  /// Serializes this ChallanCaptureResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChallanCaptureResult&&(identical(other.success, success) || other.success == success)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.errorKind, errorKind) || other.errorKind == errorKind)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.portalUrl, portalUrl) || other.portalUrl == portalUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.method, method) || other.method == method));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,payload,errorKind,errorMessage,portalUrl,status,method);

@override
String toString() {
  return 'ChallanCaptureResult(success: $success, payload: $payload, errorKind: $errorKind, errorMessage: $errorMessage, portalUrl: $portalUrl, status: $status, method: $method)';
}


}

/// @nodoc
abstract mixin class $ChallanCaptureResultCopyWith<$Res>  {
  factory $ChallanCaptureResultCopyWith(ChallanCaptureResult value, $Res Function(ChallanCaptureResult) _then) = _$ChallanCaptureResultCopyWithImpl;
@useResult
$Res call({
 bool success, CapturedPortalPayload? payload, String? errorKind, String? errorMessage, String? portalUrl, ChallanVerificationStatus status, ChallanVerificationMethod method
});


$CapturedPortalPayloadCopyWith<$Res>? get payload;

}
/// @nodoc
class _$ChallanCaptureResultCopyWithImpl<$Res>
    implements $ChallanCaptureResultCopyWith<$Res> {
  _$ChallanCaptureResultCopyWithImpl(this._self, this._then);

  final ChallanCaptureResult _self;
  final $Res Function(ChallanCaptureResult) _then;

/// Create a copy of ChallanCaptureResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? payload = freezed,Object? errorKind = freezed,Object? errorMessage = freezed,Object? portalUrl = freezed,Object? status = null,Object? method = null,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,payload: freezed == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as CapturedPortalPayload?,errorKind: freezed == errorKind ? _self.errorKind : errorKind // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,portalUrl: freezed == portalUrl ? _self.portalUrl : portalUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChallanVerificationStatus,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as ChallanVerificationMethod,
  ));
}
/// Create a copy of ChallanCaptureResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CapturedPortalPayloadCopyWith<$Res>? get payload {
    if (_self.payload == null) {
    return null;
  }

  return $CapturedPortalPayloadCopyWith<$Res>(_self.payload!, (value) {
    return _then(_self.copyWith(payload: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChallanCaptureResult].
extension ChallanCaptureResultPatterns on ChallanCaptureResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChallanCaptureResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChallanCaptureResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChallanCaptureResult value)  $default,){
final _that = this;
switch (_that) {
case _ChallanCaptureResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChallanCaptureResult value)?  $default,){
final _that = this;
switch (_that) {
case _ChallanCaptureResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  CapturedPortalPayload? payload,  String? errorKind,  String? errorMessage,  String? portalUrl,  ChallanVerificationStatus status,  ChallanVerificationMethod method)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChallanCaptureResult() when $default != null:
return $default(_that.success,_that.payload,_that.errorKind,_that.errorMessage,_that.portalUrl,_that.status,_that.method);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  CapturedPortalPayload? payload,  String? errorKind,  String? errorMessage,  String? portalUrl,  ChallanVerificationStatus status,  ChallanVerificationMethod method)  $default,) {final _that = this;
switch (_that) {
case _ChallanCaptureResult():
return $default(_that.success,_that.payload,_that.errorKind,_that.errorMessage,_that.portalUrl,_that.status,_that.method);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  CapturedPortalPayload? payload,  String? errorKind,  String? errorMessage,  String? portalUrl,  ChallanVerificationStatus status,  ChallanVerificationMethod method)?  $default,) {final _that = this;
switch (_that) {
case _ChallanCaptureResult() when $default != null:
return $default(_that.success,_that.payload,_that.errorKind,_that.errorMessage,_that.portalUrl,_that.status,_that.method);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChallanCaptureResult extends ChallanCaptureResult {
  const _ChallanCaptureResult({required this.success, this.payload, this.errorKind, this.errorMessage, this.portalUrl, required this.status, required this.method}): super._();
  factory _ChallanCaptureResult.fromJson(Map<String, dynamic> json) => _$ChallanCaptureResultFromJson(json);

@override final  bool success;
@override final  CapturedPortalPayload? payload;
/// Populated when [success] is false. Uses the module's error taxonomy.
@override final  String? errorKind;
@override final  String? errorMessage;
@override final  String? portalUrl;
@override final  ChallanVerificationStatus status;
@override final  ChallanVerificationMethod method;

/// Create a copy of ChallanCaptureResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChallanCaptureResultCopyWith<_ChallanCaptureResult> get copyWith => __$ChallanCaptureResultCopyWithImpl<_ChallanCaptureResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChallanCaptureResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChallanCaptureResult&&(identical(other.success, success) || other.success == success)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.errorKind, errorKind) || other.errorKind == errorKind)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.portalUrl, portalUrl) || other.portalUrl == portalUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.method, method) || other.method == method));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,success,payload,errorKind,errorMessage,portalUrl,status,method);

@override
String toString() {
  return 'ChallanCaptureResult(success: $success, payload: $payload, errorKind: $errorKind, errorMessage: $errorMessage, portalUrl: $portalUrl, status: $status, method: $method)';
}


}

/// @nodoc
abstract mixin class _$ChallanCaptureResultCopyWith<$Res> implements $ChallanCaptureResultCopyWith<$Res> {
  factory _$ChallanCaptureResultCopyWith(_ChallanCaptureResult value, $Res Function(_ChallanCaptureResult) _then) = __$ChallanCaptureResultCopyWithImpl;
@override @useResult
$Res call({
 bool success, CapturedPortalPayload? payload, String? errorKind, String? errorMessage, String? portalUrl, ChallanVerificationStatus status, ChallanVerificationMethod method
});


@override $CapturedPortalPayloadCopyWith<$Res>? get payload;

}
/// @nodoc
class __$ChallanCaptureResultCopyWithImpl<$Res>
    implements _$ChallanCaptureResultCopyWith<$Res> {
  __$ChallanCaptureResultCopyWithImpl(this._self, this._then);

  final _ChallanCaptureResult _self;
  final $Res Function(_ChallanCaptureResult) _then;

/// Create a copy of ChallanCaptureResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? payload = freezed,Object? errorKind = freezed,Object? errorMessage = freezed,Object? portalUrl = freezed,Object? status = null,Object? method = null,}) {
  return _then(_ChallanCaptureResult(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,payload: freezed == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as CapturedPortalPayload?,errorKind: freezed == errorKind ? _self.errorKind : errorKind // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,portalUrl: freezed == portalUrl ? _self.portalUrl : portalUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChallanVerificationStatus,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as ChallanVerificationMethod,
  ));
}

/// Create a copy of ChallanCaptureResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CapturedPortalPayloadCopyWith<$Res>? get payload {
    if (_self.payload == null) {
    return null;
  }

  return $CapturedPortalPayloadCopyWith<$Res>(_self.payload!, (value) {
    return _then(_self.copyWith(payload: value));
  });
}
}


/// @nodoc
mixin _$EPassChallanDraft {

 String get projectId; String get financialYear;/// Exactly what the user typed, tidied but not stripped.
 String get challanNumber; ChallanMaterialType? get selectedMaterialType; CapturedPortalPayload get payload; ChallanVerificationStatus get verificationStatus; ChallanVerificationMethod get verificationMethod; String? get portalUrl; String get sourcePortal;
/// Create a copy of EPassChallanDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EPassChallanDraftCopyWith<EPassChallanDraft> get copyWith => _$EPassChallanDraftCopyWithImpl<EPassChallanDraft>(this as EPassChallanDraft, _$identity);

  /// Serializes this EPassChallanDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EPassChallanDraft&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.financialYear, financialYear) || other.financialYear == financialYear)&&(identical(other.challanNumber, challanNumber) || other.challanNumber == challanNumber)&&(identical(other.selectedMaterialType, selectedMaterialType) || other.selectedMaterialType == selectedMaterialType)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.verificationMethod, verificationMethod) || other.verificationMethod == verificationMethod)&&(identical(other.portalUrl, portalUrl) || other.portalUrl == portalUrl)&&(identical(other.sourcePortal, sourcePortal) || other.sourcePortal == sourcePortal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,projectId,financialYear,challanNumber,selectedMaterialType,payload,verificationStatus,verificationMethod,portalUrl,sourcePortal);

@override
String toString() {
  return 'EPassChallanDraft(projectId: $projectId, financialYear: $financialYear, challanNumber: $challanNumber, selectedMaterialType: $selectedMaterialType, payload: $payload, verificationStatus: $verificationStatus, verificationMethod: $verificationMethod, portalUrl: $portalUrl, sourcePortal: $sourcePortal)';
}


}

/// @nodoc
abstract mixin class $EPassChallanDraftCopyWith<$Res>  {
  factory $EPassChallanDraftCopyWith(EPassChallanDraft value, $Res Function(EPassChallanDraft) _then) = _$EPassChallanDraftCopyWithImpl;
@useResult
$Res call({
 String projectId, String financialYear, String challanNumber, ChallanMaterialType? selectedMaterialType, CapturedPortalPayload payload, ChallanVerificationStatus verificationStatus, ChallanVerificationMethod verificationMethod, String? portalUrl, String sourcePortal
});


$CapturedPortalPayloadCopyWith<$Res> get payload;

}
/// @nodoc
class _$EPassChallanDraftCopyWithImpl<$Res>
    implements $EPassChallanDraftCopyWith<$Res> {
  _$EPassChallanDraftCopyWithImpl(this._self, this._then);

  final EPassChallanDraft _self;
  final $Res Function(EPassChallanDraft) _then;

/// Create a copy of EPassChallanDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? projectId = null,Object? financialYear = null,Object? challanNumber = null,Object? selectedMaterialType = freezed,Object? payload = null,Object? verificationStatus = null,Object? verificationMethod = null,Object? portalUrl = freezed,Object? sourcePortal = null,}) {
  return _then(_self.copyWith(
projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,financialYear: null == financialYear ? _self.financialYear : financialYear // ignore: cast_nullable_to_non_nullable
as String,challanNumber: null == challanNumber ? _self.challanNumber : challanNumber // ignore: cast_nullable_to_non_nullable
as String,selectedMaterialType: freezed == selectedMaterialType ? _self.selectedMaterialType : selectedMaterialType // ignore: cast_nullable_to_non_nullable
as ChallanMaterialType?,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as CapturedPortalPayload,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as ChallanVerificationStatus,verificationMethod: null == verificationMethod ? _self.verificationMethod : verificationMethod // ignore: cast_nullable_to_non_nullable
as ChallanVerificationMethod,portalUrl: freezed == portalUrl ? _self.portalUrl : portalUrl // ignore: cast_nullable_to_non_nullable
as String?,sourcePortal: null == sourcePortal ? _self.sourcePortal : sourcePortal // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of EPassChallanDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CapturedPortalPayloadCopyWith<$Res> get payload {
  
  return $CapturedPortalPayloadCopyWith<$Res>(_self.payload, (value) {
    return _then(_self.copyWith(payload: value));
  });
}
}


/// Adds pattern-matching-related methods to [EPassChallanDraft].
extension EPassChallanDraftPatterns on EPassChallanDraft {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EPassChallanDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EPassChallanDraft() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EPassChallanDraft value)  $default,){
final _that = this;
switch (_that) {
case _EPassChallanDraft():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EPassChallanDraft value)?  $default,){
final _that = this;
switch (_that) {
case _EPassChallanDraft() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String projectId,  String financialYear,  String challanNumber,  ChallanMaterialType? selectedMaterialType,  CapturedPortalPayload payload,  ChallanVerificationStatus verificationStatus,  ChallanVerificationMethod verificationMethod,  String? portalUrl,  String sourcePortal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EPassChallanDraft() when $default != null:
return $default(_that.projectId,_that.financialYear,_that.challanNumber,_that.selectedMaterialType,_that.payload,_that.verificationStatus,_that.verificationMethod,_that.portalUrl,_that.sourcePortal);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String projectId,  String financialYear,  String challanNumber,  ChallanMaterialType? selectedMaterialType,  CapturedPortalPayload payload,  ChallanVerificationStatus verificationStatus,  ChallanVerificationMethod verificationMethod,  String? portalUrl,  String sourcePortal)  $default,) {final _that = this;
switch (_that) {
case _EPassChallanDraft():
return $default(_that.projectId,_that.financialYear,_that.challanNumber,_that.selectedMaterialType,_that.payload,_that.verificationStatus,_that.verificationMethod,_that.portalUrl,_that.sourcePortal);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String projectId,  String financialYear,  String challanNumber,  ChallanMaterialType? selectedMaterialType,  CapturedPortalPayload payload,  ChallanVerificationStatus verificationStatus,  ChallanVerificationMethod verificationMethod,  String? portalUrl,  String sourcePortal)?  $default,) {final _that = this;
switch (_that) {
case _EPassChallanDraft() when $default != null:
return $default(_that.projectId,_that.financialYear,_that.challanNumber,_that.selectedMaterialType,_that.payload,_that.verificationStatus,_that.verificationMethod,_that.portalUrl,_that.sourcePortal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EPassChallanDraft extends EPassChallanDraft {
  const _EPassChallanDraft({required this.projectId, required this.financialYear, required this.challanNumber, this.selectedMaterialType, required this.payload, this.verificationStatus = ChallanVerificationStatus.portalCaptured, this.verificationMethod = ChallanVerificationMethod.webviewHumanVerification, this.portalUrl, this.sourcePortal = 'bihar_khanan_soft'}): super._();
  factory _EPassChallanDraft.fromJson(Map<String, dynamic> json) => _$EPassChallanDraftFromJson(json);

@override final  String projectId;
@override final  String financialYear;
/// Exactly what the user typed, tidied but not stripped.
@override final  String challanNumber;
@override final  ChallanMaterialType? selectedMaterialType;
@override final  CapturedPortalPayload payload;
@override@JsonKey() final  ChallanVerificationStatus verificationStatus;
@override@JsonKey() final  ChallanVerificationMethod verificationMethod;
@override final  String? portalUrl;
@override@JsonKey() final  String sourcePortal;

/// Create a copy of EPassChallanDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EPassChallanDraftCopyWith<_EPassChallanDraft> get copyWith => __$EPassChallanDraftCopyWithImpl<_EPassChallanDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EPassChallanDraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EPassChallanDraft&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.financialYear, financialYear) || other.financialYear == financialYear)&&(identical(other.challanNumber, challanNumber) || other.challanNumber == challanNumber)&&(identical(other.selectedMaterialType, selectedMaterialType) || other.selectedMaterialType == selectedMaterialType)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.verificationMethod, verificationMethod) || other.verificationMethod == verificationMethod)&&(identical(other.portalUrl, portalUrl) || other.portalUrl == portalUrl)&&(identical(other.sourcePortal, sourcePortal) || other.sourcePortal == sourcePortal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,projectId,financialYear,challanNumber,selectedMaterialType,payload,verificationStatus,verificationMethod,portalUrl,sourcePortal);

@override
String toString() {
  return 'EPassChallanDraft(projectId: $projectId, financialYear: $financialYear, challanNumber: $challanNumber, selectedMaterialType: $selectedMaterialType, payload: $payload, verificationStatus: $verificationStatus, verificationMethod: $verificationMethod, portalUrl: $portalUrl, sourcePortal: $sourcePortal)';
}


}

/// @nodoc
abstract mixin class _$EPassChallanDraftCopyWith<$Res> implements $EPassChallanDraftCopyWith<$Res> {
  factory _$EPassChallanDraftCopyWith(_EPassChallanDraft value, $Res Function(_EPassChallanDraft) _then) = __$EPassChallanDraftCopyWithImpl;
@override @useResult
$Res call({
 String projectId, String financialYear, String challanNumber, ChallanMaterialType? selectedMaterialType, CapturedPortalPayload payload, ChallanVerificationStatus verificationStatus, ChallanVerificationMethod verificationMethod, String? portalUrl, String sourcePortal
});


@override $CapturedPortalPayloadCopyWith<$Res> get payload;

}
/// @nodoc
class __$EPassChallanDraftCopyWithImpl<$Res>
    implements _$EPassChallanDraftCopyWith<$Res> {
  __$EPassChallanDraftCopyWithImpl(this._self, this._then);

  final _EPassChallanDraft _self;
  final $Res Function(_EPassChallanDraft) _then;

/// Create a copy of EPassChallanDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? projectId = null,Object? financialYear = null,Object? challanNumber = null,Object? selectedMaterialType = freezed,Object? payload = null,Object? verificationStatus = null,Object? verificationMethod = null,Object? portalUrl = freezed,Object? sourcePortal = null,}) {
  return _then(_EPassChallanDraft(
projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,financialYear: null == financialYear ? _self.financialYear : financialYear // ignore: cast_nullable_to_non_nullable
as String,challanNumber: null == challanNumber ? _self.challanNumber : challanNumber // ignore: cast_nullable_to_non_nullable
as String,selectedMaterialType: freezed == selectedMaterialType ? _self.selectedMaterialType : selectedMaterialType // ignore: cast_nullable_to_non_nullable
as ChallanMaterialType?,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as CapturedPortalPayload,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as ChallanVerificationStatus,verificationMethod: null == verificationMethod ? _self.verificationMethod : verificationMethod // ignore: cast_nullable_to_non_nullable
as ChallanVerificationMethod,portalUrl: freezed == portalUrl ? _self.portalUrl : portalUrl // ignore: cast_nullable_to_non_nullable
as String?,sourcePortal: null == sourcePortal ? _self.sourcePortal : sourcePortal // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of EPassChallanDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CapturedPortalPayloadCopyWith<$Res> get payload {
  
  return $CapturedPortalPayloadCopyWith<$Res>(_self.payload, (value) {
    return _then(_self.copyWith(payload: value));
  });
}
}


/// @nodoc
mixin _$EPassChallan {

 String get id; String get organizationId; String get projectId; String get sourcePortal; String? get portalUrl; String get financialYear; String get challanNumber; String get normalizedChallanNumber; String? get uidNumber; DateTime? get challanDate; DateTime? get validUntil; ChallanMaterialType? get selectedMaterialType; String get portalMineralName; double get quantity; String get quantityUnit; String? get vehicleType; String get vehicleNumber; String get normalizedVehicleNumber; String? get consignorName; String? get consigneeName; String? get sourceLocation; String? get destination; String? get generatedFrom; int? get royaltyAmountPaise; Map<String, dynamic> get portalPayload; String? get portalResponseHash; ChallanVerificationStatus get verificationStatus; ChallanVerificationMethod get verificationMethod; DateTime? get capturedAt; DateTime? get verifiedAt; String? get createdBy; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt;/// Joined for display only; not a column on `epass_challans`.
 String? get projectName;
/// Create a copy of EPassChallan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EPassChallanCopyWith<EPassChallan> get copyWith => _$EPassChallanCopyWithImpl<EPassChallan>(this as EPassChallan, _$identity);

  /// Serializes this EPassChallan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EPassChallan&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.sourcePortal, sourcePortal) || other.sourcePortal == sourcePortal)&&(identical(other.portalUrl, portalUrl) || other.portalUrl == portalUrl)&&(identical(other.financialYear, financialYear) || other.financialYear == financialYear)&&(identical(other.challanNumber, challanNumber) || other.challanNumber == challanNumber)&&(identical(other.normalizedChallanNumber, normalizedChallanNumber) || other.normalizedChallanNumber == normalizedChallanNumber)&&(identical(other.uidNumber, uidNumber) || other.uidNumber == uidNumber)&&(identical(other.challanDate, challanDate) || other.challanDate == challanDate)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.selectedMaterialType, selectedMaterialType) || other.selectedMaterialType == selectedMaterialType)&&(identical(other.portalMineralName, portalMineralName) || other.portalMineralName == portalMineralName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityUnit, quantityUnit) || other.quantityUnit == quantityUnit)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.normalizedVehicleNumber, normalizedVehicleNumber) || other.normalizedVehicleNumber == normalizedVehicleNumber)&&(identical(other.consignorName, consignorName) || other.consignorName == consignorName)&&(identical(other.consigneeName, consigneeName) || other.consigneeName == consigneeName)&&(identical(other.sourceLocation, sourceLocation) || other.sourceLocation == sourceLocation)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.generatedFrom, generatedFrom) || other.generatedFrom == generatedFrom)&&(identical(other.royaltyAmountPaise, royaltyAmountPaise) || other.royaltyAmountPaise == royaltyAmountPaise)&&const DeepCollectionEquality().equals(other.portalPayload, portalPayload)&&(identical(other.portalResponseHash, portalResponseHash) || other.portalResponseHash == portalResponseHash)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.verificationMethod, verificationMethod) || other.verificationMethod == verificationMethod)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.projectName, projectName) || other.projectName == projectName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,organizationId,projectId,sourcePortal,portalUrl,financialYear,challanNumber,normalizedChallanNumber,uidNumber,challanDate,validUntil,selectedMaterialType,portalMineralName,quantity,quantityUnit,vehicleType,vehicleNumber,normalizedVehicleNumber,consignorName,consigneeName,sourceLocation,destination,generatedFrom,royaltyAmountPaise,const DeepCollectionEquality().hash(portalPayload),portalResponseHash,verificationStatus,verificationMethod,capturedAt,verifiedAt,createdBy,createdAt,updatedAt,deletedAt,projectName]);

@override
String toString() {
  return 'EPassChallan(id: $id, organizationId: $organizationId, projectId: $projectId, sourcePortal: $sourcePortal, portalUrl: $portalUrl, financialYear: $financialYear, challanNumber: $challanNumber, normalizedChallanNumber: $normalizedChallanNumber, uidNumber: $uidNumber, challanDate: $challanDate, validUntil: $validUntil, selectedMaterialType: $selectedMaterialType, portalMineralName: $portalMineralName, quantity: $quantity, quantityUnit: $quantityUnit, vehicleType: $vehicleType, vehicleNumber: $vehicleNumber, normalizedVehicleNumber: $normalizedVehicleNumber, consignorName: $consignorName, consigneeName: $consigneeName, sourceLocation: $sourceLocation, destination: $destination, generatedFrom: $generatedFrom, royaltyAmountPaise: $royaltyAmountPaise, portalPayload: $portalPayload, portalResponseHash: $portalResponseHash, verificationStatus: $verificationStatus, verificationMethod: $verificationMethod, capturedAt: $capturedAt, verifiedAt: $verifiedAt, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, projectName: $projectName)';
}


}

/// @nodoc
abstract mixin class $EPassChallanCopyWith<$Res>  {
  factory $EPassChallanCopyWith(EPassChallan value, $Res Function(EPassChallan) _then) = _$EPassChallanCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String projectId, String sourcePortal, String? portalUrl, String financialYear, String challanNumber, String normalizedChallanNumber, String? uidNumber, DateTime? challanDate, DateTime? validUntil, ChallanMaterialType? selectedMaterialType, String portalMineralName, double quantity, String quantityUnit, String? vehicleType, String vehicleNumber, String normalizedVehicleNumber, String? consignorName, String? consigneeName, String? sourceLocation, String? destination, String? generatedFrom, int? royaltyAmountPaise, Map<String, dynamic> portalPayload, String? portalResponseHash, ChallanVerificationStatus verificationStatus, ChallanVerificationMethod verificationMethod, DateTime? capturedAt, DateTime? verifiedAt, String? createdBy, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, String? projectName
});




}
/// @nodoc
class _$EPassChallanCopyWithImpl<$Res>
    implements $EPassChallanCopyWith<$Res> {
  _$EPassChallanCopyWithImpl(this._self, this._then);

  final EPassChallan _self;
  final $Res Function(EPassChallan) _then;

/// Create a copy of EPassChallan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? projectId = null,Object? sourcePortal = null,Object? portalUrl = freezed,Object? financialYear = null,Object? challanNumber = null,Object? normalizedChallanNumber = null,Object? uidNumber = freezed,Object? challanDate = freezed,Object? validUntil = freezed,Object? selectedMaterialType = freezed,Object? portalMineralName = null,Object? quantity = null,Object? quantityUnit = null,Object? vehicleType = freezed,Object? vehicleNumber = null,Object? normalizedVehicleNumber = null,Object? consignorName = freezed,Object? consigneeName = freezed,Object? sourceLocation = freezed,Object? destination = freezed,Object? generatedFrom = freezed,Object? royaltyAmountPaise = freezed,Object? portalPayload = null,Object? portalResponseHash = freezed,Object? verificationStatus = null,Object? verificationMethod = null,Object? capturedAt = freezed,Object? verifiedAt = freezed,Object? createdBy = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? projectName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,sourcePortal: null == sourcePortal ? _self.sourcePortal : sourcePortal // ignore: cast_nullable_to_non_nullable
as String,portalUrl: freezed == portalUrl ? _self.portalUrl : portalUrl // ignore: cast_nullable_to_non_nullable
as String?,financialYear: null == financialYear ? _self.financialYear : financialYear // ignore: cast_nullable_to_non_nullable
as String,challanNumber: null == challanNumber ? _self.challanNumber : challanNumber // ignore: cast_nullable_to_non_nullable
as String,normalizedChallanNumber: null == normalizedChallanNumber ? _self.normalizedChallanNumber : normalizedChallanNumber // ignore: cast_nullable_to_non_nullable
as String,uidNumber: freezed == uidNumber ? _self.uidNumber : uidNumber // ignore: cast_nullable_to_non_nullable
as String?,challanDate: freezed == challanDate ? _self.challanDate : challanDate // ignore: cast_nullable_to_non_nullable
as DateTime?,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,selectedMaterialType: freezed == selectedMaterialType ? _self.selectedMaterialType : selectedMaterialType // ignore: cast_nullable_to_non_nullable
as ChallanMaterialType?,portalMineralName: null == portalMineralName ? _self.portalMineralName : portalMineralName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,quantityUnit: null == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as String,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,vehicleNumber: null == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String,normalizedVehicleNumber: null == normalizedVehicleNumber ? _self.normalizedVehicleNumber : normalizedVehicleNumber // ignore: cast_nullable_to_non_nullable
as String,consignorName: freezed == consignorName ? _self.consignorName : consignorName // ignore: cast_nullable_to_non_nullable
as String?,consigneeName: freezed == consigneeName ? _self.consigneeName : consigneeName // ignore: cast_nullable_to_non_nullable
as String?,sourceLocation: freezed == sourceLocation ? _self.sourceLocation : sourceLocation // ignore: cast_nullable_to_non_nullable
as String?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String?,generatedFrom: freezed == generatedFrom ? _self.generatedFrom : generatedFrom // ignore: cast_nullable_to_non_nullable
as String?,royaltyAmountPaise: freezed == royaltyAmountPaise ? _self.royaltyAmountPaise : royaltyAmountPaise // ignore: cast_nullable_to_non_nullable
as int?,portalPayload: null == portalPayload ? _self.portalPayload : portalPayload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,portalResponseHash: freezed == portalResponseHash ? _self.portalResponseHash : portalResponseHash // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as ChallanVerificationStatus,verificationMethod: null == verificationMethod ? _self.verificationMethod : verificationMethod // ignore: cast_nullable_to_non_nullable
as ChallanVerificationMethod,capturedAt: freezed == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,projectName: freezed == projectName ? _self.projectName : projectName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EPassChallan].
extension EPassChallanPatterns on EPassChallan {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EPassChallan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EPassChallan() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EPassChallan value)  $default,){
final _that = this;
switch (_that) {
case _EPassChallan():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EPassChallan value)?  $default,){
final _that = this;
switch (_that) {
case _EPassChallan() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String projectId,  String sourcePortal,  String? portalUrl,  String financialYear,  String challanNumber,  String normalizedChallanNumber,  String? uidNumber,  DateTime? challanDate,  DateTime? validUntil,  ChallanMaterialType? selectedMaterialType,  String portalMineralName,  double quantity,  String quantityUnit,  String? vehicleType,  String vehicleNumber,  String normalizedVehicleNumber,  String? consignorName,  String? consigneeName,  String? sourceLocation,  String? destination,  String? generatedFrom,  int? royaltyAmountPaise,  Map<String, dynamic> portalPayload,  String? portalResponseHash,  ChallanVerificationStatus verificationStatus,  ChallanVerificationMethod verificationMethod,  DateTime? capturedAt,  DateTime? verifiedAt,  String? createdBy,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  String? projectName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EPassChallan() when $default != null:
return $default(_that.id,_that.organizationId,_that.projectId,_that.sourcePortal,_that.portalUrl,_that.financialYear,_that.challanNumber,_that.normalizedChallanNumber,_that.uidNumber,_that.challanDate,_that.validUntil,_that.selectedMaterialType,_that.portalMineralName,_that.quantity,_that.quantityUnit,_that.vehicleType,_that.vehicleNumber,_that.normalizedVehicleNumber,_that.consignorName,_that.consigneeName,_that.sourceLocation,_that.destination,_that.generatedFrom,_that.royaltyAmountPaise,_that.portalPayload,_that.portalResponseHash,_that.verificationStatus,_that.verificationMethod,_that.capturedAt,_that.verifiedAt,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.projectName);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String projectId,  String sourcePortal,  String? portalUrl,  String financialYear,  String challanNumber,  String normalizedChallanNumber,  String? uidNumber,  DateTime? challanDate,  DateTime? validUntil,  ChallanMaterialType? selectedMaterialType,  String portalMineralName,  double quantity,  String quantityUnit,  String? vehicleType,  String vehicleNumber,  String normalizedVehicleNumber,  String? consignorName,  String? consigneeName,  String? sourceLocation,  String? destination,  String? generatedFrom,  int? royaltyAmountPaise,  Map<String, dynamic> portalPayload,  String? portalResponseHash,  ChallanVerificationStatus verificationStatus,  ChallanVerificationMethod verificationMethod,  DateTime? capturedAt,  DateTime? verifiedAt,  String? createdBy,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  String? projectName)  $default,) {final _that = this;
switch (_that) {
case _EPassChallan():
return $default(_that.id,_that.organizationId,_that.projectId,_that.sourcePortal,_that.portalUrl,_that.financialYear,_that.challanNumber,_that.normalizedChallanNumber,_that.uidNumber,_that.challanDate,_that.validUntil,_that.selectedMaterialType,_that.portalMineralName,_that.quantity,_that.quantityUnit,_that.vehicleType,_that.vehicleNumber,_that.normalizedVehicleNumber,_that.consignorName,_that.consigneeName,_that.sourceLocation,_that.destination,_that.generatedFrom,_that.royaltyAmountPaise,_that.portalPayload,_that.portalResponseHash,_that.verificationStatus,_that.verificationMethod,_that.capturedAt,_that.verifiedAt,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.projectName);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String projectId,  String sourcePortal,  String? portalUrl,  String financialYear,  String challanNumber,  String normalizedChallanNumber,  String? uidNumber,  DateTime? challanDate,  DateTime? validUntil,  ChallanMaterialType? selectedMaterialType,  String portalMineralName,  double quantity,  String quantityUnit,  String? vehicleType,  String vehicleNumber,  String normalizedVehicleNumber,  String? consignorName,  String? consigneeName,  String? sourceLocation,  String? destination,  String? generatedFrom,  int? royaltyAmountPaise,  Map<String, dynamic> portalPayload,  String? portalResponseHash,  ChallanVerificationStatus verificationStatus,  ChallanVerificationMethod verificationMethod,  DateTime? capturedAt,  DateTime? verifiedAt,  String? createdBy,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt,  String? projectName)?  $default,) {final _that = this;
switch (_that) {
case _EPassChallan() when $default != null:
return $default(_that.id,_that.organizationId,_that.projectId,_that.sourcePortal,_that.portalUrl,_that.financialYear,_that.challanNumber,_that.normalizedChallanNumber,_that.uidNumber,_that.challanDate,_that.validUntil,_that.selectedMaterialType,_that.portalMineralName,_that.quantity,_that.quantityUnit,_that.vehicleType,_that.vehicleNumber,_that.normalizedVehicleNumber,_that.consignorName,_that.consigneeName,_that.sourceLocation,_that.destination,_that.generatedFrom,_that.royaltyAmountPaise,_that.portalPayload,_that.portalResponseHash,_that.verificationStatus,_that.verificationMethod,_that.capturedAt,_that.verifiedAt,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt,_that.projectName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EPassChallan extends EPassChallan {
  const _EPassChallan({required this.id, required this.organizationId, required this.projectId, this.sourcePortal = 'bihar_khanan_soft', this.portalUrl, required this.financialYear, required this.challanNumber, required this.normalizedChallanNumber, this.uidNumber, this.challanDate, this.validUntil, this.selectedMaterialType, required this.portalMineralName, this.quantity = 0, this.quantityUnit = 'MT', this.vehicleType, required this.vehicleNumber, required this.normalizedVehicleNumber, this.consignorName, this.consigneeName, this.sourceLocation, this.destination, this.generatedFrom, this.royaltyAmountPaise, final  Map<String, dynamic> portalPayload = const <String, dynamic>{}, this.portalResponseHash, this.verificationStatus = ChallanVerificationStatus.manualUnverified, this.verificationMethod = ChallanVerificationMethod.manualEntry, this.capturedAt, this.verifiedAt, this.createdBy, this.createdAt, this.updatedAt, this.deletedAt, this.projectName}): _portalPayload = portalPayload,super._();
  factory _EPassChallan.fromJson(Map<String, dynamic> json) => _$EPassChallanFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String projectId;
@override@JsonKey() final  String sourcePortal;
@override final  String? portalUrl;
@override final  String financialYear;
@override final  String challanNumber;
@override final  String normalizedChallanNumber;
@override final  String? uidNumber;
@override final  DateTime? challanDate;
@override final  DateTime? validUntil;
@override final  ChallanMaterialType? selectedMaterialType;
@override final  String portalMineralName;
@override@JsonKey() final  double quantity;
@override@JsonKey() final  String quantityUnit;
@override final  String? vehicleType;
@override final  String vehicleNumber;
@override final  String normalizedVehicleNumber;
@override final  String? consignorName;
@override final  String? consigneeName;
@override final  String? sourceLocation;
@override final  String? destination;
@override final  String? generatedFrom;
@override final  int? royaltyAmountPaise;
 final  Map<String, dynamic> _portalPayload;
@override@JsonKey() Map<String, dynamic> get portalPayload {
  if (_portalPayload is EqualUnmodifiableMapView) return _portalPayload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_portalPayload);
}

@override final  String? portalResponseHash;
@override@JsonKey() final  ChallanVerificationStatus verificationStatus;
@override@JsonKey() final  ChallanVerificationMethod verificationMethod;
@override final  DateTime? capturedAt;
@override final  DateTime? verifiedAt;
@override final  String? createdBy;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? deletedAt;
/// Joined for display only; not a column on `epass_challans`.
@override final  String? projectName;

/// Create a copy of EPassChallan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EPassChallanCopyWith<_EPassChallan> get copyWith => __$EPassChallanCopyWithImpl<_EPassChallan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EPassChallanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EPassChallan&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.sourcePortal, sourcePortal) || other.sourcePortal == sourcePortal)&&(identical(other.portalUrl, portalUrl) || other.portalUrl == portalUrl)&&(identical(other.financialYear, financialYear) || other.financialYear == financialYear)&&(identical(other.challanNumber, challanNumber) || other.challanNumber == challanNumber)&&(identical(other.normalizedChallanNumber, normalizedChallanNumber) || other.normalizedChallanNumber == normalizedChallanNumber)&&(identical(other.uidNumber, uidNumber) || other.uidNumber == uidNumber)&&(identical(other.challanDate, challanDate) || other.challanDate == challanDate)&&(identical(other.validUntil, validUntil) || other.validUntil == validUntil)&&(identical(other.selectedMaterialType, selectedMaterialType) || other.selectedMaterialType == selectedMaterialType)&&(identical(other.portalMineralName, portalMineralName) || other.portalMineralName == portalMineralName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.quantityUnit, quantityUnit) || other.quantityUnit == quantityUnit)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.vehicleNumber, vehicleNumber) || other.vehicleNumber == vehicleNumber)&&(identical(other.normalizedVehicleNumber, normalizedVehicleNumber) || other.normalizedVehicleNumber == normalizedVehicleNumber)&&(identical(other.consignorName, consignorName) || other.consignorName == consignorName)&&(identical(other.consigneeName, consigneeName) || other.consigneeName == consigneeName)&&(identical(other.sourceLocation, sourceLocation) || other.sourceLocation == sourceLocation)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.generatedFrom, generatedFrom) || other.generatedFrom == generatedFrom)&&(identical(other.royaltyAmountPaise, royaltyAmountPaise) || other.royaltyAmountPaise == royaltyAmountPaise)&&const DeepCollectionEquality().equals(other._portalPayload, _portalPayload)&&(identical(other.portalResponseHash, portalResponseHash) || other.portalResponseHash == portalResponseHash)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus)&&(identical(other.verificationMethod, verificationMethod) || other.verificationMethod == verificationMethod)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.projectName, projectName) || other.projectName == projectName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,organizationId,projectId,sourcePortal,portalUrl,financialYear,challanNumber,normalizedChallanNumber,uidNumber,challanDate,validUntil,selectedMaterialType,portalMineralName,quantity,quantityUnit,vehicleType,vehicleNumber,normalizedVehicleNumber,consignorName,consigneeName,sourceLocation,destination,generatedFrom,royaltyAmountPaise,const DeepCollectionEquality().hash(_portalPayload),portalResponseHash,verificationStatus,verificationMethod,capturedAt,verifiedAt,createdBy,createdAt,updatedAt,deletedAt,projectName]);

@override
String toString() {
  return 'EPassChallan(id: $id, organizationId: $organizationId, projectId: $projectId, sourcePortal: $sourcePortal, portalUrl: $portalUrl, financialYear: $financialYear, challanNumber: $challanNumber, normalizedChallanNumber: $normalizedChallanNumber, uidNumber: $uidNumber, challanDate: $challanDate, validUntil: $validUntil, selectedMaterialType: $selectedMaterialType, portalMineralName: $portalMineralName, quantity: $quantity, quantityUnit: $quantityUnit, vehicleType: $vehicleType, vehicleNumber: $vehicleNumber, normalizedVehicleNumber: $normalizedVehicleNumber, consignorName: $consignorName, consigneeName: $consigneeName, sourceLocation: $sourceLocation, destination: $destination, generatedFrom: $generatedFrom, royaltyAmountPaise: $royaltyAmountPaise, portalPayload: $portalPayload, portalResponseHash: $portalResponseHash, verificationStatus: $verificationStatus, verificationMethod: $verificationMethod, capturedAt: $capturedAt, verifiedAt: $verifiedAt, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, projectName: $projectName)';
}


}

/// @nodoc
abstract mixin class _$EPassChallanCopyWith<$Res> implements $EPassChallanCopyWith<$Res> {
  factory _$EPassChallanCopyWith(_EPassChallan value, $Res Function(_EPassChallan) _then) = __$EPassChallanCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String projectId, String sourcePortal, String? portalUrl, String financialYear, String challanNumber, String normalizedChallanNumber, String? uidNumber, DateTime? challanDate, DateTime? validUntil, ChallanMaterialType? selectedMaterialType, String portalMineralName, double quantity, String quantityUnit, String? vehicleType, String vehicleNumber, String normalizedVehicleNumber, String? consignorName, String? consigneeName, String? sourceLocation, String? destination, String? generatedFrom, int? royaltyAmountPaise, Map<String, dynamic> portalPayload, String? portalResponseHash, ChallanVerificationStatus verificationStatus, ChallanVerificationMethod verificationMethod, DateTime? capturedAt, DateTime? verifiedAt, String? createdBy, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt, String? projectName
});




}
/// @nodoc
class __$EPassChallanCopyWithImpl<$Res>
    implements _$EPassChallanCopyWith<$Res> {
  __$EPassChallanCopyWithImpl(this._self, this._then);

  final _EPassChallan _self;
  final $Res Function(_EPassChallan) _then;

/// Create a copy of EPassChallan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? projectId = null,Object? sourcePortal = null,Object? portalUrl = freezed,Object? financialYear = null,Object? challanNumber = null,Object? normalizedChallanNumber = null,Object? uidNumber = freezed,Object? challanDate = freezed,Object? validUntil = freezed,Object? selectedMaterialType = freezed,Object? portalMineralName = null,Object? quantity = null,Object? quantityUnit = null,Object? vehicleType = freezed,Object? vehicleNumber = null,Object? normalizedVehicleNumber = null,Object? consignorName = freezed,Object? consigneeName = freezed,Object? sourceLocation = freezed,Object? destination = freezed,Object? generatedFrom = freezed,Object? royaltyAmountPaise = freezed,Object? portalPayload = null,Object? portalResponseHash = freezed,Object? verificationStatus = null,Object? verificationMethod = null,Object? capturedAt = freezed,Object? verifiedAt = freezed,Object? createdBy = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,Object? projectName = freezed,}) {
  return _then(_EPassChallan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,sourcePortal: null == sourcePortal ? _self.sourcePortal : sourcePortal // ignore: cast_nullable_to_non_nullable
as String,portalUrl: freezed == portalUrl ? _self.portalUrl : portalUrl // ignore: cast_nullable_to_non_nullable
as String?,financialYear: null == financialYear ? _self.financialYear : financialYear // ignore: cast_nullable_to_non_nullable
as String,challanNumber: null == challanNumber ? _self.challanNumber : challanNumber // ignore: cast_nullable_to_non_nullable
as String,normalizedChallanNumber: null == normalizedChallanNumber ? _self.normalizedChallanNumber : normalizedChallanNumber // ignore: cast_nullable_to_non_nullable
as String,uidNumber: freezed == uidNumber ? _self.uidNumber : uidNumber // ignore: cast_nullable_to_non_nullable
as String?,challanDate: freezed == challanDate ? _self.challanDate : challanDate // ignore: cast_nullable_to_non_nullable
as DateTime?,validUntil: freezed == validUntil ? _self.validUntil : validUntil // ignore: cast_nullable_to_non_nullable
as DateTime?,selectedMaterialType: freezed == selectedMaterialType ? _self.selectedMaterialType : selectedMaterialType // ignore: cast_nullable_to_non_nullable
as ChallanMaterialType?,portalMineralName: null == portalMineralName ? _self.portalMineralName : portalMineralName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,quantityUnit: null == quantityUnit ? _self.quantityUnit : quantityUnit // ignore: cast_nullable_to_non_nullable
as String,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,vehicleNumber: null == vehicleNumber ? _self.vehicleNumber : vehicleNumber // ignore: cast_nullable_to_non_nullable
as String,normalizedVehicleNumber: null == normalizedVehicleNumber ? _self.normalizedVehicleNumber : normalizedVehicleNumber // ignore: cast_nullable_to_non_nullable
as String,consignorName: freezed == consignorName ? _self.consignorName : consignorName // ignore: cast_nullable_to_non_nullable
as String?,consigneeName: freezed == consigneeName ? _self.consigneeName : consigneeName // ignore: cast_nullable_to_non_nullable
as String?,sourceLocation: freezed == sourceLocation ? _self.sourceLocation : sourceLocation // ignore: cast_nullable_to_non_nullable
as String?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String?,generatedFrom: freezed == generatedFrom ? _self.generatedFrom : generatedFrom // ignore: cast_nullable_to_non_nullable
as String?,royaltyAmountPaise: freezed == royaltyAmountPaise ? _self.royaltyAmountPaise : royaltyAmountPaise // ignore: cast_nullable_to_non_nullable
as int?,portalPayload: null == portalPayload ? _self._portalPayload : portalPayload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,portalResponseHash: freezed == portalResponseHash ? _self.portalResponseHash : portalResponseHash // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as ChallanVerificationStatus,verificationMethod: null == verificationMethod ? _self.verificationMethod : verificationMethod // ignore: cast_nullable_to_non_nullable
as ChallanVerificationMethod,capturedAt: freezed == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,projectName: freezed == projectName ? _self.projectName : projectName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ChallanFilter {

 String get query; String? get projectId; ChallanMaterialType? get materialType; ChallanVerificationStatus? get status; DateTime? get fromDate; DateTime? get toDate;
/// Create a copy of ChallanFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChallanFilterCopyWith<ChallanFilter> get copyWith => _$ChallanFilterCopyWithImpl<ChallanFilter>(this as ChallanFilter, _$identity);

  /// Serializes this ChallanFilter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChallanFilter&&(identical(other.query, query) || other.query == query)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.materialType, materialType) || other.materialType == materialType)&&(identical(other.status, status) || other.status == status)&&(identical(other.fromDate, fromDate) || other.fromDate == fromDate)&&(identical(other.toDate, toDate) || other.toDate == toDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,query,projectId,materialType,status,fromDate,toDate);

@override
String toString() {
  return 'ChallanFilter(query: $query, projectId: $projectId, materialType: $materialType, status: $status, fromDate: $fromDate, toDate: $toDate)';
}


}

/// @nodoc
abstract mixin class $ChallanFilterCopyWith<$Res>  {
  factory $ChallanFilterCopyWith(ChallanFilter value, $Res Function(ChallanFilter) _then) = _$ChallanFilterCopyWithImpl;
@useResult
$Res call({
 String query, String? projectId, ChallanMaterialType? materialType, ChallanVerificationStatus? status, DateTime? fromDate, DateTime? toDate
});




}
/// @nodoc
class _$ChallanFilterCopyWithImpl<$Res>
    implements $ChallanFilterCopyWith<$Res> {
  _$ChallanFilterCopyWithImpl(this._self, this._then);

  final ChallanFilter _self;
  final $Res Function(ChallanFilter) _then;

/// Create a copy of ChallanFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? projectId = freezed,Object? materialType = freezed,Object? status = freezed,Object? fromDate = freezed,Object? toDate = freezed,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,materialType: freezed == materialType ? _self.materialType : materialType // ignore: cast_nullable_to_non_nullable
as ChallanMaterialType?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChallanVerificationStatus?,fromDate: freezed == fromDate ? _self.fromDate : fromDate // ignore: cast_nullable_to_non_nullable
as DateTime?,toDate: freezed == toDate ? _self.toDate : toDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChallanFilter].
extension ChallanFilterPatterns on ChallanFilter {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChallanFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChallanFilter() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChallanFilter value)  $default,){
final _that = this;
switch (_that) {
case _ChallanFilter():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChallanFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ChallanFilter() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  String? projectId,  ChallanMaterialType? materialType,  ChallanVerificationStatus? status,  DateTime? fromDate,  DateTime? toDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChallanFilter() when $default != null:
return $default(_that.query,_that.projectId,_that.materialType,_that.status,_that.fromDate,_that.toDate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  String? projectId,  ChallanMaterialType? materialType,  ChallanVerificationStatus? status,  DateTime? fromDate,  DateTime? toDate)  $default,) {final _that = this;
switch (_that) {
case _ChallanFilter():
return $default(_that.query,_that.projectId,_that.materialType,_that.status,_that.fromDate,_that.toDate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  String? projectId,  ChallanMaterialType? materialType,  ChallanVerificationStatus? status,  DateTime? fromDate,  DateTime? toDate)?  $default,) {final _that = this;
switch (_that) {
case _ChallanFilter() when $default != null:
return $default(_that.query,_that.projectId,_that.materialType,_that.status,_that.fromDate,_that.toDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChallanFilter extends ChallanFilter {
  const _ChallanFilter({this.query = '', this.projectId, this.materialType, this.status, this.fromDate, this.toDate}): super._();
  factory _ChallanFilter.fromJson(Map<String, dynamic> json) => _$ChallanFilterFromJson(json);

@override@JsonKey() final  String query;
@override final  String? projectId;
@override final  ChallanMaterialType? materialType;
@override final  ChallanVerificationStatus? status;
@override final  DateTime? fromDate;
@override final  DateTime? toDate;

/// Create a copy of ChallanFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChallanFilterCopyWith<_ChallanFilter> get copyWith => __$ChallanFilterCopyWithImpl<_ChallanFilter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChallanFilterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChallanFilter&&(identical(other.query, query) || other.query == query)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.materialType, materialType) || other.materialType == materialType)&&(identical(other.status, status) || other.status == status)&&(identical(other.fromDate, fromDate) || other.fromDate == fromDate)&&(identical(other.toDate, toDate) || other.toDate == toDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,query,projectId,materialType,status,fromDate,toDate);

@override
String toString() {
  return 'ChallanFilter(query: $query, projectId: $projectId, materialType: $materialType, status: $status, fromDate: $fromDate, toDate: $toDate)';
}


}

/// @nodoc
abstract mixin class _$ChallanFilterCopyWith<$Res> implements $ChallanFilterCopyWith<$Res> {
  factory _$ChallanFilterCopyWith(_ChallanFilter value, $Res Function(_ChallanFilter) _then) = __$ChallanFilterCopyWithImpl;
@override @useResult
$Res call({
 String query, String? projectId, ChallanMaterialType? materialType, ChallanVerificationStatus? status, DateTime? fromDate, DateTime? toDate
});




}
/// @nodoc
class __$ChallanFilterCopyWithImpl<$Res>
    implements _$ChallanFilterCopyWith<$Res> {
  __$ChallanFilterCopyWithImpl(this._self, this._then);

  final _ChallanFilter _self;
  final $Res Function(_ChallanFilter) _then;

/// Create a copy of ChallanFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? projectId = freezed,Object? materialType = freezed,Object? status = freezed,Object? fromDate = freezed,Object? toDate = freezed,}) {
  return _then(_ChallanFilter(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,materialType: freezed == materialType ? _self.materialType : materialType // ignore: cast_nullable_to_non_nullable
as ChallanMaterialType?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ChallanVerificationStatus?,fromDate: freezed == fromDate ? _self.fromDate : fromDate // ignore: cast_nullable_to_non_nullable
as DateTime?,toDate: freezed == toDate ? _self.toDate : toDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
