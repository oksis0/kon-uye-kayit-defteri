// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'defter_satiri.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DefterSatiri {

 String get id; String get ortakId; SatirTuru get tur; int get siraNo; String? get tarihHam; DateTime? get tarih; String? get no; String? get madde; String? get aciklama; int get miktarKurus; int get yekunKurus; String? get miktarHam; String? get yekunHam;
/// Create a copy of DefterSatiri
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DefterSatiriCopyWith<DefterSatiri> get copyWith => _$DefterSatiriCopyWithImpl<DefterSatiri>(this as DefterSatiri, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DefterSatiri&&(identical(other.id, id) || other.id == id)&&(identical(other.ortakId, ortakId) || other.ortakId == ortakId)&&(identical(other.tur, tur) || other.tur == tur)&&(identical(other.siraNo, siraNo) || other.siraNo == siraNo)&&(identical(other.tarihHam, tarihHam) || other.tarihHam == tarihHam)&&(identical(other.tarih, tarih) || other.tarih == tarih)&&(identical(other.no, no) || other.no == no)&&(identical(other.madde, madde) || other.madde == madde)&&(identical(other.aciklama, aciklama) || other.aciklama == aciklama)&&(identical(other.miktarKurus, miktarKurus) || other.miktarKurus == miktarKurus)&&(identical(other.yekunKurus, yekunKurus) || other.yekunKurus == yekunKurus)&&(identical(other.miktarHam, miktarHam) || other.miktarHam == miktarHam)&&(identical(other.yekunHam, yekunHam) || other.yekunHam == yekunHam));
}


@override
int get hashCode => Object.hash(runtimeType,id,ortakId,tur,siraNo,tarihHam,tarih,no,madde,aciklama,miktarKurus,yekunKurus,miktarHam,yekunHam);

@override
String toString() {
  return 'DefterSatiri(id: $id, ortakId: $ortakId, tur: $tur, siraNo: $siraNo, tarihHam: $tarihHam, tarih: $tarih, no: $no, madde: $madde, aciklama: $aciklama, miktarKurus: $miktarKurus, yekunKurus: $yekunKurus, miktarHam: $miktarHam, yekunHam: $yekunHam)';
}


}

/// @nodoc
abstract mixin class $DefterSatiriCopyWith<$Res>  {
  factory $DefterSatiriCopyWith(DefterSatiri value, $Res Function(DefterSatiri) _then) = _$DefterSatiriCopyWithImpl;
@useResult
$Res call({
 String id, String ortakId, SatirTuru tur, int siraNo, String? tarihHam, DateTime? tarih, String? no, String? madde, String? aciklama, int miktarKurus, int yekunKurus, String? miktarHam, String? yekunHam
});




}
/// @nodoc
class _$DefterSatiriCopyWithImpl<$Res>
    implements $DefterSatiriCopyWith<$Res> {
  _$DefterSatiriCopyWithImpl(this._self, this._then);

  final DefterSatiri _self;
  final $Res Function(DefterSatiri) _then;

/// Create a copy of DefterSatiri
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ortakId = null,Object? tur = null,Object? siraNo = null,Object? tarihHam = freezed,Object? tarih = freezed,Object? no = freezed,Object? madde = freezed,Object? aciklama = freezed,Object? miktarKurus = null,Object? yekunKurus = null,Object? miktarHam = freezed,Object? yekunHam = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ortakId: null == ortakId ? _self.ortakId : ortakId // ignore: cast_nullable_to_non_nullable
as String,tur: null == tur ? _self.tur : tur // ignore: cast_nullable_to_non_nullable
as SatirTuru,siraNo: null == siraNo ? _self.siraNo : siraNo // ignore: cast_nullable_to_non_nullable
as int,tarihHam: freezed == tarihHam ? _self.tarihHam : tarihHam // ignore: cast_nullable_to_non_nullable
as String?,tarih: freezed == tarih ? _self.tarih : tarih // ignore: cast_nullable_to_non_nullable
as DateTime?,no: freezed == no ? _self.no : no // ignore: cast_nullable_to_non_nullable
as String?,madde: freezed == madde ? _self.madde : madde // ignore: cast_nullable_to_non_nullable
as String?,aciklama: freezed == aciklama ? _self.aciklama : aciklama // ignore: cast_nullable_to_non_nullable
as String?,miktarKurus: null == miktarKurus ? _self.miktarKurus : miktarKurus // ignore: cast_nullable_to_non_nullable
as int,yekunKurus: null == yekunKurus ? _self.yekunKurus : yekunKurus // ignore: cast_nullable_to_non_nullable
as int,miktarHam: freezed == miktarHam ? _self.miktarHam : miktarHam // ignore: cast_nullable_to_non_nullable
as String?,yekunHam: freezed == yekunHam ? _self.yekunHam : yekunHam // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DefterSatiri].
extension DefterSatiriPatterns on DefterSatiri {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DefterSatiri value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DefterSatiri() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DefterSatiri value)  $default,){
final _that = this;
switch (_that) {
case _DefterSatiri():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DefterSatiri value)?  $default,){
final _that = this;
switch (_that) {
case _DefterSatiri() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ortakId,  SatirTuru tur,  int siraNo,  String? tarihHam,  DateTime? tarih,  String? no,  String? madde,  String? aciklama,  int miktarKurus,  int yekunKurus,  String? miktarHam,  String? yekunHam)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DefterSatiri() when $default != null:
return $default(_that.id,_that.ortakId,_that.tur,_that.siraNo,_that.tarihHam,_that.tarih,_that.no,_that.madde,_that.aciklama,_that.miktarKurus,_that.yekunKurus,_that.miktarHam,_that.yekunHam);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ortakId,  SatirTuru tur,  int siraNo,  String? tarihHam,  DateTime? tarih,  String? no,  String? madde,  String? aciklama,  int miktarKurus,  int yekunKurus,  String? miktarHam,  String? yekunHam)  $default,) {final _that = this;
switch (_that) {
case _DefterSatiri():
return $default(_that.id,_that.ortakId,_that.tur,_that.siraNo,_that.tarihHam,_that.tarih,_that.no,_that.madde,_that.aciklama,_that.miktarKurus,_that.yekunKurus,_that.miktarHam,_that.yekunHam);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ortakId,  SatirTuru tur,  int siraNo,  String? tarihHam,  DateTime? tarih,  String? no,  String? madde,  String? aciklama,  int miktarKurus,  int yekunKurus,  String? miktarHam,  String? yekunHam)?  $default,) {final _that = this;
switch (_that) {
case _DefterSatiri() when $default != null:
return $default(_that.id,_that.ortakId,_that.tur,_that.siraNo,_that.tarihHam,_that.tarih,_that.no,_that.madde,_that.aciklama,_that.miktarKurus,_that.yekunKurus,_that.miktarHam,_that.yekunHam);case _:
  return null;

}
}

}

/// @nodoc


class _DefterSatiri implements DefterSatiri {
  const _DefterSatiri({required this.id, required this.ortakId, required this.tur, required this.siraNo, this.tarihHam, this.tarih, this.no, this.madde, this.aciklama, this.miktarKurus = 0, this.yekunKurus = 0, this.miktarHam, this.yekunHam});
  

@override final  String id;
@override final  String ortakId;
@override final  SatirTuru tur;
@override final  int siraNo;
@override final  String? tarihHam;
@override final  DateTime? tarih;
@override final  String? no;
@override final  String? madde;
@override final  String? aciklama;
@override@JsonKey() final  int miktarKurus;
@override@JsonKey() final  int yekunKurus;
@override final  String? miktarHam;
@override final  String? yekunHam;

/// Create a copy of DefterSatiri
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DefterSatiriCopyWith<_DefterSatiri> get copyWith => __$DefterSatiriCopyWithImpl<_DefterSatiri>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DefterSatiri&&(identical(other.id, id) || other.id == id)&&(identical(other.ortakId, ortakId) || other.ortakId == ortakId)&&(identical(other.tur, tur) || other.tur == tur)&&(identical(other.siraNo, siraNo) || other.siraNo == siraNo)&&(identical(other.tarihHam, tarihHam) || other.tarihHam == tarihHam)&&(identical(other.tarih, tarih) || other.tarih == tarih)&&(identical(other.no, no) || other.no == no)&&(identical(other.madde, madde) || other.madde == madde)&&(identical(other.aciklama, aciklama) || other.aciklama == aciklama)&&(identical(other.miktarKurus, miktarKurus) || other.miktarKurus == miktarKurus)&&(identical(other.yekunKurus, yekunKurus) || other.yekunKurus == yekunKurus)&&(identical(other.miktarHam, miktarHam) || other.miktarHam == miktarHam)&&(identical(other.yekunHam, yekunHam) || other.yekunHam == yekunHam));
}


@override
int get hashCode => Object.hash(runtimeType,id,ortakId,tur,siraNo,tarihHam,tarih,no,madde,aciklama,miktarKurus,yekunKurus,miktarHam,yekunHam);

@override
String toString() {
  return 'DefterSatiri(id: $id, ortakId: $ortakId, tur: $tur, siraNo: $siraNo, tarihHam: $tarihHam, tarih: $tarih, no: $no, madde: $madde, aciklama: $aciklama, miktarKurus: $miktarKurus, yekunKurus: $yekunKurus, miktarHam: $miktarHam, yekunHam: $yekunHam)';
}


}

/// @nodoc
abstract mixin class _$DefterSatiriCopyWith<$Res> implements $DefterSatiriCopyWith<$Res> {
  factory _$DefterSatiriCopyWith(_DefterSatiri value, $Res Function(_DefterSatiri) _then) = __$DefterSatiriCopyWithImpl;
@override @useResult
$Res call({
 String id, String ortakId, SatirTuru tur, int siraNo, String? tarihHam, DateTime? tarih, String? no, String? madde, String? aciklama, int miktarKurus, int yekunKurus, String? miktarHam, String? yekunHam
});




}
/// @nodoc
class __$DefterSatiriCopyWithImpl<$Res>
    implements _$DefterSatiriCopyWith<$Res> {
  __$DefterSatiriCopyWithImpl(this._self, this._then);

  final _DefterSatiri _self;
  final $Res Function(_DefterSatiri) _then;

/// Create a copy of DefterSatiri
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ortakId = null,Object? tur = null,Object? siraNo = null,Object? tarihHam = freezed,Object? tarih = freezed,Object? no = freezed,Object? madde = freezed,Object? aciklama = freezed,Object? miktarKurus = null,Object? yekunKurus = null,Object? miktarHam = freezed,Object? yekunHam = freezed,}) {
  return _then(_DefterSatiri(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ortakId: null == ortakId ? _self.ortakId : ortakId // ignore: cast_nullable_to_non_nullable
as String,tur: null == tur ? _self.tur : tur // ignore: cast_nullable_to_non_nullable
as SatirTuru,siraNo: null == siraNo ? _self.siraNo : siraNo // ignore: cast_nullable_to_non_nullable
as int,tarihHam: freezed == tarihHam ? _self.tarihHam : tarihHam // ignore: cast_nullable_to_non_nullable
as String?,tarih: freezed == tarih ? _self.tarih : tarih // ignore: cast_nullable_to_non_nullable
as DateTime?,no: freezed == no ? _self.no : no // ignore: cast_nullable_to_non_nullable
as String?,madde: freezed == madde ? _self.madde : madde // ignore: cast_nullable_to_non_nullable
as String?,aciklama: freezed == aciklama ? _self.aciklama : aciklama // ignore: cast_nullable_to_non_nullable
as String?,miktarKurus: null == miktarKurus ? _self.miktarKurus : miktarKurus // ignore: cast_nullable_to_non_nullable
as int,yekunKurus: null == yekunKurus ? _self.yekunKurus : yekunKurus // ignore: cast_nullable_to_non_nullable
as int,miktarHam: freezed == miktarHam ? _self.miktarHam : miktarHam // ignore: cast_nullable_to_non_nullable
as String?,yekunHam: freezed == yekunHam ? _self.yekunHam : yekunHam // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
