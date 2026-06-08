// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'material_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Tender {

 String get id; String get organizationId; String get name; String? get code; int? get year; String get status; String? get description;
/// Create a copy of Tender
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenderCopyWith<Tender> get copyWith => _$TenderCopyWithImpl<Tender>(this as Tender, _$identity);

  /// Serializes this Tender to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tender&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.year, year) || other.year == year)&&(identical(other.status, status) || other.status == status)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,name,code,year,status,description);

@override
String toString() {
  return 'Tender(id: $id, organizationId: $organizationId, name: $name, code: $code, year: $year, status: $status, description: $description)';
}


}

/// @nodoc
abstract mixin class $TenderCopyWith<$Res>  {
  factory $TenderCopyWith(Tender value, $Res Function(Tender) _then) = _$TenderCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String name, String? code, int? year, String status, String? description
});




}
/// @nodoc
class _$TenderCopyWithImpl<$Res>
    implements $TenderCopyWith<$Res> {
  _$TenderCopyWithImpl(this._self, this._then);

  final Tender _self;
  final $Res Function(Tender) _then;

/// Create a copy of Tender
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? code = freezed,Object? year = freezed,Object? status = null,Object? description = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Tender].
extension TenderPatterns on Tender {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tender value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tender() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tender value)  $default,){
final _that = this;
switch (_that) {
case _Tender():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tender value)?  $default,){
final _that = this;
switch (_that) {
case _Tender() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String? code,  int? year,  String status,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tender() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.code,_that.year,_that.status,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String? code,  int? year,  String status,  String? description)  $default,) {final _that = this;
switch (_that) {
case _Tender():
return $default(_that.id,_that.organizationId,_that.name,_that.code,_that.year,_that.status,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String name,  String? code,  int? year,  String status,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _Tender() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.code,_that.year,_that.status,_that.description);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Tender implements Tender {
  const _Tender({required this.id, required this.organizationId, required this.name, this.code, this.year, this.status = 'active', this.description});
  factory _Tender.fromJson(Map<String, dynamic> json) => _$TenderFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String name;
@override final  String? code;
@override final  int? year;
@override@JsonKey() final  String status;
@override final  String? description;

/// Create a copy of Tender
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TenderCopyWith<_Tender> get copyWith => __$TenderCopyWithImpl<_Tender>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TenderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tender&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.year, year) || other.year == year)&&(identical(other.status, status) || other.status == status)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,name,code,year,status,description);

@override
String toString() {
  return 'Tender(id: $id, organizationId: $organizationId, name: $name, code: $code, year: $year, status: $status, description: $description)';
}


}

/// @nodoc
abstract mixin class _$TenderCopyWith<$Res> implements $TenderCopyWith<$Res> {
  factory _$TenderCopyWith(_Tender value, $Res Function(_Tender) _then) = __$TenderCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String name, String? code, int? year, String status, String? description
});




}
/// @nodoc
class __$TenderCopyWithImpl<$Res>
    implements _$TenderCopyWith<$Res> {
  __$TenderCopyWithImpl(this._self, this._then);

  final _Tender _self;
  final $Res Function(_Tender) _then;

/// Create a copy of Tender
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? code = freezed,Object? year = freezed,Object? status = null,Object? description = freezed,}) {
  return _then(_Tender(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$District {

 String get id; String get organizationId; String get name; String? get state;
/// Create a copy of District
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DistrictCopyWith<District> get copyWith => _$DistrictCopyWithImpl<District>(this as District, _$identity);

  /// Serializes this District to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is District&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,name,state);

@override
String toString() {
  return 'District(id: $id, organizationId: $organizationId, name: $name, state: $state)';
}


}

/// @nodoc
abstract mixin class $DistrictCopyWith<$Res>  {
  factory $DistrictCopyWith(District value, $Res Function(District) _then) = _$DistrictCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String name, String? state
});




}
/// @nodoc
class _$DistrictCopyWithImpl<$Res>
    implements $DistrictCopyWith<$Res> {
  _$DistrictCopyWithImpl(this._self, this._then);

  final District _self;
  final $Res Function(District) _then;

/// Create a copy of District
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? state = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [District].
extension DistrictPatterns on District {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _District value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _District() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _District value)  $default,){
final _that = this;
switch (_that) {
case _District():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _District value)?  $default,){
final _that = this;
switch (_that) {
case _District() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String? state)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _District() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.state);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String? state)  $default,) {final _that = this;
switch (_that) {
case _District():
return $default(_that.id,_that.organizationId,_that.name,_that.state);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String name,  String? state)?  $default,) {final _that = this;
switch (_that) {
case _District() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.state);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _District implements District {
  const _District({required this.id, required this.organizationId, required this.name, this.state});
  factory _District.fromJson(Map<String, dynamic> json) => _$DistrictFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String name;
@override final  String? state;

/// Create a copy of District
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DistrictCopyWith<_District> get copyWith => __$DistrictCopyWithImpl<_District>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DistrictToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _District&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.state, state) || other.state == state));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,name,state);

@override
String toString() {
  return 'District(id: $id, organizationId: $organizationId, name: $name, state: $state)';
}


}

/// @nodoc
abstract mixin class _$DistrictCopyWith<$Res> implements $DistrictCopyWith<$Res> {
  factory _$DistrictCopyWith(_District value, $Res Function(_District) _then) = __$DistrictCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String name, String? state
});




}
/// @nodoc
class __$DistrictCopyWithImpl<$Res>
    implements _$DistrictCopyWith<$Res> {
  __$DistrictCopyWithImpl(this._self, this._then);

  final _District _self;
  final $Res Function(_District) _then;

/// Create a copy of District
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? state = freezed,}) {
  return _then(_District(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Warehouse {

 String get id; String get organizationId; String get name; String? get districtId; String? get address; String? get managerName; String? get phone; bool get isCentral;
/// Create a copy of Warehouse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WarehouseCopyWith<Warehouse> get copyWith => _$WarehouseCopyWithImpl<Warehouse>(this as Warehouse, _$identity);

  /// Serializes this Warehouse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Warehouse&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.districtId, districtId) || other.districtId == districtId)&&(identical(other.address, address) || other.address == address)&&(identical(other.managerName, managerName) || other.managerName == managerName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isCentral, isCentral) || other.isCentral == isCentral));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,name,districtId,address,managerName,phone,isCentral);

@override
String toString() {
  return 'Warehouse(id: $id, organizationId: $organizationId, name: $name, districtId: $districtId, address: $address, managerName: $managerName, phone: $phone, isCentral: $isCentral)';
}


}

/// @nodoc
abstract mixin class $WarehouseCopyWith<$Res>  {
  factory $WarehouseCopyWith(Warehouse value, $Res Function(Warehouse) _then) = _$WarehouseCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String name, String? districtId, String? address, String? managerName, String? phone, bool isCentral
});




}
/// @nodoc
class _$WarehouseCopyWithImpl<$Res>
    implements $WarehouseCopyWith<$Res> {
  _$WarehouseCopyWithImpl(this._self, this._then);

  final Warehouse _self;
  final $Res Function(Warehouse) _then;

/// Create a copy of Warehouse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? districtId = freezed,Object? address = freezed,Object? managerName = freezed,Object? phone = freezed,Object? isCentral = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,districtId: freezed == districtId ? _self.districtId : districtId // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,managerName: freezed == managerName ? _self.managerName : managerName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isCentral: null == isCentral ? _self.isCentral : isCentral // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Warehouse].
extension WarehousePatterns on Warehouse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Warehouse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Warehouse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Warehouse value)  $default,){
final _that = this;
switch (_that) {
case _Warehouse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Warehouse value)?  $default,){
final _that = this;
switch (_that) {
case _Warehouse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String? districtId,  String? address,  String? managerName,  String? phone,  bool isCentral)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Warehouse() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.districtId,_that.address,_that.managerName,_that.phone,_that.isCentral);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String? districtId,  String? address,  String? managerName,  String? phone,  bool isCentral)  $default,) {final _that = this;
switch (_that) {
case _Warehouse():
return $default(_that.id,_that.organizationId,_that.name,_that.districtId,_that.address,_that.managerName,_that.phone,_that.isCentral);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String name,  String? districtId,  String? address,  String? managerName,  String? phone,  bool isCentral)?  $default,) {final _that = this;
switch (_that) {
case _Warehouse() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.districtId,_that.address,_that.managerName,_that.phone,_that.isCentral);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Warehouse implements Warehouse {
  const _Warehouse({required this.id, required this.organizationId, required this.name, this.districtId, this.address, this.managerName, this.phone, this.isCentral = false});
  factory _Warehouse.fromJson(Map<String, dynamic> json) => _$WarehouseFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String name;
@override final  String? districtId;
@override final  String? address;
@override final  String? managerName;
@override final  String? phone;
@override@JsonKey() final  bool isCentral;

/// Create a copy of Warehouse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WarehouseCopyWith<_Warehouse> get copyWith => __$WarehouseCopyWithImpl<_Warehouse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WarehouseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Warehouse&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.districtId, districtId) || other.districtId == districtId)&&(identical(other.address, address) || other.address == address)&&(identical(other.managerName, managerName) || other.managerName == managerName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isCentral, isCentral) || other.isCentral == isCentral));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,name,districtId,address,managerName,phone,isCentral);

@override
String toString() {
  return 'Warehouse(id: $id, organizationId: $organizationId, name: $name, districtId: $districtId, address: $address, managerName: $managerName, phone: $phone, isCentral: $isCentral)';
}


}

/// @nodoc
abstract mixin class _$WarehouseCopyWith<$Res> implements $WarehouseCopyWith<$Res> {
  factory _$WarehouseCopyWith(_Warehouse value, $Res Function(_Warehouse) _then) = __$WarehouseCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String name, String? districtId, String? address, String? managerName, String? phone, bool isCentral
});




}
/// @nodoc
class __$WarehouseCopyWithImpl<$Res>
    implements _$WarehouseCopyWith<$Res> {
  __$WarehouseCopyWithImpl(this._self, this._then);

  final _Warehouse _self;
  final $Res Function(_Warehouse) _then;

/// Create a copy of Warehouse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? districtId = freezed,Object? address = freezed,Object? managerName = freezed,Object? phone = freezed,Object? isCentral = null,}) {
  return _then(_Warehouse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,districtId: freezed == districtId ? _self.districtId : districtId // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,managerName: freezed == managerName ? _self.managerName : managerName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isCentral: null == isCentral ? _self.isCentral : isCentral // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$School {

 String get id; String get organizationId; String get tenderId; String get name; String? get districtId; String? get code; String? get address; String get status; int get progressPercent; String? get assignedManagerId; int get roomQuantity; List<String> get gpsPhotoPaths; double? get gpsLatitude; double? get gpsLongitude; double? get gpsAccuracyMeters; DateTime? get gpsCapturedAt;
/// Create a copy of School
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchoolCopyWith<School> get copyWith => _$SchoolCopyWithImpl<School>(this as School, _$identity);

  /// Serializes this School to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is School&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.tenderId, tenderId) || other.tenderId == tenderId)&&(identical(other.name, name) || other.name == name)&&(identical(other.districtId, districtId) || other.districtId == districtId)&&(identical(other.code, code) || other.code == code)&&(identical(other.address, address) || other.address == address)&&(identical(other.status, status) || other.status == status)&&(identical(other.progressPercent, progressPercent) || other.progressPercent == progressPercent)&&(identical(other.assignedManagerId, assignedManagerId) || other.assignedManagerId == assignedManagerId)&&(identical(other.roomQuantity, roomQuantity) || other.roomQuantity == roomQuantity)&&const DeepCollectionEquality().equals(other.gpsPhotoPaths, gpsPhotoPaths)&&(identical(other.gpsLatitude, gpsLatitude) || other.gpsLatitude == gpsLatitude)&&(identical(other.gpsLongitude, gpsLongitude) || other.gpsLongitude == gpsLongitude)&&(identical(other.gpsAccuracyMeters, gpsAccuracyMeters) || other.gpsAccuracyMeters == gpsAccuracyMeters)&&(identical(other.gpsCapturedAt, gpsCapturedAt) || other.gpsCapturedAt == gpsCapturedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,tenderId,name,districtId,code,address,status,progressPercent,assignedManagerId,roomQuantity,const DeepCollectionEquality().hash(gpsPhotoPaths),gpsLatitude,gpsLongitude,gpsAccuracyMeters,gpsCapturedAt);

@override
String toString() {
  return 'School(id: $id, organizationId: $organizationId, tenderId: $tenderId, name: $name, districtId: $districtId, code: $code, address: $address, status: $status, progressPercent: $progressPercent, assignedManagerId: $assignedManagerId, roomQuantity: $roomQuantity, gpsPhotoPaths: $gpsPhotoPaths, gpsLatitude: $gpsLatitude, gpsLongitude: $gpsLongitude, gpsAccuracyMeters: $gpsAccuracyMeters, gpsCapturedAt: $gpsCapturedAt)';
}


}

/// @nodoc
abstract mixin class $SchoolCopyWith<$Res>  {
  factory $SchoolCopyWith(School value, $Res Function(School) _then) = _$SchoolCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String tenderId, String name, String? districtId, String? code, String? address, String status, int progressPercent, String? assignedManagerId, int roomQuantity, List<String> gpsPhotoPaths, double? gpsLatitude, double? gpsLongitude, double? gpsAccuracyMeters, DateTime? gpsCapturedAt
});




}
/// @nodoc
class _$SchoolCopyWithImpl<$Res>
    implements $SchoolCopyWith<$Res> {
  _$SchoolCopyWithImpl(this._self, this._then);

  final School _self;
  final $Res Function(School) _then;

/// Create a copy of School
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? tenderId = null,Object? name = null,Object? districtId = freezed,Object? code = freezed,Object? address = freezed,Object? status = null,Object? progressPercent = null,Object? assignedManagerId = freezed,Object? roomQuantity = null,Object? gpsPhotoPaths = null,Object? gpsLatitude = freezed,Object? gpsLongitude = freezed,Object? gpsAccuracyMeters = freezed,Object? gpsCapturedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,tenderId: null == tenderId ? _self.tenderId : tenderId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,districtId: freezed == districtId ? _self.districtId : districtId // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,progressPercent: null == progressPercent ? _self.progressPercent : progressPercent // ignore: cast_nullable_to_non_nullable
as int,assignedManagerId: freezed == assignedManagerId ? _self.assignedManagerId : assignedManagerId // ignore: cast_nullable_to_non_nullable
as String?,roomQuantity: null == roomQuantity ? _self.roomQuantity : roomQuantity // ignore: cast_nullable_to_non_nullable
as int,gpsPhotoPaths: null == gpsPhotoPaths ? _self.gpsPhotoPaths : gpsPhotoPaths // ignore: cast_nullable_to_non_nullable
as List<String>,gpsLatitude: freezed == gpsLatitude ? _self.gpsLatitude : gpsLatitude // ignore: cast_nullable_to_non_nullable
as double?,gpsLongitude: freezed == gpsLongitude ? _self.gpsLongitude : gpsLongitude // ignore: cast_nullable_to_non_nullable
as double?,gpsAccuracyMeters: freezed == gpsAccuracyMeters ? _self.gpsAccuracyMeters : gpsAccuracyMeters // ignore: cast_nullable_to_non_nullable
as double?,gpsCapturedAt: freezed == gpsCapturedAt ? _self.gpsCapturedAt : gpsCapturedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [School].
extension SchoolPatterns on School {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _School value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _School() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _School value)  $default,){
final _that = this;
switch (_that) {
case _School():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _School value)?  $default,){
final _that = this;
switch (_that) {
case _School() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String tenderId,  String name,  String? districtId,  String? code,  String? address,  String status,  int progressPercent,  String? assignedManagerId,  int roomQuantity,  List<String> gpsPhotoPaths,  double? gpsLatitude,  double? gpsLongitude,  double? gpsAccuracyMeters,  DateTime? gpsCapturedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _School() when $default != null:
return $default(_that.id,_that.organizationId,_that.tenderId,_that.name,_that.districtId,_that.code,_that.address,_that.status,_that.progressPercent,_that.assignedManagerId,_that.roomQuantity,_that.gpsPhotoPaths,_that.gpsLatitude,_that.gpsLongitude,_that.gpsAccuracyMeters,_that.gpsCapturedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String tenderId,  String name,  String? districtId,  String? code,  String? address,  String status,  int progressPercent,  String? assignedManagerId,  int roomQuantity,  List<String> gpsPhotoPaths,  double? gpsLatitude,  double? gpsLongitude,  double? gpsAccuracyMeters,  DateTime? gpsCapturedAt)  $default,) {final _that = this;
switch (_that) {
case _School():
return $default(_that.id,_that.organizationId,_that.tenderId,_that.name,_that.districtId,_that.code,_that.address,_that.status,_that.progressPercent,_that.assignedManagerId,_that.roomQuantity,_that.gpsPhotoPaths,_that.gpsLatitude,_that.gpsLongitude,_that.gpsAccuracyMeters,_that.gpsCapturedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String tenderId,  String name,  String? districtId,  String? code,  String? address,  String status,  int progressPercent,  String? assignedManagerId,  int roomQuantity,  List<String> gpsPhotoPaths,  double? gpsLatitude,  double? gpsLongitude,  double? gpsAccuracyMeters,  DateTime? gpsCapturedAt)?  $default,) {final _that = this;
switch (_that) {
case _School() when $default != null:
return $default(_that.id,_that.organizationId,_that.tenderId,_that.name,_that.districtId,_that.code,_that.address,_that.status,_that.progressPercent,_that.assignedManagerId,_that.roomQuantity,_that.gpsPhotoPaths,_that.gpsLatitude,_that.gpsLongitude,_that.gpsAccuracyMeters,_that.gpsCapturedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _School implements School {
  const _School({required this.id, required this.organizationId, required this.tenderId, required this.name, this.districtId, this.code, this.address, this.status = 'not_started', this.progressPercent = 0, this.assignedManagerId, this.roomQuantity = 0, final  List<String> gpsPhotoPaths = const <String>[], this.gpsLatitude, this.gpsLongitude, this.gpsAccuracyMeters, this.gpsCapturedAt}): _gpsPhotoPaths = gpsPhotoPaths;
  factory _School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String tenderId;
@override final  String name;
@override final  String? districtId;
@override final  String? code;
@override final  String? address;
@override@JsonKey() final  String status;
@override@JsonKey() final  int progressPercent;
@override final  String? assignedManagerId;
@override@JsonKey() final  int roomQuantity;
 final  List<String> _gpsPhotoPaths;
@override@JsonKey() List<String> get gpsPhotoPaths {
  if (_gpsPhotoPaths is EqualUnmodifiableListView) return _gpsPhotoPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_gpsPhotoPaths);
}

@override final  double? gpsLatitude;
@override final  double? gpsLongitude;
@override final  double? gpsAccuracyMeters;
@override final  DateTime? gpsCapturedAt;

/// Create a copy of School
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchoolCopyWith<_School> get copyWith => __$SchoolCopyWithImpl<_School>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SchoolToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _School&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.tenderId, tenderId) || other.tenderId == tenderId)&&(identical(other.name, name) || other.name == name)&&(identical(other.districtId, districtId) || other.districtId == districtId)&&(identical(other.code, code) || other.code == code)&&(identical(other.address, address) || other.address == address)&&(identical(other.status, status) || other.status == status)&&(identical(other.progressPercent, progressPercent) || other.progressPercent == progressPercent)&&(identical(other.assignedManagerId, assignedManagerId) || other.assignedManagerId == assignedManagerId)&&(identical(other.roomQuantity, roomQuantity) || other.roomQuantity == roomQuantity)&&const DeepCollectionEquality().equals(other._gpsPhotoPaths, _gpsPhotoPaths)&&(identical(other.gpsLatitude, gpsLatitude) || other.gpsLatitude == gpsLatitude)&&(identical(other.gpsLongitude, gpsLongitude) || other.gpsLongitude == gpsLongitude)&&(identical(other.gpsAccuracyMeters, gpsAccuracyMeters) || other.gpsAccuracyMeters == gpsAccuracyMeters)&&(identical(other.gpsCapturedAt, gpsCapturedAt) || other.gpsCapturedAt == gpsCapturedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,tenderId,name,districtId,code,address,status,progressPercent,assignedManagerId,roomQuantity,const DeepCollectionEquality().hash(_gpsPhotoPaths),gpsLatitude,gpsLongitude,gpsAccuracyMeters,gpsCapturedAt);

@override
String toString() {
  return 'School(id: $id, organizationId: $organizationId, tenderId: $tenderId, name: $name, districtId: $districtId, code: $code, address: $address, status: $status, progressPercent: $progressPercent, assignedManagerId: $assignedManagerId, roomQuantity: $roomQuantity, gpsPhotoPaths: $gpsPhotoPaths, gpsLatitude: $gpsLatitude, gpsLongitude: $gpsLongitude, gpsAccuracyMeters: $gpsAccuracyMeters, gpsCapturedAt: $gpsCapturedAt)';
}


}

/// @nodoc
abstract mixin class _$SchoolCopyWith<$Res> implements $SchoolCopyWith<$Res> {
  factory _$SchoolCopyWith(_School value, $Res Function(_School) _then) = __$SchoolCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String tenderId, String name, String? districtId, String? code, String? address, String status, int progressPercent, String? assignedManagerId, int roomQuantity, List<String> gpsPhotoPaths, double? gpsLatitude, double? gpsLongitude, double? gpsAccuracyMeters, DateTime? gpsCapturedAt
});




}
/// @nodoc
class __$SchoolCopyWithImpl<$Res>
    implements _$SchoolCopyWith<$Res> {
  __$SchoolCopyWithImpl(this._self, this._then);

  final _School _self;
  final $Res Function(_School) _then;

/// Create a copy of School
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? tenderId = null,Object? name = null,Object? districtId = freezed,Object? code = freezed,Object? address = freezed,Object? status = null,Object? progressPercent = null,Object? assignedManagerId = freezed,Object? roomQuantity = null,Object? gpsPhotoPaths = null,Object? gpsLatitude = freezed,Object? gpsLongitude = freezed,Object? gpsAccuracyMeters = freezed,Object? gpsCapturedAt = freezed,}) {
  return _then(_School(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,tenderId: null == tenderId ? _self.tenderId : tenderId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,districtId: freezed == districtId ? _self.districtId : districtId // ignore: cast_nullable_to_non_nullable
as String?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,progressPercent: null == progressPercent ? _self.progressPercent : progressPercent // ignore: cast_nullable_to_non_nullable
as int,assignedManagerId: freezed == assignedManagerId ? _self.assignedManagerId : assignedManagerId // ignore: cast_nullable_to_non_nullable
as String?,roomQuantity: null == roomQuantity ? _self.roomQuantity : roomQuantity // ignore: cast_nullable_to_non_nullable
as int,gpsPhotoPaths: null == gpsPhotoPaths ? _self._gpsPhotoPaths : gpsPhotoPaths // ignore: cast_nullable_to_non_nullable
as List<String>,gpsLatitude: freezed == gpsLatitude ? _self.gpsLatitude : gpsLatitude // ignore: cast_nullable_to_non_nullable
as double?,gpsLongitude: freezed == gpsLongitude ? _self.gpsLongitude : gpsLongitude // ignore: cast_nullable_to_non_nullable
as double?,gpsAccuracyMeters: freezed == gpsAccuracyMeters ? _self.gpsAccuracyMeters : gpsAccuracyMeters // ignore: cast_nullable_to_non_nullable
as double?,gpsCapturedAt: freezed == gpsCapturedAt ? _self.gpsCapturedAt : gpsCapturedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SiteManager {

 String get id; String get organizationId; String get fullName; String? get phone; String? get email; String get roleLabel; bool get active;
/// Create a copy of SiteManager
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiteManagerCopyWith<SiteManager> get copyWith => _$SiteManagerCopyWithImpl<SiteManager>(this as SiteManager, _$identity);

  /// Serializes this SiteManager to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SiteManager&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.roleLabel, roleLabel) || other.roleLabel == roleLabel)&&(identical(other.active, active) || other.active == active));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,fullName,phone,email,roleLabel,active);

@override
String toString() {
  return 'SiteManager(id: $id, organizationId: $organizationId, fullName: $fullName, phone: $phone, email: $email, roleLabel: $roleLabel, active: $active)';
}


}

/// @nodoc
abstract mixin class $SiteManagerCopyWith<$Res>  {
  factory $SiteManagerCopyWith(SiteManager value, $Res Function(SiteManager) _then) = _$SiteManagerCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String fullName, String? phone, String? email, String roleLabel, bool active
});




}
/// @nodoc
class _$SiteManagerCopyWithImpl<$Res>
    implements $SiteManagerCopyWith<$Res> {
  _$SiteManagerCopyWithImpl(this._self, this._then);

  final SiteManager _self;
  final $Res Function(SiteManager) _then;

/// Create a copy of SiteManager
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? fullName = null,Object? phone = freezed,Object? email = freezed,Object? roleLabel = null,Object? active = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,roleLabel: null == roleLabel ? _self.roleLabel : roleLabel // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SiteManager].
extension SiteManagerPatterns on SiteManager {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SiteManager value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SiteManager() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SiteManager value)  $default,){
final _that = this;
switch (_that) {
case _SiteManager():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SiteManager value)?  $default,){
final _that = this;
switch (_that) {
case _SiteManager() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String fullName,  String? phone,  String? email,  String roleLabel,  bool active)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SiteManager() when $default != null:
return $default(_that.id,_that.organizationId,_that.fullName,_that.phone,_that.email,_that.roleLabel,_that.active);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String fullName,  String? phone,  String? email,  String roleLabel,  bool active)  $default,) {final _that = this;
switch (_that) {
case _SiteManager():
return $default(_that.id,_that.organizationId,_that.fullName,_that.phone,_that.email,_that.roleLabel,_that.active);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String fullName,  String? phone,  String? email,  String roleLabel,  bool active)?  $default,) {final _that = this;
switch (_that) {
case _SiteManager() when $default != null:
return $default(_that.id,_that.organizationId,_that.fullName,_that.phone,_that.email,_that.roleLabel,_that.active);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SiteManager implements SiteManager {
  const _SiteManager({required this.id, required this.organizationId, required this.fullName, this.phone, this.email, this.roleLabel = 'Project Manager', this.active = true});
  factory _SiteManager.fromJson(Map<String, dynamic> json) => _$SiteManagerFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String fullName;
@override final  String? phone;
@override final  String? email;
@override@JsonKey() final  String roleLabel;
@override@JsonKey() final  bool active;

/// Create a copy of SiteManager
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiteManagerCopyWith<_SiteManager> get copyWith => __$SiteManagerCopyWithImpl<_SiteManager>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SiteManagerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SiteManager&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.roleLabel, roleLabel) || other.roleLabel == roleLabel)&&(identical(other.active, active) || other.active == active));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,fullName,phone,email,roleLabel,active);

@override
String toString() {
  return 'SiteManager(id: $id, organizationId: $organizationId, fullName: $fullName, phone: $phone, email: $email, roleLabel: $roleLabel, active: $active)';
}


}

/// @nodoc
abstract mixin class _$SiteManagerCopyWith<$Res> implements $SiteManagerCopyWith<$Res> {
  factory _$SiteManagerCopyWith(_SiteManager value, $Res Function(_SiteManager) _then) = __$SiteManagerCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String fullName, String? phone, String? email, String roleLabel, bool active
});




}
/// @nodoc
class __$SiteManagerCopyWithImpl<$Res>
    implements _$SiteManagerCopyWith<$Res> {
  __$SiteManagerCopyWithImpl(this._self, this._then);

  final _SiteManager _self;
  final $Res Function(_SiteManager) _then;

/// Create a copy of SiteManager
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? fullName = null,Object? phone = freezed,Object? email = freezed,Object? roleLabel = null,Object? active = null,}) {
  return _then(_SiteManager(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,roleLabel: null == roleLabel ? _self.roleLabel : roleLabel // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$MaterialItem {

 String get id; String get organizationId; String get name; String get unit; String? get sku; String? get category; double get lowStockThreshold;
/// Create a copy of MaterialItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaterialItemCopyWith<MaterialItem> get copyWith => _$MaterialItemCopyWithImpl<MaterialItem>(this as MaterialItem, _$identity);

  /// Serializes this MaterialItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaterialItem&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.category, category) || other.category == category)&&(identical(other.lowStockThreshold, lowStockThreshold) || other.lowStockThreshold == lowStockThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,name,unit,sku,category,lowStockThreshold);

@override
String toString() {
  return 'MaterialItem(id: $id, organizationId: $organizationId, name: $name, unit: $unit, sku: $sku, category: $category, lowStockThreshold: $lowStockThreshold)';
}


}

/// @nodoc
abstract mixin class $MaterialItemCopyWith<$Res>  {
  factory $MaterialItemCopyWith(MaterialItem value, $Res Function(MaterialItem) _then) = _$MaterialItemCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String name, String unit, String? sku, String? category, double lowStockThreshold
});




}
/// @nodoc
class _$MaterialItemCopyWithImpl<$Res>
    implements $MaterialItemCopyWith<$Res> {
  _$MaterialItemCopyWithImpl(this._self, this._then);

  final MaterialItem _self;
  final $Res Function(MaterialItem) _then;

/// Create a copy of MaterialItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? unit = null,Object? sku = freezed,Object? category = freezed,Object? lowStockThreshold = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,lowStockThreshold: null == lowStockThreshold ? _self.lowStockThreshold : lowStockThreshold // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MaterialItem].
extension MaterialItemPatterns on MaterialItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaterialItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaterialItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaterialItem value)  $default,){
final _that = this;
switch (_that) {
case _MaterialItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaterialItem value)?  $default,){
final _that = this;
switch (_that) {
case _MaterialItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String unit,  String? sku,  String? category,  double lowStockThreshold)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaterialItem() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.unit,_that.sku,_that.category,_that.lowStockThreshold);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String name,  String unit,  String? sku,  String? category,  double lowStockThreshold)  $default,) {final _that = this;
switch (_that) {
case _MaterialItem():
return $default(_that.id,_that.organizationId,_that.name,_that.unit,_that.sku,_that.category,_that.lowStockThreshold);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String name,  String unit,  String? sku,  String? category,  double lowStockThreshold)?  $default,) {final _that = this;
switch (_that) {
case _MaterialItem() when $default != null:
return $default(_that.id,_that.organizationId,_that.name,_that.unit,_that.sku,_that.category,_that.lowStockThreshold);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MaterialItem implements MaterialItem {
  const _MaterialItem({required this.id, required this.organizationId, required this.name, required this.unit, this.sku, this.category, this.lowStockThreshold = 0});
  factory _MaterialItem.fromJson(Map<String, dynamic> json) => _$MaterialItemFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String name;
@override final  String unit;
@override final  String? sku;
@override final  String? category;
@override@JsonKey() final  double lowStockThreshold;

/// Create a copy of MaterialItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaterialItemCopyWith<_MaterialItem> get copyWith => __$MaterialItemCopyWithImpl<_MaterialItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaterialItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaterialItem&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.category, category) || other.category == category)&&(identical(other.lowStockThreshold, lowStockThreshold) || other.lowStockThreshold == lowStockThreshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,name,unit,sku,category,lowStockThreshold);

@override
String toString() {
  return 'MaterialItem(id: $id, organizationId: $organizationId, name: $name, unit: $unit, sku: $sku, category: $category, lowStockThreshold: $lowStockThreshold)';
}


}

/// @nodoc
abstract mixin class _$MaterialItemCopyWith<$Res> implements $MaterialItemCopyWith<$Res> {
  factory _$MaterialItemCopyWith(_MaterialItem value, $Res Function(_MaterialItem) _then) = __$MaterialItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String name, String unit, String? sku, String? category, double lowStockThreshold
});




}
/// @nodoc
class __$MaterialItemCopyWithImpl<$Res>
    implements _$MaterialItemCopyWith<$Res> {
  __$MaterialItemCopyWithImpl(this._self, this._then);

  final _MaterialItem _self;
  final $Res Function(_MaterialItem) _then;

/// Create a copy of MaterialItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? name = null,Object? unit = null,Object? sku = freezed,Object? category = freezed,Object? lowStockThreshold = null,}) {
  return _then(_MaterialItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,lowStockThreshold: null == lowStockThreshold ? _self.lowStockThreshold : lowStockThreshold // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$WarehouseStockRow {

 String get materialId; String get materialName; String get unit; double get totalReceived; double get totalIssued; double get remainingStock; double get threshold; String get stockStatus;
/// Create a copy of WarehouseStockRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WarehouseStockRowCopyWith<WarehouseStockRow> get copyWith => _$WarehouseStockRowCopyWithImpl<WarehouseStockRow>(this as WarehouseStockRow, _$identity);

  /// Serializes this WarehouseStockRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WarehouseStockRow&&(identical(other.materialId, materialId) || other.materialId == materialId)&&(identical(other.materialName, materialName) || other.materialName == materialName)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.totalReceived, totalReceived) || other.totalReceived == totalReceived)&&(identical(other.totalIssued, totalIssued) || other.totalIssued == totalIssued)&&(identical(other.remainingStock, remainingStock) || other.remainingStock == remainingStock)&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.stockStatus, stockStatus) || other.stockStatus == stockStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,materialId,materialName,unit,totalReceived,totalIssued,remainingStock,threshold,stockStatus);

@override
String toString() {
  return 'WarehouseStockRow(materialId: $materialId, materialName: $materialName, unit: $unit, totalReceived: $totalReceived, totalIssued: $totalIssued, remainingStock: $remainingStock, threshold: $threshold, stockStatus: $stockStatus)';
}


}

/// @nodoc
abstract mixin class $WarehouseStockRowCopyWith<$Res>  {
  factory $WarehouseStockRowCopyWith(WarehouseStockRow value, $Res Function(WarehouseStockRow) _then) = _$WarehouseStockRowCopyWithImpl;
@useResult
$Res call({
 String materialId, String materialName, String unit, double totalReceived, double totalIssued, double remainingStock, double threshold, String stockStatus
});




}
/// @nodoc
class _$WarehouseStockRowCopyWithImpl<$Res>
    implements $WarehouseStockRowCopyWith<$Res> {
  _$WarehouseStockRowCopyWithImpl(this._self, this._then);

  final WarehouseStockRow _self;
  final $Res Function(WarehouseStockRow) _then;

/// Create a copy of WarehouseStockRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? materialId = null,Object? materialName = null,Object? unit = null,Object? totalReceived = null,Object? totalIssued = null,Object? remainingStock = null,Object? threshold = null,Object? stockStatus = null,}) {
  return _then(_self.copyWith(
materialId: null == materialId ? _self.materialId : materialId // ignore: cast_nullable_to_non_nullable
as String,materialName: null == materialName ? _self.materialName : materialName // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,totalReceived: null == totalReceived ? _self.totalReceived : totalReceived // ignore: cast_nullable_to_non_nullable
as double,totalIssued: null == totalIssued ? _self.totalIssued : totalIssued // ignore: cast_nullable_to_non_nullable
as double,remainingStock: null == remainingStock ? _self.remainingStock : remainingStock // ignore: cast_nullable_to_non_nullable
as double,threshold: null == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as double,stockStatus: null == stockStatus ? _self.stockStatus : stockStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WarehouseStockRow].
extension WarehouseStockRowPatterns on WarehouseStockRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WarehouseStockRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WarehouseStockRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WarehouseStockRow value)  $default,){
final _that = this;
switch (_that) {
case _WarehouseStockRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WarehouseStockRow value)?  $default,){
final _that = this;
switch (_that) {
case _WarehouseStockRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String materialId,  String materialName,  String unit,  double totalReceived,  double totalIssued,  double remainingStock,  double threshold,  String stockStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WarehouseStockRow() when $default != null:
return $default(_that.materialId,_that.materialName,_that.unit,_that.totalReceived,_that.totalIssued,_that.remainingStock,_that.threshold,_that.stockStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String materialId,  String materialName,  String unit,  double totalReceived,  double totalIssued,  double remainingStock,  double threshold,  String stockStatus)  $default,) {final _that = this;
switch (_that) {
case _WarehouseStockRow():
return $default(_that.materialId,_that.materialName,_that.unit,_that.totalReceived,_that.totalIssued,_that.remainingStock,_that.threshold,_that.stockStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String materialId,  String materialName,  String unit,  double totalReceived,  double totalIssued,  double remainingStock,  double threshold,  String stockStatus)?  $default,) {final _that = this;
switch (_that) {
case _WarehouseStockRow() when $default != null:
return $default(_that.materialId,_that.materialName,_that.unit,_that.totalReceived,_that.totalIssued,_that.remainingStock,_that.threshold,_that.stockStatus);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _WarehouseStockRow implements WarehouseStockRow {
  const _WarehouseStockRow({required this.materialId, required this.materialName, required this.unit, this.totalReceived = 0, this.totalIssued = 0, this.remainingStock = 0, this.threshold = 0, this.stockStatus = 'in_stock'});
  factory _WarehouseStockRow.fromJson(Map<String, dynamic> json) => _$WarehouseStockRowFromJson(json);

@override final  String materialId;
@override final  String materialName;
@override final  String unit;
@override@JsonKey() final  double totalReceived;
@override@JsonKey() final  double totalIssued;
@override@JsonKey() final  double remainingStock;
@override@JsonKey() final  double threshold;
@override@JsonKey() final  String stockStatus;

/// Create a copy of WarehouseStockRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WarehouseStockRowCopyWith<_WarehouseStockRow> get copyWith => __$WarehouseStockRowCopyWithImpl<_WarehouseStockRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WarehouseStockRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WarehouseStockRow&&(identical(other.materialId, materialId) || other.materialId == materialId)&&(identical(other.materialName, materialName) || other.materialName == materialName)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.totalReceived, totalReceived) || other.totalReceived == totalReceived)&&(identical(other.totalIssued, totalIssued) || other.totalIssued == totalIssued)&&(identical(other.remainingStock, remainingStock) || other.remainingStock == remainingStock)&&(identical(other.threshold, threshold) || other.threshold == threshold)&&(identical(other.stockStatus, stockStatus) || other.stockStatus == stockStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,materialId,materialName,unit,totalReceived,totalIssued,remainingStock,threshold,stockStatus);

@override
String toString() {
  return 'WarehouseStockRow(materialId: $materialId, materialName: $materialName, unit: $unit, totalReceived: $totalReceived, totalIssued: $totalIssued, remainingStock: $remainingStock, threshold: $threshold, stockStatus: $stockStatus)';
}


}

/// @nodoc
abstract mixin class _$WarehouseStockRowCopyWith<$Res> implements $WarehouseStockRowCopyWith<$Res> {
  factory _$WarehouseStockRowCopyWith(_WarehouseStockRow value, $Res Function(_WarehouseStockRow) _then) = __$WarehouseStockRowCopyWithImpl;
@override @useResult
$Res call({
 String materialId, String materialName, String unit, double totalReceived, double totalIssued, double remainingStock, double threshold, String stockStatus
});




}
/// @nodoc
class __$WarehouseStockRowCopyWithImpl<$Res>
    implements _$WarehouseStockRowCopyWith<$Res> {
  __$WarehouseStockRowCopyWithImpl(this._self, this._then);

  final _WarehouseStockRow _self;
  final $Res Function(_WarehouseStockRow) _then;

/// Create a copy of WarehouseStockRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? materialId = null,Object? materialName = null,Object? unit = null,Object? totalReceived = null,Object? totalIssued = null,Object? remainingStock = null,Object? threshold = null,Object? stockStatus = null,}) {
  return _then(_WarehouseStockRow(
materialId: null == materialId ? _self.materialId : materialId // ignore: cast_nullable_to_non_nullable
as String,materialName: null == materialName ? _self.materialName : materialName // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,totalReceived: null == totalReceived ? _self.totalReceived : totalReceived // ignore: cast_nullable_to_non_nullable
as double,totalIssued: null == totalIssued ? _self.totalIssued : totalIssued // ignore: cast_nullable_to_non_nullable
as double,remainingStock: null == remainingStock ? _self.remainingStock : remainingStock // ignore: cast_nullable_to_non_nullable
as double,threshold: null == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as double,stockStatus: null == stockStatus ? _self.stockStatus : stockStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MaterialDashboardSummary {

 int get totalSchools; int get runningSchools; int get completedSchools; int get pendingSchools; int get totalItemsInWarehouse; int get lowStockItems; double get totalReceivedQuantity; double get totalIssuedQuantity; double get totalRemainingQuantity;
/// Create a copy of MaterialDashboardSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaterialDashboardSummaryCopyWith<MaterialDashboardSummary> get copyWith => _$MaterialDashboardSummaryCopyWithImpl<MaterialDashboardSummary>(this as MaterialDashboardSummary, _$identity);

  /// Serializes this MaterialDashboardSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaterialDashboardSummary&&(identical(other.totalSchools, totalSchools) || other.totalSchools == totalSchools)&&(identical(other.runningSchools, runningSchools) || other.runningSchools == runningSchools)&&(identical(other.completedSchools, completedSchools) || other.completedSchools == completedSchools)&&(identical(other.pendingSchools, pendingSchools) || other.pendingSchools == pendingSchools)&&(identical(other.totalItemsInWarehouse, totalItemsInWarehouse) || other.totalItemsInWarehouse == totalItemsInWarehouse)&&(identical(other.lowStockItems, lowStockItems) || other.lowStockItems == lowStockItems)&&(identical(other.totalReceivedQuantity, totalReceivedQuantity) || other.totalReceivedQuantity == totalReceivedQuantity)&&(identical(other.totalIssuedQuantity, totalIssuedQuantity) || other.totalIssuedQuantity == totalIssuedQuantity)&&(identical(other.totalRemainingQuantity, totalRemainingQuantity) || other.totalRemainingQuantity == totalRemainingQuantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalSchools,runningSchools,completedSchools,pendingSchools,totalItemsInWarehouse,lowStockItems,totalReceivedQuantity,totalIssuedQuantity,totalRemainingQuantity);

@override
String toString() {
  return 'MaterialDashboardSummary(totalSchools: $totalSchools, runningSchools: $runningSchools, completedSchools: $completedSchools, pendingSchools: $pendingSchools, totalItemsInWarehouse: $totalItemsInWarehouse, lowStockItems: $lowStockItems, totalReceivedQuantity: $totalReceivedQuantity, totalIssuedQuantity: $totalIssuedQuantity, totalRemainingQuantity: $totalRemainingQuantity)';
}


}

/// @nodoc
abstract mixin class $MaterialDashboardSummaryCopyWith<$Res>  {
  factory $MaterialDashboardSummaryCopyWith(MaterialDashboardSummary value, $Res Function(MaterialDashboardSummary) _then) = _$MaterialDashboardSummaryCopyWithImpl;
@useResult
$Res call({
 int totalSchools, int runningSchools, int completedSchools, int pendingSchools, int totalItemsInWarehouse, int lowStockItems, double totalReceivedQuantity, double totalIssuedQuantity, double totalRemainingQuantity
});




}
/// @nodoc
class _$MaterialDashboardSummaryCopyWithImpl<$Res>
    implements $MaterialDashboardSummaryCopyWith<$Res> {
  _$MaterialDashboardSummaryCopyWithImpl(this._self, this._then);

  final MaterialDashboardSummary _self;
  final $Res Function(MaterialDashboardSummary) _then;

/// Create a copy of MaterialDashboardSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalSchools = null,Object? runningSchools = null,Object? completedSchools = null,Object? pendingSchools = null,Object? totalItemsInWarehouse = null,Object? lowStockItems = null,Object? totalReceivedQuantity = null,Object? totalIssuedQuantity = null,Object? totalRemainingQuantity = null,}) {
  return _then(_self.copyWith(
totalSchools: null == totalSchools ? _self.totalSchools : totalSchools // ignore: cast_nullable_to_non_nullable
as int,runningSchools: null == runningSchools ? _self.runningSchools : runningSchools // ignore: cast_nullable_to_non_nullable
as int,completedSchools: null == completedSchools ? _self.completedSchools : completedSchools // ignore: cast_nullable_to_non_nullable
as int,pendingSchools: null == pendingSchools ? _self.pendingSchools : pendingSchools // ignore: cast_nullable_to_non_nullable
as int,totalItemsInWarehouse: null == totalItemsInWarehouse ? _self.totalItemsInWarehouse : totalItemsInWarehouse // ignore: cast_nullable_to_non_nullable
as int,lowStockItems: null == lowStockItems ? _self.lowStockItems : lowStockItems // ignore: cast_nullable_to_non_nullable
as int,totalReceivedQuantity: null == totalReceivedQuantity ? _self.totalReceivedQuantity : totalReceivedQuantity // ignore: cast_nullable_to_non_nullable
as double,totalIssuedQuantity: null == totalIssuedQuantity ? _self.totalIssuedQuantity : totalIssuedQuantity // ignore: cast_nullable_to_non_nullable
as double,totalRemainingQuantity: null == totalRemainingQuantity ? _self.totalRemainingQuantity : totalRemainingQuantity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [MaterialDashboardSummary].
extension MaterialDashboardSummaryPatterns on MaterialDashboardSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaterialDashboardSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaterialDashboardSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaterialDashboardSummary value)  $default,){
final _that = this;
switch (_that) {
case _MaterialDashboardSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaterialDashboardSummary value)?  $default,){
final _that = this;
switch (_that) {
case _MaterialDashboardSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalSchools,  int runningSchools,  int completedSchools,  int pendingSchools,  int totalItemsInWarehouse,  int lowStockItems,  double totalReceivedQuantity,  double totalIssuedQuantity,  double totalRemainingQuantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaterialDashboardSummary() when $default != null:
return $default(_that.totalSchools,_that.runningSchools,_that.completedSchools,_that.pendingSchools,_that.totalItemsInWarehouse,_that.lowStockItems,_that.totalReceivedQuantity,_that.totalIssuedQuantity,_that.totalRemainingQuantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalSchools,  int runningSchools,  int completedSchools,  int pendingSchools,  int totalItemsInWarehouse,  int lowStockItems,  double totalReceivedQuantity,  double totalIssuedQuantity,  double totalRemainingQuantity)  $default,) {final _that = this;
switch (_that) {
case _MaterialDashboardSummary():
return $default(_that.totalSchools,_that.runningSchools,_that.completedSchools,_that.pendingSchools,_that.totalItemsInWarehouse,_that.lowStockItems,_that.totalReceivedQuantity,_that.totalIssuedQuantity,_that.totalRemainingQuantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalSchools,  int runningSchools,  int completedSchools,  int pendingSchools,  int totalItemsInWarehouse,  int lowStockItems,  double totalReceivedQuantity,  double totalIssuedQuantity,  double totalRemainingQuantity)?  $default,) {final _that = this;
switch (_that) {
case _MaterialDashboardSummary() when $default != null:
return $default(_that.totalSchools,_that.runningSchools,_that.completedSchools,_that.pendingSchools,_that.totalItemsInWarehouse,_that.lowStockItems,_that.totalReceivedQuantity,_that.totalIssuedQuantity,_that.totalRemainingQuantity);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MaterialDashboardSummary implements MaterialDashboardSummary {
  const _MaterialDashboardSummary({this.totalSchools = 0, this.runningSchools = 0, this.completedSchools = 0, this.pendingSchools = 0, this.totalItemsInWarehouse = 0, this.lowStockItems = 0, this.totalReceivedQuantity = 0, this.totalIssuedQuantity = 0, this.totalRemainingQuantity = 0});
  factory _MaterialDashboardSummary.fromJson(Map<String, dynamic> json) => _$MaterialDashboardSummaryFromJson(json);

@override@JsonKey() final  int totalSchools;
@override@JsonKey() final  int runningSchools;
@override@JsonKey() final  int completedSchools;
@override@JsonKey() final  int pendingSchools;
@override@JsonKey() final  int totalItemsInWarehouse;
@override@JsonKey() final  int lowStockItems;
@override@JsonKey() final  double totalReceivedQuantity;
@override@JsonKey() final  double totalIssuedQuantity;
@override@JsonKey() final  double totalRemainingQuantity;

/// Create a copy of MaterialDashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaterialDashboardSummaryCopyWith<_MaterialDashboardSummary> get copyWith => __$MaterialDashboardSummaryCopyWithImpl<_MaterialDashboardSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaterialDashboardSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaterialDashboardSummary&&(identical(other.totalSchools, totalSchools) || other.totalSchools == totalSchools)&&(identical(other.runningSchools, runningSchools) || other.runningSchools == runningSchools)&&(identical(other.completedSchools, completedSchools) || other.completedSchools == completedSchools)&&(identical(other.pendingSchools, pendingSchools) || other.pendingSchools == pendingSchools)&&(identical(other.totalItemsInWarehouse, totalItemsInWarehouse) || other.totalItemsInWarehouse == totalItemsInWarehouse)&&(identical(other.lowStockItems, lowStockItems) || other.lowStockItems == lowStockItems)&&(identical(other.totalReceivedQuantity, totalReceivedQuantity) || other.totalReceivedQuantity == totalReceivedQuantity)&&(identical(other.totalIssuedQuantity, totalIssuedQuantity) || other.totalIssuedQuantity == totalIssuedQuantity)&&(identical(other.totalRemainingQuantity, totalRemainingQuantity) || other.totalRemainingQuantity == totalRemainingQuantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalSchools,runningSchools,completedSchools,pendingSchools,totalItemsInWarehouse,lowStockItems,totalReceivedQuantity,totalIssuedQuantity,totalRemainingQuantity);

@override
String toString() {
  return 'MaterialDashboardSummary(totalSchools: $totalSchools, runningSchools: $runningSchools, completedSchools: $completedSchools, pendingSchools: $pendingSchools, totalItemsInWarehouse: $totalItemsInWarehouse, lowStockItems: $lowStockItems, totalReceivedQuantity: $totalReceivedQuantity, totalIssuedQuantity: $totalIssuedQuantity, totalRemainingQuantity: $totalRemainingQuantity)';
}


}

/// @nodoc
abstract mixin class _$MaterialDashboardSummaryCopyWith<$Res> implements $MaterialDashboardSummaryCopyWith<$Res> {
  factory _$MaterialDashboardSummaryCopyWith(_MaterialDashboardSummary value, $Res Function(_MaterialDashboardSummary) _then) = __$MaterialDashboardSummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalSchools, int runningSchools, int completedSchools, int pendingSchools, int totalItemsInWarehouse, int lowStockItems, double totalReceivedQuantity, double totalIssuedQuantity, double totalRemainingQuantity
});




}
/// @nodoc
class __$MaterialDashboardSummaryCopyWithImpl<$Res>
    implements _$MaterialDashboardSummaryCopyWith<$Res> {
  __$MaterialDashboardSummaryCopyWithImpl(this._self, this._then);

  final _MaterialDashboardSummary _self;
  final $Res Function(_MaterialDashboardSummary) _then;

/// Create a copy of MaterialDashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalSchools = null,Object? runningSchools = null,Object? completedSchools = null,Object? pendingSchools = null,Object? totalItemsInWarehouse = null,Object? lowStockItems = null,Object? totalReceivedQuantity = null,Object? totalIssuedQuantity = null,Object? totalRemainingQuantity = null,}) {
  return _then(_MaterialDashboardSummary(
totalSchools: null == totalSchools ? _self.totalSchools : totalSchools // ignore: cast_nullable_to_non_nullable
as int,runningSchools: null == runningSchools ? _self.runningSchools : runningSchools // ignore: cast_nullable_to_non_nullable
as int,completedSchools: null == completedSchools ? _self.completedSchools : completedSchools // ignore: cast_nullable_to_non_nullable
as int,pendingSchools: null == pendingSchools ? _self.pendingSchools : pendingSchools // ignore: cast_nullable_to_non_nullable
as int,totalItemsInWarehouse: null == totalItemsInWarehouse ? _self.totalItemsInWarehouse : totalItemsInWarehouse // ignore: cast_nullable_to_non_nullable
as int,lowStockItems: null == lowStockItems ? _self.lowStockItems : lowStockItems // ignore: cast_nullable_to_non_nullable
as int,totalReceivedQuantity: null == totalReceivedQuantity ? _self.totalReceivedQuantity : totalReceivedQuantity // ignore: cast_nullable_to_non_nullable
as double,totalIssuedQuantity: null == totalIssuedQuantity ? _self.totalIssuedQuantity : totalIssuedQuantity // ignore: cast_nullable_to_non_nullable
as double,totalRemainingQuantity: null == totalRemainingQuantity ? _self.totalRemainingQuantity : totalRemainingQuantity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$SchoolRequirementIssueRow {

 String get schoolId; String get schoolName; int get totalItems; double get requiredPercent; double get issuedPercent; double get pendingPercent; String get status;
/// Create a copy of SchoolRequirementIssueRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SchoolRequirementIssueRowCopyWith<SchoolRequirementIssueRow> get copyWith => _$SchoolRequirementIssueRowCopyWithImpl<SchoolRequirementIssueRow>(this as SchoolRequirementIssueRow, _$identity);

  /// Serializes this SchoolRequirementIssueRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SchoolRequirementIssueRow&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.requiredPercent, requiredPercent) || other.requiredPercent == requiredPercent)&&(identical(other.issuedPercent, issuedPercent) || other.issuedPercent == issuedPercent)&&(identical(other.pendingPercent, pendingPercent) || other.pendingPercent == pendingPercent)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schoolId,schoolName,totalItems,requiredPercent,issuedPercent,pendingPercent,status);

@override
String toString() {
  return 'SchoolRequirementIssueRow(schoolId: $schoolId, schoolName: $schoolName, totalItems: $totalItems, requiredPercent: $requiredPercent, issuedPercent: $issuedPercent, pendingPercent: $pendingPercent, status: $status)';
}


}

/// @nodoc
abstract mixin class $SchoolRequirementIssueRowCopyWith<$Res>  {
  factory $SchoolRequirementIssueRowCopyWith(SchoolRequirementIssueRow value, $Res Function(SchoolRequirementIssueRow) _then) = _$SchoolRequirementIssueRowCopyWithImpl;
@useResult
$Res call({
 String schoolId, String schoolName, int totalItems, double requiredPercent, double issuedPercent, double pendingPercent, String status
});




}
/// @nodoc
class _$SchoolRequirementIssueRowCopyWithImpl<$Res>
    implements $SchoolRequirementIssueRowCopyWith<$Res> {
  _$SchoolRequirementIssueRowCopyWithImpl(this._self, this._then);

  final SchoolRequirementIssueRow _self;
  final $Res Function(SchoolRequirementIssueRow) _then;

/// Create a copy of SchoolRequirementIssueRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schoolId = null,Object? schoolName = null,Object? totalItems = null,Object? requiredPercent = null,Object? issuedPercent = null,Object? pendingPercent = null,Object? status = null,}) {
  return _then(_self.copyWith(
schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,requiredPercent: null == requiredPercent ? _self.requiredPercent : requiredPercent // ignore: cast_nullable_to_non_nullable
as double,issuedPercent: null == issuedPercent ? _self.issuedPercent : issuedPercent // ignore: cast_nullable_to_non_nullable
as double,pendingPercent: null == pendingPercent ? _self.pendingPercent : pendingPercent // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SchoolRequirementIssueRow].
extension SchoolRequirementIssueRowPatterns on SchoolRequirementIssueRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SchoolRequirementIssueRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SchoolRequirementIssueRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SchoolRequirementIssueRow value)  $default,){
final _that = this;
switch (_that) {
case _SchoolRequirementIssueRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SchoolRequirementIssueRow value)?  $default,){
final _that = this;
switch (_that) {
case _SchoolRequirementIssueRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String schoolId,  String schoolName,  int totalItems,  double requiredPercent,  double issuedPercent,  double pendingPercent,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SchoolRequirementIssueRow() when $default != null:
return $default(_that.schoolId,_that.schoolName,_that.totalItems,_that.requiredPercent,_that.issuedPercent,_that.pendingPercent,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String schoolId,  String schoolName,  int totalItems,  double requiredPercent,  double issuedPercent,  double pendingPercent,  String status)  $default,) {final _that = this;
switch (_that) {
case _SchoolRequirementIssueRow():
return $default(_that.schoolId,_that.schoolName,_that.totalItems,_that.requiredPercent,_that.issuedPercent,_that.pendingPercent,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String schoolId,  String schoolName,  int totalItems,  double requiredPercent,  double issuedPercent,  double pendingPercent,  String status)?  $default,) {final _that = this;
switch (_that) {
case _SchoolRequirementIssueRow() when $default != null:
return $default(_that.schoolId,_that.schoolName,_that.totalItems,_that.requiredPercent,_that.issuedPercent,_that.pendingPercent,_that.status);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SchoolRequirementIssueRow implements SchoolRequirementIssueRow {
  const _SchoolRequirementIssueRow({required this.schoolId, required this.schoolName, this.totalItems = 0, this.requiredPercent = 0, this.issuedPercent = 0, this.pendingPercent = 0, this.status = 'pending'});
  factory _SchoolRequirementIssueRow.fromJson(Map<String, dynamic> json) => _$SchoolRequirementIssueRowFromJson(json);

@override final  String schoolId;
@override final  String schoolName;
@override@JsonKey() final  int totalItems;
@override@JsonKey() final  double requiredPercent;
@override@JsonKey() final  double issuedPercent;
@override@JsonKey() final  double pendingPercent;
@override@JsonKey() final  String status;

/// Create a copy of SchoolRequirementIssueRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SchoolRequirementIssueRowCopyWith<_SchoolRequirementIssueRow> get copyWith => __$SchoolRequirementIssueRowCopyWithImpl<_SchoolRequirementIssueRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SchoolRequirementIssueRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SchoolRequirementIssueRow&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.requiredPercent, requiredPercent) || other.requiredPercent == requiredPercent)&&(identical(other.issuedPercent, issuedPercent) || other.issuedPercent == issuedPercent)&&(identical(other.pendingPercent, pendingPercent) || other.pendingPercent == pendingPercent)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schoolId,schoolName,totalItems,requiredPercent,issuedPercent,pendingPercent,status);

@override
String toString() {
  return 'SchoolRequirementIssueRow(schoolId: $schoolId, schoolName: $schoolName, totalItems: $totalItems, requiredPercent: $requiredPercent, issuedPercent: $issuedPercent, pendingPercent: $pendingPercent, status: $status)';
}


}

/// @nodoc
abstract mixin class _$SchoolRequirementIssueRowCopyWith<$Res> implements $SchoolRequirementIssueRowCopyWith<$Res> {
  factory _$SchoolRequirementIssueRowCopyWith(_SchoolRequirementIssueRow value, $Res Function(_SchoolRequirementIssueRow) _then) = __$SchoolRequirementIssueRowCopyWithImpl;
@override @useResult
$Res call({
 String schoolId, String schoolName, int totalItems, double requiredPercent, double issuedPercent, double pendingPercent, String status
});




}
/// @nodoc
class __$SchoolRequirementIssueRowCopyWithImpl<$Res>
    implements _$SchoolRequirementIssueRowCopyWith<$Res> {
  __$SchoolRequirementIssueRowCopyWithImpl(this._self, this._then);

  final _SchoolRequirementIssueRow _self;
  final $Res Function(_SchoolRequirementIssueRow) _then;

/// Create a copy of SchoolRequirementIssueRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schoolId = null,Object? schoolName = null,Object? totalItems = null,Object? requiredPercent = null,Object? issuedPercent = null,Object? pendingPercent = null,Object? status = null,}) {
  return _then(_SchoolRequirementIssueRow(
schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,requiredPercent: null == requiredPercent ? _self.requiredPercent : requiredPercent // ignore: cast_nullable_to_non_nullable
as double,issuedPercent: null == issuedPercent ? _self.issuedPercent : issuedPercent // ignore: cast_nullable_to_non_nullable
as double,pendingPercent: null == pendingPercent ? _self.pendingPercent : pendingPercent // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$RecentMaterialIssue {

 String get issueId; String get managerName; String get schoolName; DateTime get issueDate; String get summaryText; int get materialCount; double get totalQuantity;
/// Create a copy of RecentMaterialIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentMaterialIssueCopyWith<RecentMaterialIssue> get copyWith => _$RecentMaterialIssueCopyWithImpl<RecentMaterialIssue>(this as RecentMaterialIssue, _$identity);

  /// Serializes this RecentMaterialIssue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentMaterialIssue&&(identical(other.issueId, issueId) || other.issueId == issueId)&&(identical(other.managerName, managerName) || other.managerName == managerName)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.summaryText, summaryText) || other.summaryText == summaryText)&&(identical(other.materialCount, materialCount) || other.materialCount == materialCount)&&(identical(other.totalQuantity, totalQuantity) || other.totalQuantity == totalQuantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,issueId,managerName,schoolName,issueDate,summaryText,materialCount,totalQuantity);

@override
String toString() {
  return 'RecentMaterialIssue(issueId: $issueId, managerName: $managerName, schoolName: $schoolName, issueDate: $issueDate, summaryText: $summaryText, materialCount: $materialCount, totalQuantity: $totalQuantity)';
}


}

/// @nodoc
abstract mixin class $RecentMaterialIssueCopyWith<$Res>  {
  factory $RecentMaterialIssueCopyWith(RecentMaterialIssue value, $Res Function(RecentMaterialIssue) _then) = _$RecentMaterialIssueCopyWithImpl;
@useResult
$Res call({
 String issueId, String managerName, String schoolName, DateTime issueDate, String summaryText, int materialCount, double totalQuantity
});




}
/// @nodoc
class _$RecentMaterialIssueCopyWithImpl<$Res>
    implements $RecentMaterialIssueCopyWith<$Res> {
  _$RecentMaterialIssueCopyWithImpl(this._self, this._then);

  final RecentMaterialIssue _self;
  final $Res Function(RecentMaterialIssue) _then;

/// Create a copy of RecentMaterialIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? issueId = null,Object? managerName = null,Object? schoolName = null,Object? issueDate = null,Object? summaryText = null,Object? materialCount = null,Object? totalQuantity = null,}) {
  return _then(_self.copyWith(
issueId: null == issueId ? _self.issueId : issueId // ignore: cast_nullable_to_non_nullable
as String,managerName: null == managerName ? _self.managerName : managerName // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,summaryText: null == summaryText ? _self.summaryText : summaryText // ignore: cast_nullable_to_non_nullable
as String,materialCount: null == materialCount ? _self.materialCount : materialCount // ignore: cast_nullable_to_non_nullable
as int,totalQuantity: null == totalQuantity ? _self.totalQuantity : totalQuantity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentMaterialIssue].
extension RecentMaterialIssuePatterns on RecentMaterialIssue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentMaterialIssue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentMaterialIssue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentMaterialIssue value)  $default,){
final _that = this;
switch (_that) {
case _RecentMaterialIssue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentMaterialIssue value)?  $default,){
final _that = this;
switch (_that) {
case _RecentMaterialIssue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String issueId,  String managerName,  String schoolName,  DateTime issueDate,  String summaryText,  int materialCount,  double totalQuantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentMaterialIssue() when $default != null:
return $default(_that.issueId,_that.managerName,_that.schoolName,_that.issueDate,_that.summaryText,_that.materialCount,_that.totalQuantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String issueId,  String managerName,  String schoolName,  DateTime issueDate,  String summaryText,  int materialCount,  double totalQuantity)  $default,) {final _that = this;
switch (_that) {
case _RecentMaterialIssue():
return $default(_that.issueId,_that.managerName,_that.schoolName,_that.issueDate,_that.summaryText,_that.materialCount,_that.totalQuantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String issueId,  String managerName,  String schoolName,  DateTime issueDate,  String summaryText,  int materialCount,  double totalQuantity)?  $default,) {final _that = this;
switch (_that) {
case _RecentMaterialIssue() when $default != null:
return $default(_that.issueId,_that.managerName,_that.schoolName,_that.issueDate,_that.summaryText,_that.materialCount,_that.totalQuantity);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _RecentMaterialIssue implements RecentMaterialIssue {
  const _RecentMaterialIssue({required this.issueId, required this.managerName, required this.schoolName, required this.issueDate, required this.summaryText, this.materialCount = 0, this.totalQuantity = 0});
  factory _RecentMaterialIssue.fromJson(Map<String, dynamic> json) => _$RecentMaterialIssueFromJson(json);

@override final  String issueId;
@override final  String managerName;
@override final  String schoolName;
@override final  DateTime issueDate;
@override final  String summaryText;
@override@JsonKey() final  int materialCount;
@override@JsonKey() final  double totalQuantity;

/// Create a copy of RecentMaterialIssue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentMaterialIssueCopyWith<_RecentMaterialIssue> get copyWith => __$RecentMaterialIssueCopyWithImpl<_RecentMaterialIssue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecentMaterialIssueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentMaterialIssue&&(identical(other.issueId, issueId) || other.issueId == issueId)&&(identical(other.managerName, managerName) || other.managerName == managerName)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.summaryText, summaryText) || other.summaryText == summaryText)&&(identical(other.materialCount, materialCount) || other.materialCount == materialCount)&&(identical(other.totalQuantity, totalQuantity) || other.totalQuantity == totalQuantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,issueId,managerName,schoolName,issueDate,summaryText,materialCount,totalQuantity);

@override
String toString() {
  return 'RecentMaterialIssue(issueId: $issueId, managerName: $managerName, schoolName: $schoolName, issueDate: $issueDate, summaryText: $summaryText, materialCount: $materialCount, totalQuantity: $totalQuantity)';
}


}

/// @nodoc
abstract mixin class _$RecentMaterialIssueCopyWith<$Res> implements $RecentMaterialIssueCopyWith<$Res> {
  factory _$RecentMaterialIssueCopyWith(_RecentMaterialIssue value, $Res Function(_RecentMaterialIssue) _then) = __$RecentMaterialIssueCopyWithImpl;
@override @useResult
$Res call({
 String issueId, String managerName, String schoolName, DateTime issueDate, String summaryText, int materialCount, double totalQuantity
});




}
/// @nodoc
class __$RecentMaterialIssueCopyWithImpl<$Res>
    implements _$RecentMaterialIssueCopyWith<$Res> {
  __$RecentMaterialIssueCopyWithImpl(this._self, this._then);

  final _RecentMaterialIssue _self;
  final $Res Function(_RecentMaterialIssue) _then;

/// Create a copy of RecentMaterialIssue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? issueId = null,Object? managerName = null,Object? schoolName = null,Object? issueDate = null,Object? summaryText = null,Object? materialCount = null,Object? totalQuantity = null,}) {
  return _then(_RecentMaterialIssue(
issueId: null == issueId ? _self.issueId : issueId // ignore: cast_nullable_to_non_nullable
as String,managerName: null == managerName ? _self.managerName : managerName // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,issueDate: null == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime,summaryText: null == summaryText ? _self.summaryText : summaryText // ignore: cast_nullable_to_non_nullable
as String,materialCount: null == materialCount ? _self.materialCount : materialCount // ignore: cast_nullable_to_non_nullable
as int,totalQuantity: null == totalQuantity ? _self.totalQuantity : totalQuantity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$LowStockAlert {

 String get materialId; String get materialName; String get unit; double get remainingStock; String get alertLevel;
/// Create a copy of LowStockAlert
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LowStockAlertCopyWith<LowStockAlert> get copyWith => _$LowStockAlertCopyWithImpl<LowStockAlert>(this as LowStockAlert, _$identity);

  /// Serializes this LowStockAlert to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LowStockAlert&&(identical(other.materialId, materialId) || other.materialId == materialId)&&(identical(other.materialName, materialName) || other.materialName == materialName)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.remainingStock, remainingStock) || other.remainingStock == remainingStock)&&(identical(other.alertLevel, alertLevel) || other.alertLevel == alertLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,materialId,materialName,unit,remainingStock,alertLevel);

@override
String toString() {
  return 'LowStockAlert(materialId: $materialId, materialName: $materialName, unit: $unit, remainingStock: $remainingStock, alertLevel: $alertLevel)';
}


}

/// @nodoc
abstract mixin class $LowStockAlertCopyWith<$Res>  {
  factory $LowStockAlertCopyWith(LowStockAlert value, $Res Function(LowStockAlert) _then) = _$LowStockAlertCopyWithImpl;
@useResult
$Res call({
 String materialId, String materialName, String unit, double remainingStock, String alertLevel
});




}
/// @nodoc
class _$LowStockAlertCopyWithImpl<$Res>
    implements $LowStockAlertCopyWith<$Res> {
  _$LowStockAlertCopyWithImpl(this._self, this._then);

  final LowStockAlert _self;
  final $Res Function(LowStockAlert) _then;

/// Create a copy of LowStockAlert
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? materialId = null,Object? materialName = null,Object? unit = null,Object? remainingStock = null,Object? alertLevel = null,}) {
  return _then(_self.copyWith(
materialId: null == materialId ? _self.materialId : materialId // ignore: cast_nullable_to_non_nullable
as String,materialName: null == materialName ? _self.materialName : materialName // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,remainingStock: null == remainingStock ? _self.remainingStock : remainingStock // ignore: cast_nullable_to_non_nullable
as double,alertLevel: null == alertLevel ? _self.alertLevel : alertLevel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [LowStockAlert].
extension LowStockAlertPatterns on LowStockAlert {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LowStockAlert value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LowStockAlert() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LowStockAlert value)  $default,){
final _that = this;
switch (_that) {
case _LowStockAlert():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LowStockAlert value)?  $default,){
final _that = this;
switch (_that) {
case _LowStockAlert() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String materialId,  String materialName,  String unit,  double remainingStock,  String alertLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LowStockAlert() when $default != null:
return $default(_that.materialId,_that.materialName,_that.unit,_that.remainingStock,_that.alertLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String materialId,  String materialName,  String unit,  double remainingStock,  String alertLevel)  $default,) {final _that = this;
switch (_that) {
case _LowStockAlert():
return $default(_that.materialId,_that.materialName,_that.unit,_that.remainingStock,_that.alertLevel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String materialId,  String materialName,  String unit,  double remainingStock,  String alertLevel)?  $default,) {final _that = this;
switch (_that) {
case _LowStockAlert() when $default != null:
return $default(_that.materialId,_that.materialName,_that.unit,_that.remainingStock,_that.alertLevel);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _LowStockAlert implements LowStockAlert {
  const _LowStockAlert({required this.materialId, required this.materialName, required this.unit, this.remainingStock = 0, this.alertLevel = 'low'});
  factory _LowStockAlert.fromJson(Map<String, dynamic> json) => _$LowStockAlertFromJson(json);

@override final  String materialId;
@override final  String materialName;
@override final  String unit;
@override@JsonKey() final  double remainingStock;
@override@JsonKey() final  String alertLevel;

/// Create a copy of LowStockAlert
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LowStockAlertCopyWith<_LowStockAlert> get copyWith => __$LowStockAlertCopyWithImpl<_LowStockAlert>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LowStockAlertToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LowStockAlert&&(identical(other.materialId, materialId) || other.materialId == materialId)&&(identical(other.materialName, materialName) || other.materialName == materialName)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.remainingStock, remainingStock) || other.remainingStock == remainingStock)&&(identical(other.alertLevel, alertLevel) || other.alertLevel == alertLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,materialId,materialName,unit,remainingStock,alertLevel);

@override
String toString() {
  return 'LowStockAlert(materialId: $materialId, materialName: $materialName, unit: $unit, remainingStock: $remainingStock, alertLevel: $alertLevel)';
}


}

/// @nodoc
abstract mixin class _$LowStockAlertCopyWith<$Res> implements $LowStockAlertCopyWith<$Res> {
  factory _$LowStockAlertCopyWith(_LowStockAlert value, $Res Function(_LowStockAlert) _then) = __$LowStockAlertCopyWithImpl;
@override @useResult
$Res call({
 String materialId, String materialName, String unit, double remainingStock, String alertLevel
});




}
/// @nodoc
class __$LowStockAlertCopyWithImpl<$Res>
    implements _$LowStockAlertCopyWith<$Res> {
  __$LowStockAlertCopyWithImpl(this._self, this._then);

  final _LowStockAlert _self;
  final $Res Function(_LowStockAlert) _then;

/// Create a copy of LowStockAlert
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? materialId = null,Object? materialName = null,Object? unit = null,Object? remainingStock = null,Object? alertLevel = null,}) {
  return _then(_LowStockAlert(
materialId: null == materialId ? _self.materialId : materialId // ignore: cast_nullable_to_non_nullable
as String,materialName: null == materialName ? _self.materialName : materialName // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,remainingStock: null == remainingStock ? _self.remainingStock : remainingStock // ignore: cast_nullable_to_non_nullable
as double,alertLevel: null == alertLevel ? _self.alertLevel : alertLevel // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ManagerMaterialIssueRow {

 String? get managerId; String get managerName; String get schoolName; String get materialId; String get materialName; String get unit; double get issuedQuantity; double get totalItems;
/// Create a copy of ManagerMaterialIssueRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ManagerMaterialIssueRowCopyWith<ManagerMaterialIssueRow> get copyWith => _$ManagerMaterialIssueRowCopyWithImpl<ManagerMaterialIssueRow>(this as ManagerMaterialIssueRow, _$identity);

  /// Serializes this ManagerMaterialIssueRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ManagerMaterialIssueRow&&(identical(other.managerId, managerId) || other.managerId == managerId)&&(identical(other.managerName, managerName) || other.managerName == managerName)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.materialId, materialId) || other.materialId == materialId)&&(identical(other.materialName, materialName) || other.materialName == materialName)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.issuedQuantity, issuedQuantity) || other.issuedQuantity == issuedQuantity)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,managerId,managerName,schoolName,materialId,materialName,unit,issuedQuantity,totalItems);

@override
String toString() {
  return 'ManagerMaterialIssueRow(managerId: $managerId, managerName: $managerName, schoolName: $schoolName, materialId: $materialId, materialName: $materialName, unit: $unit, issuedQuantity: $issuedQuantity, totalItems: $totalItems)';
}


}

/// @nodoc
abstract mixin class $ManagerMaterialIssueRowCopyWith<$Res>  {
  factory $ManagerMaterialIssueRowCopyWith(ManagerMaterialIssueRow value, $Res Function(ManagerMaterialIssueRow) _then) = _$ManagerMaterialIssueRowCopyWithImpl;
@useResult
$Res call({
 String? managerId, String managerName, String schoolName, String materialId, String materialName, String unit, double issuedQuantity, double totalItems
});




}
/// @nodoc
class _$ManagerMaterialIssueRowCopyWithImpl<$Res>
    implements $ManagerMaterialIssueRowCopyWith<$Res> {
  _$ManagerMaterialIssueRowCopyWithImpl(this._self, this._then);

  final ManagerMaterialIssueRow _self;
  final $Res Function(ManagerMaterialIssueRow) _then;

/// Create a copy of ManagerMaterialIssueRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? managerId = freezed,Object? managerName = null,Object? schoolName = null,Object? materialId = null,Object? materialName = null,Object? unit = null,Object? issuedQuantity = null,Object? totalItems = null,}) {
  return _then(_self.copyWith(
managerId: freezed == managerId ? _self.managerId : managerId // ignore: cast_nullable_to_non_nullable
as String?,managerName: null == managerName ? _self.managerName : managerName // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,materialId: null == materialId ? _self.materialId : materialId // ignore: cast_nullable_to_non_nullable
as String,materialName: null == materialName ? _self.materialName : materialName // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,issuedQuantity: null == issuedQuantity ? _self.issuedQuantity : issuedQuantity // ignore: cast_nullable_to_non_nullable
as double,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ManagerMaterialIssueRow].
extension ManagerMaterialIssueRowPatterns on ManagerMaterialIssueRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ManagerMaterialIssueRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ManagerMaterialIssueRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ManagerMaterialIssueRow value)  $default,){
final _that = this;
switch (_that) {
case _ManagerMaterialIssueRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ManagerMaterialIssueRow value)?  $default,){
final _that = this;
switch (_that) {
case _ManagerMaterialIssueRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? managerId,  String managerName,  String schoolName,  String materialId,  String materialName,  String unit,  double issuedQuantity,  double totalItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ManagerMaterialIssueRow() when $default != null:
return $default(_that.managerId,_that.managerName,_that.schoolName,_that.materialId,_that.materialName,_that.unit,_that.issuedQuantity,_that.totalItems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? managerId,  String managerName,  String schoolName,  String materialId,  String materialName,  String unit,  double issuedQuantity,  double totalItems)  $default,) {final _that = this;
switch (_that) {
case _ManagerMaterialIssueRow():
return $default(_that.managerId,_that.managerName,_that.schoolName,_that.materialId,_that.materialName,_that.unit,_that.issuedQuantity,_that.totalItems);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? managerId,  String managerName,  String schoolName,  String materialId,  String materialName,  String unit,  double issuedQuantity,  double totalItems)?  $default,) {final _that = this;
switch (_that) {
case _ManagerMaterialIssueRow() when $default != null:
return $default(_that.managerId,_that.managerName,_that.schoolName,_that.materialId,_that.materialName,_that.unit,_that.issuedQuantity,_that.totalItems);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ManagerMaterialIssueRow implements ManagerMaterialIssueRow {
  const _ManagerMaterialIssueRow({this.managerId, required this.managerName, required this.schoolName, required this.materialId, required this.materialName, required this.unit, this.issuedQuantity = 0, this.totalItems = 0});
  factory _ManagerMaterialIssueRow.fromJson(Map<String, dynamic> json) => _$ManagerMaterialIssueRowFromJson(json);

@override final  String? managerId;
@override final  String managerName;
@override final  String schoolName;
@override final  String materialId;
@override final  String materialName;
@override final  String unit;
@override@JsonKey() final  double issuedQuantity;
@override@JsonKey() final  double totalItems;

/// Create a copy of ManagerMaterialIssueRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ManagerMaterialIssueRowCopyWith<_ManagerMaterialIssueRow> get copyWith => __$ManagerMaterialIssueRowCopyWithImpl<_ManagerMaterialIssueRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ManagerMaterialIssueRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ManagerMaterialIssueRow&&(identical(other.managerId, managerId) || other.managerId == managerId)&&(identical(other.managerName, managerName) || other.managerName == managerName)&&(identical(other.schoolName, schoolName) || other.schoolName == schoolName)&&(identical(other.materialId, materialId) || other.materialId == materialId)&&(identical(other.materialName, materialName) || other.materialName == materialName)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.issuedQuantity, issuedQuantity) || other.issuedQuantity == issuedQuantity)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,managerId,managerName,schoolName,materialId,materialName,unit,issuedQuantity,totalItems);

@override
String toString() {
  return 'ManagerMaterialIssueRow(managerId: $managerId, managerName: $managerName, schoolName: $schoolName, materialId: $materialId, materialName: $materialName, unit: $unit, issuedQuantity: $issuedQuantity, totalItems: $totalItems)';
}


}

/// @nodoc
abstract mixin class _$ManagerMaterialIssueRowCopyWith<$Res> implements $ManagerMaterialIssueRowCopyWith<$Res> {
  factory _$ManagerMaterialIssueRowCopyWith(_ManagerMaterialIssueRow value, $Res Function(_ManagerMaterialIssueRow) _then) = __$ManagerMaterialIssueRowCopyWithImpl;
@override @useResult
$Res call({
 String? managerId, String managerName, String schoolName, String materialId, String materialName, String unit, double issuedQuantity, double totalItems
});




}
/// @nodoc
class __$ManagerMaterialIssueRowCopyWithImpl<$Res>
    implements _$ManagerMaterialIssueRowCopyWith<$Res> {
  __$ManagerMaterialIssueRowCopyWithImpl(this._self, this._then);

  final _ManagerMaterialIssueRow _self;
  final $Res Function(_ManagerMaterialIssueRow) _then;

/// Create a copy of ManagerMaterialIssueRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? managerId = freezed,Object? managerName = null,Object? schoolName = null,Object? materialId = null,Object? materialName = null,Object? unit = null,Object? issuedQuantity = null,Object? totalItems = null,}) {
  return _then(_ManagerMaterialIssueRow(
managerId: freezed == managerId ? _self.managerId : managerId // ignore: cast_nullable_to_non_nullable
as String?,managerName: null == managerName ? _self.managerName : managerName // ignore: cast_nullable_to_non_nullable
as String,schoolName: null == schoolName ? _self.schoolName : schoolName // ignore: cast_nullable_to_non_nullable
as String,materialId: null == materialId ? _self.materialId : materialId // ignore: cast_nullable_to_non_nullable
as String,materialName: null == materialName ? _self.materialName : materialName // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,issuedQuantity: null == issuedQuantity ? _self.issuedQuantity : issuedQuantity // ignore: cast_nullable_to_non_nullable
as double,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$MaterialReceipt {

 String get id; String get organizationId; String get tenderId; String get warehouseId; String get materialId; double get quantity; DateTime? get receivedDate; String? get supplierName; String? get invoiceNumber; String? get notes;
/// Create a copy of MaterialReceipt
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaterialReceiptCopyWith<MaterialReceipt> get copyWith => _$MaterialReceiptCopyWithImpl<MaterialReceipt>(this as MaterialReceipt, _$identity);

  /// Serializes this MaterialReceipt to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaterialReceipt&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.tenderId, tenderId) || other.tenderId == tenderId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.materialId, materialId) || other.materialId == materialId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.receivedDate, receivedDate) || other.receivedDate == receivedDate)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,tenderId,warehouseId,materialId,quantity,receivedDate,supplierName,invoiceNumber,notes);

@override
String toString() {
  return 'MaterialReceipt(id: $id, organizationId: $organizationId, tenderId: $tenderId, warehouseId: $warehouseId, materialId: $materialId, quantity: $quantity, receivedDate: $receivedDate, supplierName: $supplierName, invoiceNumber: $invoiceNumber, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $MaterialReceiptCopyWith<$Res>  {
  factory $MaterialReceiptCopyWith(MaterialReceipt value, $Res Function(MaterialReceipt) _then) = _$MaterialReceiptCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String tenderId, String warehouseId, String materialId, double quantity, DateTime? receivedDate, String? supplierName, String? invoiceNumber, String? notes
});




}
/// @nodoc
class _$MaterialReceiptCopyWithImpl<$Res>
    implements $MaterialReceiptCopyWith<$Res> {
  _$MaterialReceiptCopyWithImpl(this._self, this._then);

  final MaterialReceipt _self;
  final $Res Function(MaterialReceipt) _then;

/// Create a copy of MaterialReceipt
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? tenderId = null,Object? warehouseId = null,Object? materialId = null,Object? quantity = null,Object? receivedDate = freezed,Object? supplierName = freezed,Object? invoiceNumber = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,tenderId: null == tenderId ? _self.tenderId : tenderId // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String,materialId: null == materialId ? _self.materialId : materialId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,receivedDate: freezed == receivedDate ? _self.receivedDate : receivedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,invoiceNumber: freezed == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MaterialReceipt].
extension MaterialReceiptPatterns on MaterialReceipt {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaterialReceipt value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaterialReceipt() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaterialReceipt value)  $default,){
final _that = this;
switch (_that) {
case _MaterialReceipt():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaterialReceipt value)?  $default,){
final _that = this;
switch (_that) {
case _MaterialReceipt() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String tenderId,  String warehouseId,  String materialId,  double quantity,  DateTime? receivedDate,  String? supplierName,  String? invoiceNumber,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaterialReceipt() when $default != null:
return $default(_that.id,_that.organizationId,_that.tenderId,_that.warehouseId,_that.materialId,_that.quantity,_that.receivedDate,_that.supplierName,_that.invoiceNumber,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String tenderId,  String warehouseId,  String materialId,  double quantity,  DateTime? receivedDate,  String? supplierName,  String? invoiceNumber,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _MaterialReceipt():
return $default(_that.id,_that.organizationId,_that.tenderId,_that.warehouseId,_that.materialId,_that.quantity,_that.receivedDate,_that.supplierName,_that.invoiceNumber,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String tenderId,  String warehouseId,  String materialId,  double quantity,  DateTime? receivedDate,  String? supplierName,  String? invoiceNumber,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _MaterialReceipt() when $default != null:
return $default(_that.id,_that.organizationId,_that.tenderId,_that.warehouseId,_that.materialId,_that.quantity,_that.receivedDate,_that.supplierName,_that.invoiceNumber,_that.notes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MaterialReceipt implements MaterialReceipt {
  const _MaterialReceipt({required this.id, required this.organizationId, required this.tenderId, required this.warehouseId, required this.materialId, required this.quantity, this.receivedDate, this.supplierName, this.invoiceNumber, this.notes});
  factory _MaterialReceipt.fromJson(Map<String, dynamic> json) => _$MaterialReceiptFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String tenderId;
@override final  String warehouseId;
@override final  String materialId;
@override final  double quantity;
@override final  DateTime? receivedDate;
@override final  String? supplierName;
@override final  String? invoiceNumber;
@override final  String? notes;

/// Create a copy of MaterialReceipt
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaterialReceiptCopyWith<_MaterialReceipt> get copyWith => __$MaterialReceiptCopyWithImpl<_MaterialReceipt>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaterialReceiptToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaterialReceipt&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.tenderId, tenderId) || other.tenderId == tenderId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.materialId, materialId) || other.materialId == materialId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.receivedDate, receivedDate) || other.receivedDate == receivedDate)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,tenderId,warehouseId,materialId,quantity,receivedDate,supplierName,invoiceNumber,notes);

@override
String toString() {
  return 'MaterialReceipt(id: $id, organizationId: $organizationId, tenderId: $tenderId, warehouseId: $warehouseId, materialId: $materialId, quantity: $quantity, receivedDate: $receivedDate, supplierName: $supplierName, invoiceNumber: $invoiceNumber, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$MaterialReceiptCopyWith<$Res> implements $MaterialReceiptCopyWith<$Res> {
  factory _$MaterialReceiptCopyWith(_MaterialReceipt value, $Res Function(_MaterialReceipt) _then) = __$MaterialReceiptCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String tenderId, String warehouseId, String materialId, double quantity, DateTime? receivedDate, String? supplierName, String? invoiceNumber, String? notes
});




}
/// @nodoc
class __$MaterialReceiptCopyWithImpl<$Res>
    implements _$MaterialReceiptCopyWith<$Res> {
  __$MaterialReceiptCopyWithImpl(this._self, this._then);

  final _MaterialReceipt _self;
  final $Res Function(_MaterialReceipt) _then;

/// Create a copy of MaterialReceipt
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? tenderId = null,Object? warehouseId = null,Object? materialId = null,Object? quantity = null,Object? receivedDate = freezed,Object? supplierName = freezed,Object? invoiceNumber = freezed,Object? notes = freezed,}) {
  return _then(_MaterialReceipt(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,tenderId: null == tenderId ? _self.tenderId : tenderId // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String,materialId: null == materialId ? _self.materialId : materialId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,receivedDate: freezed == receivedDate ? _self.receivedDate : receivedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,invoiceNumber: freezed == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MaterialIssue {

 String get id; String get organizationId; String get tenderId; String get warehouseId; String get schoolId; String get materialId; double get quantity; String? get managerId; DateTime? get issueDate; String? get notes;
/// Create a copy of MaterialIssue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaterialIssueCopyWith<MaterialIssue> get copyWith => _$MaterialIssueCopyWithImpl<MaterialIssue>(this as MaterialIssue, _$identity);

  /// Serializes this MaterialIssue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaterialIssue&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.tenderId, tenderId) || other.tenderId == tenderId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.materialId, materialId) || other.materialId == materialId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.managerId, managerId) || other.managerId == managerId)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,tenderId,warehouseId,schoolId,materialId,quantity,managerId,issueDate,notes);

@override
String toString() {
  return 'MaterialIssue(id: $id, organizationId: $organizationId, tenderId: $tenderId, warehouseId: $warehouseId, schoolId: $schoolId, materialId: $materialId, quantity: $quantity, managerId: $managerId, issueDate: $issueDate, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $MaterialIssueCopyWith<$Res>  {
  factory $MaterialIssueCopyWith(MaterialIssue value, $Res Function(MaterialIssue) _then) = _$MaterialIssueCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String tenderId, String warehouseId, String schoolId, String materialId, double quantity, String? managerId, DateTime? issueDate, String? notes
});




}
/// @nodoc
class _$MaterialIssueCopyWithImpl<$Res>
    implements $MaterialIssueCopyWith<$Res> {
  _$MaterialIssueCopyWithImpl(this._self, this._then);

  final MaterialIssue _self;
  final $Res Function(MaterialIssue) _then;

/// Create a copy of MaterialIssue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? tenderId = null,Object? warehouseId = null,Object? schoolId = null,Object? materialId = null,Object? quantity = null,Object? managerId = freezed,Object? issueDate = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,tenderId: null == tenderId ? _self.tenderId : tenderId // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String,schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,materialId: null == materialId ? _self.materialId : materialId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,managerId: freezed == managerId ? _self.managerId : managerId // ignore: cast_nullable_to_non_nullable
as String?,issueDate: freezed == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MaterialIssue].
extension MaterialIssuePatterns on MaterialIssue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaterialIssue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaterialIssue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaterialIssue value)  $default,){
final _that = this;
switch (_that) {
case _MaterialIssue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaterialIssue value)?  $default,){
final _that = this;
switch (_that) {
case _MaterialIssue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String tenderId,  String warehouseId,  String schoolId,  String materialId,  double quantity,  String? managerId,  DateTime? issueDate,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaterialIssue() when $default != null:
return $default(_that.id,_that.organizationId,_that.tenderId,_that.warehouseId,_that.schoolId,_that.materialId,_that.quantity,_that.managerId,_that.issueDate,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String tenderId,  String warehouseId,  String schoolId,  String materialId,  double quantity,  String? managerId,  DateTime? issueDate,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _MaterialIssue():
return $default(_that.id,_that.organizationId,_that.tenderId,_that.warehouseId,_that.schoolId,_that.materialId,_that.quantity,_that.managerId,_that.issueDate,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String tenderId,  String warehouseId,  String schoolId,  String materialId,  double quantity,  String? managerId,  DateTime? issueDate,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _MaterialIssue() when $default != null:
return $default(_that.id,_that.organizationId,_that.tenderId,_that.warehouseId,_that.schoolId,_that.materialId,_that.quantity,_that.managerId,_that.issueDate,_that.notes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MaterialIssue implements MaterialIssue {
  const _MaterialIssue({required this.id, required this.organizationId, required this.tenderId, required this.warehouseId, required this.schoolId, required this.materialId, required this.quantity, this.managerId, this.issueDate, this.notes});
  factory _MaterialIssue.fromJson(Map<String, dynamic> json) => _$MaterialIssueFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String tenderId;
@override final  String warehouseId;
@override final  String schoolId;
@override final  String materialId;
@override final  double quantity;
@override final  String? managerId;
@override final  DateTime? issueDate;
@override final  String? notes;

/// Create a copy of MaterialIssue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaterialIssueCopyWith<_MaterialIssue> get copyWith => __$MaterialIssueCopyWithImpl<_MaterialIssue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaterialIssueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaterialIssue&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.tenderId, tenderId) || other.tenderId == tenderId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.materialId, materialId) || other.materialId == materialId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.managerId, managerId) || other.managerId == managerId)&&(identical(other.issueDate, issueDate) || other.issueDate == issueDate)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,tenderId,warehouseId,schoolId,materialId,quantity,managerId,issueDate,notes);

@override
String toString() {
  return 'MaterialIssue(id: $id, organizationId: $organizationId, tenderId: $tenderId, warehouseId: $warehouseId, schoolId: $schoolId, materialId: $materialId, quantity: $quantity, managerId: $managerId, issueDate: $issueDate, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$MaterialIssueCopyWith<$Res> implements $MaterialIssueCopyWith<$Res> {
  factory _$MaterialIssueCopyWith(_MaterialIssue value, $Res Function(_MaterialIssue) _then) = __$MaterialIssueCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String tenderId, String warehouseId, String schoolId, String materialId, double quantity, String? managerId, DateTime? issueDate, String? notes
});




}
/// @nodoc
class __$MaterialIssueCopyWithImpl<$Res>
    implements _$MaterialIssueCopyWith<$Res> {
  __$MaterialIssueCopyWithImpl(this._self, this._then);

  final _MaterialIssue _self;
  final $Res Function(_MaterialIssue) _then;

/// Create a copy of MaterialIssue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? tenderId = null,Object? warehouseId = null,Object? schoolId = null,Object? materialId = null,Object? quantity = null,Object? managerId = freezed,Object? issueDate = freezed,Object? notes = freezed,}) {
  return _then(_MaterialIssue(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,tenderId: null == tenderId ? _self.tenderId : tenderId // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String,schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,materialId: null == materialId ? _self.materialId : materialId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,managerId: freezed == managerId ? _self.managerId : managerId // ignore: cast_nullable_to_non_nullable
as String?,issueDate: freezed == issueDate ? _self.issueDate : issueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MaterialReturn {

 String get id; String get organizationId; String get tenderId; String get warehouseId; String get schoolId; String get materialId; double get quantity; String? get managerId; DateTime? get returnDate; String? get reason; String? get notes;
/// Create a copy of MaterialReturn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaterialReturnCopyWith<MaterialReturn> get copyWith => _$MaterialReturnCopyWithImpl<MaterialReturn>(this as MaterialReturn, _$identity);

  /// Serializes this MaterialReturn to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaterialReturn&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.tenderId, tenderId) || other.tenderId == tenderId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.materialId, materialId) || other.materialId == materialId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.managerId, managerId) || other.managerId == managerId)&&(identical(other.returnDate, returnDate) || other.returnDate == returnDate)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,tenderId,warehouseId,schoolId,materialId,quantity,managerId,returnDate,reason,notes);

@override
String toString() {
  return 'MaterialReturn(id: $id, organizationId: $organizationId, tenderId: $tenderId, warehouseId: $warehouseId, schoolId: $schoolId, materialId: $materialId, quantity: $quantity, managerId: $managerId, returnDate: $returnDate, reason: $reason, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $MaterialReturnCopyWith<$Res>  {
  factory $MaterialReturnCopyWith(MaterialReturn value, $Res Function(MaterialReturn) _then) = _$MaterialReturnCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String tenderId, String warehouseId, String schoolId, String materialId, double quantity, String? managerId, DateTime? returnDate, String? reason, String? notes
});




}
/// @nodoc
class _$MaterialReturnCopyWithImpl<$Res>
    implements $MaterialReturnCopyWith<$Res> {
  _$MaterialReturnCopyWithImpl(this._self, this._then);

  final MaterialReturn _self;
  final $Res Function(MaterialReturn) _then;

/// Create a copy of MaterialReturn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? tenderId = null,Object? warehouseId = null,Object? schoolId = null,Object? materialId = null,Object? quantity = null,Object? managerId = freezed,Object? returnDate = freezed,Object? reason = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,tenderId: null == tenderId ? _self.tenderId : tenderId // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String,schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,materialId: null == materialId ? _self.materialId : materialId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,managerId: freezed == managerId ? _self.managerId : managerId // ignore: cast_nullable_to_non_nullable
as String?,returnDate: freezed == returnDate ? _self.returnDate : returnDate // ignore: cast_nullable_to_non_nullable
as DateTime?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MaterialReturn].
extension MaterialReturnPatterns on MaterialReturn {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaterialReturn value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaterialReturn() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaterialReturn value)  $default,){
final _that = this;
switch (_that) {
case _MaterialReturn():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaterialReturn value)?  $default,){
final _that = this;
switch (_that) {
case _MaterialReturn() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String tenderId,  String warehouseId,  String schoolId,  String materialId,  double quantity,  String? managerId,  DateTime? returnDate,  String? reason,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaterialReturn() when $default != null:
return $default(_that.id,_that.organizationId,_that.tenderId,_that.warehouseId,_that.schoolId,_that.materialId,_that.quantity,_that.managerId,_that.returnDate,_that.reason,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String tenderId,  String warehouseId,  String schoolId,  String materialId,  double quantity,  String? managerId,  DateTime? returnDate,  String? reason,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _MaterialReturn():
return $default(_that.id,_that.organizationId,_that.tenderId,_that.warehouseId,_that.schoolId,_that.materialId,_that.quantity,_that.managerId,_that.returnDate,_that.reason,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String tenderId,  String warehouseId,  String schoolId,  String materialId,  double quantity,  String? managerId,  DateTime? returnDate,  String? reason,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _MaterialReturn() when $default != null:
return $default(_that.id,_that.organizationId,_that.tenderId,_that.warehouseId,_that.schoolId,_that.materialId,_that.quantity,_that.managerId,_that.returnDate,_that.reason,_that.notes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MaterialReturn implements MaterialReturn {
  const _MaterialReturn({required this.id, required this.organizationId, required this.tenderId, required this.warehouseId, required this.schoolId, required this.materialId, required this.quantity, this.managerId, this.returnDate, this.reason, this.notes});
  factory _MaterialReturn.fromJson(Map<String, dynamic> json) => _$MaterialReturnFromJson(json);

@override final  String id;
@override final  String organizationId;
@override final  String tenderId;
@override final  String warehouseId;
@override final  String schoolId;
@override final  String materialId;
@override final  double quantity;
@override final  String? managerId;
@override final  DateTime? returnDate;
@override final  String? reason;
@override final  String? notes;

/// Create a copy of MaterialReturn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaterialReturnCopyWith<_MaterialReturn> get copyWith => __$MaterialReturnCopyWithImpl<_MaterialReturn>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaterialReturnToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaterialReturn&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.tenderId, tenderId) || other.tenderId == tenderId)&&(identical(other.warehouseId, warehouseId) || other.warehouseId == warehouseId)&&(identical(other.schoolId, schoolId) || other.schoolId == schoolId)&&(identical(other.materialId, materialId) || other.materialId == materialId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.managerId, managerId) || other.managerId == managerId)&&(identical(other.returnDate, returnDate) || other.returnDate == returnDate)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,organizationId,tenderId,warehouseId,schoolId,materialId,quantity,managerId,returnDate,reason,notes);

@override
String toString() {
  return 'MaterialReturn(id: $id, organizationId: $organizationId, tenderId: $tenderId, warehouseId: $warehouseId, schoolId: $schoolId, materialId: $materialId, quantity: $quantity, managerId: $managerId, returnDate: $returnDate, reason: $reason, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$MaterialReturnCopyWith<$Res> implements $MaterialReturnCopyWith<$Res> {
  factory _$MaterialReturnCopyWith(_MaterialReturn value, $Res Function(_MaterialReturn) _then) = __$MaterialReturnCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String tenderId, String warehouseId, String schoolId, String materialId, double quantity, String? managerId, DateTime? returnDate, String? reason, String? notes
});




}
/// @nodoc
class __$MaterialReturnCopyWithImpl<$Res>
    implements _$MaterialReturnCopyWith<$Res> {
  __$MaterialReturnCopyWithImpl(this._self, this._then);

  final _MaterialReturn _self;
  final $Res Function(_MaterialReturn) _then;

/// Create a copy of MaterialReturn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? tenderId = null,Object? warehouseId = null,Object? schoolId = null,Object? materialId = null,Object? quantity = null,Object? managerId = freezed,Object? returnDate = freezed,Object? reason = freezed,Object? notes = freezed,}) {
  return _then(_MaterialReturn(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,tenderId: null == tenderId ? _self.tenderId : tenderId // ignore: cast_nullable_to_non_nullable
as String,warehouseId: null == warehouseId ? _self.warehouseId : warehouseId // ignore: cast_nullable_to_non_nullable
as String,schoolId: null == schoolId ? _self.schoolId : schoolId // ignore: cast_nullable_to_non_nullable
as String,materialId: null == materialId ? _self.materialId : materialId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,managerId: freezed == managerId ? _self.managerId : managerId // ignore: cast_nullable_to_non_nullable
as String?,returnDate: freezed == returnDate ? _self.returnDate : returnDate // ignore: cast_nullable_to_non_nullable
as DateTime?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
