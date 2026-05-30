// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ledger_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Party {

 String get id; String get businessId; String get bookId; String get name; String get phone; PartyType get type; int get balancePaise; int get creditLimitPaise; List<String> get tags; String? get alternatePhone; String? get address; String? get gstin; String? get upiId; String? get notes; String? get profileImageUrl; DateTime? get lastActivityAt; SyncStatus get syncStatus; DateTime? get deletedAt;
/// Create a copy of Party
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartyCopyWith<Party> get copyWith => _$PartyCopyWithImpl<Party>(this as Party, _$identity);

  /// Serializes this Party to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Party&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.type, type) || other.type == type)&&(identical(other.balancePaise, balancePaise) || other.balancePaise == balancePaise)&&(identical(other.creditLimitPaise, creditLimitPaise) || other.creditLimitPaise == creditLimitPaise)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.alternatePhone, alternatePhone) || other.alternatePhone == alternatePhone)&&(identical(other.address, address) || other.address == address)&&(identical(other.gstin, gstin) || other.gstin == gstin)&&(identical(other.upiId, upiId) || other.upiId == upiId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,bookId,name,phone,type,balancePaise,creditLimitPaise,const DeepCollectionEquality().hash(tags),alternatePhone,address,gstin,upiId,notes,profileImageUrl,lastActivityAt,syncStatus,deletedAt);

@override
String toString() {
  return 'Party(id: $id, businessId: $businessId, bookId: $bookId, name: $name, phone: $phone, type: $type, balancePaise: $balancePaise, creditLimitPaise: $creditLimitPaise, tags: $tags, alternatePhone: $alternatePhone, address: $address, gstin: $gstin, upiId: $upiId, notes: $notes, profileImageUrl: $profileImageUrl, lastActivityAt: $lastActivityAt, syncStatus: $syncStatus, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $PartyCopyWith<$Res>  {
  factory $PartyCopyWith(Party value, $Res Function(Party) _then) = _$PartyCopyWithImpl;
@useResult
$Res call({
 String id, String businessId, String bookId, String name, String phone, PartyType type, int balancePaise, int creditLimitPaise, List<String> tags, String? alternatePhone, String? address, String? gstin, String? upiId, String? notes, String? profileImageUrl, DateTime? lastActivityAt, SyncStatus syncStatus, DateTime? deletedAt
});




}
/// @nodoc
class _$PartyCopyWithImpl<$Res>
    implements $PartyCopyWith<$Res> {
  _$PartyCopyWithImpl(this._self, this._then);

  final Party _self;
  final $Res Function(Party) _then;

/// Create a copy of Party
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? businessId = null,Object? bookId = null,Object? name = null,Object? phone = null,Object? type = null,Object? balancePaise = null,Object? creditLimitPaise = null,Object? tags = null,Object? alternatePhone = freezed,Object? address = freezed,Object? gstin = freezed,Object? upiId = freezed,Object? notes = freezed,Object? profileImageUrl = freezed,Object? lastActivityAt = freezed,Object? syncStatus = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PartyType,balancePaise: null == balancePaise ? _self.balancePaise : balancePaise // ignore: cast_nullable_to_non_nullable
as int,creditLimitPaise: null == creditLimitPaise ? _self.creditLimitPaise : creditLimitPaise // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,alternatePhone: freezed == alternatePhone ? _self.alternatePhone : alternatePhone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,gstin: freezed == gstin ? _self.gstin : gstin // ignore: cast_nullable_to_non_nullable
as String?,upiId: freezed == upiId ? _self.upiId : upiId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Party].
extension PartyPatterns on Party {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Party value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Party() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Party value)  $default,){
final _that = this;
switch (_that) {
case _Party():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Party value)?  $default,){
final _that = this;
switch (_that) {
case _Party() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String businessId,  String bookId,  String name,  String phone,  PartyType type,  int balancePaise,  int creditLimitPaise,  List<String> tags,  String? alternatePhone,  String? address,  String? gstin,  String? upiId,  String? notes,  String? profileImageUrl,  DateTime? lastActivityAt,  SyncStatus syncStatus,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Party() when $default != null:
return $default(_that.id,_that.businessId,_that.bookId,_that.name,_that.phone,_that.type,_that.balancePaise,_that.creditLimitPaise,_that.tags,_that.alternatePhone,_that.address,_that.gstin,_that.upiId,_that.notes,_that.profileImageUrl,_that.lastActivityAt,_that.syncStatus,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String businessId,  String bookId,  String name,  String phone,  PartyType type,  int balancePaise,  int creditLimitPaise,  List<String> tags,  String? alternatePhone,  String? address,  String? gstin,  String? upiId,  String? notes,  String? profileImageUrl,  DateTime? lastActivityAt,  SyncStatus syncStatus,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Party():
return $default(_that.id,_that.businessId,_that.bookId,_that.name,_that.phone,_that.type,_that.balancePaise,_that.creditLimitPaise,_that.tags,_that.alternatePhone,_that.address,_that.gstin,_that.upiId,_that.notes,_that.profileImageUrl,_that.lastActivityAt,_that.syncStatus,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String businessId,  String bookId,  String name,  String phone,  PartyType type,  int balancePaise,  int creditLimitPaise,  List<String> tags,  String? alternatePhone,  String? address,  String? gstin,  String? upiId,  String? notes,  String? profileImageUrl,  DateTime? lastActivityAt,  SyncStatus syncStatus,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Party() when $default != null:
return $default(_that.id,_that.businessId,_that.bookId,_that.name,_that.phone,_that.type,_that.balancePaise,_that.creditLimitPaise,_that.tags,_that.alternatePhone,_that.address,_that.gstin,_that.upiId,_that.notes,_that.profileImageUrl,_that.lastActivityAt,_that.syncStatus,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Party implements Party {
  const _Party({required this.id, required this.businessId, required this.bookId, required this.name, required this.phone, this.type = PartyType.customer, this.balancePaise = 0, this.creditLimitPaise = 0, final  List<String> tags = const <String>[], this.alternatePhone, this.address, this.gstin, this.upiId, this.notes, this.profileImageUrl, this.lastActivityAt, this.syncStatus = SyncStatus.synced, this.deletedAt}): _tags = tags;
  factory _Party.fromJson(Map<String, dynamic> json) => _$PartyFromJson(json);

@override final  String id;
@override final  String businessId;
@override final  String bookId;
@override final  String name;
@override final  String phone;
@override@JsonKey() final  PartyType type;
@override@JsonKey() final  int balancePaise;
@override@JsonKey() final  int creditLimitPaise;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  String? alternatePhone;
@override final  String? address;
@override final  String? gstin;
@override final  String? upiId;
@override final  String? notes;
@override final  String? profileImageUrl;
@override final  DateTime? lastActivityAt;
@override@JsonKey() final  SyncStatus syncStatus;
@override final  DateTime? deletedAt;

/// Create a copy of Party
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartyCopyWith<_Party> get copyWith => __$PartyCopyWithImpl<_Party>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Party&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.type, type) || other.type == type)&&(identical(other.balancePaise, balancePaise) || other.balancePaise == balancePaise)&&(identical(other.creditLimitPaise, creditLimitPaise) || other.creditLimitPaise == creditLimitPaise)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.alternatePhone, alternatePhone) || other.alternatePhone == alternatePhone)&&(identical(other.address, address) || other.address == address)&&(identical(other.gstin, gstin) || other.gstin == gstin)&&(identical(other.upiId, upiId) || other.upiId == upiId)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.lastActivityAt, lastActivityAt) || other.lastActivityAt == lastActivityAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,bookId,name,phone,type,balancePaise,creditLimitPaise,const DeepCollectionEquality().hash(_tags),alternatePhone,address,gstin,upiId,notes,profileImageUrl,lastActivityAt,syncStatus,deletedAt);

@override
String toString() {
  return 'Party(id: $id, businessId: $businessId, bookId: $bookId, name: $name, phone: $phone, type: $type, balancePaise: $balancePaise, creditLimitPaise: $creditLimitPaise, tags: $tags, alternatePhone: $alternatePhone, address: $address, gstin: $gstin, upiId: $upiId, notes: $notes, profileImageUrl: $profileImageUrl, lastActivityAt: $lastActivityAt, syncStatus: $syncStatus, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$PartyCopyWith<$Res> implements $PartyCopyWith<$Res> {
  factory _$PartyCopyWith(_Party value, $Res Function(_Party) _then) = __$PartyCopyWithImpl;
@override @useResult
$Res call({
 String id, String businessId, String bookId, String name, String phone, PartyType type, int balancePaise, int creditLimitPaise, List<String> tags, String? alternatePhone, String? address, String? gstin, String? upiId, String? notes, String? profileImageUrl, DateTime? lastActivityAt, SyncStatus syncStatus, DateTime? deletedAt
});




}
/// @nodoc
class __$PartyCopyWithImpl<$Res>
    implements _$PartyCopyWith<$Res> {
  __$PartyCopyWithImpl(this._self, this._then);

  final _Party _self;
  final $Res Function(_Party) _then;

/// Create a copy of Party
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? businessId = null,Object? bookId = null,Object? name = null,Object? phone = null,Object? type = null,Object? balancePaise = null,Object? creditLimitPaise = null,Object? tags = null,Object? alternatePhone = freezed,Object? address = freezed,Object? gstin = freezed,Object? upiId = freezed,Object? notes = freezed,Object? profileImageUrl = freezed,Object? lastActivityAt = freezed,Object? syncStatus = null,Object? deletedAt = freezed,}) {
  return _then(_Party(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PartyType,balancePaise: null == balancePaise ? _self.balancePaise : balancePaise // ignore: cast_nullable_to_non_nullable
as int,creditLimitPaise: null == creditLimitPaise ? _self.creditLimitPaise : creditLimitPaise // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,alternatePhone: freezed == alternatePhone ? _self.alternatePhone : alternatePhone // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,gstin: freezed == gstin ? _self.gstin : gstin // ignore: cast_nullable_to_non_nullable
as String?,upiId: freezed == upiId ? _self.upiId : upiId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,lastActivityAt: freezed == lastActivityAt ? _self.lastActivityAt : lastActivityAt // ignore: cast_nullable_to_non_nullable
as DateTime?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$LedgerTransaction {

 String get id; String get businessId; String get bookId; String get partyId; TransactionType get type; int get amountPaise; DateTime get occurredAt; PaymentMode get paymentMode; String? get note; DateTime? get dueDate; DateTime? get reminderDate; String? get attachmentPath; String? get createdBy; String? get updatedBy; String? get reversalOfTransactionId; bool get isReversal; SyncStatus get syncStatus; DateTime? get deletedAt;
/// Create a copy of LedgerTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LedgerTransactionCopyWith<LedgerTransaction> get copyWith => _$LedgerTransactionCopyWithImpl<LedgerTransaction>(this as LedgerTransaction, _$identity);

  /// Serializes this LedgerTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LedgerTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.partyId, partyId) || other.partyId == partyId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.note, note) || other.note == note)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.reminderDate, reminderDate) || other.reminderDate == reminderDate)&&(identical(other.attachmentPath, attachmentPath) || other.attachmentPath == attachmentPath)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy)&&(identical(other.reversalOfTransactionId, reversalOfTransactionId) || other.reversalOfTransactionId == reversalOfTransactionId)&&(identical(other.isReversal, isReversal) || other.isReversal == isReversal)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,bookId,partyId,type,amountPaise,occurredAt,paymentMode,note,dueDate,reminderDate,attachmentPath,createdBy,updatedBy,reversalOfTransactionId,isReversal,syncStatus,deletedAt);

@override
String toString() {
  return 'LedgerTransaction(id: $id, businessId: $businessId, bookId: $bookId, partyId: $partyId, type: $type, amountPaise: $amountPaise, occurredAt: $occurredAt, paymentMode: $paymentMode, note: $note, dueDate: $dueDate, reminderDate: $reminderDate, attachmentPath: $attachmentPath, createdBy: $createdBy, updatedBy: $updatedBy, reversalOfTransactionId: $reversalOfTransactionId, isReversal: $isReversal, syncStatus: $syncStatus, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $LedgerTransactionCopyWith<$Res>  {
  factory $LedgerTransactionCopyWith(LedgerTransaction value, $Res Function(LedgerTransaction) _then) = _$LedgerTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String businessId, String bookId, String partyId, TransactionType type, int amountPaise, DateTime occurredAt, PaymentMode paymentMode, String? note, DateTime? dueDate, DateTime? reminderDate, String? attachmentPath, String? createdBy, String? updatedBy, String? reversalOfTransactionId, bool isReversal, SyncStatus syncStatus, DateTime? deletedAt
});




}
/// @nodoc
class _$LedgerTransactionCopyWithImpl<$Res>
    implements $LedgerTransactionCopyWith<$Res> {
  _$LedgerTransactionCopyWithImpl(this._self, this._then);

  final LedgerTransaction _self;
  final $Res Function(LedgerTransaction) _then;

/// Create a copy of LedgerTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? businessId = null,Object? bookId = null,Object? partyId = null,Object? type = null,Object? amountPaise = null,Object? occurredAt = null,Object? paymentMode = null,Object? note = freezed,Object? dueDate = freezed,Object? reminderDate = freezed,Object? attachmentPath = freezed,Object? createdBy = freezed,Object? updatedBy = freezed,Object? reversalOfTransactionId = freezed,Object? isReversal = null,Object? syncStatus = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as String,partyId: null == partyId ? _self.partyId : partyId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,amountPaise: null == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as PaymentMode,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,reminderDate: freezed == reminderDate ? _self.reminderDate : reminderDate // ignore: cast_nullable_to_non_nullable
as DateTime?,attachmentPath: freezed == attachmentPath ? _self.attachmentPath : attachmentPath // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,reversalOfTransactionId: freezed == reversalOfTransactionId ? _self.reversalOfTransactionId : reversalOfTransactionId // ignore: cast_nullable_to_non_nullable
as String?,isReversal: null == isReversal ? _self.isReversal : isReversal // ignore: cast_nullable_to_non_nullable
as bool,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LedgerTransaction].
extension LedgerTransactionPatterns on LedgerTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LedgerTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LedgerTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LedgerTransaction value)  $default,){
final _that = this;
switch (_that) {
case _LedgerTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LedgerTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _LedgerTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String businessId,  String bookId,  String partyId,  TransactionType type,  int amountPaise,  DateTime occurredAt,  PaymentMode paymentMode,  String? note,  DateTime? dueDate,  DateTime? reminderDate,  String? attachmentPath,  String? createdBy,  String? updatedBy,  String? reversalOfTransactionId,  bool isReversal,  SyncStatus syncStatus,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LedgerTransaction() when $default != null:
return $default(_that.id,_that.businessId,_that.bookId,_that.partyId,_that.type,_that.amountPaise,_that.occurredAt,_that.paymentMode,_that.note,_that.dueDate,_that.reminderDate,_that.attachmentPath,_that.createdBy,_that.updatedBy,_that.reversalOfTransactionId,_that.isReversal,_that.syncStatus,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String businessId,  String bookId,  String partyId,  TransactionType type,  int amountPaise,  DateTime occurredAt,  PaymentMode paymentMode,  String? note,  DateTime? dueDate,  DateTime? reminderDate,  String? attachmentPath,  String? createdBy,  String? updatedBy,  String? reversalOfTransactionId,  bool isReversal,  SyncStatus syncStatus,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _LedgerTransaction():
return $default(_that.id,_that.businessId,_that.bookId,_that.partyId,_that.type,_that.amountPaise,_that.occurredAt,_that.paymentMode,_that.note,_that.dueDate,_that.reminderDate,_that.attachmentPath,_that.createdBy,_that.updatedBy,_that.reversalOfTransactionId,_that.isReversal,_that.syncStatus,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String businessId,  String bookId,  String partyId,  TransactionType type,  int amountPaise,  DateTime occurredAt,  PaymentMode paymentMode,  String? note,  DateTime? dueDate,  DateTime? reminderDate,  String? attachmentPath,  String? createdBy,  String? updatedBy,  String? reversalOfTransactionId,  bool isReversal,  SyncStatus syncStatus,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _LedgerTransaction() when $default != null:
return $default(_that.id,_that.businessId,_that.bookId,_that.partyId,_that.type,_that.amountPaise,_that.occurredAt,_that.paymentMode,_that.note,_that.dueDate,_that.reminderDate,_that.attachmentPath,_that.createdBy,_that.updatedBy,_that.reversalOfTransactionId,_that.isReversal,_that.syncStatus,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LedgerTransaction implements LedgerTransaction {
  const _LedgerTransaction({required this.id, required this.businessId, required this.bookId, required this.partyId, required this.type, required this.amountPaise, required this.occurredAt, this.paymentMode = PaymentMode.cash, this.note, this.dueDate, this.reminderDate, this.attachmentPath, this.createdBy, this.updatedBy, this.reversalOfTransactionId, this.isReversal = false, this.syncStatus = SyncStatus.pending, this.deletedAt});
  factory _LedgerTransaction.fromJson(Map<String, dynamic> json) => _$LedgerTransactionFromJson(json);

@override final  String id;
@override final  String businessId;
@override final  String bookId;
@override final  String partyId;
@override final  TransactionType type;
@override final  int amountPaise;
@override final  DateTime occurredAt;
@override@JsonKey() final  PaymentMode paymentMode;
@override final  String? note;
@override final  DateTime? dueDate;
@override final  DateTime? reminderDate;
@override final  String? attachmentPath;
@override final  String? createdBy;
@override final  String? updatedBy;
@override final  String? reversalOfTransactionId;
@override@JsonKey() final  bool isReversal;
@override@JsonKey() final  SyncStatus syncStatus;
@override final  DateTime? deletedAt;

/// Create a copy of LedgerTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LedgerTransactionCopyWith<_LedgerTransaction> get copyWith => __$LedgerTransactionCopyWithImpl<_LedgerTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LedgerTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LedgerTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.partyId, partyId) || other.partyId == partyId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amountPaise, amountPaise) || other.amountPaise == amountPaise)&&(identical(other.occurredAt, occurredAt) || other.occurredAt == occurredAt)&&(identical(other.paymentMode, paymentMode) || other.paymentMode == paymentMode)&&(identical(other.note, note) || other.note == note)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.reminderDate, reminderDate) || other.reminderDate == reminderDate)&&(identical(other.attachmentPath, attachmentPath) || other.attachmentPath == attachmentPath)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.updatedBy, updatedBy) || other.updatedBy == updatedBy)&&(identical(other.reversalOfTransactionId, reversalOfTransactionId) || other.reversalOfTransactionId == reversalOfTransactionId)&&(identical(other.isReversal, isReversal) || other.isReversal == isReversal)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,bookId,partyId,type,amountPaise,occurredAt,paymentMode,note,dueDate,reminderDate,attachmentPath,createdBy,updatedBy,reversalOfTransactionId,isReversal,syncStatus,deletedAt);

@override
String toString() {
  return 'LedgerTransaction(id: $id, businessId: $businessId, bookId: $bookId, partyId: $partyId, type: $type, amountPaise: $amountPaise, occurredAt: $occurredAt, paymentMode: $paymentMode, note: $note, dueDate: $dueDate, reminderDate: $reminderDate, attachmentPath: $attachmentPath, createdBy: $createdBy, updatedBy: $updatedBy, reversalOfTransactionId: $reversalOfTransactionId, isReversal: $isReversal, syncStatus: $syncStatus, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$LedgerTransactionCopyWith<$Res> implements $LedgerTransactionCopyWith<$Res> {
  factory _$LedgerTransactionCopyWith(_LedgerTransaction value, $Res Function(_LedgerTransaction) _then) = __$LedgerTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String businessId, String bookId, String partyId, TransactionType type, int amountPaise, DateTime occurredAt, PaymentMode paymentMode, String? note, DateTime? dueDate, DateTime? reminderDate, String? attachmentPath, String? createdBy, String? updatedBy, String? reversalOfTransactionId, bool isReversal, SyncStatus syncStatus, DateTime? deletedAt
});




}
/// @nodoc
class __$LedgerTransactionCopyWithImpl<$Res>
    implements _$LedgerTransactionCopyWith<$Res> {
  __$LedgerTransactionCopyWithImpl(this._self, this._then);

  final _LedgerTransaction _self;
  final $Res Function(_LedgerTransaction) _then;

/// Create a copy of LedgerTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? businessId = null,Object? bookId = null,Object? partyId = null,Object? type = null,Object? amountPaise = null,Object? occurredAt = null,Object? paymentMode = null,Object? note = freezed,Object? dueDate = freezed,Object? reminderDate = freezed,Object? attachmentPath = freezed,Object? createdBy = freezed,Object? updatedBy = freezed,Object? reversalOfTransactionId = freezed,Object? isReversal = null,Object? syncStatus = null,Object? deletedAt = freezed,}) {
  return _then(_LedgerTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as String,partyId: null == partyId ? _self.partyId : partyId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,amountPaise: null == amountPaise ? _self.amountPaise : amountPaise // ignore: cast_nullable_to_non_nullable
as int,occurredAt: null == occurredAt ? _self.occurredAt : occurredAt // ignore: cast_nullable_to_non_nullable
as DateTime,paymentMode: null == paymentMode ? _self.paymentMode : paymentMode // ignore: cast_nullable_to_non_nullable
as PaymentMode,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,reminderDate: freezed == reminderDate ? _self.reminderDate : reminderDate // ignore: cast_nullable_to_non_nullable
as DateTime?,attachmentPath: freezed == attachmentPath ? _self.attachmentPath : attachmentPath // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,updatedBy: freezed == updatedBy ? _self.updatedBy : updatedBy // ignore: cast_nullable_to_non_nullable
as String?,reversalOfTransactionId: freezed == reversalOfTransactionId ? _self.reversalOfTransactionId : reversalOfTransactionId // ignore: cast_nullable_to_non_nullable
as String?,isReversal: null == isReversal ? _self.isReversal : isReversal // ignore: cast_nullable_to_non_nullable
as bool,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$BusinessProfile {

 String get id; String get name; String? get ownerName; String? get phone; String? get upiId; String? get gstin; String? get address;
/// Create a copy of BusinessProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BusinessProfileCopyWith<BusinessProfile> get copyWith => _$BusinessProfileCopyWithImpl<BusinessProfile>(this as BusinessProfile, _$identity);

  /// Serializes this BusinessProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BusinessProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.upiId, upiId) || other.upiId == upiId)&&(identical(other.gstin, gstin) || other.gstin == gstin)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerName,phone,upiId,gstin,address);

@override
String toString() {
  return 'BusinessProfile(id: $id, name: $name, ownerName: $ownerName, phone: $phone, upiId: $upiId, gstin: $gstin, address: $address)';
}


}

/// @nodoc
abstract mixin class $BusinessProfileCopyWith<$Res>  {
  factory $BusinessProfileCopyWith(BusinessProfile value, $Res Function(BusinessProfile) _then) = _$BusinessProfileCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? ownerName, String? phone, String? upiId, String? gstin, String? address
});




}
/// @nodoc
class _$BusinessProfileCopyWithImpl<$Res>
    implements $BusinessProfileCopyWith<$Res> {
  _$BusinessProfileCopyWithImpl(this._self, this._then);

  final BusinessProfile _self;
  final $Res Function(BusinessProfile) _then;

/// Create a copy of BusinessProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? ownerName = freezed,Object? phone = freezed,Object? upiId = freezed,Object? gstin = freezed,Object? address = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: freezed == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,upiId: freezed == upiId ? _self.upiId : upiId // ignore: cast_nullable_to_non_nullable
as String?,gstin: freezed == gstin ? _self.gstin : gstin // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BusinessProfile].
extension BusinessProfilePatterns on BusinessProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BusinessProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BusinessProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BusinessProfile value)  $default,){
final _that = this;
switch (_that) {
case _BusinessProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BusinessProfile value)?  $default,){
final _that = this;
switch (_that) {
case _BusinessProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? ownerName,  String? phone,  String? upiId,  String? gstin,  String? address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BusinessProfile() when $default != null:
return $default(_that.id,_that.name,_that.ownerName,_that.phone,_that.upiId,_that.gstin,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? ownerName,  String? phone,  String? upiId,  String? gstin,  String? address)  $default,) {final _that = this;
switch (_that) {
case _BusinessProfile():
return $default(_that.id,_that.name,_that.ownerName,_that.phone,_that.upiId,_that.gstin,_that.address);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? ownerName,  String? phone,  String? upiId,  String? gstin,  String? address)?  $default,) {final _that = this;
switch (_that) {
case _BusinessProfile() when $default != null:
return $default(_that.id,_that.name,_that.ownerName,_that.phone,_that.upiId,_that.gstin,_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BusinessProfile implements BusinessProfile {
  const _BusinessProfile({required this.id, required this.name, this.ownerName, this.phone, this.upiId, this.gstin, this.address});
  factory _BusinessProfile.fromJson(Map<String, dynamic> json) => _$BusinessProfileFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? ownerName;
@override final  String? phone;
@override final  String? upiId;
@override final  String? gstin;
@override final  String? address;

/// Create a copy of BusinessProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BusinessProfileCopyWith<_BusinessProfile> get copyWith => __$BusinessProfileCopyWithImpl<_BusinessProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BusinessProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BusinessProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.upiId, upiId) || other.upiId == upiId)&&(identical(other.gstin, gstin) || other.gstin == gstin)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,ownerName,phone,upiId,gstin,address);

@override
String toString() {
  return 'BusinessProfile(id: $id, name: $name, ownerName: $ownerName, phone: $phone, upiId: $upiId, gstin: $gstin, address: $address)';
}


}

/// @nodoc
abstract mixin class _$BusinessProfileCopyWith<$Res> implements $BusinessProfileCopyWith<$Res> {
  factory _$BusinessProfileCopyWith(_BusinessProfile value, $Res Function(_BusinessProfile) _then) = __$BusinessProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? ownerName, String? phone, String? upiId, String? gstin, String? address
});




}
/// @nodoc
class __$BusinessProfileCopyWithImpl<$Res>
    implements _$BusinessProfileCopyWith<$Res> {
  __$BusinessProfileCopyWithImpl(this._self, this._then);

  final _BusinessProfile _self;
  final $Res Function(_BusinessProfile) _then;

/// Create a copy of BusinessProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? ownerName = freezed,Object? phone = freezed,Object? upiId = freezed,Object? gstin = freezed,Object? address = freezed,}) {
  return _then(_BusinessProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: freezed == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,upiId: freezed == upiId ? _self.upiId : upiId // ignore: cast_nullable_to_non_nullable
as String?,gstin: freezed == gstin ? _self.gstin : gstin // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BusinessSummary {

 int get totalReceivablePaise; int get totalPayablePaise; int get todayCollectionPaise; int get todayCreditGivenPaise; int get overdueParties; int get activeParties; int get lowStockItems; int get pendingSyncItems;
/// Create a copy of BusinessSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BusinessSummaryCopyWith<BusinessSummary> get copyWith => _$BusinessSummaryCopyWithImpl<BusinessSummary>(this as BusinessSummary, _$identity);

  /// Serializes this BusinessSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BusinessSummary&&(identical(other.totalReceivablePaise, totalReceivablePaise) || other.totalReceivablePaise == totalReceivablePaise)&&(identical(other.totalPayablePaise, totalPayablePaise) || other.totalPayablePaise == totalPayablePaise)&&(identical(other.todayCollectionPaise, todayCollectionPaise) || other.todayCollectionPaise == todayCollectionPaise)&&(identical(other.todayCreditGivenPaise, todayCreditGivenPaise) || other.todayCreditGivenPaise == todayCreditGivenPaise)&&(identical(other.overdueParties, overdueParties) || other.overdueParties == overdueParties)&&(identical(other.activeParties, activeParties) || other.activeParties == activeParties)&&(identical(other.lowStockItems, lowStockItems) || other.lowStockItems == lowStockItems)&&(identical(other.pendingSyncItems, pendingSyncItems) || other.pendingSyncItems == pendingSyncItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalReceivablePaise,totalPayablePaise,todayCollectionPaise,todayCreditGivenPaise,overdueParties,activeParties,lowStockItems,pendingSyncItems);

@override
String toString() {
  return 'BusinessSummary(totalReceivablePaise: $totalReceivablePaise, totalPayablePaise: $totalPayablePaise, todayCollectionPaise: $todayCollectionPaise, todayCreditGivenPaise: $todayCreditGivenPaise, overdueParties: $overdueParties, activeParties: $activeParties, lowStockItems: $lowStockItems, pendingSyncItems: $pendingSyncItems)';
}


}

/// @nodoc
abstract mixin class $BusinessSummaryCopyWith<$Res>  {
  factory $BusinessSummaryCopyWith(BusinessSummary value, $Res Function(BusinessSummary) _then) = _$BusinessSummaryCopyWithImpl;
@useResult
$Res call({
 int totalReceivablePaise, int totalPayablePaise, int todayCollectionPaise, int todayCreditGivenPaise, int overdueParties, int activeParties, int lowStockItems, int pendingSyncItems
});




}
/// @nodoc
class _$BusinessSummaryCopyWithImpl<$Res>
    implements $BusinessSummaryCopyWith<$Res> {
  _$BusinessSummaryCopyWithImpl(this._self, this._then);

  final BusinessSummary _self;
  final $Res Function(BusinessSummary) _then;

/// Create a copy of BusinessSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalReceivablePaise = null,Object? totalPayablePaise = null,Object? todayCollectionPaise = null,Object? todayCreditGivenPaise = null,Object? overdueParties = null,Object? activeParties = null,Object? lowStockItems = null,Object? pendingSyncItems = null,}) {
  return _then(_self.copyWith(
totalReceivablePaise: null == totalReceivablePaise ? _self.totalReceivablePaise : totalReceivablePaise // ignore: cast_nullable_to_non_nullable
as int,totalPayablePaise: null == totalPayablePaise ? _self.totalPayablePaise : totalPayablePaise // ignore: cast_nullable_to_non_nullable
as int,todayCollectionPaise: null == todayCollectionPaise ? _self.todayCollectionPaise : todayCollectionPaise // ignore: cast_nullable_to_non_nullable
as int,todayCreditGivenPaise: null == todayCreditGivenPaise ? _self.todayCreditGivenPaise : todayCreditGivenPaise // ignore: cast_nullable_to_non_nullable
as int,overdueParties: null == overdueParties ? _self.overdueParties : overdueParties // ignore: cast_nullable_to_non_nullable
as int,activeParties: null == activeParties ? _self.activeParties : activeParties // ignore: cast_nullable_to_non_nullable
as int,lowStockItems: null == lowStockItems ? _self.lowStockItems : lowStockItems // ignore: cast_nullable_to_non_nullable
as int,pendingSyncItems: null == pendingSyncItems ? _self.pendingSyncItems : pendingSyncItems // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BusinessSummary].
extension BusinessSummaryPatterns on BusinessSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BusinessSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BusinessSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BusinessSummary value)  $default,){
final _that = this;
switch (_that) {
case _BusinessSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BusinessSummary value)?  $default,){
final _that = this;
switch (_that) {
case _BusinessSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalReceivablePaise,  int totalPayablePaise,  int todayCollectionPaise,  int todayCreditGivenPaise,  int overdueParties,  int activeParties,  int lowStockItems,  int pendingSyncItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BusinessSummary() when $default != null:
return $default(_that.totalReceivablePaise,_that.totalPayablePaise,_that.todayCollectionPaise,_that.todayCreditGivenPaise,_that.overdueParties,_that.activeParties,_that.lowStockItems,_that.pendingSyncItems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalReceivablePaise,  int totalPayablePaise,  int todayCollectionPaise,  int todayCreditGivenPaise,  int overdueParties,  int activeParties,  int lowStockItems,  int pendingSyncItems)  $default,) {final _that = this;
switch (_that) {
case _BusinessSummary():
return $default(_that.totalReceivablePaise,_that.totalPayablePaise,_that.todayCollectionPaise,_that.todayCreditGivenPaise,_that.overdueParties,_that.activeParties,_that.lowStockItems,_that.pendingSyncItems);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalReceivablePaise,  int totalPayablePaise,  int todayCollectionPaise,  int todayCreditGivenPaise,  int overdueParties,  int activeParties,  int lowStockItems,  int pendingSyncItems)?  $default,) {final _that = this;
switch (_that) {
case _BusinessSummary() when $default != null:
return $default(_that.totalReceivablePaise,_that.totalPayablePaise,_that.todayCollectionPaise,_that.todayCreditGivenPaise,_that.overdueParties,_that.activeParties,_that.lowStockItems,_that.pendingSyncItems);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BusinessSummary implements BusinessSummary {
  const _BusinessSummary({required this.totalReceivablePaise, required this.totalPayablePaise, required this.todayCollectionPaise, required this.todayCreditGivenPaise, required this.overdueParties, required this.activeParties, required this.lowStockItems, required this.pendingSyncItems});
  factory _BusinessSummary.fromJson(Map<String, dynamic> json) => _$BusinessSummaryFromJson(json);

@override final  int totalReceivablePaise;
@override final  int totalPayablePaise;
@override final  int todayCollectionPaise;
@override final  int todayCreditGivenPaise;
@override final  int overdueParties;
@override final  int activeParties;
@override final  int lowStockItems;
@override final  int pendingSyncItems;

/// Create a copy of BusinessSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BusinessSummaryCopyWith<_BusinessSummary> get copyWith => __$BusinessSummaryCopyWithImpl<_BusinessSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BusinessSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BusinessSummary&&(identical(other.totalReceivablePaise, totalReceivablePaise) || other.totalReceivablePaise == totalReceivablePaise)&&(identical(other.totalPayablePaise, totalPayablePaise) || other.totalPayablePaise == totalPayablePaise)&&(identical(other.todayCollectionPaise, todayCollectionPaise) || other.todayCollectionPaise == todayCollectionPaise)&&(identical(other.todayCreditGivenPaise, todayCreditGivenPaise) || other.todayCreditGivenPaise == todayCreditGivenPaise)&&(identical(other.overdueParties, overdueParties) || other.overdueParties == overdueParties)&&(identical(other.activeParties, activeParties) || other.activeParties == activeParties)&&(identical(other.lowStockItems, lowStockItems) || other.lowStockItems == lowStockItems)&&(identical(other.pendingSyncItems, pendingSyncItems) || other.pendingSyncItems == pendingSyncItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalReceivablePaise,totalPayablePaise,todayCollectionPaise,todayCreditGivenPaise,overdueParties,activeParties,lowStockItems,pendingSyncItems);

@override
String toString() {
  return 'BusinessSummary(totalReceivablePaise: $totalReceivablePaise, totalPayablePaise: $totalPayablePaise, todayCollectionPaise: $todayCollectionPaise, todayCreditGivenPaise: $todayCreditGivenPaise, overdueParties: $overdueParties, activeParties: $activeParties, lowStockItems: $lowStockItems, pendingSyncItems: $pendingSyncItems)';
}


}

/// @nodoc
abstract mixin class _$BusinessSummaryCopyWith<$Res> implements $BusinessSummaryCopyWith<$Res> {
  factory _$BusinessSummaryCopyWith(_BusinessSummary value, $Res Function(_BusinessSummary) _then) = __$BusinessSummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalReceivablePaise, int totalPayablePaise, int todayCollectionPaise, int todayCreditGivenPaise, int overdueParties, int activeParties, int lowStockItems, int pendingSyncItems
});




}
/// @nodoc
class __$BusinessSummaryCopyWithImpl<$Res>
    implements _$BusinessSummaryCopyWith<$Res> {
  __$BusinessSummaryCopyWithImpl(this._self, this._then);

  final _BusinessSummary _self;
  final $Res Function(_BusinessSummary) _then;

/// Create a copy of BusinessSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalReceivablePaise = null,Object? totalPayablePaise = null,Object? todayCollectionPaise = null,Object? todayCreditGivenPaise = null,Object? overdueParties = null,Object? activeParties = null,Object? lowStockItems = null,Object? pendingSyncItems = null,}) {
  return _then(_BusinessSummary(
totalReceivablePaise: null == totalReceivablePaise ? _self.totalReceivablePaise : totalReceivablePaise // ignore: cast_nullable_to_non_nullable
as int,totalPayablePaise: null == totalPayablePaise ? _self.totalPayablePaise : totalPayablePaise // ignore: cast_nullable_to_non_nullable
as int,todayCollectionPaise: null == todayCollectionPaise ? _self.todayCollectionPaise : todayCollectionPaise // ignore: cast_nullable_to_non_nullable
as int,todayCreditGivenPaise: null == todayCreditGivenPaise ? _self.todayCreditGivenPaise : todayCreditGivenPaise // ignore: cast_nullable_to_non_nullable
as int,overdueParties: null == overdueParties ? _self.overdueParties : overdueParties // ignore: cast_nullable_to_non_nullable
as int,activeParties: null == activeParties ? _self.activeParties : activeParties // ignore: cast_nullable_to_non_nullable
as int,lowStockItems: null == lowStockItems ? _self.lowStockItems : lowStockItems // ignore: cast_nullable_to_non_nullable
as int,pendingSyncItems: null == pendingSyncItems ? _self.pendingSyncItems : pendingSyncItems // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ReminderTemplate {

 String get id; String get name; String get languageCode; String get body; bool get firmTone;
/// Create a copy of ReminderTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReminderTemplateCopyWith<ReminderTemplate> get copyWith => _$ReminderTemplateCopyWithImpl<ReminderTemplate>(this as ReminderTemplate, _$identity);

  /// Serializes this ReminderTemplate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReminderTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.body, body) || other.body == body)&&(identical(other.firmTone, firmTone) || other.firmTone == firmTone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,languageCode,body,firmTone);

@override
String toString() {
  return 'ReminderTemplate(id: $id, name: $name, languageCode: $languageCode, body: $body, firmTone: $firmTone)';
}


}

/// @nodoc
abstract mixin class $ReminderTemplateCopyWith<$Res>  {
  factory $ReminderTemplateCopyWith(ReminderTemplate value, $Res Function(ReminderTemplate) _then) = _$ReminderTemplateCopyWithImpl;
@useResult
$Res call({
 String id, String name, String languageCode, String body, bool firmTone
});




}
/// @nodoc
class _$ReminderTemplateCopyWithImpl<$Res>
    implements $ReminderTemplateCopyWith<$Res> {
  _$ReminderTemplateCopyWithImpl(this._self, this._then);

  final ReminderTemplate _self;
  final $Res Function(ReminderTemplate) _then;

/// Create a copy of ReminderTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? languageCode = null,Object? body = null,Object? firmTone = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,firmTone: null == firmTone ? _self.firmTone : firmTone // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ReminderTemplate].
extension ReminderTemplatePatterns on ReminderTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReminderTemplate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReminderTemplate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReminderTemplate value)  $default,){
final _that = this;
switch (_that) {
case _ReminderTemplate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReminderTemplate value)?  $default,){
final _that = this;
switch (_that) {
case _ReminderTemplate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String languageCode,  String body,  bool firmTone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReminderTemplate() when $default != null:
return $default(_that.id,_that.name,_that.languageCode,_that.body,_that.firmTone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String languageCode,  String body,  bool firmTone)  $default,) {final _that = this;
switch (_that) {
case _ReminderTemplate():
return $default(_that.id,_that.name,_that.languageCode,_that.body,_that.firmTone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String languageCode,  String body,  bool firmTone)?  $default,) {final _that = this;
switch (_that) {
case _ReminderTemplate() when $default != null:
return $default(_that.id,_that.name,_that.languageCode,_that.body,_that.firmTone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReminderTemplate implements ReminderTemplate {
  const _ReminderTemplate({required this.id, required this.name, required this.languageCode, required this.body, this.firmTone = false});
  factory _ReminderTemplate.fromJson(Map<String, dynamic> json) => _$ReminderTemplateFromJson(json);

@override final  String id;
@override final  String name;
@override final  String languageCode;
@override final  String body;
@override@JsonKey() final  bool firmTone;

/// Create a copy of ReminderTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReminderTemplateCopyWith<_ReminderTemplate> get copyWith => __$ReminderTemplateCopyWithImpl<_ReminderTemplate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReminderTemplateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReminderTemplate&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.body, body) || other.body == body)&&(identical(other.firmTone, firmTone) || other.firmTone == firmTone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,languageCode,body,firmTone);

@override
String toString() {
  return 'ReminderTemplate(id: $id, name: $name, languageCode: $languageCode, body: $body, firmTone: $firmTone)';
}


}

/// @nodoc
abstract mixin class _$ReminderTemplateCopyWith<$Res> implements $ReminderTemplateCopyWith<$Res> {
  factory _$ReminderTemplateCopyWith(_ReminderTemplate value, $Res Function(_ReminderTemplate) _then) = __$ReminderTemplateCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String languageCode, String body, bool firmTone
});




}
/// @nodoc
class __$ReminderTemplateCopyWithImpl<$Res>
    implements _$ReminderTemplateCopyWith<$Res> {
  __$ReminderTemplateCopyWithImpl(this._self, this._then);

  final _ReminderTemplate _self;
  final $Res Function(_ReminderTemplate) _then;

/// Create a copy of ReminderTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? languageCode = null,Object? body = null,Object? firmTone = null,}) {
  return _then(_ReminderTemplate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,firmTone: null == firmTone ? _self.firmTone : firmTone // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Product {

 String get id; String get businessId; String get name; String get unit; int get salePricePaise; int get purchasePricePaise; int get stockOnHand; int get lowStockThreshold; String? get sku; String? get barcode; String? get category; String? get imageUrl;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.salePricePaise, salePricePaise) || other.salePricePaise == salePricePaise)&&(identical(other.purchasePricePaise, purchasePricePaise) || other.purchasePricePaise == purchasePricePaise)&&(identical(other.stockOnHand, stockOnHand) || other.stockOnHand == stockOnHand)&&(identical(other.lowStockThreshold, lowStockThreshold) || other.lowStockThreshold == lowStockThreshold)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.category, category) || other.category == category)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,name,unit,salePricePaise,purchasePricePaise,stockOnHand,lowStockThreshold,sku,barcode,category,imageUrl);

@override
String toString() {
  return 'Product(id: $id, businessId: $businessId, name: $name, unit: $unit, salePricePaise: $salePricePaise, purchasePricePaise: $purchasePricePaise, stockOnHand: $stockOnHand, lowStockThreshold: $lowStockThreshold, sku: $sku, barcode: $barcode, category: $category, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String id, String businessId, String name, String unit, int salePricePaise, int purchasePricePaise, int stockOnHand, int lowStockThreshold, String? sku, String? barcode, String? category, String? imageUrl
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? businessId = null,Object? name = null,Object? unit = null,Object? salePricePaise = null,Object? purchasePricePaise = null,Object? stockOnHand = null,Object? lowStockThreshold = null,Object? sku = freezed,Object? barcode = freezed,Object? category = freezed,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,salePricePaise: null == salePricePaise ? _self.salePricePaise : salePricePaise // ignore: cast_nullable_to_non_nullable
as int,purchasePricePaise: null == purchasePricePaise ? _self.purchasePricePaise : purchasePricePaise // ignore: cast_nullable_to_non_nullable
as int,stockOnHand: null == stockOnHand ? _self.stockOnHand : stockOnHand // ignore: cast_nullable_to_non_nullable
as int,lowStockThreshold: null == lowStockThreshold ? _self.lowStockThreshold : lowStockThreshold // ignore: cast_nullable_to_non_nullable
as int,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String businessId,  String name,  String unit,  int salePricePaise,  int purchasePricePaise,  int stockOnHand,  int lowStockThreshold,  String? sku,  String? barcode,  String? category,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.businessId,_that.name,_that.unit,_that.salePricePaise,_that.purchasePricePaise,_that.stockOnHand,_that.lowStockThreshold,_that.sku,_that.barcode,_that.category,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String businessId,  String name,  String unit,  int salePricePaise,  int purchasePricePaise,  int stockOnHand,  int lowStockThreshold,  String? sku,  String? barcode,  String? category,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.businessId,_that.name,_that.unit,_that.salePricePaise,_that.purchasePricePaise,_that.stockOnHand,_that.lowStockThreshold,_that.sku,_that.barcode,_that.category,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String businessId,  String name,  String unit,  int salePricePaise,  int purchasePricePaise,  int stockOnHand,  int lowStockThreshold,  String? sku,  String? barcode,  String? category,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.businessId,_that.name,_that.unit,_that.salePricePaise,_that.purchasePricePaise,_that.stockOnHand,_that.lowStockThreshold,_that.sku,_that.barcode,_that.category,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Product implements Product {
  const _Product({required this.id, required this.businessId, required this.name, required this.unit, this.salePricePaise = 0, this.purchasePricePaise = 0, this.stockOnHand = 0, this.lowStockThreshold = 0, this.sku, this.barcode, this.category, this.imageUrl});
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  String id;
@override final  String businessId;
@override final  String name;
@override final  String unit;
@override@JsonKey() final  int salePricePaise;
@override@JsonKey() final  int purchasePricePaise;
@override@JsonKey() final  int stockOnHand;
@override@JsonKey() final  int lowStockThreshold;
@override final  String? sku;
@override final  String? barcode;
@override final  String? category;
@override final  String? imageUrl;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.salePricePaise, salePricePaise) || other.salePricePaise == salePricePaise)&&(identical(other.purchasePricePaise, purchasePricePaise) || other.purchasePricePaise == purchasePricePaise)&&(identical(other.stockOnHand, stockOnHand) || other.stockOnHand == stockOnHand)&&(identical(other.lowStockThreshold, lowStockThreshold) || other.lowStockThreshold == lowStockThreshold)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.barcode, barcode) || other.barcode == barcode)&&(identical(other.category, category) || other.category == category)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,name,unit,salePricePaise,purchasePricePaise,stockOnHand,lowStockThreshold,sku,barcode,category,imageUrl);

@override
String toString() {
  return 'Product(id: $id, businessId: $businessId, name: $name, unit: $unit, salePricePaise: $salePricePaise, purchasePricePaise: $purchasePricePaise, stockOnHand: $stockOnHand, lowStockThreshold: $lowStockThreshold, sku: $sku, barcode: $barcode, category: $category, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String businessId, String name, String unit, int salePricePaise, int purchasePricePaise, int stockOnHand, int lowStockThreshold, String? sku, String? barcode, String? category, String? imageUrl
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? businessId = null,Object? name = null,Object? unit = null,Object? salePricePaise = null,Object? purchasePricePaise = null,Object? stockOnHand = null,Object? lowStockThreshold = null,Object? sku = freezed,Object? barcode = freezed,Object? category = freezed,Object? imageUrl = freezed,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,salePricePaise: null == salePricePaise ? _self.salePricePaise : salePricePaise // ignore: cast_nullable_to_non_nullable
as int,purchasePricePaise: null == purchasePricePaise ? _self.purchasePricePaise : purchasePricePaise // ignore: cast_nullable_to_non_nullable
as int,stockOnHand: null == stockOnHand ? _self.stockOnHand : stockOnHand // ignore: cast_nullable_to_non_nullable
as int,lowStockThreshold: null == lowStockThreshold ? _self.lowStockThreshold : lowStockThreshold // ignore: cast_nullable_to_non_nullable
as int,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,barcode: freezed == barcode ? _self.barcode : barcode // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Invoice {

 String get id; String get businessId; String get bookId; String get invoiceNumber; String get partyId; DateTime get date; DateTime? get dueDate; int get subtotalPaise; int get gstPaise; int get totalPaise; int get paidPaise; InvoiceStatus get status; String? get notes; String? get terms;
/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvoiceCopyWith<Invoice> get copyWith => _$InvoiceCopyWithImpl<Invoice>(this as Invoice, _$identity);

  /// Serializes this Invoice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Invoice&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.partyId, partyId) || other.partyId == partyId)&&(identical(other.date, date) || other.date == date)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.subtotalPaise, subtotalPaise) || other.subtotalPaise == subtotalPaise)&&(identical(other.gstPaise, gstPaise) || other.gstPaise == gstPaise)&&(identical(other.totalPaise, totalPaise) || other.totalPaise == totalPaise)&&(identical(other.paidPaise, paidPaise) || other.paidPaise == paidPaise)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.terms, terms) || other.terms == terms));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,bookId,invoiceNumber,partyId,date,dueDate,subtotalPaise,gstPaise,totalPaise,paidPaise,status,notes,terms);

@override
String toString() {
  return 'Invoice(id: $id, businessId: $businessId, bookId: $bookId, invoiceNumber: $invoiceNumber, partyId: $partyId, date: $date, dueDate: $dueDate, subtotalPaise: $subtotalPaise, gstPaise: $gstPaise, totalPaise: $totalPaise, paidPaise: $paidPaise, status: $status, notes: $notes, terms: $terms)';
}


}

/// @nodoc
abstract mixin class $InvoiceCopyWith<$Res>  {
  factory $InvoiceCopyWith(Invoice value, $Res Function(Invoice) _then) = _$InvoiceCopyWithImpl;
@useResult
$Res call({
 String id, String businessId, String bookId, String invoiceNumber, String partyId, DateTime date, DateTime? dueDate, int subtotalPaise, int gstPaise, int totalPaise, int paidPaise, InvoiceStatus status, String? notes, String? terms
});




}
/// @nodoc
class _$InvoiceCopyWithImpl<$Res>
    implements $InvoiceCopyWith<$Res> {
  _$InvoiceCopyWithImpl(this._self, this._then);

  final Invoice _self;
  final $Res Function(Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? businessId = null,Object? bookId = null,Object? invoiceNumber = null,Object? partyId = null,Object? date = null,Object? dueDate = freezed,Object? subtotalPaise = null,Object? gstPaise = null,Object? totalPaise = null,Object? paidPaise = null,Object? status = null,Object? notes = freezed,Object? terms = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as String,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,partyId: null == partyId ? _self.partyId : partyId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,subtotalPaise: null == subtotalPaise ? _self.subtotalPaise : subtotalPaise // ignore: cast_nullable_to_non_nullable
as int,gstPaise: null == gstPaise ? _self.gstPaise : gstPaise // ignore: cast_nullable_to_non_nullable
as int,totalPaise: null == totalPaise ? _self.totalPaise : totalPaise // ignore: cast_nullable_to_non_nullable
as int,paidPaise: null == paidPaise ? _self.paidPaise : paidPaise // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,terms: freezed == terms ? _self.terms : terms // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Invoice].
extension InvoicePatterns on Invoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Invoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Invoice value)  $default,){
final _that = this;
switch (_that) {
case _Invoice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Invoice value)?  $default,){
final _that = this;
switch (_that) {
case _Invoice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String businessId,  String bookId,  String invoiceNumber,  String partyId,  DateTime date,  DateTime? dueDate,  int subtotalPaise,  int gstPaise,  int totalPaise,  int paidPaise,  InvoiceStatus status,  String? notes,  String? terms)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.businessId,_that.bookId,_that.invoiceNumber,_that.partyId,_that.date,_that.dueDate,_that.subtotalPaise,_that.gstPaise,_that.totalPaise,_that.paidPaise,_that.status,_that.notes,_that.terms);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String businessId,  String bookId,  String invoiceNumber,  String partyId,  DateTime date,  DateTime? dueDate,  int subtotalPaise,  int gstPaise,  int totalPaise,  int paidPaise,  InvoiceStatus status,  String? notes,  String? terms)  $default,) {final _that = this;
switch (_that) {
case _Invoice():
return $default(_that.id,_that.businessId,_that.bookId,_that.invoiceNumber,_that.partyId,_that.date,_that.dueDate,_that.subtotalPaise,_that.gstPaise,_that.totalPaise,_that.paidPaise,_that.status,_that.notes,_that.terms);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String businessId,  String bookId,  String invoiceNumber,  String partyId,  DateTime date,  DateTime? dueDate,  int subtotalPaise,  int gstPaise,  int totalPaise,  int paidPaise,  InvoiceStatus status,  String? notes,  String? terms)?  $default,) {final _that = this;
switch (_that) {
case _Invoice() when $default != null:
return $default(_that.id,_that.businessId,_that.bookId,_that.invoiceNumber,_that.partyId,_that.date,_that.dueDate,_that.subtotalPaise,_that.gstPaise,_that.totalPaise,_that.paidPaise,_that.status,_that.notes,_that.terms);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Invoice implements Invoice {
  const _Invoice({required this.id, required this.businessId, required this.bookId, required this.invoiceNumber, required this.partyId, required this.date, this.dueDate, this.subtotalPaise = 0, this.gstPaise = 0, this.totalPaise = 0, this.paidPaise = 0, this.status = InvoiceStatus.draft, this.notes, this.terms});
  factory _Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

@override final  String id;
@override final  String businessId;
@override final  String bookId;
@override final  String invoiceNumber;
@override final  String partyId;
@override final  DateTime date;
@override final  DateTime? dueDate;
@override@JsonKey() final  int subtotalPaise;
@override@JsonKey() final  int gstPaise;
@override@JsonKey() final  int totalPaise;
@override@JsonKey() final  int paidPaise;
@override@JsonKey() final  InvoiceStatus status;
@override final  String? notes;
@override final  String? terms;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvoiceCopyWith<_Invoice> get copyWith => __$InvoiceCopyWithImpl<_Invoice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvoiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Invoice&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.bookId, bookId) || other.bookId == bookId)&&(identical(other.invoiceNumber, invoiceNumber) || other.invoiceNumber == invoiceNumber)&&(identical(other.partyId, partyId) || other.partyId == partyId)&&(identical(other.date, date) || other.date == date)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.subtotalPaise, subtotalPaise) || other.subtotalPaise == subtotalPaise)&&(identical(other.gstPaise, gstPaise) || other.gstPaise == gstPaise)&&(identical(other.totalPaise, totalPaise) || other.totalPaise == totalPaise)&&(identical(other.paidPaise, paidPaise) || other.paidPaise == paidPaise)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.terms, terms) || other.terms == terms));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,bookId,invoiceNumber,partyId,date,dueDate,subtotalPaise,gstPaise,totalPaise,paidPaise,status,notes,terms);

@override
String toString() {
  return 'Invoice(id: $id, businessId: $businessId, bookId: $bookId, invoiceNumber: $invoiceNumber, partyId: $partyId, date: $date, dueDate: $dueDate, subtotalPaise: $subtotalPaise, gstPaise: $gstPaise, totalPaise: $totalPaise, paidPaise: $paidPaise, status: $status, notes: $notes, terms: $terms)';
}


}

/// @nodoc
abstract mixin class _$InvoiceCopyWith<$Res> implements $InvoiceCopyWith<$Res> {
  factory _$InvoiceCopyWith(_Invoice value, $Res Function(_Invoice) _then) = __$InvoiceCopyWithImpl;
@override @useResult
$Res call({
 String id, String businessId, String bookId, String invoiceNumber, String partyId, DateTime date, DateTime? dueDate, int subtotalPaise, int gstPaise, int totalPaise, int paidPaise, InvoiceStatus status, String? notes, String? terms
});




}
/// @nodoc
class __$InvoiceCopyWithImpl<$Res>
    implements _$InvoiceCopyWith<$Res> {
  __$InvoiceCopyWithImpl(this._self, this._then);

  final _Invoice _self;
  final $Res Function(_Invoice) _then;

/// Create a copy of Invoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? businessId = null,Object? bookId = null,Object? invoiceNumber = null,Object? partyId = null,Object? date = null,Object? dueDate = freezed,Object? subtotalPaise = null,Object? gstPaise = null,Object? totalPaise = null,Object? paidPaise = null,Object? status = null,Object? notes = freezed,Object? terms = freezed,}) {
  return _then(_Invoice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,bookId: null == bookId ? _self.bookId : bookId // ignore: cast_nullable_to_non_nullable
as String,invoiceNumber: null == invoiceNumber ? _self.invoiceNumber : invoiceNumber // ignore: cast_nullable_to_non_nullable
as String,partyId: null == partyId ? _self.partyId : partyId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,subtotalPaise: null == subtotalPaise ? _self.subtotalPaise : subtotalPaise // ignore: cast_nullable_to_non_nullable
as int,gstPaise: null == gstPaise ? _self.gstPaise : gstPaise // ignore: cast_nullable_to_non_nullable
as int,totalPaise: null == totalPaise ? _self.totalPaise : totalPaise // ignore: cast_nullable_to_non_nullable
as int,paidPaise: null == paidPaise ? _self.paidPaise : paidPaise // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as InvoiceStatus,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,terms: freezed == terms ? _self.terms : terms // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$StaffMember {

 String get id; String get businessId; String get userId; MemberRole get role; List<String> get permissions; String? get fullName; String? get phone;
/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffMemberCopyWith<StaffMember> get copyWith => _$StaffMemberCopyWithImpl<StaffMember>(this as StaffMember, _$identity);

  /// Serializes this StaffMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffMember&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other.permissions, permissions)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,userId,role,const DeepCollectionEquality().hash(permissions),fullName,phone);

@override
String toString() {
  return 'StaffMember(id: $id, businessId: $businessId, userId: $userId, role: $role, permissions: $permissions, fullName: $fullName, phone: $phone)';
}


}

/// @nodoc
abstract mixin class $StaffMemberCopyWith<$Res>  {
  factory $StaffMemberCopyWith(StaffMember value, $Res Function(StaffMember) _then) = _$StaffMemberCopyWithImpl;
@useResult
$Res call({
 String id, String businessId, String userId, MemberRole role, List<String> permissions, String? fullName, String? phone
});




}
/// @nodoc
class _$StaffMemberCopyWithImpl<$Res>
    implements $StaffMemberCopyWith<$Res> {
  _$StaffMemberCopyWithImpl(this._self, this._then);

  final StaffMember _self;
  final $Res Function(StaffMember) _then;

/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? businessId = null,Object? userId = null,Object? role = null,Object? permissions = null,Object? fullName = freezed,Object? phone = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffMember].
extension StaffMemberPatterns on StaffMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffMember value)  $default,){
final _that = this;
switch (_that) {
case _StaffMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffMember value)?  $default,){
final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String businessId,  String userId,  MemberRole role,  List<String> permissions,  String? fullName,  String? phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
return $default(_that.id,_that.businessId,_that.userId,_that.role,_that.permissions,_that.fullName,_that.phone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String businessId,  String userId,  MemberRole role,  List<String> permissions,  String? fullName,  String? phone)  $default,) {final _that = this;
switch (_that) {
case _StaffMember():
return $default(_that.id,_that.businessId,_that.userId,_that.role,_that.permissions,_that.fullName,_that.phone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String businessId,  String userId,  MemberRole role,  List<String> permissions,  String? fullName,  String? phone)?  $default,) {final _that = this;
switch (_that) {
case _StaffMember() when $default != null:
return $default(_that.id,_that.businessId,_that.userId,_that.role,_that.permissions,_that.fullName,_that.phone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffMember implements StaffMember {
  const _StaffMember({required this.id, required this.businessId, required this.userId, required this.role, final  List<String> permissions = const <String>[], this.fullName, this.phone}): _permissions = permissions;
  factory _StaffMember.fromJson(Map<String, dynamic> json) => _$StaffMemberFromJson(json);

@override final  String id;
@override final  String businessId;
@override final  String userId;
@override final  MemberRole role;
 final  List<String> _permissions;
@override@JsonKey() List<String> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}

@override final  String? fullName;
@override final  String? phone;

/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffMemberCopyWith<_StaffMember> get copyWith => __$StaffMemberCopyWithImpl<_StaffMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffMember&&(identical(other.id, id) || other.id == id)&&(identical(other.businessId, businessId) || other.businessId == businessId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other._permissions, _permissions)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,businessId,userId,role,const DeepCollectionEquality().hash(_permissions),fullName,phone);

@override
String toString() {
  return 'StaffMember(id: $id, businessId: $businessId, userId: $userId, role: $role, permissions: $permissions, fullName: $fullName, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$StaffMemberCopyWith<$Res> implements $StaffMemberCopyWith<$Res> {
  factory _$StaffMemberCopyWith(_StaffMember value, $Res Function(_StaffMember) _then) = __$StaffMemberCopyWithImpl;
@override @useResult
$Res call({
 String id, String businessId, String userId, MemberRole role, List<String> permissions, String? fullName, String? phone
});




}
/// @nodoc
class __$StaffMemberCopyWithImpl<$Res>
    implements _$StaffMemberCopyWith<$Res> {
  __$StaffMemberCopyWithImpl(this._self, this._then);

  final _StaffMember _self;
  final $Res Function(_StaffMember) _then;

/// Create a copy of StaffMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? businessId = null,Object? userId = null,Object? role = null,Object? permissions = null,Object? fullName = freezed,Object? phone = freezed,}) {
  return _then(_StaffMember(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,businessId: null == businessId ? _self.businessId : businessId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,fullName: freezed == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AuditLogEntry {

 String get id; String get entityTable; String get action; DateTime get createdAt; String? get actorId;
/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditLogEntryCopyWith<AuditLogEntry> get copyWith => _$AuditLogEntryCopyWithImpl<AuditLogEntry>(this as AuditLogEntry, _$identity);

  /// Serializes this AuditLogEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditLogEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.entityTable, entityTable) || other.entityTable == entityTable)&&(identical(other.action, action) || other.action == action)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.actorId, actorId) || other.actorId == actorId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,entityTable,action,createdAt,actorId);

@override
String toString() {
  return 'AuditLogEntry(id: $id, entityTable: $entityTable, action: $action, createdAt: $createdAt, actorId: $actorId)';
}


}

/// @nodoc
abstract mixin class $AuditLogEntryCopyWith<$Res>  {
  factory $AuditLogEntryCopyWith(AuditLogEntry value, $Res Function(AuditLogEntry) _then) = _$AuditLogEntryCopyWithImpl;
@useResult
$Res call({
 String id, String entityTable, String action, DateTime createdAt, String? actorId
});




}
/// @nodoc
class _$AuditLogEntryCopyWithImpl<$Res>
    implements $AuditLogEntryCopyWith<$Res> {
  _$AuditLogEntryCopyWithImpl(this._self, this._then);

  final AuditLogEntry _self;
  final $Res Function(AuditLogEntry) _then;

/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? entityTable = null,Object? action = null,Object? createdAt = null,Object? actorId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,entityTable: null == entityTable ? _self.entityTable : entityTable // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,actorId: freezed == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditLogEntry].
extension AuditLogEntryPatterns on AuditLogEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditLogEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditLogEntry value)  $default,){
final _that = this;
switch (_that) {
case _AuditLogEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditLogEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String entityTable,  String action,  DateTime createdAt,  String? actorId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
return $default(_that.id,_that.entityTable,_that.action,_that.createdAt,_that.actorId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String entityTable,  String action,  DateTime createdAt,  String? actorId)  $default,) {final _that = this;
switch (_that) {
case _AuditLogEntry():
return $default(_that.id,_that.entityTable,_that.action,_that.createdAt,_that.actorId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String entityTable,  String action,  DateTime createdAt,  String? actorId)?  $default,) {final _that = this;
switch (_that) {
case _AuditLogEntry() when $default != null:
return $default(_that.id,_that.entityTable,_that.action,_that.createdAt,_that.actorId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuditLogEntry implements AuditLogEntry {
  const _AuditLogEntry({required this.id, required this.entityTable, required this.action, required this.createdAt, this.actorId});
  factory _AuditLogEntry.fromJson(Map<String, dynamic> json) => _$AuditLogEntryFromJson(json);

@override final  String id;
@override final  String entityTable;
@override final  String action;
@override final  DateTime createdAt;
@override final  String? actorId;

/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditLogEntryCopyWith<_AuditLogEntry> get copyWith => __$AuditLogEntryCopyWithImpl<_AuditLogEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuditLogEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditLogEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.entityTable, entityTable) || other.entityTable == entityTable)&&(identical(other.action, action) || other.action == action)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.actorId, actorId) || other.actorId == actorId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,entityTable,action,createdAt,actorId);

@override
String toString() {
  return 'AuditLogEntry(id: $id, entityTable: $entityTable, action: $action, createdAt: $createdAt, actorId: $actorId)';
}


}

/// @nodoc
abstract mixin class _$AuditLogEntryCopyWith<$Res> implements $AuditLogEntryCopyWith<$Res> {
  factory _$AuditLogEntryCopyWith(_AuditLogEntry value, $Res Function(_AuditLogEntry) _then) = __$AuditLogEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String entityTable, String action, DateTime createdAt, String? actorId
});




}
/// @nodoc
class __$AuditLogEntryCopyWithImpl<$Res>
    implements _$AuditLogEntryCopyWith<$Res> {
  __$AuditLogEntryCopyWithImpl(this._self, this._then);

  final _AuditLogEntry _self;
  final $Res Function(_AuditLogEntry) _then;

/// Create a copy of AuditLogEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? entityTable = null,Object? action = null,Object? createdAt = null,Object? actorId = freezed,}) {
  return _then(_AuditLogEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,entityTable: null == entityTable ? _self.entityTable : entityTable // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,actorId: freezed == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SyncQueueItem {

 String get id; String get entityType; SyncStatus get status; int get attempts; String? get lastError; DateTime? get lastSyncedAt;
/// Create a copy of SyncQueueItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncQueueItemCopyWith<SyncQueueItem> get copyWith => _$SyncQueueItemCopyWithImpl<SyncQueueItem>(this as SyncQueueItem, _$identity);

  /// Serializes this SyncQueueItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncQueueItem&&(identical(other.id, id) || other.id == id)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.status, status) || other.status == status)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,entityType,status,attempts,lastError,lastSyncedAt);

@override
String toString() {
  return 'SyncQueueItem(id: $id, entityType: $entityType, status: $status, attempts: $attempts, lastError: $lastError, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class $SyncQueueItemCopyWith<$Res>  {
  factory $SyncQueueItemCopyWith(SyncQueueItem value, $Res Function(SyncQueueItem) _then) = _$SyncQueueItemCopyWithImpl;
@useResult
$Res call({
 String id, String entityType, SyncStatus status, int attempts, String? lastError, DateTime? lastSyncedAt
});




}
/// @nodoc
class _$SyncQueueItemCopyWithImpl<$Res>
    implements $SyncQueueItemCopyWith<$Res> {
  _$SyncQueueItemCopyWithImpl(this._self, this._then);

  final SyncQueueItem _self;
  final $Res Function(SyncQueueItem) _then;

/// Create a copy of SyncQueueItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? entityType = null,Object? status = null,Object? attempts = null,Object? lastError = freezed,Object? lastSyncedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SyncStatus,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncQueueItem].
extension SyncQueueItemPatterns on SyncQueueItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncQueueItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncQueueItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncQueueItem value)  $default,){
final _that = this;
switch (_that) {
case _SyncQueueItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncQueueItem value)?  $default,){
final _that = this;
switch (_that) {
case _SyncQueueItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String entityType,  SyncStatus status,  int attempts,  String? lastError,  DateTime? lastSyncedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncQueueItem() when $default != null:
return $default(_that.id,_that.entityType,_that.status,_that.attempts,_that.lastError,_that.lastSyncedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String entityType,  SyncStatus status,  int attempts,  String? lastError,  DateTime? lastSyncedAt)  $default,) {final _that = this;
switch (_that) {
case _SyncQueueItem():
return $default(_that.id,_that.entityType,_that.status,_that.attempts,_that.lastError,_that.lastSyncedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String entityType,  SyncStatus status,  int attempts,  String? lastError,  DateTime? lastSyncedAt)?  $default,) {final _that = this;
switch (_that) {
case _SyncQueueItem() when $default != null:
return $default(_that.id,_that.entityType,_that.status,_that.attempts,_that.lastError,_that.lastSyncedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncQueueItem implements SyncQueueItem {
  const _SyncQueueItem({required this.id, required this.entityType, required this.status, this.attempts = 0, this.lastError, this.lastSyncedAt});
  factory _SyncQueueItem.fromJson(Map<String, dynamic> json) => _$SyncQueueItemFromJson(json);

@override final  String id;
@override final  String entityType;
@override final  SyncStatus status;
@override@JsonKey() final  int attempts;
@override final  String? lastError;
@override final  DateTime? lastSyncedAt;

/// Create a copy of SyncQueueItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncQueueItemCopyWith<_SyncQueueItem> get copyWith => __$SyncQueueItemCopyWithImpl<_SyncQueueItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncQueueItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncQueueItem&&(identical(other.id, id) || other.id == id)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.status, status) || other.status == status)&&(identical(other.attempts, attempts) || other.attempts == attempts)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,entityType,status,attempts,lastError,lastSyncedAt);

@override
String toString() {
  return 'SyncQueueItem(id: $id, entityType: $entityType, status: $status, attempts: $attempts, lastError: $lastError, lastSyncedAt: $lastSyncedAt)';
}


}

/// @nodoc
abstract mixin class _$SyncQueueItemCopyWith<$Res> implements $SyncQueueItemCopyWith<$Res> {
  factory _$SyncQueueItemCopyWith(_SyncQueueItem value, $Res Function(_SyncQueueItem) _then) = __$SyncQueueItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String entityType, SyncStatus status, int attempts, String? lastError, DateTime? lastSyncedAt
});




}
/// @nodoc
class __$SyncQueueItemCopyWithImpl<$Res>
    implements _$SyncQueueItemCopyWith<$Res> {
  __$SyncQueueItemCopyWithImpl(this._self, this._then);

  final _SyncQueueItem _self;
  final $Res Function(_SyncQueueItem) _then;

/// Create a copy of SyncQueueItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? entityType = null,Object? status = null,Object? attempts = null,Object? lastError = freezed,Object? lastSyncedAt = freezed,}) {
  return _then(_SyncQueueItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SyncStatus,attempts: null == attempts ? _self.attempts : attempts // ignore: cast_nullable_to_non_nullable
as int,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
