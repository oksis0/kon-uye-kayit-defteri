// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ice_aktarma_isi.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IceAktarmaIsi {

 String get id; String get dosyaYolu; String get dosyaAdi; String get dosyaHash; KuyrukDurumu get durum; bool get islendi; String? get hataMesaji; int get denemeSayisi; String? get olusanOrtakId;/// Azure'un ham cevabı. Uygulama inceleme formundayken çökerse, açılışta
/// OCR'ı tekrarlamadan (kota israfı olmadan) forma dönebilmek için.
 String? get ocrHamJson;/// `ocrYapiliyor` durumundayken hangi Azure işleminin sorgulanacağı.
 String? get azureOperationId; DateTime get eklenmeTarihi;
/// Create a copy of IceAktarmaIsi
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IceAktarmaIsiCopyWith<IceAktarmaIsi> get copyWith => _$IceAktarmaIsiCopyWithImpl<IceAktarmaIsi>(this as IceAktarmaIsi, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IceAktarmaIsi&&(identical(other.id, id) || other.id == id)&&(identical(other.dosyaYolu, dosyaYolu) || other.dosyaYolu == dosyaYolu)&&(identical(other.dosyaAdi, dosyaAdi) || other.dosyaAdi == dosyaAdi)&&(identical(other.dosyaHash, dosyaHash) || other.dosyaHash == dosyaHash)&&(identical(other.durum, durum) || other.durum == durum)&&(identical(other.islendi, islendi) || other.islendi == islendi)&&(identical(other.hataMesaji, hataMesaji) || other.hataMesaji == hataMesaji)&&(identical(other.denemeSayisi, denemeSayisi) || other.denemeSayisi == denemeSayisi)&&(identical(other.olusanOrtakId, olusanOrtakId) || other.olusanOrtakId == olusanOrtakId)&&(identical(other.ocrHamJson, ocrHamJson) || other.ocrHamJson == ocrHamJson)&&(identical(other.azureOperationId, azureOperationId) || other.azureOperationId == azureOperationId)&&(identical(other.eklenmeTarihi, eklenmeTarihi) || other.eklenmeTarihi == eklenmeTarihi));
}


@override
int get hashCode => Object.hash(runtimeType,id,dosyaYolu,dosyaAdi,dosyaHash,durum,islendi,hataMesaji,denemeSayisi,olusanOrtakId,ocrHamJson,azureOperationId,eklenmeTarihi);

@override
String toString() {
  return 'IceAktarmaIsi(id: $id, dosyaYolu: $dosyaYolu, dosyaAdi: $dosyaAdi, dosyaHash: $dosyaHash, durum: $durum, islendi: $islendi, hataMesaji: $hataMesaji, denemeSayisi: $denemeSayisi, olusanOrtakId: $olusanOrtakId, ocrHamJson: $ocrHamJson, azureOperationId: $azureOperationId, eklenmeTarihi: $eklenmeTarihi)';
}


}

/// @nodoc
abstract mixin class $IceAktarmaIsiCopyWith<$Res>  {
  factory $IceAktarmaIsiCopyWith(IceAktarmaIsi value, $Res Function(IceAktarmaIsi) _then) = _$IceAktarmaIsiCopyWithImpl;
@useResult
$Res call({
 String id, String dosyaYolu, String dosyaAdi, String dosyaHash, KuyrukDurumu durum, bool islendi, String? hataMesaji, int denemeSayisi, String? olusanOrtakId, String? ocrHamJson, String? azureOperationId, DateTime eklenmeTarihi
});




}
/// @nodoc
class _$IceAktarmaIsiCopyWithImpl<$Res>
    implements $IceAktarmaIsiCopyWith<$Res> {
  _$IceAktarmaIsiCopyWithImpl(this._self, this._then);

  final IceAktarmaIsi _self;
  final $Res Function(IceAktarmaIsi) _then;

/// Create a copy of IceAktarmaIsi
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? dosyaYolu = null,Object? dosyaAdi = null,Object? dosyaHash = null,Object? durum = null,Object? islendi = null,Object? hataMesaji = freezed,Object? denemeSayisi = null,Object? olusanOrtakId = freezed,Object? ocrHamJson = freezed,Object? azureOperationId = freezed,Object? eklenmeTarihi = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dosyaYolu: null == dosyaYolu ? _self.dosyaYolu : dosyaYolu // ignore: cast_nullable_to_non_nullable
as String,dosyaAdi: null == dosyaAdi ? _self.dosyaAdi : dosyaAdi // ignore: cast_nullable_to_non_nullable
as String,dosyaHash: null == dosyaHash ? _self.dosyaHash : dosyaHash // ignore: cast_nullable_to_non_nullable
as String,durum: null == durum ? _self.durum : durum // ignore: cast_nullable_to_non_nullable
as KuyrukDurumu,islendi: null == islendi ? _self.islendi : islendi // ignore: cast_nullable_to_non_nullable
as bool,hataMesaji: freezed == hataMesaji ? _self.hataMesaji : hataMesaji // ignore: cast_nullable_to_non_nullable
as String?,denemeSayisi: null == denemeSayisi ? _self.denemeSayisi : denemeSayisi // ignore: cast_nullable_to_non_nullable
as int,olusanOrtakId: freezed == olusanOrtakId ? _self.olusanOrtakId : olusanOrtakId // ignore: cast_nullable_to_non_nullable
as String?,ocrHamJson: freezed == ocrHamJson ? _self.ocrHamJson : ocrHamJson // ignore: cast_nullable_to_non_nullable
as String?,azureOperationId: freezed == azureOperationId ? _self.azureOperationId : azureOperationId // ignore: cast_nullable_to_non_nullable
as String?,eklenmeTarihi: null == eklenmeTarihi ? _self.eklenmeTarihi : eklenmeTarihi // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [IceAktarmaIsi].
extension IceAktarmaIsiPatterns on IceAktarmaIsi {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IceAktarmaIsi value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IceAktarmaIsi() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IceAktarmaIsi value)  $default,){
final _that = this;
switch (_that) {
case _IceAktarmaIsi():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IceAktarmaIsi value)?  $default,){
final _that = this;
switch (_that) {
case _IceAktarmaIsi() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String dosyaYolu,  String dosyaAdi,  String dosyaHash,  KuyrukDurumu durum,  bool islendi,  String? hataMesaji,  int denemeSayisi,  String? olusanOrtakId,  String? ocrHamJson,  String? azureOperationId,  DateTime eklenmeTarihi)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IceAktarmaIsi() when $default != null:
return $default(_that.id,_that.dosyaYolu,_that.dosyaAdi,_that.dosyaHash,_that.durum,_that.islendi,_that.hataMesaji,_that.denemeSayisi,_that.olusanOrtakId,_that.ocrHamJson,_that.azureOperationId,_that.eklenmeTarihi);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String dosyaYolu,  String dosyaAdi,  String dosyaHash,  KuyrukDurumu durum,  bool islendi,  String? hataMesaji,  int denemeSayisi,  String? olusanOrtakId,  String? ocrHamJson,  String? azureOperationId,  DateTime eklenmeTarihi)  $default,) {final _that = this;
switch (_that) {
case _IceAktarmaIsi():
return $default(_that.id,_that.dosyaYolu,_that.dosyaAdi,_that.dosyaHash,_that.durum,_that.islendi,_that.hataMesaji,_that.denemeSayisi,_that.olusanOrtakId,_that.ocrHamJson,_that.azureOperationId,_that.eklenmeTarihi);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String dosyaYolu,  String dosyaAdi,  String dosyaHash,  KuyrukDurumu durum,  bool islendi,  String? hataMesaji,  int denemeSayisi,  String? olusanOrtakId,  String? ocrHamJson,  String? azureOperationId,  DateTime eklenmeTarihi)?  $default,) {final _that = this;
switch (_that) {
case _IceAktarmaIsi() when $default != null:
return $default(_that.id,_that.dosyaYolu,_that.dosyaAdi,_that.dosyaHash,_that.durum,_that.islendi,_that.hataMesaji,_that.denemeSayisi,_that.olusanOrtakId,_that.ocrHamJson,_that.azureOperationId,_that.eklenmeTarihi);case _:
  return null;

}
}

}

/// @nodoc


class _IceAktarmaIsi implements IceAktarmaIsi {
  const _IceAktarmaIsi({required this.id, required this.dosyaYolu, required this.dosyaAdi, required this.dosyaHash, required this.durum, this.islendi = false, this.hataMesaji, this.denemeSayisi = 0, this.olusanOrtakId, this.ocrHamJson, this.azureOperationId, required this.eklenmeTarihi});
  

@override final  String id;
@override final  String dosyaYolu;
@override final  String dosyaAdi;
@override final  String dosyaHash;
@override final  KuyrukDurumu durum;
@override@JsonKey() final  bool islendi;
@override final  String? hataMesaji;
@override@JsonKey() final  int denemeSayisi;
@override final  String? olusanOrtakId;
/// Azure'un ham cevabı. Uygulama inceleme formundayken çökerse, açılışta
/// OCR'ı tekrarlamadan (kota israfı olmadan) forma dönebilmek için.
@override final  String? ocrHamJson;
/// `ocrYapiliyor` durumundayken hangi Azure işleminin sorgulanacağı.
@override final  String? azureOperationId;
@override final  DateTime eklenmeTarihi;

/// Create a copy of IceAktarmaIsi
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IceAktarmaIsiCopyWith<_IceAktarmaIsi> get copyWith => __$IceAktarmaIsiCopyWithImpl<_IceAktarmaIsi>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IceAktarmaIsi&&(identical(other.id, id) || other.id == id)&&(identical(other.dosyaYolu, dosyaYolu) || other.dosyaYolu == dosyaYolu)&&(identical(other.dosyaAdi, dosyaAdi) || other.dosyaAdi == dosyaAdi)&&(identical(other.dosyaHash, dosyaHash) || other.dosyaHash == dosyaHash)&&(identical(other.durum, durum) || other.durum == durum)&&(identical(other.islendi, islendi) || other.islendi == islendi)&&(identical(other.hataMesaji, hataMesaji) || other.hataMesaji == hataMesaji)&&(identical(other.denemeSayisi, denemeSayisi) || other.denemeSayisi == denemeSayisi)&&(identical(other.olusanOrtakId, olusanOrtakId) || other.olusanOrtakId == olusanOrtakId)&&(identical(other.ocrHamJson, ocrHamJson) || other.ocrHamJson == ocrHamJson)&&(identical(other.azureOperationId, azureOperationId) || other.azureOperationId == azureOperationId)&&(identical(other.eklenmeTarihi, eklenmeTarihi) || other.eklenmeTarihi == eklenmeTarihi));
}


@override
int get hashCode => Object.hash(runtimeType,id,dosyaYolu,dosyaAdi,dosyaHash,durum,islendi,hataMesaji,denemeSayisi,olusanOrtakId,ocrHamJson,azureOperationId,eklenmeTarihi);

@override
String toString() {
  return 'IceAktarmaIsi(id: $id, dosyaYolu: $dosyaYolu, dosyaAdi: $dosyaAdi, dosyaHash: $dosyaHash, durum: $durum, islendi: $islendi, hataMesaji: $hataMesaji, denemeSayisi: $denemeSayisi, olusanOrtakId: $olusanOrtakId, ocrHamJson: $ocrHamJson, azureOperationId: $azureOperationId, eklenmeTarihi: $eklenmeTarihi)';
}


}

/// @nodoc
abstract mixin class _$IceAktarmaIsiCopyWith<$Res> implements $IceAktarmaIsiCopyWith<$Res> {
  factory _$IceAktarmaIsiCopyWith(_IceAktarmaIsi value, $Res Function(_IceAktarmaIsi) _then) = __$IceAktarmaIsiCopyWithImpl;
@override @useResult
$Res call({
 String id, String dosyaYolu, String dosyaAdi, String dosyaHash, KuyrukDurumu durum, bool islendi, String? hataMesaji, int denemeSayisi, String? olusanOrtakId, String? ocrHamJson, String? azureOperationId, DateTime eklenmeTarihi
});




}
/// @nodoc
class __$IceAktarmaIsiCopyWithImpl<$Res>
    implements _$IceAktarmaIsiCopyWith<$Res> {
  __$IceAktarmaIsiCopyWithImpl(this._self, this._then);

  final _IceAktarmaIsi _self;
  final $Res Function(_IceAktarmaIsi) _then;

/// Create a copy of IceAktarmaIsi
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? dosyaYolu = null,Object? dosyaAdi = null,Object? dosyaHash = null,Object? durum = null,Object? islendi = null,Object? hataMesaji = freezed,Object? denemeSayisi = null,Object? olusanOrtakId = freezed,Object? ocrHamJson = freezed,Object? azureOperationId = freezed,Object? eklenmeTarihi = null,}) {
  return _then(_IceAktarmaIsi(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,dosyaYolu: null == dosyaYolu ? _self.dosyaYolu : dosyaYolu // ignore: cast_nullable_to_non_nullable
as String,dosyaAdi: null == dosyaAdi ? _self.dosyaAdi : dosyaAdi // ignore: cast_nullable_to_non_nullable
as String,dosyaHash: null == dosyaHash ? _self.dosyaHash : dosyaHash // ignore: cast_nullable_to_non_nullable
as String,durum: null == durum ? _self.durum : durum // ignore: cast_nullable_to_non_nullable
as KuyrukDurumu,islendi: null == islendi ? _self.islendi : islendi // ignore: cast_nullable_to_non_nullable
as bool,hataMesaji: freezed == hataMesaji ? _self.hataMesaji : hataMesaji // ignore: cast_nullable_to_non_nullable
as String?,denemeSayisi: null == denemeSayisi ? _self.denemeSayisi : denemeSayisi // ignore: cast_nullable_to_non_nullable
as int,olusanOrtakId: freezed == olusanOrtakId ? _self.olusanOrtakId : olusanOrtakId // ignore: cast_nullable_to_non_nullable
as String?,ocrHamJson: freezed == ocrHamJson ? _self.ocrHamJson : ocrHamJson // ignore: cast_nullable_to_non_nullable
as String?,azureOperationId: freezed == azureOperationId ? _self.azureOperationId : azureOperationId // ignore: cast_nullable_to_non_nullable
as String?,eklenmeTarihi: null == eklenmeTarihi ? _self.eklenmeTarihi : eklenmeTarihi // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
