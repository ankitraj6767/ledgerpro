// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challan_flow_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChallanFlowState {

 ChallanFlowStep get step;/// Which state government portal this entry is being captured from.
 ChallanPortal get portal; String? get projectId; ChallanMaterialType? get materialType; String get financialYear;/// Exactly what the user typed, tidied but not stripped.
 String get challanNumber;/// Result of the most recent capture attempt.
 ChallanCaptureResult? get captureResult;/// Set when the same challan already exists in this organization.
 EPassChallan? get duplicateOf;/// The saved row once step 5 succeeds.
 EPassChallan? get savedChallan; bool get isCapturing; bool get isSaving; bool get isCheckingDuplicate;/// User explicitly confirmed saving despite a material mismatch.
 bool get materialMismatchAcknowledged;/// User chose to save corrected data as a manual entry instead.
 bool get manualFallback;/// Actionable, user-safe error for the current step.
 String? get errorMessage; bool get isOffline;
/// Create a copy of ChallanFlowState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChallanFlowStateCopyWith<ChallanFlowState> get copyWith => _$ChallanFlowStateCopyWithImpl<ChallanFlowState>(this as ChallanFlowState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChallanFlowState&&(identical(other.step, step) || other.step == step)&&(identical(other.portal, portal) || other.portal == portal)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.materialType, materialType) || other.materialType == materialType)&&(identical(other.financialYear, financialYear) || other.financialYear == financialYear)&&(identical(other.challanNumber, challanNumber) || other.challanNumber == challanNumber)&&(identical(other.captureResult, captureResult) || other.captureResult == captureResult)&&(identical(other.duplicateOf, duplicateOf) || other.duplicateOf == duplicateOf)&&(identical(other.savedChallan, savedChallan) || other.savedChallan == savedChallan)&&(identical(other.isCapturing, isCapturing) || other.isCapturing == isCapturing)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isCheckingDuplicate, isCheckingDuplicate) || other.isCheckingDuplicate == isCheckingDuplicate)&&(identical(other.materialMismatchAcknowledged, materialMismatchAcknowledged) || other.materialMismatchAcknowledged == materialMismatchAcknowledged)&&(identical(other.manualFallback, manualFallback) || other.manualFallback == manualFallback)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isOffline, isOffline) || other.isOffline == isOffline));
}


@override
int get hashCode => Object.hash(runtimeType,step,portal,projectId,materialType,financialYear,challanNumber,captureResult,duplicateOf,savedChallan,isCapturing,isSaving,isCheckingDuplicate,materialMismatchAcknowledged,manualFallback,errorMessage,isOffline);

@override
String toString() {
  return 'ChallanFlowState(step: $step, portal: $portal, projectId: $projectId, materialType: $materialType, financialYear: $financialYear, challanNumber: $challanNumber, captureResult: $captureResult, duplicateOf: $duplicateOf, savedChallan: $savedChallan, isCapturing: $isCapturing, isSaving: $isSaving, isCheckingDuplicate: $isCheckingDuplicate, materialMismatchAcknowledged: $materialMismatchAcknowledged, manualFallback: $manualFallback, errorMessage: $errorMessage, isOffline: $isOffline)';
}


}

/// @nodoc
abstract mixin class $ChallanFlowStateCopyWith<$Res>  {
  factory $ChallanFlowStateCopyWith(ChallanFlowState value, $Res Function(ChallanFlowState) _then) = _$ChallanFlowStateCopyWithImpl;
@useResult
$Res call({
 ChallanFlowStep step, ChallanPortal portal, String? projectId, ChallanMaterialType? materialType, String financialYear, String challanNumber, ChallanCaptureResult? captureResult, EPassChallan? duplicateOf, EPassChallan? savedChallan, bool isCapturing, bool isSaving, bool isCheckingDuplicate, bool materialMismatchAcknowledged, bool manualFallback, String? errorMessage, bool isOffline
});


$ChallanCaptureResultCopyWith<$Res>? get captureResult;$EPassChallanCopyWith<$Res>? get duplicateOf;$EPassChallanCopyWith<$Res>? get savedChallan;

}
/// @nodoc
class _$ChallanFlowStateCopyWithImpl<$Res>
    implements $ChallanFlowStateCopyWith<$Res> {
  _$ChallanFlowStateCopyWithImpl(this._self, this._then);

  final ChallanFlowState _self;
  final $Res Function(ChallanFlowState) _then;

/// Create a copy of ChallanFlowState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? portal = null,Object? projectId = freezed,Object? materialType = freezed,Object? financialYear = null,Object? challanNumber = null,Object? captureResult = freezed,Object? duplicateOf = freezed,Object? savedChallan = freezed,Object? isCapturing = null,Object? isSaving = null,Object? isCheckingDuplicate = null,Object? materialMismatchAcknowledged = null,Object? manualFallback = null,Object? errorMessage = freezed,Object? isOffline = null,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as ChallanFlowStep,portal: null == portal ? _self.portal : portal // ignore: cast_nullable_to_non_nullable
as ChallanPortal,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,materialType: freezed == materialType ? _self.materialType : materialType // ignore: cast_nullable_to_non_nullable
as ChallanMaterialType?,financialYear: null == financialYear ? _self.financialYear : financialYear // ignore: cast_nullable_to_non_nullable
as String,challanNumber: null == challanNumber ? _self.challanNumber : challanNumber // ignore: cast_nullable_to_non_nullable
as String,captureResult: freezed == captureResult ? _self.captureResult : captureResult // ignore: cast_nullable_to_non_nullable
as ChallanCaptureResult?,duplicateOf: freezed == duplicateOf ? _self.duplicateOf : duplicateOf // ignore: cast_nullable_to_non_nullable
as EPassChallan?,savedChallan: freezed == savedChallan ? _self.savedChallan : savedChallan // ignore: cast_nullable_to_non_nullable
as EPassChallan?,isCapturing: null == isCapturing ? _self.isCapturing : isCapturing // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isCheckingDuplicate: null == isCheckingDuplicate ? _self.isCheckingDuplicate : isCheckingDuplicate // ignore: cast_nullable_to_non_nullable
as bool,materialMismatchAcknowledged: null == materialMismatchAcknowledged ? _self.materialMismatchAcknowledged : materialMismatchAcknowledged // ignore: cast_nullable_to_non_nullable
as bool,manualFallback: null == manualFallback ? _self.manualFallback : manualFallback // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isOffline: null == isOffline ? _self.isOffline : isOffline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ChallanFlowState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChallanCaptureResultCopyWith<$Res>? get captureResult {
    if (_self.captureResult == null) {
    return null;
  }

  return $ChallanCaptureResultCopyWith<$Res>(_self.captureResult!, (value) {
    return _then(_self.copyWith(captureResult: value));
  });
}/// Create a copy of ChallanFlowState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EPassChallanCopyWith<$Res>? get duplicateOf {
    if (_self.duplicateOf == null) {
    return null;
  }

  return $EPassChallanCopyWith<$Res>(_self.duplicateOf!, (value) {
    return _then(_self.copyWith(duplicateOf: value));
  });
}/// Create a copy of ChallanFlowState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EPassChallanCopyWith<$Res>? get savedChallan {
    if (_self.savedChallan == null) {
    return null;
  }

  return $EPassChallanCopyWith<$Res>(_self.savedChallan!, (value) {
    return _then(_self.copyWith(savedChallan: value));
  });
}
}


/// Adds pattern-matching-related methods to [ChallanFlowState].
extension ChallanFlowStatePatterns on ChallanFlowState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChallanFlowState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChallanFlowState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChallanFlowState value)  $default,){
final _that = this;
switch (_that) {
case _ChallanFlowState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChallanFlowState value)?  $default,){
final _that = this;
switch (_that) {
case _ChallanFlowState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ChallanFlowStep step,  ChallanPortal portal,  String? projectId,  ChallanMaterialType? materialType,  String financialYear,  String challanNumber,  ChallanCaptureResult? captureResult,  EPassChallan? duplicateOf,  EPassChallan? savedChallan,  bool isCapturing,  bool isSaving,  bool isCheckingDuplicate,  bool materialMismatchAcknowledged,  bool manualFallback,  String? errorMessage,  bool isOffline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChallanFlowState() when $default != null:
return $default(_that.step,_that.portal,_that.projectId,_that.materialType,_that.financialYear,_that.challanNumber,_that.captureResult,_that.duplicateOf,_that.savedChallan,_that.isCapturing,_that.isSaving,_that.isCheckingDuplicate,_that.materialMismatchAcknowledged,_that.manualFallback,_that.errorMessage,_that.isOffline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ChallanFlowStep step,  ChallanPortal portal,  String? projectId,  ChallanMaterialType? materialType,  String financialYear,  String challanNumber,  ChallanCaptureResult? captureResult,  EPassChallan? duplicateOf,  EPassChallan? savedChallan,  bool isCapturing,  bool isSaving,  bool isCheckingDuplicate,  bool materialMismatchAcknowledged,  bool manualFallback,  String? errorMessage,  bool isOffline)  $default,) {final _that = this;
switch (_that) {
case _ChallanFlowState():
return $default(_that.step,_that.portal,_that.projectId,_that.materialType,_that.financialYear,_that.challanNumber,_that.captureResult,_that.duplicateOf,_that.savedChallan,_that.isCapturing,_that.isSaving,_that.isCheckingDuplicate,_that.materialMismatchAcknowledged,_that.manualFallback,_that.errorMessage,_that.isOffline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ChallanFlowStep step,  ChallanPortal portal,  String? projectId,  ChallanMaterialType? materialType,  String financialYear,  String challanNumber,  ChallanCaptureResult? captureResult,  EPassChallan? duplicateOf,  EPassChallan? savedChallan,  bool isCapturing,  bool isSaving,  bool isCheckingDuplicate,  bool materialMismatchAcknowledged,  bool manualFallback,  String? errorMessage,  bool isOffline)?  $default,) {final _that = this;
switch (_that) {
case _ChallanFlowState() when $default != null:
return $default(_that.step,_that.portal,_that.projectId,_that.materialType,_that.financialYear,_that.challanNumber,_that.captureResult,_that.duplicateOf,_that.savedChallan,_that.isCapturing,_that.isSaving,_that.isCheckingDuplicate,_that.materialMismatchAcknowledged,_that.manualFallback,_that.errorMessage,_that.isOffline);case _:
  return null;

}
}

}

/// @nodoc


class _ChallanFlowState extends ChallanFlowState {
  const _ChallanFlowState({this.step = ChallanFlowStep.selection, this.portal = ChallanPortal.bihar, this.projectId, this.materialType, this.financialYear = '', this.challanNumber = '', this.captureResult, this.duplicateOf, this.savedChallan, this.isCapturing = false, this.isSaving = false, this.isCheckingDuplicate = false, this.materialMismatchAcknowledged = false, this.manualFallback = false, this.errorMessage, this.isOffline = false}): super._();
  

@override@JsonKey() final  ChallanFlowStep step;
/// Which state government portal this entry is being captured from.
@override@JsonKey() final  ChallanPortal portal;
@override final  String? projectId;
@override final  ChallanMaterialType? materialType;
@override@JsonKey() final  String financialYear;
/// Exactly what the user typed, tidied but not stripped.
@override@JsonKey() final  String challanNumber;
/// Result of the most recent capture attempt.
@override final  ChallanCaptureResult? captureResult;
/// Set when the same challan already exists in this organization.
@override final  EPassChallan? duplicateOf;
/// The saved row once step 5 succeeds.
@override final  EPassChallan? savedChallan;
@override@JsonKey() final  bool isCapturing;
@override@JsonKey() final  bool isSaving;
@override@JsonKey() final  bool isCheckingDuplicate;
/// User explicitly confirmed saving despite a material mismatch.
@override@JsonKey() final  bool materialMismatchAcknowledged;
/// User chose to save corrected data as a manual entry instead.
@override@JsonKey() final  bool manualFallback;
/// Actionable, user-safe error for the current step.
@override final  String? errorMessage;
@override@JsonKey() final  bool isOffline;

/// Create a copy of ChallanFlowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChallanFlowStateCopyWith<_ChallanFlowState> get copyWith => __$ChallanFlowStateCopyWithImpl<_ChallanFlowState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChallanFlowState&&(identical(other.step, step) || other.step == step)&&(identical(other.portal, portal) || other.portal == portal)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.materialType, materialType) || other.materialType == materialType)&&(identical(other.financialYear, financialYear) || other.financialYear == financialYear)&&(identical(other.challanNumber, challanNumber) || other.challanNumber == challanNumber)&&(identical(other.captureResult, captureResult) || other.captureResult == captureResult)&&(identical(other.duplicateOf, duplicateOf) || other.duplicateOf == duplicateOf)&&(identical(other.savedChallan, savedChallan) || other.savedChallan == savedChallan)&&(identical(other.isCapturing, isCapturing) || other.isCapturing == isCapturing)&&(identical(other.isSaving, isSaving) || other.isSaving == isSaving)&&(identical(other.isCheckingDuplicate, isCheckingDuplicate) || other.isCheckingDuplicate == isCheckingDuplicate)&&(identical(other.materialMismatchAcknowledged, materialMismatchAcknowledged) || other.materialMismatchAcknowledged == materialMismatchAcknowledged)&&(identical(other.manualFallback, manualFallback) || other.manualFallback == manualFallback)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.isOffline, isOffline) || other.isOffline == isOffline));
}


@override
int get hashCode => Object.hash(runtimeType,step,portal,projectId,materialType,financialYear,challanNumber,captureResult,duplicateOf,savedChallan,isCapturing,isSaving,isCheckingDuplicate,materialMismatchAcknowledged,manualFallback,errorMessage,isOffline);

@override
String toString() {
  return 'ChallanFlowState(step: $step, portal: $portal, projectId: $projectId, materialType: $materialType, financialYear: $financialYear, challanNumber: $challanNumber, captureResult: $captureResult, duplicateOf: $duplicateOf, savedChallan: $savedChallan, isCapturing: $isCapturing, isSaving: $isSaving, isCheckingDuplicate: $isCheckingDuplicate, materialMismatchAcknowledged: $materialMismatchAcknowledged, manualFallback: $manualFallback, errorMessage: $errorMessage, isOffline: $isOffline)';
}


}

/// @nodoc
abstract mixin class _$ChallanFlowStateCopyWith<$Res> implements $ChallanFlowStateCopyWith<$Res> {
  factory _$ChallanFlowStateCopyWith(_ChallanFlowState value, $Res Function(_ChallanFlowState) _then) = __$ChallanFlowStateCopyWithImpl;
@override @useResult
$Res call({
 ChallanFlowStep step, ChallanPortal portal, String? projectId, ChallanMaterialType? materialType, String financialYear, String challanNumber, ChallanCaptureResult? captureResult, EPassChallan? duplicateOf, EPassChallan? savedChallan, bool isCapturing, bool isSaving, bool isCheckingDuplicate, bool materialMismatchAcknowledged, bool manualFallback, String? errorMessage, bool isOffline
});


@override $ChallanCaptureResultCopyWith<$Res>? get captureResult;@override $EPassChallanCopyWith<$Res>? get duplicateOf;@override $EPassChallanCopyWith<$Res>? get savedChallan;

}
/// @nodoc
class __$ChallanFlowStateCopyWithImpl<$Res>
    implements _$ChallanFlowStateCopyWith<$Res> {
  __$ChallanFlowStateCopyWithImpl(this._self, this._then);

  final _ChallanFlowState _self;
  final $Res Function(_ChallanFlowState) _then;

/// Create a copy of ChallanFlowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? portal = null,Object? projectId = freezed,Object? materialType = freezed,Object? financialYear = null,Object? challanNumber = null,Object? captureResult = freezed,Object? duplicateOf = freezed,Object? savedChallan = freezed,Object? isCapturing = null,Object? isSaving = null,Object? isCheckingDuplicate = null,Object? materialMismatchAcknowledged = null,Object? manualFallback = null,Object? errorMessage = freezed,Object? isOffline = null,}) {
  return _then(_ChallanFlowState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as ChallanFlowStep,portal: null == portal ? _self.portal : portal // ignore: cast_nullable_to_non_nullable
as ChallanPortal,projectId: freezed == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String?,materialType: freezed == materialType ? _self.materialType : materialType // ignore: cast_nullable_to_non_nullable
as ChallanMaterialType?,financialYear: null == financialYear ? _self.financialYear : financialYear // ignore: cast_nullable_to_non_nullable
as String,challanNumber: null == challanNumber ? _self.challanNumber : challanNumber // ignore: cast_nullable_to_non_nullable
as String,captureResult: freezed == captureResult ? _self.captureResult : captureResult // ignore: cast_nullable_to_non_nullable
as ChallanCaptureResult?,duplicateOf: freezed == duplicateOf ? _self.duplicateOf : duplicateOf // ignore: cast_nullable_to_non_nullable
as EPassChallan?,savedChallan: freezed == savedChallan ? _self.savedChallan : savedChallan // ignore: cast_nullable_to_non_nullable
as EPassChallan?,isCapturing: null == isCapturing ? _self.isCapturing : isCapturing // ignore: cast_nullable_to_non_nullable
as bool,isSaving: null == isSaving ? _self.isSaving : isSaving // ignore: cast_nullable_to_non_nullable
as bool,isCheckingDuplicate: null == isCheckingDuplicate ? _self.isCheckingDuplicate : isCheckingDuplicate // ignore: cast_nullable_to_non_nullable
as bool,materialMismatchAcknowledged: null == materialMismatchAcknowledged ? _self.materialMismatchAcknowledged : materialMismatchAcknowledged // ignore: cast_nullable_to_non_nullable
as bool,manualFallback: null == manualFallback ? _self.manualFallback : manualFallback // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,isOffline: null == isOffline ? _self.isOffline : isOffline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ChallanFlowState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChallanCaptureResultCopyWith<$Res>? get captureResult {
    if (_self.captureResult == null) {
    return null;
  }

  return $ChallanCaptureResultCopyWith<$Res>(_self.captureResult!, (value) {
    return _then(_self.copyWith(captureResult: value));
  });
}/// Create a copy of ChallanFlowState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EPassChallanCopyWith<$Res>? get duplicateOf {
    if (_self.duplicateOf == null) {
    return null;
  }

  return $EPassChallanCopyWith<$Res>(_self.duplicateOf!, (value) {
    return _then(_self.copyWith(duplicateOf: value));
  });
}/// Create a copy of ChallanFlowState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EPassChallanCopyWith<$Res>? get savedChallan {
    if (_self.savedChallan == null) {
    return null;
  }

  return $EPassChallanCopyWith<$Res>(_self.savedChallan!, (value) {
    return _then(_self.copyWith(savedChallan: value));
  });
}
}

// dart format on
