// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'infra_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InfraProject {

 String get id; String get organizationId; String get name; String? get code; String? get category; String? get locationCity; String? get locationState; String? get address; InfraProjectStatus get status; DateTime? get startDate; DateTime? get expectedEndDate; DateTime? get actualEndDate; int get progressPercent; int get totalEstimatedCostPaise; int get totalInvestmentPaise; int get totalGovtSanctionedPaise; int get totalGovtReceivedPaise; int get totalExpensePaise; String? get description; String? get coverImageUrl; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt;
/// Create a copy of InfraProject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InfraProjectCopyWith<InfraProject> get copyWith => _$InfraProjectCopyWithImpl<InfraProject>(this as InfraProject, _$identity);

  /// Serializes this InfraProject to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InfraProject&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.category, category) || other.category == category)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.locationState, locationState) || other.locationState == locationState)&&(identical(other.address, address) || other.address == address)&&(identical(other.status, status) || other.status == status)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.expectedEndDate, expectedEndDate) || other.expectedEndDate == expectedEndDate)&&(identical(other.actualEndDate, actualEndDate) || other.actualEndDate == actualEndDate)&&(identical(other.progressPercent, progressPercent) || other.progressPercent == progressPercent)&&(identical(other.totalEstimatedCostPaise, totalEstimatedCostPaise) || other.totalEstimatedCostPaise == totalEstimatedCostPaise)&&(identical(other.totalInvestmentPaise, totalInvestmentPaise) || other.totalInvestmentPaise == totalInvestmentPaise)&&(identical(other.totalGovtSanctionedPaise, totalGovtSanctionedPaise) || other.totalGovtSanctionedPaise == totalGovtSanctionedPaise)&&(identical(other.totalGovtReceivedPaise, totalGovtReceivedPaise) || other.totalGovtReceivedPaise == totalGovtReceivedPaise)&&(identical(other.totalExpensePaise, totalExpensePaise) || other.totalExpensePaise == totalExpensePaise)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,organizationId,name,code,category,locationCity,locationState,address,status,startDate,expectedEndDate,actualEndDate,progressPercent,totalEstimatedCostPaise,totalInvestmentPaise,totalGovtSanctionedPaise,totalGovtReceivedPaise,totalExpensePaise,description,coverImageUrl,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'InfraProject(id: $id, organizationId: $organizationId, name: $name, code: $code, category: $category, locationCity: $locationCity, locationState: $locationState, address: $address, status: $status, startDate: $startDate, expectedEndDate: $expectedEndDate, actualEndDate: $actualEndDate, progressPercent: $progressPercent, totalEstimatedCostPaise: $totalEstimatedCostPaise, totalInvestmentPaise: $totalInvestmentPaise, totalGovtSanctionedPaise: $totalGovtSanctionedPaise, totalGovtReceivedPaise: $totalGovtReceivedPaise, totalExpensePaise: $totalExpensePaise, description: $description, coverImageUrl: $coverImageUrl, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $InfraProjectCopyWith<$Res>  {
  factory $InfraProjectCopyWith(InfraProject value, $Res Function(InfraProject) _then) = _$InfraProjectCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String name, String? code, String? category, String? locationCity, String? locationState, String? address, InfraProjectStatus status, DateTime? startDate, DateTime? expectedEndDate, DateTime? actualEndDate, int progressPercent, int totalEstimatedCostPaise, int totalInvestmentPaise, int totalGovtSanctionedPaise, int totalGovtReceivedPaise, int totalExpensePaise, String? description, String? coverImageUrl, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$InfraProjectCopyWithImpl<$Res>
    implements $InfraProjectCopyWith<$Res> {
  _$InfraProjectCopyWithImpl(this._self, this._then);

  final InfraProject _self;
  final $Res Function(InfraProject) _then;

/// Create a copy of InfraProject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? code = freezed,Object? category = freezed,Object? locationCity = freezed,Object? locationState = freezed,Object? address = freezed,Object? status = null,Object? startDate = freezed,Object? expectedEndDate = freezed,Object? actualEndDate = freezed,Object? progressPercent = null,Object? totalEstimatedCostPaise = null,Object? totalInvestmentPaise = null,Object? totalGovtSanctionedPaise = null,Object? totalGovtReceivedPaise = null,Object? totalExpensePaise = null,Object? description = freezed,Object? coverImageUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,locationCity: freezed == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String?,locationState: freezed == locationState ? _self.locationState : locationState // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InfraProjectStatus,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expectedEndDate: freezed == expectedEndDate ? _self.expectedEndDate : expectedEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,actualEndDate: freezed == actualEndDate ? _self.actualEndDate : actualEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,progressPercent: null == progressPercent ? _self.progressPercent : progressPercent // ignore: cast_nullable_to_non_nullable
as int,totalEstimatedCostPaise: null == totalEstimatedCostPaise ? _self.totalEstimatedCostPaise : totalEstimatedCostPaise // ignore: cast_nullable_to_non_nullable
as int,totalInvestmentPaise: null == totalInvestmentPaise ? _self.totalInvestmentPaise : totalInvestmentPaise // ignore: cast_nullable_to_non_nullable
as int,totalGovtSanctionedPaise: null == totalGovtSanctionedPaise ? _self.totalGovtSanctionedPaise : totalGovtSanctionedPaise // ignore: cast_nullable_to_non_nullable
as int,totalGovtReceivedPaise: null == totalGovtReceivedPaise ? _self.totalGovtReceivedPaise : totalGovtReceivedPaise // ignore: cast_nullable_to_non_nullable
as int,totalExpensePaise: null == totalExpensePaise ? _self.totalExpensePaise : totalExpensePaise // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InfraProject].
extension InfraProjectPatterns on InfraProject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InfraProject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InfraProject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InfraProject value)  $default,){
final _that = this;
switch (_that) {
case _InfraProject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InfraProject value)?  $default,){
final _that = this;
switch (_that) {
case _InfraProject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String? code,  String? category,  String? locationCity,  String? locationState,  String? address,  InfraProjectStatus status,  DateTime? startDate,  DateTime? expectedEndDate,  DateTime? actualEndDate,  int progressPercent,  int totalEstimatedCostPaise,  int totalInvestmentPaise,  int totalGovtSanctionedPaise,  int totalGovtReceivedPaise,  int totalExpensePaise,  String? description,  String? coverImageUrl,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InfraProject() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.code,_that.category,_that.locationCity,_that.locationState,_that.address,_that.status,_that.startDate,_that.expectedEndDate,_that.actualEndDate,_that.progressPercent,_that.totalEstimatedCostPaise,_that.totalInvestmentPaise,_that.totalGovtSanctionedPaise,_that.totalGovtReceivedPaise,_that.totalExpensePaise,_that.description,_that.coverImageUrl,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String? code,  String? category,  String? locationCity,  String? locationState,  String? address,  InfraProjectStatus status,  DateTime? startDate,  DateTime? expectedEndDate,  DateTime? actualEndDate,  int progressPercent,  int totalEstimatedCostPaise,  int totalInvestmentPaise,  int totalGovtSanctionedPaise,  int totalGovtReceivedPaise,  int totalExpensePaise,  String? description,  String? coverImageUrl,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _InfraProject():
return $default(_that.id,_that.organizationId,_that.name,_that.code,_that.category,_that.locationCity,_that.locationState,_that.address,_that.status,_that.startDate,_that.expectedEndDate,_that.actualEndDate,_that.progressPercent,_that.totalEstimatedCostPaise,_that.totalInvestmentPaise,_that.totalGovtSanctionedPaise,_that.totalGovtReceivedPaise,_that.totalExpensePaise,_that.description,_that.coverImageUrl,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String name,  String? code,  String? category,  String? locationCity,  String? locationState,  String? address,  InfraProjectStatus status,  DateTime? startDate,  DateTime? expectedEndDate,  DateTime? actualEndDate,  int progressPercent,  int totalEstimatedCostPaise,  int totalInvestmentPaise,  int totalGovtSanctionedPaise,  int totalGovtReceivedPaise,  int totalExpensePaise,  String? description,  String? coverImageUrl,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _InfraProject() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.code,_that.category,_that.locationCity,_that.locationState,_that.address,_that.status,_that.startDate,_that.expectedEndDate,_that.actualEndDate,_that.progressPercent,_that.totalEstimatedCostPaise,_that.totalInvestmentPaise,_that.totalGovtSanctionedPaise,_that.totalGovtReceivedPaise,_that.totalExpensePaise,_that.description,_that.coverImageUrl,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InfraProject implements InfraProject {
  const _InfraProject({required this.id, required this.organizationId, required this.name, this.code, this.category, this.locationCity, this.locationState, this.address, this.status = InfraProjectStatus.planning, this.startDate, this.expectedEndDate, this.actualEndDate, this.progressPercent = 0, this.totalEstimatedCostPaise = 0, this.totalInvestmentPaise = 0, this.totalGovtSanctionedPaise = 0, this.totalGovtReceivedPaise = 0, this.totalExpensePaise = 0, this.description, this.coverImageUrl, this.createdAt, this.updatedAt, this.deletedAt});
  factory _InfraProject.fromJson(Map<String, dynamic> json) => _$InfraProjectFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String name;
@override final  String? code;
@override final  String? category;
@override final  String? locationCity;
@override final  String? locationState;
@override final  String? address;
@override@JsonKey() final  InfraProjectStatus status;
@override final  DateTime? startDate;
@override final  DateTime? expectedEndDate;
@override final  DateTime? actualEndDate;
@override@JsonKey() final  int progressPercent;
@override@JsonKey() final  int totalEstimatedCostPaise;
@override@JsonKey() final  int totalInvestmentPaise;
@override@JsonKey() final  int totalGovtSanctionedPaise;
@override@JsonKey() final  int totalGovtReceivedPaise;
@override@JsonKey() final  int totalExpensePaise;
@override final  String? description;
@override final  String? coverImageUrl;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of InfraProject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InfraProjectCopyWith<_InfraProject> get copyWith => __$InfraProjectCopyWithImpl<_InfraProject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InfraProjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InfraProject&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.category, category) || other.category == category)&&(identical(other.locationCity, locationCity) || other.locationCity == locationCity)&&(identical(other.locationState, locationState) || other.locationState == locationState)&&(identical(other.address, address) || other.address == address)&&(identical(other.status, status) || other.status == status)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.expectedEndDate, expectedEndDate) || other.expectedEndDate == expectedEndDate)&&(identical(other.actualEndDate, actualEndDate) || other.actualEndDate == actualEndDate)&&(identical(other.progressPercent, progressPercent) || other.progressPercent == progressPercent)&&(identical(other.totalEstimatedCostPaise, totalEstimatedCostPaise) || other.totalEstimatedCostPaise == totalEstimatedCostPaise)&&(identical(other.totalInvestmentPaise, totalInvestmentPaise) || other.totalInvestmentPaise == totalInvestmentPaise)&&(identical(other.totalGovtSanctionedPaise, totalGovtSanctionedPaise) || other.totalGovtSanctionedPaise == totalGovtSanctionedPaise)&&(identical(other.totalGovtReceivedPaise, totalGovtReceivedPaise) || other.totalGovtReceivedPaise == totalGovtReceivedPaise)&&(identical(other.totalExpensePaise, totalExpensePaise) || other.totalExpensePaise == totalExpensePaise)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageUrl, coverImageUrl) || other.coverImageUrl == coverImageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,organizationId,name,code,category,locationCity,locationState,address,status,startDate,expectedEndDate,actualEndDate,progressPercent,totalEstimatedCostPaise,totalInvestmentPaise,totalGovtSanctionedPaise,totalGovtReceivedPaise,totalExpensePaise,description,coverImageUrl,createdAt,updatedAt,deletedAt]);

@override
String toString() {
  return 'InfraProject(id: $id, organizationId: $organizationId, name: $name, code: $code, category: $category, locationCity: $locationCity, locationState: $locationState, address: $address, status: $status, startDate: $startDate, expectedEndDate: $expectedEndDate, actualEndDate: $actualEndDate, progressPercent: $progressPercent, totalEstimatedCostPaise: $totalEstimatedCostPaise, totalInvestmentPaise: $totalInvestmentPaise, totalGovtSanctionedPaise: $totalGovtSanctionedPaise, totalGovtReceivedPaise: $totalGovtReceivedPaise, totalExpensePaise: $totalExpensePaise, description: $description, coverImageUrl: $coverImageUrl, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$InfraProjectCopyWith<$Res> implements $InfraProjectCopyWith<$Res> {
  factory _$InfraProjectCopyWith(_InfraProject value, $Res Function(_InfraProject) _then) = __$InfraProjectCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String name, String? code, String? category, String? locationCity, String? locationState, String? address, InfraProjectStatus status, DateTime? startDate, DateTime? expectedEndDate, DateTime? actualEndDate, int progressPercent, int totalEstimatedCostPaise, int totalInvestmentPaise, int totalGovtSanctionedPaise, int totalGovtReceivedPaise, int totalExpensePaise, String? description, String? coverImageUrl, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$InfraProjectCopyWithImpl<$Res>
    implements _$InfraProjectCopyWith<$Res> {
  __$InfraProjectCopyWithImpl(this._self, this._then);

  final _InfraProject _self;
  final $Res Function(_InfraProject) _then;

/// Create a copy of InfraProject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? code = freezed,Object? category = freezed,Object? locationCity = freezed,Object? locationState = freezed,Object? address = freezed,Object? status = null,Object? startDate = freezed,Object? expectedEndDate = freezed,Object? actualEndDate = freezed,Object? progressPercent = null,Object? totalEstimatedCostPaise = null,Object? totalInvestmentPaise = null,Object? totalGovtSanctionedPaise = null,Object? totalGovtReceivedPaise = null,Object? totalExpensePaise = null,Object? description = freezed,Object? coverImageUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_InfraProject(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,locationCity: freezed == locationCity ? _self.locationCity : locationCity // ignore: cast_nullable_to_non_nullable
as String?,locationState: freezed == locationState ? _self.locationState : locationState // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InfraProjectStatus,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,expectedEndDate: freezed == expectedEndDate ? _self.expectedEndDate : expectedEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,actualEndDate: freezed == actualEndDate ? _self.actualEndDate : actualEndDate // ignore: cast_nullable_to_non_nullable
as DateTime?,progressPercent: null == progressPercent ? _self.progressPercent : progressPercent // ignore: cast_nullable_to_non_nullable
as int,totalEstimatedCostPaise: null == totalEstimatedCostPaise ? _self.totalEstimatedCostPaise : totalEstimatedCostPaise // ignore: cast_nullable_to_non_nullable
as int,totalInvestmentPaise: null == totalInvestmentPaise ? _self.totalInvestmentPaise : totalInvestmentPaise // ignore: cast_nullable_to_non_nullable
as int,totalGovtSanctionedPaise: null == totalGovtSanctionedPaise ? _self.totalGovtSanctionedPaise : totalGovtSanctionedPaise // ignore: cast_nullable_to_non_nullable
as int,totalGovtReceivedPaise: null == totalGovtReceivedPaise ? _self.totalGovtReceivedPaise : totalGovtReceivedPaise // ignore: cast_nullable_to_non_nullable
as int,totalExpensePaise: null == totalExpensePaise ? _self.totalExpensePaise : totalExpensePaise // ignore: cast_nullable_to_non_nullable
as int,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverImageUrl: freezed == coverImageUrl ? _self.coverImageUrl : coverImageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Investor {

 String get id; String get organizationId; String get name; String? get phone; String? get email; String? get address; String? get pan; String? get notes; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt;
/// Create a copy of Investor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvestorCopyWith<Investor> get copyWith => _$InvestorCopyWithImpl<Investor>(this as Investor, _$identity);

  /// Serializes this Investor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Investor&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.address, address) || other.address == address)&&(identical(other.pan, pan) || other.pan == pan)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,name,phone,email,address,pan,notes,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'Investor(id: $id, organizationId: $organizationId, name: $name, phone: $phone, email: $email, address: $address, pan: $pan, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $InvestorCopyWith<$Res>  {
  factory $InvestorCopyWith(Investor value, $Res Function(Investor) _then) = _$InvestorCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String name, String? phone, String? email, String? address, String? pan, String? notes, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$InvestorCopyWithImpl<$Res>
    implements $InvestorCopyWith<$Res> {
  _$InvestorCopyWithImpl(this._self, this._then);

  final Investor _self;
  final $Res Function(Investor) _then;

/// Create a copy of Investor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? phone = freezed,Object? email = freezed,Object? address = freezed,Object? pan = freezed,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,pan: freezed == pan ? _self.pan : pan // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Investor].
extension InvestorPatterns on Investor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Investor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Investor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Investor value)  $default,){
final _that = this;
switch (_that) {
case _Investor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Investor value)?  $default,){
final _that = this;
switch (_that) {
case _Investor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String? phone,  String? email,  String? address,  String? pan,  String? notes,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Investor() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.phone,_that.email,_that.address,_that.pan,_that.notes,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String? phone,  String? email,  String? address,  String? pan,  String? notes,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Investor():
return $default(_that.id,_that.organizationId,_that.name,_that.phone,_that.email,_that.address,_that.pan,_that.notes,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String name,  String? phone,  String? email,  String? address,  String? pan,  String? notes,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Investor() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.phone,_that.email,_that.address,_that.pan,_that.notes,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Investor implements Investor {
  const _Investor({required this.id, required this.organizationId, required this.name, this.phone, this.email, this.address, this.pan, this.notes, this.createdAt, this.updatedAt, this.deletedAt});
  factory _Investor.fromJson(Map<String, dynamic> json) => _$InvestorFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String name;
@override final  String? phone;
@override final  String? email;
@override final  String? address;
@override final  String? pan;
@override final  String? notes;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of Investor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvestorCopyWith<_Investor> get copyWith => __$InvestorCopyWithImpl<_Investor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvestorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Investor&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.address, address) || other.address == address)&&(identical(other.pan, pan) || other.pan == pan)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,name,phone,email,address,pan,notes,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'Investor(id: $id, organizationId: $organizationId, name: $name, phone: $phone, email: $email, address: $address, pan: $pan, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$InvestorCopyWith<$Res> implements $InvestorCopyWith<$Res> {
  factory _$InvestorCopyWith(_Investor value, $Res Function(_Investor) _then) = __$InvestorCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String name, String? phone, String? email, String? address, String? pan, String? notes, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$InvestorCopyWithImpl<$Res>
    implements _$InvestorCopyWith<$Res> {
  __$InvestorCopyWithImpl(this._self, this._then);

  final _Investor _self;
  final $Res Function(_Investor) _then;

/// Create a copy of Investor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? phone = freezed,Object? email = freezed,Object? address = freezed,Object? pan = freezed,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_Investor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,pan: freezed == pan ? _self.pan : pan // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ProjectInvestment {

 String get id; String get projectId; String get investorId; int get amountPaise; DateTime? get investmentDate; String get paymentMode; String? get referenceNumber; String? get notes; String? get investorName; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt;
/// Create a copy of ProjectInvestment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectInvestmentCopyWith<ProjectInvestment> get copyWith => _$ProjectInvestmentCopyWithImpl<ProjectInvestment>(this as ProjectInvestment, _$identity);

  /// Serializes this ProjectInvestment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectInvestment&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.investorId, investorId) || other.investorId == investorId)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.investmentDate, investmentDate) || other.investmentDate == investmentDate)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.investorName, investorName) || other.investorName == investorName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,investorId,amountPaise,investmentDate,paymentMode,referenceNumber,notes,investorName,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'ProjectInvestment(id: $id, projectId: $projectId, investorId: $investorId, amountPaise: $amountPaise, investmentDate: $investmentDate, paymentMode: $paymentMode, referenceNumber: $referenceNumber, notes: $notes, investorName: $investorName, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $ProjectInvestmentCopyWith<$Res>  {
  factory $ProjectInvestmentCopyWith(ProjectInvestment value, $Res Function(ProjectInvestment) _then) = _$ProjectInvestmentCopyWithImpl;
@useResult
$Res call({
 String id, String projectId, String investorId, int amountPaise, DateTime? investmentDate, String paymentMode, String? referenceNumber, String? notes, String? investorName, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$ProjectInvestmentCopyWithImpl<$Res>
    implements $ProjectInvestmentCopyWith<$Res> {
  _$ProjectInvestmentCopyWithImpl(this._self, this._then);

  final ProjectInvestment _self;
  final $Res Function(ProjectInvestment) _then;

/// Create a copy of ProjectInvestment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? investorId = null,Object? amountPaise = null,Object? investmentDate = freezed,Object? paymentMode = null,Object? referenceNumber = freezed,Object? notes = freezed,Object? investorName = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,investorId: null == investorId ? _self.investorId : investorId // ignore: cast_nullable_to_non_nullable
as String,amountPaise: null == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int,investmentDate: freezed == investmentDate ? _self.investmentDate : investmentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,referenceNumber: freezed == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,investorName: freezed == investorName ? _self.investorName : investorName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectInvestment].
extension ProjectInvestmentPatterns on ProjectInvestment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectInvestment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectInvestment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectInvestment value)  $default,){
final _that = this;
switch (_that) {
case _ProjectInvestment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectInvestment value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectInvestment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String projectId,  String investorId,  int amountPaise,  DateTime? investmentDate,  String paymentMode,  String? referenceNumber,  String? notes,  String? investorName,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectInvestment() when $default != null:
return $default(_that.id,_that.projectId,_that.investorId,_that.amountPaise,_that.investmentDate,_that.paymentMode,_that.referenceNumber,_that.notes,_that.investorName,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String projectId,  String investorId,  int amountPaise,  DateTime? investmentDate,  String paymentMode,  String? referenceNumber,  String? notes,  String? investorName,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _ProjectInvestment():
return $default(_that.id,_that.projectId,_that.investorId,_that.amountPaise,_that.investmentDate,_that.paymentMode,_that.referenceNumber,_that.notes,_that.investorName,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String projectId,  String investorId,  int amountPaise,  DateTime? investmentDate,  String paymentMode,  String? referenceNumber,  String? notes,  String? investorName,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProjectInvestment() when $default != null:
return $default(_that.id,_that.projectId,_that.investorId,_that.amountPaise,_that.investmentDate,_that.paymentMode,_that.referenceNumber,_that.notes,_that.investorName,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectInvestment implements ProjectInvestment {
  const _ProjectInvestment({required this.id, required this.projectId, required this.investorId, this.amountPaise = 0, this.investmentDate, this.paymentMode = 'bank', this.referenceNumber, this.notes, this.investorName, this.createdAt, this.updatedAt, this.deletedAt});
  factory _ProjectInvestment.fromJson(Map<String, dynamic> json) => _$ProjectInvestmentFromJson(json);

@override final  String id;
@override final  String projectId;
@override final  String investorId;
@override@JsonKey() final  int amountPaise;
@override final  DateTime? investmentDate;
@override@JsonKey() final  String paymentMode;
@override final  String? referenceNumber;
@override final  String? notes;
@override final  String? investorName;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of ProjectInvestment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectInvestmentCopyWith<_ProjectInvestment> get copyWith => __$ProjectInvestmentCopyWithImpl<_ProjectInvestment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectInvestmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectInvestment&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.investorId, investorId) || other.investorId == investorId)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.investmentDate, investmentDate) || other.investmentDate == investmentDate)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.investorName, investorName) || other.investorName == investorName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,investorId,amountPaise,investmentDate,paymentMode,referenceNumber,notes,investorName,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'ProjectInvestment(id: $id, projectId: $projectId, investorId: $investorId, amountPaise: $amountPaise, investmentDate: $investmentDate, paymentMode: $paymentMode, referenceNumber: $referenceNumber, notes: $notes, investorName: $investorName, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$ProjectInvestmentCopyWith<$Res> implements $ProjectInvestmentCopyWith<$Res> {
  factory _$ProjectInvestmentCopyWith(_ProjectInvestment value, $Res Function(_ProjectInvestment) _then) = __$ProjectInvestmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String projectId, String investorId, int amountPaise, DateTime? investmentDate, String paymentMode, String? referenceNumber, String? notes, String? investorName, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$ProjectInvestmentCopyWithImpl<$Res>
    implements _$ProjectInvestmentCopyWith<$Res> {
  __$ProjectInvestmentCopyWithImpl(this._self, this._then);

  final _ProjectInvestment _self;
  final $Res Function(_ProjectInvestment) _then;

/// Create a copy of ProjectInvestment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? investorId = null,Object? amountPaise = null,Object? investmentDate = freezed,Object? paymentMode = null,Object? referenceNumber = freezed,Object? notes = freezed,Object? investorName = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_ProjectInvestment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,investorId: null == investorId ? _self.investorId : investorId // ignore: cast_nullable_to_non_nullable
as String,amountPaise: null == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int,investmentDate: freezed == investmentDate ? _self.investmentDate : investmentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,referenceNumber: freezed == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,investorName: freezed == investorName ? _self.investorName : investorName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$GovernmentFund {

 String get id; String get projectId; String get departmentName; String? get schemeName; String? get sanctionOrderNumber; int get amountSanctionedPaise; int get amountReceivedPaise; DateTime? get sanctionDate; DateTime? get lastReceivedDate; GovtFundStatus get status; String? get documentPath; String? get notes; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt;
/// Create a copy of GovernmentFund
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GovernmentFundCopyWith<GovernmentFund> get copyWith => _$GovernmentFundCopyWithImpl<GovernmentFund>(this as GovernmentFund, _$identity);

  /// Serializes this GovernmentFund to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GovernmentFund&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.departmentName, departmentName) || other.departmentName == departmentName)&&(identical(other.schemeName, schemeName) || other.schemeName == schemeName)&&(identical(other.sanctionOrderNumber, sanctionOrderNumber) || other.sanctionOrderNumber == sanctionOrderNumber)&&(identical(other.amountSanctionedPaise, amountSanctionedPaise) || other.amountSanctionedPaise == amountSanctionedPaise)&&(identical(other.amountReceivedPaise, amountReceivedPaise) || other.amountReceivedPaise == amountReceivedPaise)&&(identical(other.sanctionDate, sanctionDate) || other.sanctionDate == sanctionDate)&&(identical(other.lastReceivedDate, lastReceivedDate) || other.lastReceivedDate == lastReceivedDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.documentPath, documentPath) || other.documentPath == documentPath)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,departmentName,schemeName,sanctionOrderNumber,amountSanctionedPaise,amountReceivedPaise,sanctionDate,lastReceivedDate,status,documentPath,notes,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'GovernmentFund(id: $id, projectId: $projectId, departmentName: $departmentName, schemeName: $schemeName, sanctionOrderNumber: $sanctionOrderNumber, amountSanctionedPaise: $amountSanctionedPaise, amountReceivedPaise: $amountReceivedPaise, sanctionDate: $sanctionDate, lastReceivedDate: $lastReceivedDate, status: $status, documentPath: $documentPath, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $GovernmentFundCopyWith<$Res>  {
  factory $GovernmentFundCopyWith(GovernmentFund value, $Res Function(GovernmentFund) _then) = _$GovernmentFundCopyWithImpl;
@useResult
$Res call({
 String id, String projectId, String departmentName, String? schemeName, String? sanctionOrderNumber, int amountSanctionedPaise, int amountReceivedPaise, DateTime? sanctionDate, DateTime? lastReceivedDate, GovtFundStatus status, String? documentPath, String? notes, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$GovernmentFundCopyWithImpl<$Res>
    implements $GovernmentFundCopyWith<$Res> {
  _$GovernmentFundCopyWithImpl(this._self, this._then);

  final GovernmentFund _self;
  final $Res Function(GovernmentFund) _then;

/// Create a copy of GovernmentFund
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? departmentName = null,Object? schemeName = freezed,Object? sanctionOrderNumber = freezed,Object? amountSanctionedPaise = null,Object? amountReceivedPaise = null,Object? sanctionDate = freezed,Object? lastReceivedDate = freezed,Object? status = null,Object? documentPath = freezed,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,departmentName: null == departmentName ? _self.departmentName : departmentName // ignore: cast_nullable_to_non_nullable
as String,schemeName: freezed == schemeName ? _self.schemeName : schemeName // ignore: cast_nullable_to_non_nullable
as String?,sanctionOrderNumber: freezed == sanctionOrderNumber ? _self.sanctionOrderNumber : sanctionOrderNumber // ignore: cast_nullable_to_non_nullable
as String?,amountSanctionedPaise: null == amountSanctionedPaise ? _self.amountSanctionedPaise : amountSanctionedPaise // ignore: cast_nullable_to_non_nullable
as int,amountReceivedPaise: null == amountReceivedPaise ? _self.amountReceivedPaise : amountReceivedPaise // ignore: cast_nullable_to_non_nullable
as int,sanctionDate: freezed == sanctionDate ? _self.sanctionDate : sanctionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,lastReceivedDate: freezed == lastReceivedDate ? _self.lastReceivedDate : lastReceivedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GovtFundStatus,documentPath: freezed == documentPath ? _self.documentPath : documentPath // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GovernmentFund].
extension GovernmentFundPatterns on GovernmentFund {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GovernmentFund value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GovernmentFund() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GovernmentFund value)  $default,){
final _that = this;
switch (_that) {
case _GovernmentFund():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GovernmentFund value)?  $default,){
final _that = this;
switch (_that) {
case _GovernmentFund() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String projectId,  String departmentName,  String? schemeName,  String? sanctionOrderNumber,  int amountSanctionedPaise,  int amountReceivedPaise,  DateTime? sanctionDate,  DateTime? lastReceivedDate,  GovtFundStatus status,  String? documentPath,  String? notes,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GovernmentFund() when $default != null:
return $default(_that.id,_that.projectId,_that.departmentName,_that.schemeName,_that.sanctionOrderNumber,_that.amountSanctionedPaise,_that.amountReceivedPaise,_that.sanctionDate,_that.lastReceivedDate,_that.status,_that.documentPath,_that.notes,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String projectId,  String departmentName,  String? schemeName,  String? sanctionOrderNumber,  int amountSanctionedPaise,  int amountReceivedPaise,  DateTime? sanctionDate,  DateTime? lastReceivedDate,  GovtFundStatus status,  String? documentPath,  String? notes,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _GovernmentFund():
return $default(_that.id,_that.projectId,_that.departmentName,_that.schemeName,_that.sanctionOrderNumber,_that.amountSanctionedPaise,_that.amountReceivedPaise,_that.sanctionDate,_that.lastReceivedDate,_that.status,_that.documentPath,_that.notes,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String projectId,  String departmentName,  String? schemeName,  String? sanctionOrderNumber,  int amountSanctionedPaise,  int amountReceivedPaise,  DateTime? sanctionDate,  DateTime? lastReceivedDate,  GovtFundStatus status,  String? documentPath,  String? notes,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _GovernmentFund() when $default != null:
return $default(_that.id,_that.projectId,_that.departmentName,_that.schemeName,_that.sanctionOrderNumber,_that.amountSanctionedPaise,_that.amountReceivedPaise,_that.sanctionDate,_that.lastReceivedDate,_that.status,_that.documentPath,_that.notes,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GovernmentFund extends GovernmentFund {
  const _GovernmentFund({required this.id, required this.projectId, required this.departmentName, this.schemeName, this.sanctionOrderNumber, this.amountSanctionedPaise = 0, this.amountReceivedPaise = 0, this.sanctionDate, this.lastReceivedDate, this.status = GovtFundStatus.sanctioned, this.documentPath, this.notes, this.createdAt, this.updatedAt, this.deletedAt}): super._();
  factory _GovernmentFund.fromJson(Map<String, dynamic> json) => _$GovernmentFundFromJson(json);

@override final  String id;
@override final  String projectId;
@override final  String departmentName;
@override final  String? schemeName;
@override final  String? sanctionOrderNumber;
@override@JsonKey() final  int amountSanctionedPaise;
@override@JsonKey() final  int amountReceivedPaise;
@override final  DateTime? sanctionDate;
@override final  DateTime? lastReceivedDate;
@override@JsonKey() final  GovtFundStatus status;
@override final  String? documentPath;
@override final  String? notes;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of GovernmentFund
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GovernmentFundCopyWith<_GovernmentFund> get copyWith => __$GovernmentFundCopyWithImpl<_GovernmentFund>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GovernmentFundToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GovernmentFund&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.departmentName, departmentName) || other.departmentName == departmentName)&&(identical(other.schemeName, schemeName) || other.schemeName == schemeName)&&(identical(other.sanctionOrderNumber, sanctionOrderNumber) || other.sanctionOrderNumber == sanctionOrderNumber)&&(identical(other.amountSanctionedPaise, amountSanctionedPaise) || other.amountSanctionedPaise == amountSanctionedPaise)&&(identical(other.amountReceivedPaise, amountReceivedPaise) || other.amountReceivedPaise == amountReceivedPaise)&&(identical(other.sanctionDate, sanctionDate) || other.sanctionDate == sanctionDate)&&(identical(other.lastReceivedDate, lastReceivedDate) || other.lastReceivedDate == lastReceivedDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.documentPath, documentPath) || other.documentPath == documentPath)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,departmentName,schemeName,sanctionOrderNumber,amountSanctionedPaise,amountReceivedPaise,sanctionDate,lastReceivedDate,status,documentPath,notes,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'GovernmentFund(id: $id, projectId: $projectId, departmentName: $departmentName, schemeName: $schemeName, sanctionOrderNumber: $sanctionOrderNumber, amountSanctionedPaise: $amountSanctionedPaise, amountReceivedPaise: $amountReceivedPaise, sanctionDate: $sanctionDate, lastReceivedDate: $lastReceivedDate, status: $status, documentPath: $documentPath, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$GovernmentFundCopyWith<$Res> implements $GovernmentFundCopyWith<$Res> {
  factory _$GovernmentFundCopyWith(_GovernmentFund value, $Res Function(_GovernmentFund) _then) = __$GovernmentFundCopyWithImpl;
@override @useResult
$Res call({
 String id, String projectId, String departmentName, String? schemeName, String? sanctionOrderNumber, int amountSanctionedPaise, int amountReceivedPaise, DateTime? sanctionDate, DateTime? lastReceivedDate, GovtFundStatus status, String? documentPath, String? notes, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$GovernmentFundCopyWithImpl<$Res>
    implements _$GovernmentFundCopyWith<$Res> {
  __$GovernmentFundCopyWithImpl(this._self, this._then);

  final _GovernmentFund _self;
  final $Res Function(_GovernmentFund) _then;

/// Create a copy of GovernmentFund
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? departmentName = null,Object? schemeName = freezed,Object? sanctionOrderNumber = freezed,Object? amountSanctionedPaise = null,Object? amountReceivedPaise = null,Object? sanctionDate = freezed,Object? lastReceivedDate = freezed,Object? status = null,Object? documentPath = freezed,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_GovernmentFund(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,departmentName: null == departmentName ? _self.departmentName : departmentName // ignore: cast_nullable_to_non_nullable
as String,schemeName: freezed == schemeName ? _self.schemeName : schemeName // ignore: cast_nullable_to_non_nullable
as String?,sanctionOrderNumber: freezed == sanctionOrderNumber ? _self.sanctionOrderNumber : sanctionOrderNumber // ignore: cast_nullable_to_non_nullable
as String?,amountSanctionedPaise: null == amountSanctionedPaise ? _self.amountSanctionedPaise : amountSanctionedPaise // ignore: cast_nullable_to_non_nullable
as int,amountReceivedPaise: null == amountReceivedPaise ? _self.amountReceivedPaise : amountReceivedPaise // ignore: cast_nullable_to_non_nullable
as int,sanctionDate: freezed == sanctionDate ? _self.sanctionDate : sanctionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,lastReceivedDate: freezed == lastReceivedDate ? _self.lastReceivedDate : lastReceivedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GovtFundStatus,documentPath: freezed == documentPath ? _self.documentPath : documentPath // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$GovernmentFundReceipt {

 String get id; String get governmentFundId; String get projectId; int get amountPaise; DateTime? get receivedDate; String get paymentMode; String? get referenceNumber; String? get documentPath; String? get notes; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt;
/// Create a copy of GovernmentFundReceipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GovernmentFundReceiptCopyWith<GovernmentFundReceipt> get copyWith => _$GovernmentFundReceiptCopyWithImpl<GovernmentFundReceipt>(this as GovernmentFundReceipt, _$identity);

  /// Serializes this GovernmentFundReceipt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GovernmentFundReceipt&&(identical(other.id, id) || other.id == id)&&(identical(other.governmentFundId, governmentFundId) || other.governmentFundId == governmentFundId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.receivedDate, receivedDate) || other.receivedDate == receivedDate)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber)&&(identical(other.documentPath, documentPath) || other.documentPath == documentPath)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,governmentFundId,projectId,amountPaise,receivedDate,paymentMode,referenceNumber,documentPath,notes,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'GovernmentFundReceipt(id: $id, governmentFundId: $governmentFundId, projectId: $projectId, amountPaise: $amountPaise, receivedDate: $receivedDate, paymentMode: $paymentMode, referenceNumber: $referenceNumber, documentPath: $documentPath, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $GovernmentFundReceiptCopyWith<$Res>  {
  factory $GovernmentFundReceiptCopyWith(GovernmentFundReceipt value, $Res Function(GovernmentFundReceipt) _then) = _$GovernmentFundReceiptCopyWithImpl;
@useResult
$Res call({
 String id, String governmentFundId, String projectId, int amountPaise, DateTime? receivedDate, String paymentMode, String? referenceNumber, String? documentPath, String? notes, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$GovernmentFundReceiptCopyWithImpl<$Res>
    implements $GovernmentFundReceiptCopyWith<$Res> {
  _$GovernmentFundReceiptCopyWithImpl(this._self, this._then);

  final GovernmentFundReceipt _self;
  final $Res Function(GovernmentFundReceipt) _then;

/// Create a copy of GovernmentFundReceipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? governmentFundId = null,Object? projectId = null,Object? amountPaise = null,Object? receivedDate = freezed,Object? paymentMode = null,Object? referenceNumber = freezed,Object? documentPath = freezed,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,governmentFundId: null == governmentFundId ? _self.governmentFundId : governmentFundId // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,amountPaise: null == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int,receivedDate: freezed == receivedDate ? _self.receivedDate : receivedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,referenceNumber: freezed == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String?,documentPath: freezed == documentPath ? _self.documentPath : documentPath // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GovernmentFundReceipt].
extension GovernmentFundReceiptPatterns on GovernmentFundReceipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GovernmentFundReceipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GovernmentFundReceipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GovernmentFundReceipt value)  $default,){
final _that = this;
switch (_that) {
case _GovernmentFundReceipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GovernmentFundReceipt value)?  $default,){
final _that = this;
switch (_that) {
case _GovernmentFundReceipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String governmentFundId,  String projectId,  int amountPaise,  DateTime? receivedDate,  String paymentMode,  String? referenceNumber,  String? documentPath,  String? notes,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GovernmentFundReceipt() when $default != null:
return $default(_that.id,_that.governmentFundId,_that.projectId,_that.amountPaise,_that.receivedDate,_that.paymentMode,_that.referenceNumber,_that.documentPath,_that.notes,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String governmentFundId,  String projectId,  int amountPaise,  DateTime? receivedDate,  String paymentMode,  String? referenceNumber,  String? documentPath,  String? notes,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _GovernmentFundReceipt():
return $default(_that.id,_that.governmentFundId,_that.projectId,_that.amountPaise,_that.receivedDate,_that.paymentMode,_that.referenceNumber,_that.documentPath,_that.notes,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String governmentFundId,  String projectId,  int amountPaise,  DateTime? receivedDate,  String paymentMode,  String? referenceNumber,  String? documentPath,  String? notes,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _GovernmentFundReceipt() when $default != null:
return $default(_that.id,_that.governmentFundId,_that.projectId,_that.amountPaise,_that.receivedDate,_that.paymentMode,_that.referenceNumber,_that.documentPath,_that.notes,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GovernmentFundReceipt implements GovernmentFundReceipt {
  const _GovernmentFundReceipt({required this.id, required this.governmentFundId, required this.projectId, this.amountPaise = 0, this.receivedDate, this.paymentMode = 'bank', this.referenceNumber, this.documentPath, this.notes, this.createdAt, this.updatedAt, this.deletedAt});
  factory _GovernmentFundReceipt.fromJson(Map<String, dynamic> json) => _$GovernmentFundReceiptFromJson(json);

@override final  String id;
@override final  String governmentFundId;
@override final  String projectId;
@override@JsonKey() final  int amountPaise;
@override final  DateTime? receivedDate;
@override@JsonKey() final  String paymentMode;
@override final  String? referenceNumber;
@override final  String? documentPath;
@override final  String? notes;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of GovernmentFundReceipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GovernmentFundReceiptCopyWith<_GovernmentFundReceipt> get copyWith => __$GovernmentFundReceiptCopyWithImpl<_GovernmentFundReceipt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GovernmentFundReceiptToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GovernmentFundReceipt&&(identical(other.id, id) || other.id == id)&&(identical(other.governmentFundId, governmentFundId) || other.governmentFundId == governmentFundId)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.receivedDate, receivedDate) || other.receivedDate == receivedDate)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber)&&(identical(other.documentPath, documentPath) || other.documentPath == documentPath)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,governmentFundId,projectId,amountPaise,receivedDate,paymentMode,referenceNumber,documentPath,notes,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'GovernmentFundReceipt(id: $id, governmentFundId: $governmentFundId, projectId: $projectId, amountPaise: $amountPaise, receivedDate: $receivedDate, paymentMode: $paymentMode, referenceNumber: $referenceNumber, documentPath: $documentPath, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$GovernmentFundReceiptCopyWith<$Res> implements $GovernmentFundReceiptCopyWith<$Res> {
  factory _$GovernmentFundReceiptCopyWith(_GovernmentFundReceipt value, $Res Function(_GovernmentFundReceipt) _then) = __$GovernmentFundReceiptCopyWithImpl;
@override @useResult
$Res call({
 String id, String governmentFundId, String projectId, int amountPaise, DateTime? receivedDate, String paymentMode, String? referenceNumber, String? documentPath, String? notes, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$GovernmentFundReceiptCopyWithImpl<$Res>
    implements _$GovernmentFundReceiptCopyWith<$Res> {
  __$GovernmentFundReceiptCopyWithImpl(this._self, this._then);

  final _GovernmentFundReceipt _self;
  final $Res Function(_GovernmentFundReceipt) _then;

/// Create a copy of GovernmentFundReceipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? governmentFundId = null,Object? projectId = null,Object? amountPaise = null,Object? receivedDate = freezed,Object? paymentMode = null,Object? referenceNumber = freezed,Object? documentPath = freezed,Object? notes = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_GovernmentFundReceipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,governmentFundId: null == governmentFundId ? _self.governmentFundId : governmentFundId // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,amountPaise: null == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int,receivedDate: freezed == receivedDate ? _self.receivedDate : receivedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,referenceNumber: freezed == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String?,documentPath: freezed == documentPath ? _self.documentPath : documentPath // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ProjectExpense {

 String get id; String get projectId; String get category; String? get vendorName; int get amountPaise; DateTime? get expenseDate; String get paymentMode; String? get billNumber; String? get billImagePath; String? get notes; String? get createdBy; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt;
/// Create a copy of ProjectExpense
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectExpenseCopyWith<ProjectExpense> get copyWith => _$ProjectExpenseCopyWithImpl<ProjectExpense>(this as ProjectExpense, _$identity);

  /// Serializes this ProjectExpense to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectExpense&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.category, category) || other.category == category)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.expenseDate, expenseDate) || other.expenseDate == expenseDate)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.billNumber, billNumber) || other.billNumber == billNumber)&&(identical(other.billImagePath, billImagePath) || other.billImagePath == billImagePath)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,category,vendorName,amountPaise,expenseDate,paymentMode,billNumber,billImagePath,notes,createdBy,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'ProjectExpense(id: $id, projectId: $projectId, category: $category, vendorName: $vendorName, amountPaise: $amountPaise, expenseDate: $expenseDate, paymentMode: $paymentMode, billNumber: $billNumber, billImagePath: $billImagePath, notes: $notes, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $ProjectExpenseCopyWith<$Res>  {
  factory $ProjectExpenseCopyWith(ProjectExpense value, $Res Function(ProjectExpense) _then) = _$ProjectExpenseCopyWithImpl;
@useResult
$Res call({
 String id, String projectId, String category, String? vendorName, int amountPaise, DateTime? expenseDate, String paymentMode, String? billNumber, String? billImagePath, String? notes, String? createdBy, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$ProjectExpenseCopyWithImpl<$Res>
    implements $ProjectExpenseCopyWith<$Res> {
  _$ProjectExpenseCopyWithImpl(this._self, this._then);

  final ProjectExpense _self;
  final $Res Function(ProjectExpense) _then;

/// Create a copy of ProjectExpense
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? category = null,Object? vendorName = freezed,Object? amountPaise = null,Object? expenseDate = freezed,Object? paymentMode = null,Object? billNumber = freezed,Object? billImagePath = freezed,Object? notes = freezed,Object? createdBy = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,vendorName: freezed == vendorName ? _self.vendorName : vendorName // ignore: cast_nullable_to_non_nullable
as String?,amountPaise: null == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int,expenseDate: freezed == expenseDate ? _self.expenseDate : expenseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,billNumber: freezed == billNumber ? _self.billNumber : billNumber // ignore: cast_nullable_to_non_nullable
as String?,billImagePath: freezed == billImagePath ? _self.billImagePath : billImagePath // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectExpense].
extension ProjectExpensePatterns on ProjectExpense {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectExpense value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectExpense() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectExpense value)  $default,){
final _that = this;
switch (_that) {
case _ProjectExpense():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectExpense value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectExpense() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String projectId,  String category,  String? vendorName,  int amountPaise,  DateTime? expenseDate,  String paymentMode,  String? billNumber,  String? billImagePath,  String? notes,  String? createdBy,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectExpense() when $default != null:
return $default(_that.id,_that.projectId,_that.category,_that.vendorName,_that.amountPaise,_that.expenseDate,_that.paymentMode,_that.billNumber,_that.billImagePath,_that.notes,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String projectId,  String category,  String? vendorName,  int amountPaise,  DateTime? expenseDate,  String paymentMode,  String? billNumber,  String? billImagePath,  String? notes,  String? createdBy,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _ProjectExpense():
return $default(_that.id,_that.projectId,_that.category,_that.vendorName,_that.amountPaise,_that.expenseDate,_that.paymentMode,_that.billNumber,_that.billImagePath,_that.notes,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String projectId,  String category,  String? vendorName,  int amountPaise,  DateTime? expenseDate,  String paymentMode,  String? billNumber,  String? billImagePath,  String? notes,  String? createdBy,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProjectExpense() when $default != null:
return $default(_that.id,_that.projectId,_that.category,_that.vendorName,_that.amountPaise,_that.expenseDate,_that.paymentMode,_that.billNumber,_that.billImagePath,_that.notes,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectExpense implements ProjectExpense {
  const _ProjectExpense({required this.id, required this.projectId, this.category = 'Miscellaneous', this.vendorName, this.amountPaise = 0, this.expenseDate, this.paymentMode = 'cash', this.billNumber, this.billImagePath, this.notes, this.createdBy, this.createdAt, this.updatedAt, this.deletedAt});
  factory _ProjectExpense.fromJson(Map<String, dynamic> json) => _$ProjectExpenseFromJson(json);

@override final  String id;
@override final  String projectId;
@override@JsonKey() final  String category;
@override final  String? vendorName;
@override@JsonKey() final  int amountPaise;
@override final  DateTime? expenseDate;
@override@JsonKey() final  String paymentMode;
@override final  String? billNumber;
@override final  String? billImagePath;
@override final  String? notes;
@override final  String? createdBy;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of ProjectExpense
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectExpenseCopyWith<_ProjectExpense> get copyWith => __$ProjectExpenseCopyWithImpl<_ProjectExpense>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectExpenseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectExpense&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.category, category) || other.category == category)&&(identical(other.vendorName, vendorName) || other.vendorName == vendorName)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.expenseDate, expenseDate) || other.expenseDate == expenseDate)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.billNumber, billNumber) || other.billNumber == billNumber)&&(identical(other.billImagePath, billImagePath) || other.billImagePath == billImagePath)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,category,vendorName,amountPaise,expenseDate,paymentMode,billNumber,billImagePath,notes,createdBy,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'ProjectExpense(id: $id, projectId: $projectId, category: $category, vendorName: $vendorName, amountPaise: $amountPaise, expenseDate: $expenseDate, paymentMode: $paymentMode, billNumber: $billNumber, billImagePath: $billImagePath, notes: $notes, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$ProjectExpenseCopyWith<$Res> implements $ProjectExpenseCopyWith<$Res> {
  factory _$ProjectExpenseCopyWith(_ProjectExpense value, $Res Function(_ProjectExpense) _then) = __$ProjectExpenseCopyWithImpl;
@override @useResult
$Res call({
 String id, String projectId, String category, String? vendorName, int amountPaise, DateTime? expenseDate, String paymentMode, String? billNumber, String? billImagePath, String? notes, String? createdBy, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$ProjectExpenseCopyWithImpl<$Res>
    implements _$ProjectExpenseCopyWith<$Res> {
  __$ProjectExpenseCopyWithImpl(this._self, this._then);

  final _ProjectExpense _self;
  final $Res Function(_ProjectExpense) _then;

/// Create a copy of ProjectExpense
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? category = null,Object? vendorName = freezed,Object? amountPaise = null,Object? expenseDate = freezed,Object? paymentMode = null,Object? billNumber = freezed,Object? billImagePath = freezed,Object? notes = freezed,Object? createdBy = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_ProjectExpense(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,vendorName: freezed == vendorName ? _self.vendorName : vendorName // ignore: cast_nullable_to_non_nullable
as String?,amountPaise: null == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int,expenseDate: freezed == expenseDate ? _self.expenseDate : expenseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,billNumber: freezed == billNumber ? _self.billNumber : billNumber // ignore: cast_nullable_to_non_nullable
as String?,billImagePath: freezed == billImagePath ? _self.billImagePath : billImagePath // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ProjectDocument {

 String get id; String get projectId; String get title; String get documentType; String get storagePath; String? get mimeType; int? get sizeBytes; String? get uploadedBy; DateTime? get createdAt; DateTime? get deletedAt;
/// Create a copy of ProjectDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectDocumentCopyWith<ProjectDocument> get copyWith => _$ProjectDocumentCopyWithImpl<ProjectDocument>(this as ProjectDocument, _$identity);

  /// Serializes this ProjectDocument to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.title, title) || other.title == title)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,title,documentType,storagePath,mimeType,sizeBytes,uploadedBy,createdAt,deletedAt);

@override
String toString() {
  return 'ProjectDocument(id: $id, projectId: $projectId, title: $title, documentType: $documentType, storagePath: $storagePath, mimeType: $mimeType, sizeBytes: $sizeBytes, uploadedBy: $uploadedBy, createdAt: $createdAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $ProjectDocumentCopyWith<$Res>  {
  factory $ProjectDocumentCopyWith(ProjectDocument value, $Res Function(ProjectDocument) _then) = _$ProjectDocumentCopyWithImpl;
@useResult
$Res call({
 String id, String projectId, String title, String documentType, String storagePath, String? mimeType, int? sizeBytes, String? uploadedBy, DateTime? createdAt, DateTime? deletedAt
});




}
/// @nodoc
class _$ProjectDocumentCopyWithImpl<$Res>
    implements $ProjectDocumentCopyWith<$Res> {
  _$ProjectDocumentCopyWithImpl(this._self, this._then);

  final ProjectDocument _self;
  final $Res Function(ProjectDocument) _then;

/// Create a copy of ProjectDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? title = null,Object? documentType = null,Object? storagePath = null,Object? mimeType = freezed,Object? sizeBytes = freezed,Object? uploadedBy = freezed,Object? createdAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,uploadedBy: freezed == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectDocument].
extension ProjectDocumentPatterns on ProjectDocument {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectDocument() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectDocument value)  $default,){
final _that = this;
switch (_that) {
case _ProjectDocument():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectDocument value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectDocument() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String projectId,  String title,  String documentType,  String storagePath,  String? mimeType,  int? sizeBytes,  String? uploadedBy,  DateTime? createdAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectDocument() when $default != null:
return $default(_that.id,_that.projectId,_that.title,_that.documentType,_that.storagePath,_that.mimeType,_that.sizeBytes,_that.uploadedBy,_that.createdAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String projectId,  String title,  String documentType,  String storagePath,  String? mimeType,  int? sizeBytes,  String? uploadedBy,  DateTime? createdAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _ProjectDocument():
return $default(_that.id,_that.projectId,_that.title,_that.documentType,_that.storagePath,_that.mimeType,_that.sizeBytes,_that.uploadedBy,_that.createdAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String projectId,  String title,  String documentType,  String storagePath,  String? mimeType,  int? sizeBytes,  String? uploadedBy,  DateTime? createdAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProjectDocument() when $default != null:
return $default(_that.id,_that.projectId,_that.title,_that.documentType,_that.storagePath,_that.mimeType,_that.sizeBytes,_that.uploadedBy,_that.createdAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectDocument implements ProjectDocument {
  const _ProjectDocument({required this.id, required this.projectId, required this.title, this.documentType = 'other', required this.storagePath, this.mimeType, this.sizeBytes, this.uploadedBy, this.createdAt, this.deletedAt});
  factory _ProjectDocument.fromJson(Map<String, dynamic> json) => _$ProjectDocumentFromJson(json);

@override final  String id;
@override final  String projectId;
@override final  String title;
@override@JsonKey() final  String documentType;
@override final  String storagePath;
@override final  String? mimeType;
@override final  int? sizeBytes;
@override final  String? uploadedBy;
@override final  DateTime? createdAt;
@override final  DateTime? deletedAt;

/// Create a copy of ProjectDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectDocumentCopyWith<_ProjectDocument> get copyWith => __$ProjectDocumentCopyWithImpl<_ProjectDocument>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectDocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectDocument&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.title, title) || other.title == title)&&(identical(other.documentType, documentType) || other.documentType == documentType)&&(identical(other.storagePath, storagePath) || other.storagePath == storagePath)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,title,documentType,storagePath,mimeType,sizeBytes,uploadedBy,createdAt,deletedAt);

@override
String toString() {
  return 'ProjectDocument(id: $id, projectId: $projectId, title: $title, documentType: $documentType, storagePath: $storagePath, mimeType: $mimeType, sizeBytes: $sizeBytes, uploadedBy: $uploadedBy, createdAt: $createdAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$ProjectDocumentCopyWith<$Res> implements $ProjectDocumentCopyWith<$Res> {
  factory _$ProjectDocumentCopyWith(_ProjectDocument value, $Res Function(_ProjectDocument) _then) = __$ProjectDocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, String projectId, String title, String documentType, String storagePath, String? mimeType, int? sizeBytes, String? uploadedBy, DateTime? createdAt, DateTime? deletedAt
});




}
/// @nodoc
class __$ProjectDocumentCopyWithImpl<$Res>
    implements _$ProjectDocumentCopyWith<$Res> {
  __$ProjectDocumentCopyWithImpl(this._self, this._then);

  final _ProjectDocument _self;
  final $Res Function(_ProjectDocument) _then;

/// Create a copy of ProjectDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? title = null,Object? documentType = null,Object? storagePath = null,Object? mimeType = freezed,Object? sizeBytes = freezed,Object? uploadedBy = freezed,Object? createdAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_ProjectDocument(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,documentType: null == documentType ? _self.documentType : documentType // ignore: cast_nullable_to_non_nullable
as String,storagePath: null == storagePath ? _self.storagePath : storagePath // ignore: cast_nullable_to_non_nullable
as String,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,uploadedBy: freezed == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ProjectNote {

 String get id; String get projectId; String get note; String? get createdBy; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt;
/// Create a copy of ProjectNote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectNoteCopyWith<ProjectNote> get copyWith => _$ProjectNoteCopyWithImpl<ProjectNote>(this as ProjectNote, _$identity);

  /// Serializes this ProjectNote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectNote&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,note,createdBy,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'ProjectNote(id: $id, projectId: $projectId, note: $note, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $ProjectNoteCopyWith<$Res>  {
  factory $ProjectNoteCopyWith(ProjectNote value, $Res Function(ProjectNote) _then) = _$ProjectNoteCopyWithImpl;
@useResult
$Res call({
 String id, String projectId, String note, String? createdBy, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$ProjectNoteCopyWithImpl<$Res>
    implements $ProjectNoteCopyWith<$Res> {
  _$ProjectNoteCopyWithImpl(this._self, this._then);

  final ProjectNote _self;
  final $Res Function(ProjectNote) _then;

/// Create a copy of ProjectNote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? note = null,Object? createdBy = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectNote].
extension ProjectNotePatterns on ProjectNote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectNote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectNote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectNote value)  $default,){
final _that = this;
switch (_that) {
case _ProjectNote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectNote value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectNote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String projectId,  String note,  String? createdBy,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectNote() when $default != null:
return $default(_that.id,_that.projectId,_that.note,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String projectId,  String note,  String? createdBy,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _ProjectNote():
return $default(_that.id,_that.projectId,_that.note,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String projectId,  String note,  String? createdBy,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProjectNote() when $default != null:
return $default(_that.id,_that.projectId,_that.note,_that.createdBy,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectNote implements ProjectNote {
  const _ProjectNote({required this.id, required this.projectId, required this.note, this.createdBy, this.createdAt, this.updatedAt, this.deletedAt});
  factory _ProjectNote.fromJson(Map<String, dynamic> json) => _$ProjectNoteFromJson(json);

@override final  String id;
@override final  String projectId;
@override final  String note;
@override final  String? createdBy;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of ProjectNote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectNoteCopyWith<_ProjectNote> get copyWith => __$ProjectNoteCopyWithImpl<_ProjectNote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectNoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectNote&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,note,createdBy,createdAt,updatedAt,deletedAt);

@override
String toString() {
  return 'ProjectNote(id: $id, projectId: $projectId, note: $note, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$ProjectNoteCopyWith<$Res> implements $ProjectNoteCopyWith<$Res> {
  factory _$ProjectNoteCopyWith(_ProjectNote value, $Res Function(_ProjectNote) _then) = __$ProjectNoteCopyWithImpl;
@override @useResult
$Res call({
 String id, String projectId, String note, String? createdBy, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$ProjectNoteCopyWithImpl<$Res>
    implements _$ProjectNoteCopyWith<$Res> {
  __$ProjectNoteCopyWithImpl(this._self, this._then);

  final _ProjectNote _self;
  final $Res Function(_ProjectNote) _then;

/// Create a copy of ProjectNote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? note = null,Object? createdBy = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_ProjectNote(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$Organization {

 String get id; String get name; String? get ownerName; String? get phone; String? get address; String? get logoPath;
/// Create a copy of Organization
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrganizationCopyWith<Organization> get copyWith => _$OrganizationCopyWithImpl<Organization>(this as Organization, _$identity);

  /// Serializes this Organization to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Organization&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerName,phone,address,logoPath);

@override
String toString() {
  return 'Organization(id: $id, name: $name, ownerName: $ownerName, phone: $phone, address: $address, logoPath: $logoPath)';
}


}

/// @nodoc
abstract mixin class $OrganizationCopyWith<$Res>  {
  factory $OrganizationCopyWith(Organization value, $Res Function(Organization) _then) = _$OrganizationCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? ownerName, String? phone, String? address, String? logoPath
});




}
/// @nodoc
class _$OrganizationCopyWithImpl<$Res>
    implements $OrganizationCopyWith<$Res> {
  _$OrganizationCopyWithImpl(this._self, this._then);

  final Organization _self;
  final $Res Function(Organization) _then;

/// Create a copy of Organization
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ownerName = freezed,Object? phone = freezed,Object? address = freezed,Object? logoPath = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: freezed == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Organization].
extension OrganizationPatterns on Organization {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Organization value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Organization() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Organization value)  $default,){
final _that = this;
switch (_that) {
case _Organization():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Organization value)?  $default,){
final _that = this;
switch (_that) {
case _Organization() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? ownerName,  String? phone,  String? address,  String? logoPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Organization() when $default != null:
return $default(_that.id,_that.name,_that.ownerName,_that.phone,_that.address,_that.logoPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? ownerName,  String? phone,  String? address,  String? logoPath)  $default,) {final _that = this;
switch (_that) {
case _Organization():
return $default(_that.id,_that.name,_that.ownerName,_that.phone,_that.address,_that.logoPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? ownerName,  String? phone,  String? address,  String? logoPath)?  $default,) {final _that = this;
switch (_that) {
case _Organization() when $default != null:
return $default(_that.id,_that.name,_that.ownerName,_that.phone,_that.address,_that.logoPath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Organization implements Organization {
  const _Organization({required this.id, required this.name, this.ownerName, this.phone, this.address, this.logoPath});
  factory _Organization.fromJson(Map<String, dynamic> json) => _$OrganizationFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? ownerName;
@override final  String? phone;
@override final  String? address;
@override final  String? logoPath;

/// Create a copy of Organization
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrganizationCopyWith<_Organization> get copyWith => __$OrganizationCopyWithImpl<_Organization>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrganizationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Organization&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.address, address) || other.address == address)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerName,phone,address,logoPath);

@override
String toString() {
  return 'Organization(id: $id, name: $name, ownerName: $ownerName, phone: $phone, address: $address, logoPath: $logoPath)';
}


}

/// @nodoc
abstract mixin class _$OrganizationCopyWith<$Res> implements $OrganizationCopyWith<$Res> {
  factory _$OrganizationCopyWith(_Organization value, $Res Function(_Organization) _then) = __$OrganizationCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? ownerName, String? phone, String? address, String? logoPath
});




}
/// @nodoc
class __$OrganizationCopyWithImpl<$Res>
    implements _$OrganizationCopyWith<$Res> {
  __$OrganizationCopyWithImpl(this._self, this._then);

  final _Organization _self;
  final $Res Function(_Organization) _then;

/// Create a copy of Organization
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ownerName = freezed,Object? phone = freezed,Object? address = freezed,Object? logoPath = freezed,}) {
  return _then(_Organization(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: freezed == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$InfraDashboardSummary {

 int get totalProjects; int get activeProjects; int get completedProjects; int get delayedProjects; int get totalInvestmentPaise; int get totalGovtSanctionedPaise; int get totalGovtReceivedPaise; int get totalExpensePaise; int get pendingGovtFundsPaise;
/// Create a copy of InfraDashboardSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InfraDashboardSummaryCopyWith<InfraDashboardSummary> get copyWith => _$InfraDashboardSummaryCopyWithImpl<InfraDashboardSummary>(this as InfraDashboardSummary, _$identity);

  /// Serializes this InfraDashboardSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InfraDashboardSummary&&(identical(other.totalProjects, totalProjects) || other.totalProjects == totalProjects)&&(identical(other.activeProjects, activeProjects) || other.activeProjects == activeProjects)&&(identical(other.completedProjects, completedProjects) || other.completedProjects == completedProjects)&&(identical(other.delayedProjects, delayedProjects) || other.delayedProjects == delayedProjects)&&(identical(other.totalInvestmentPaise, totalInvestmentPaise) || other.totalInvestmentPaise == totalInvestmentPaise)&&(identical(other.totalGovtSanctionedPaise, totalGovtSanctionedPaise) || other.totalGovtSanctionedPaise == totalGovtSanctionedPaise)&&(identical(other.totalGovtReceivedPaise, totalGovtReceivedPaise) || other.totalGovtReceivedPaise == totalGovtReceivedPaise)&&(identical(other.totalExpensePaise, totalExpensePaise) || other.totalExpensePaise == totalExpensePaise)&&(identical(other.pendingGovtFundsPaise, pendingGovtFundsPaise) || other.pendingGovtFundsPaise == pendingGovtFundsPaise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalProjects,activeProjects,completedProjects,delayedProjects,totalInvestmentPaise,totalGovtSanctionedPaise,totalGovtReceivedPaise,totalExpensePaise,pendingGovtFundsPaise);

@override
String toString() {
  return 'InfraDashboardSummary(totalProjects: $totalProjects, activeProjects: $activeProjects, completedProjects: $completedProjects, delayedProjects: $delayedProjects, totalInvestmentPaise: $totalInvestmentPaise, totalGovtSanctionedPaise: $totalGovtSanctionedPaise, totalGovtReceivedPaise: $totalGovtReceivedPaise, totalExpensePaise: $totalExpensePaise, pendingGovtFundsPaise: $pendingGovtFundsPaise)';
}


}

/// @nodoc
abstract mixin class $InfraDashboardSummaryCopyWith<$Res>  {
  factory $InfraDashboardSummaryCopyWith(InfraDashboardSummary value, $Res Function(InfraDashboardSummary) _then) = _$InfraDashboardSummaryCopyWithImpl;
@useResult
$Res call({
 int totalProjects, int activeProjects, int completedProjects, int delayedProjects, int totalInvestmentPaise, int totalGovtSanctionedPaise, int totalGovtReceivedPaise, int totalExpensePaise, int pendingGovtFundsPaise
});




}
/// @nodoc
class _$InfraDashboardSummaryCopyWithImpl<$Res>
    implements $InfraDashboardSummaryCopyWith<$Res> {
  _$InfraDashboardSummaryCopyWithImpl(this._self, this._then);

  final InfraDashboardSummary _self;
  final $Res Function(InfraDashboardSummary) _then;

/// Create a copy of InfraDashboardSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalProjects = null,Object? activeProjects = null,Object? completedProjects = null,Object? delayedProjects = null,Object? totalInvestmentPaise = null,Object? totalGovtSanctionedPaise = null,Object? totalGovtReceivedPaise = null,Object? totalExpensePaise = null,Object? pendingGovtFundsPaise = null,}) {
  return _then(_self.copyWith(
totalProjects: null == totalProjects ? _self.totalProjects : totalProjects // ignore: cast_nullable_to_non_nullable
as int,activeProjects: null == activeProjects ? _self.activeProjects : activeProjects // ignore: cast_nullable_to_non_nullable
as int,completedProjects: null == completedProjects ? _self.completedProjects : completedProjects // ignore: cast_nullable_to_non_nullable
as int,delayedProjects: null == delayedProjects ? _self.delayedProjects : delayedProjects // ignore: cast_nullable_to_non_nullable
as int,totalInvestmentPaise: null == totalInvestmentPaise ? _self.totalInvestmentPaise : totalInvestmentPaise // ignore: cast_nullable_to_non_nullable
as int,totalGovtSanctionedPaise: null == totalGovtSanctionedPaise ? _self.totalGovtSanctionedPaise : totalGovtSanctionedPaise // ignore: cast_nullable_to_non_nullable
as int,totalGovtReceivedPaise: null == totalGovtReceivedPaise ? _self.totalGovtReceivedPaise : totalGovtReceivedPaise // ignore: cast_nullable_to_non_nullable
as int,totalExpensePaise: null == totalExpensePaise ? _self.totalExpensePaise : totalExpensePaise // ignore: cast_nullable_to_non_nullable
as int,pendingGovtFundsPaise: null == pendingGovtFundsPaise ? _self.pendingGovtFundsPaise : pendingGovtFundsPaise // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [InfraDashboardSummary].
extension InfraDashboardSummaryPatterns on InfraDashboardSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InfraDashboardSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InfraDashboardSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InfraDashboardSummary value)  $default,){
final _that = this;
switch (_that) {
case _InfraDashboardSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InfraDashboardSummary value)?  $default,){
final _that = this;
switch (_that) {
case _InfraDashboardSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalProjects,  int activeProjects,  int completedProjects,  int delayedProjects,  int totalInvestmentPaise,  int totalGovtSanctionedPaise,  int totalGovtReceivedPaise,  int totalExpensePaise,  int pendingGovtFundsPaise)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InfraDashboardSummary() when $default != null:
return $default(_that.totalProjects,_that.activeProjects,_that.completedProjects,_that.delayedProjects,_that.totalInvestmentPaise,_that.totalGovtSanctionedPaise,_that.totalGovtReceivedPaise,_that.totalExpensePaise,_that.pendingGovtFundsPaise);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalProjects,  int activeProjects,  int completedProjects,  int delayedProjects,  int totalInvestmentPaise,  int totalGovtSanctionedPaise,  int totalGovtReceivedPaise,  int totalExpensePaise,  int pendingGovtFundsPaise)  $default,) {final _that = this;
switch (_that) {
case _InfraDashboardSummary():
return $default(_that.totalProjects,_that.activeProjects,_that.completedProjects,_that.delayedProjects,_that.totalInvestmentPaise,_that.totalGovtSanctionedPaise,_that.totalGovtReceivedPaise,_that.totalExpensePaise,_that.pendingGovtFundsPaise);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalProjects,  int activeProjects,  int completedProjects,  int delayedProjects,  int totalInvestmentPaise,  int totalGovtSanctionedPaise,  int totalGovtReceivedPaise,  int totalExpensePaise,  int pendingGovtFundsPaise)?  $default,) {final _that = this;
switch (_that) {
case _InfraDashboardSummary() when $default != null:
return $default(_that.totalProjects,_that.activeProjects,_that.completedProjects,_that.delayedProjects,_that.totalInvestmentPaise,_that.totalGovtSanctionedPaise,_that.totalGovtReceivedPaise,_that.totalExpensePaise,_that.pendingGovtFundsPaise);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InfraDashboardSummary implements InfraDashboardSummary {
  const _InfraDashboardSummary({this.totalProjects = 0, this.activeProjects = 0, this.completedProjects = 0, this.delayedProjects = 0, this.totalInvestmentPaise = 0, this.totalGovtSanctionedPaise = 0, this.totalGovtReceivedPaise = 0, this.totalExpensePaise = 0, this.pendingGovtFundsPaise = 0});
  factory _InfraDashboardSummary.fromJson(Map<String, dynamic> json) => _$InfraDashboardSummaryFromJson(json);

@override@JsonKey() final  int totalProjects;
@override@JsonKey() final  int activeProjects;
@override@JsonKey() final  int completedProjects;
@override@JsonKey() final  int delayedProjects;
@override@JsonKey() final  int totalInvestmentPaise;
@override@JsonKey() final  int totalGovtSanctionedPaise;
@override@JsonKey() final  int totalGovtReceivedPaise;
@override@JsonKey() final  int totalExpensePaise;
@override@JsonKey() final  int pendingGovtFundsPaise;

/// Create a copy of InfraDashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InfraDashboardSummaryCopyWith<_InfraDashboardSummary> get copyWith => __$InfraDashboardSummaryCopyWithImpl<_InfraDashboardSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InfraDashboardSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InfraDashboardSummary&&(identical(other.totalProjects, totalProjects) || other.totalProjects == totalProjects)&&(identical(other.activeProjects, activeProjects) || other.activeProjects == activeProjects)&&(identical(other.completedProjects, completedProjects) || other.completedProjects == completedProjects)&&(identical(other.delayedProjects, delayedProjects) || other.delayedProjects == delayedProjects)&&(identical(other.totalInvestmentPaise, totalInvestmentPaise) || other.totalInvestmentPaise == totalInvestmentPaise)&&(identical(other.totalGovtSanctionedPaise, totalGovtSanctionedPaise) || other.totalGovtSanctionedPaise == totalGovtSanctionedPaise)&&(identical(other.totalGovtReceivedPaise, totalGovtReceivedPaise) || other.totalGovtReceivedPaise == totalGovtReceivedPaise)&&(identical(other.totalExpensePaise, totalExpensePaise) || other.totalExpensePaise == totalExpensePaise)&&(identical(other.pendingGovtFundsPaise, pendingGovtFundsPaise) || other.pendingGovtFundsPaise == pendingGovtFundsPaise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalProjects,activeProjects,completedProjects,delayedProjects,totalInvestmentPaise,totalGovtSanctionedPaise,totalGovtReceivedPaise,totalExpensePaise,pendingGovtFundsPaise);

@override
String toString() {
  return 'InfraDashboardSummary(totalProjects: $totalProjects, activeProjects: $activeProjects, completedProjects: $completedProjects, delayedProjects: $delayedProjects, totalInvestmentPaise: $totalInvestmentPaise, totalGovtSanctionedPaise: $totalGovtSanctionedPaise, totalGovtReceivedPaise: $totalGovtReceivedPaise, totalExpensePaise: $totalExpensePaise, pendingGovtFundsPaise: $pendingGovtFundsPaise)';
}


}

/// @nodoc
abstract mixin class _$InfraDashboardSummaryCopyWith<$Res> implements $InfraDashboardSummaryCopyWith<$Res> {
  factory _$InfraDashboardSummaryCopyWith(_InfraDashboardSummary value, $Res Function(_InfraDashboardSummary) _then) = __$InfraDashboardSummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalProjects, int activeProjects, int completedProjects, int delayedProjects, int totalInvestmentPaise, int totalGovtSanctionedPaise, int totalGovtReceivedPaise, int totalExpensePaise, int pendingGovtFundsPaise
});




}
/// @nodoc
class __$InfraDashboardSummaryCopyWithImpl<$Res>
    implements _$InfraDashboardSummaryCopyWith<$Res> {
  __$InfraDashboardSummaryCopyWithImpl(this._self, this._then);

  final _InfraDashboardSummary _self;
  final $Res Function(_InfraDashboardSummary) _then;

/// Create a copy of InfraDashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalProjects = null,Object? activeProjects = null,Object? completedProjects = null,Object? delayedProjects = null,Object? totalInvestmentPaise = null,Object? totalGovtSanctionedPaise = null,Object? totalGovtReceivedPaise = null,Object? totalExpensePaise = null,Object? pendingGovtFundsPaise = null,}) {
  return _then(_InfraDashboardSummary(
totalProjects: null == totalProjects ? _self.totalProjects : totalProjects // ignore: cast_nullable_to_non_nullable
as int,activeProjects: null == activeProjects ? _self.activeProjects : activeProjects // ignore: cast_nullable_to_non_nullable
as int,completedProjects: null == completedProjects ? _self.completedProjects : completedProjects // ignore: cast_nullable_to_non_nullable
as int,delayedProjects: null == delayedProjects ? _self.delayedProjects : delayedProjects // ignore: cast_nullable_to_non_nullable
as int,totalInvestmentPaise: null == totalInvestmentPaise ? _self.totalInvestmentPaise : totalInvestmentPaise // ignore: cast_nullable_to_non_nullable
as int,totalGovtSanctionedPaise: null == totalGovtSanctionedPaise ? _self.totalGovtSanctionedPaise : totalGovtSanctionedPaise // ignore: cast_nullable_to_non_nullable
as int,totalGovtReceivedPaise: null == totalGovtReceivedPaise ? _self.totalGovtReceivedPaise : totalGovtReceivedPaise // ignore: cast_nullable_to_non_nullable
as int,totalExpensePaise: null == totalExpensePaise ? _self.totalExpensePaise : totalExpensePaise // ignore: cast_nullable_to_non_nullable
as int,pendingGovtFundsPaise: null == pendingGovtFundsPaise ? _self.pendingGovtFundsPaise : pendingGovtFundsPaise // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ProjectFinancialSummary {

 int get totalInvestmentPaise; int get totalGovtSanctionedPaise; int get totalGovtReceivedPaise; int get pendingGovtPaise; int get totalExpensePaise; int get availableBalancePaise;
/// Create a copy of ProjectFinancialSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectFinancialSummaryCopyWith<ProjectFinancialSummary> get copyWith => _$ProjectFinancialSummaryCopyWithImpl<ProjectFinancialSummary>(this as ProjectFinancialSummary, _$identity);

  /// Serializes this ProjectFinancialSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectFinancialSummary&&(identical(other.totalInvestmentPaise, totalInvestmentPaise) || other.totalInvestmentPaise == totalInvestmentPaise)&&(identical(other.totalGovtSanctionedPaise, totalGovtSanctionedPaise) || other.totalGovtSanctionedPaise == totalGovtSanctionedPaise)&&(identical(other.totalGovtReceivedPaise, totalGovtReceivedPaise) || other.totalGovtReceivedPaise == totalGovtReceivedPaise)&&(identical(other.pendingGovtPaise, pendingGovtPaise) || other.pendingGovtPaise == pendingGovtPaise)&&(identical(other.totalExpensePaise, totalExpensePaise) || other.totalExpensePaise == totalExpensePaise)&&(identical(other.availableBalancePaise, availableBalancePaise) || other.availableBalancePaise == availableBalancePaise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalInvestmentPaise,totalGovtSanctionedPaise,totalGovtReceivedPaise,pendingGovtPaise,totalExpensePaise,availableBalancePaise);

@override
String toString() {
  return 'ProjectFinancialSummary(totalInvestmentPaise: $totalInvestmentPaise, totalGovtSanctionedPaise: $totalGovtSanctionedPaise, totalGovtReceivedPaise: $totalGovtReceivedPaise, pendingGovtPaise: $pendingGovtPaise, totalExpensePaise: $totalExpensePaise, availableBalancePaise: $availableBalancePaise)';
}


}

/// @nodoc
abstract mixin class $ProjectFinancialSummaryCopyWith<$Res>  {
  factory $ProjectFinancialSummaryCopyWith(ProjectFinancialSummary value, $Res Function(ProjectFinancialSummary) _then) = _$ProjectFinancialSummaryCopyWithImpl;
@useResult
$Res call({
 int totalInvestmentPaise, int totalGovtSanctionedPaise, int totalGovtReceivedPaise, int pendingGovtPaise, int totalExpensePaise, int availableBalancePaise
});




}
/// @nodoc
class _$ProjectFinancialSummaryCopyWithImpl<$Res>
    implements $ProjectFinancialSummaryCopyWith<$Res> {
  _$ProjectFinancialSummaryCopyWithImpl(this._self, this._then);

  final ProjectFinancialSummary _self;
  final $Res Function(ProjectFinancialSummary) _then;

/// Create a copy of ProjectFinancialSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalInvestmentPaise = null,Object? totalGovtSanctionedPaise = null,Object? totalGovtReceivedPaise = null,Object? pendingGovtPaise = null,Object? totalExpensePaise = null,Object? availableBalancePaise = null,}) {
  return _then(_self.copyWith(
totalInvestmentPaise: null == totalInvestmentPaise ? _self.totalInvestmentPaise : totalInvestmentPaise // ignore: cast_nullable_to_non_nullable
as int,totalGovtSanctionedPaise: null == totalGovtSanctionedPaise ? _self.totalGovtSanctionedPaise : totalGovtSanctionedPaise // ignore: cast_nullable_to_non_nullable
as int,totalGovtReceivedPaise: null == totalGovtReceivedPaise ? _self.totalGovtReceivedPaise : totalGovtReceivedPaise // ignore: cast_nullable_to_non_nullable
as int,pendingGovtPaise: null == pendingGovtPaise ? _self.pendingGovtPaise : pendingGovtPaise // ignore: cast_nullable_to_non_nullable
as int,totalExpensePaise: null == totalExpensePaise ? _self.totalExpensePaise : totalExpensePaise // ignore: cast_nullable_to_non_nullable
as int,availableBalancePaise: null == availableBalancePaise ? _self.availableBalancePaise : availableBalancePaise // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectFinancialSummary].
extension ProjectFinancialSummaryPatterns on ProjectFinancialSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectFinancialSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectFinancialSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectFinancialSummary value)  $default,){
final _that = this;
switch (_that) {
case _ProjectFinancialSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectFinancialSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectFinancialSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalInvestmentPaise,  int totalGovtSanctionedPaise,  int totalGovtReceivedPaise,  int pendingGovtPaise,  int totalExpensePaise,  int availableBalancePaise)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectFinancialSummary() when $default != null:
return $default(_that.totalInvestmentPaise,_that.totalGovtSanctionedPaise,_that.totalGovtReceivedPaise,_that.pendingGovtPaise,_that.totalExpensePaise,_that.availableBalancePaise);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalInvestmentPaise,  int totalGovtSanctionedPaise,  int totalGovtReceivedPaise,  int pendingGovtPaise,  int totalExpensePaise,  int availableBalancePaise)  $default,) {final _that = this;
switch (_that) {
case _ProjectFinancialSummary():
return $default(_that.totalInvestmentPaise,_that.totalGovtSanctionedPaise,_that.totalGovtReceivedPaise,_that.pendingGovtPaise,_that.totalExpensePaise,_that.availableBalancePaise);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalInvestmentPaise,  int totalGovtSanctionedPaise,  int totalGovtReceivedPaise,  int pendingGovtPaise,  int totalExpensePaise,  int availableBalancePaise)?  $default,) {final _that = this;
switch (_that) {
case _ProjectFinancialSummary() when $default != null:
return $default(_that.totalInvestmentPaise,_that.totalGovtSanctionedPaise,_that.totalGovtReceivedPaise,_that.pendingGovtPaise,_that.totalExpensePaise,_that.availableBalancePaise);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectFinancialSummary implements ProjectFinancialSummary {
  const _ProjectFinancialSummary({this.totalInvestmentPaise = 0, this.totalGovtSanctionedPaise = 0, this.totalGovtReceivedPaise = 0, this.pendingGovtPaise = 0, this.totalExpensePaise = 0, this.availableBalancePaise = 0});
  factory _ProjectFinancialSummary.fromJson(Map<String, dynamic> json) => _$ProjectFinancialSummaryFromJson(json);

@override@JsonKey() final  int totalInvestmentPaise;
@override@JsonKey() final  int totalGovtSanctionedPaise;
@override@JsonKey() final  int totalGovtReceivedPaise;
@override@JsonKey() final  int pendingGovtPaise;
@override@JsonKey() final  int totalExpensePaise;
@override@JsonKey() final  int availableBalancePaise;

/// Create a copy of ProjectFinancialSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectFinancialSummaryCopyWith<_ProjectFinancialSummary> get copyWith => __$ProjectFinancialSummaryCopyWithImpl<_ProjectFinancialSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectFinancialSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectFinancialSummary&&(identical(other.totalInvestmentPaise, totalInvestmentPaise) || other.totalInvestmentPaise == totalInvestmentPaise)&&(identical(other.totalGovtSanctionedPaise, totalGovtSanctionedPaise) || other.totalGovtSanctionedPaise == totalGovtSanctionedPaise)&&(identical(other.totalGovtReceivedPaise, totalGovtReceivedPaise) || other.totalGovtReceivedPaise == totalGovtReceivedPaise)&&(identical(other.pendingGovtPaise, pendingGovtPaise) || other.pendingGovtPaise == pendingGovtPaise)&&(identical(other.totalExpensePaise, totalExpensePaise) || other.totalExpensePaise == totalExpensePaise)&&(identical(other.availableBalancePaise, availableBalancePaise) || other.availableBalancePaise == availableBalancePaise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalInvestmentPaise,totalGovtSanctionedPaise,totalGovtReceivedPaise,pendingGovtPaise,totalExpensePaise,availableBalancePaise);

@override
String toString() {
  return 'ProjectFinancialSummary(totalInvestmentPaise: $totalInvestmentPaise, totalGovtSanctionedPaise: $totalGovtSanctionedPaise, totalGovtReceivedPaise: $totalGovtReceivedPaise, pendingGovtPaise: $pendingGovtPaise, totalExpensePaise: $totalExpensePaise, availableBalancePaise: $availableBalancePaise)';
}


}

/// @nodoc
abstract mixin class _$ProjectFinancialSummaryCopyWith<$Res> implements $ProjectFinancialSummaryCopyWith<$Res> {
  factory _$ProjectFinancialSummaryCopyWith(_ProjectFinancialSummary value, $Res Function(_ProjectFinancialSummary) _then) = __$ProjectFinancialSummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalInvestmentPaise, int totalGovtSanctionedPaise, int totalGovtReceivedPaise, int pendingGovtPaise, int totalExpensePaise, int availableBalancePaise
});




}
/// @nodoc
class __$ProjectFinancialSummaryCopyWithImpl<$Res>
    implements _$ProjectFinancialSummaryCopyWith<$Res> {
  __$ProjectFinancialSummaryCopyWithImpl(this._self, this._then);

  final _ProjectFinancialSummary _self;
  final $Res Function(_ProjectFinancialSummary) _then;

/// Create a copy of ProjectFinancialSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalInvestmentPaise = null,Object? totalGovtSanctionedPaise = null,Object? totalGovtReceivedPaise = null,Object? pendingGovtPaise = null,Object? totalExpensePaise = null,Object? availableBalancePaise = null,}) {
  return _then(_ProjectFinancialSummary(
totalInvestmentPaise: null == totalInvestmentPaise ? _self.totalInvestmentPaise : totalInvestmentPaise // ignore: cast_nullable_to_non_nullable
as int,totalGovtSanctionedPaise: null == totalGovtSanctionedPaise ? _self.totalGovtSanctionedPaise : totalGovtSanctionedPaise // ignore: cast_nullable_to_non_nullable
as int,totalGovtReceivedPaise: null == totalGovtReceivedPaise ? _self.totalGovtReceivedPaise : totalGovtReceivedPaise // ignore: cast_nullable_to_non_nullable
as int,pendingGovtPaise: null == pendingGovtPaise ? _self.pendingGovtPaise : pendingGovtPaise // ignore: cast_nullable_to_non_nullable
as int,totalExpensePaise: null == totalExpensePaise ? _self.totalExpensePaise : totalExpensePaise // ignore: cast_nullable_to_non_nullable
as int,availableBalancePaise: null == availableBalancePaise ? _self.availableBalancePaise : availableBalancePaise // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$InvestmentReturn {

 String get id; String get projectId; String get investorId; int get amountPaise; DateTime? get returnDate; String get paymentMode; String? get referenceNumber; String? get notes; String? get investorName; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of InvestmentReturn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvestmentReturnCopyWith<InvestmentReturn> get copyWith => _$InvestmentReturnCopyWithImpl<InvestmentReturn>(this as InvestmentReturn, _$identity);

  /// Serializes this InvestmentReturn to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvestmentReturn&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.investorId, investorId) || other.investorId == investorId)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.returnDate, returnDate) || other.returnDate == returnDate)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.investorName, investorName) || other.investorName == investorName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,investorId,amountPaise,returnDate,paymentMode,referenceNumber,notes,investorName,createdAt,updatedAt);

@override
String toString() {
  return 'InvestmentReturn(id: $id, projectId: $projectId, investorId: $investorId, amountPaise: $amountPaise, returnDate: $returnDate, paymentMode: $paymentMode, referenceNumber: $referenceNumber, notes: $notes, investorName: $investorName, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $InvestmentReturnCopyWith<$Res>  {
  factory $InvestmentReturnCopyWith(InvestmentReturn value, $Res Function(InvestmentReturn) _then) = _$InvestmentReturnCopyWithImpl;
@useResult
$Res call({
 String id, String projectId, String investorId, int amountPaise, DateTime? returnDate, String paymentMode, String? referenceNumber, String? notes, String? investorName, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$InvestmentReturnCopyWithImpl<$Res>
    implements $InvestmentReturnCopyWith<$Res> {
  _$InvestmentReturnCopyWithImpl(this._self, this._then);

  final InvestmentReturn _self;
  final $Res Function(InvestmentReturn) _then;

/// Create a copy of InvestmentReturn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? investorId = null,Object? amountPaise = null,Object? returnDate = freezed,Object? paymentMode = null,Object? referenceNumber = freezed,Object? notes = freezed,Object? investorName = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,investorId: null == investorId ? _self.investorId : investorId // ignore: cast_nullable_to_non_nullable
as String,amountPaise: null == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int,returnDate: freezed == returnDate ? _self.returnDate : returnDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,referenceNumber: freezed == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,investorName: freezed == investorName ? _self.investorName : investorName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InvestmentReturn].
extension InvestmentReturnPatterns on InvestmentReturn {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InvestmentReturn value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InvestmentReturn() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InvestmentReturn value)  $default,){
final _that = this;
switch (_that) {
case _InvestmentReturn():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InvestmentReturn value)?  $default,){
final _that = this;
switch (_that) {
case _InvestmentReturn() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String projectId,  String investorId,  int amountPaise,  DateTime? returnDate,  String paymentMode,  String? referenceNumber,  String? notes,  String? investorName,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InvestmentReturn() when $default != null:
return $default(_that.id,_that.projectId,_that.investorId,_that.amountPaise,_that.returnDate,_that.paymentMode,_that.referenceNumber,_that.notes,_that.investorName,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String projectId,  String investorId,  int amountPaise,  DateTime? returnDate,  String paymentMode,  String? referenceNumber,  String? notes,  String? investorName,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _InvestmentReturn():
return $default(_that.id,_that.projectId,_that.investorId,_that.amountPaise,_that.returnDate,_that.paymentMode,_that.referenceNumber,_that.notes,_that.investorName,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String projectId,  String investorId,  int amountPaise,  DateTime? returnDate,  String paymentMode,  String? referenceNumber,  String? notes,  String? investorName,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _InvestmentReturn() when $default != null:
return $default(_that.id,_that.projectId,_that.investorId,_that.amountPaise,_that.returnDate,_that.paymentMode,_that.referenceNumber,_that.notes,_that.investorName,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InvestmentReturn implements InvestmentReturn {
  const _InvestmentReturn({required this.id, required this.projectId, required this.investorId, this.amountPaise = 0, this.returnDate, this.paymentMode = 'bank', this.referenceNumber, this.notes, this.investorName, this.createdAt, this.updatedAt});
  factory _InvestmentReturn.fromJson(Map<String, dynamic> json) => _$InvestmentReturnFromJson(json);

@override final  String id;
@override final  String projectId;
@override final  String investorId;
@override@JsonKey() final  int amountPaise;
@override final  DateTime? returnDate;
@override@JsonKey() final  String paymentMode;
@override final  String? referenceNumber;
@override final  String? notes;
@override final  String? investorName;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of InvestmentReturn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvestmentReturnCopyWith<_InvestmentReturn> get copyWith => __$InvestmentReturnCopyWithImpl<_InvestmentReturn>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvestmentReturnToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InvestmentReturn&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.investorId, investorId) || other.investorId == investorId)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.returnDate, returnDate) || other.returnDate == returnDate)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.referenceNumber, referenceNumber) || other.referenceNumber == referenceNumber)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.investorName, investorName) || other.investorName == investorName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,investorId,amountPaise,returnDate,paymentMode,referenceNumber,notes,investorName,createdAt,updatedAt);

@override
String toString() {
  return 'InvestmentReturn(id: $id, projectId: $projectId, investorId: $investorId, amountPaise: $amountPaise, returnDate: $returnDate, paymentMode: $paymentMode, referenceNumber: $referenceNumber, notes: $notes, investorName: $investorName, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$InvestmentReturnCopyWith<$Res> implements $InvestmentReturnCopyWith<$Res> {
  factory _$InvestmentReturnCopyWith(_InvestmentReturn value, $Res Function(_InvestmentReturn) _then) = __$InvestmentReturnCopyWithImpl;
@override @useResult
$Res call({
 String id, String projectId, String investorId, int amountPaise, DateTime? returnDate, String paymentMode, String? referenceNumber, String? notes, String? investorName, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$InvestmentReturnCopyWithImpl<$Res>
    implements _$InvestmentReturnCopyWith<$Res> {
  __$InvestmentReturnCopyWithImpl(this._self, this._then);

  final _InvestmentReturn _self;
  final $Res Function(_InvestmentReturn) _then;

/// Create a copy of InvestmentReturn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? investorId = null,Object? amountPaise = null,Object? returnDate = freezed,Object? paymentMode = null,Object? referenceNumber = freezed,Object? notes = freezed,Object? investorName = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_InvestmentReturn(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,investorId: null == investorId ? _self.investorId : investorId // ignore: cast_nullable_to_non_nullable
as String,amountPaise: null == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int,returnDate: freezed == returnDate ? _self.returnDate : returnDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as String,referenceNumber: freezed == referenceNumber ? _self.referenceNumber : referenceNumber // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,investorName: freezed == investorName ? _self.investorName : investorName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
