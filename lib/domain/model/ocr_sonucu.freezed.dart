// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ocr_sonucu.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OcrAlan {

 String get metin; double get guven;
/// Create a copy of OcrAlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<OcrAlan> get copyWith => _$OcrAlanCopyWithImpl<OcrAlan>(this as OcrAlan, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrAlan&&(identical(other.metin, metin) || other.metin == metin)&&(identical(other.guven, guven) || other.guven == guven));
}


@override
int get hashCode => Object.hash(runtimeType,metin,guven);

@override
String toString() {
  return 'OcrAlan(metin: $metin, guven: $guven)';
}


}

/// @nodoc
abstract mixin class $OcrAlanCopyWith<$Res>  {
  factory $OcrAlanCopyWith(OcrAlan value, $Res Function(OcrAlan) _then) = _$OcrAlanCopyWithImpl;
@useResult
$Res call({
 String metin, double guven
});




}
/// @nodoc
class _$OcrAlanCopyWithImpl<$Res>
    implements $OcrAlanCopyWith<$Res> {
  _$OcrAlanCopyWithImpl(this._self, this._then);

  final OcrAlan _self;
  final $Res Function(OcrAlan) _then;

/// Create a copy of OcrAlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? metin = null,Object? guven = null,}) {
  return _then(_self.copyWith(
metin: null == metin ? _self.metin : metin // ignore: cast_nullable_to_non_nullable
as String,guven: null == guven ? _self.guven : guven // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [OcrAlan].
extension OcrAlanPatterns on OcrAlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OcrAlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OcrAlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OcrAlan value)  $default,){
final _that = this;
switch (_that) {
case _OcrAlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OcrAlan value)?  $default,){
final _that = this;
switch (_that) {
case _OcrAlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String metin,  double guven)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OcrAlan() when $default != null:
return $default(_that.metin,_that.guven);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String metin,  double guven)  $default,) {final _that = this;
switch (_that) {
case _OcrAlan():
return $default(_that.metin,_that.guven);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String metin,  double guven)?  $default,) {final _that = this;
switch (_that) {
case _OcrAlan() when $default != null:
return $default(_that.metin,_that.guven);case _:
  return null;

}
}

}

/// @nodoc


class _OcrAlan implements OcrAlan {
  const _OcrAlan({required this.metin, required this.guven});
  

@override final  String metin;
@override final  double guven;

/// Create a copy of OcrAlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OcrAlanCopyWith<_OcrAlan> get copyWith => __$OcrAlanCopyWithImpl<_OcrAlan>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OcrAlan&&(identical(other.metin, metin) || other.metin == metin)&&(identical(other.guven, guven) || other.guven == guven));
}


@override
int get hashCode => Object.hash(runtimeType,metin,guven);

@override
String toString() {
  return 'OcrAlan(metin: $metin, guven: $guven)';
}


}

/// @nodoc
abstract mixin class _$OcrAlanCopyWith<$Res> implements $OcrAlanCopyWith<$Res> {
  factory _$OcrAlanCopyWith(_OcrAlan value, $Res Function(_OcrAlan) _then) = __$OcrAlanCopyWithImpl;
@override @useResult
$Res call({
 String metin, double guven
});




}
/// @nodoc
class __$OcrAlanCopyWithImpl<$Res>
    implements _$OcrAlanCopyWith<$Res> {
  __$OcrAlanCopyWithImpl(this._self, this._then);

  final _OcrAlan _self;
  final $Res Function(_OcrAlan) _then;

/// Create a copy of OcrAlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? metin = null,Object? guven = null,}) {
  return _then(_OcrAlan(
metin: null == metin ? _self.metin : metin // ignore: cast_nullable_to_non_nullable
as String,guven: null == guven ? _self.guven : guven // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$OcrSonucu {

 OcrAlan? get ortakNo; OcrAlan? get adSoyad; OcrAlan? get babaAdi; OcrAlan? get dogumYeri; OcrAlan? get dogumTarihi; OcrAlan? get girisTarihi; OcrAlan? get cikisTarihi; OcrAlan? get ikametAdresi; OcrAlan? get nufusKayitYeri; List<DefterSatiri> get sermayeSatirlari; List<DefterSatiri> get odemeSatirlari;
/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OcrSonucuCopyWith<OcrSonucu> get copyWith => _$OcrSonucuCopyWithImpl<OcrSonucu>(this as OcrSonucu, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OcrSonucu&&(identical(other.ortakNo, ortakNo) || other.ortakNo == ortakNo)&&(identical(other.adSoyad, adSoyad) || other.adSoyad == adSoyad)&&(identical(other.babaAdi, babaAdi) || other.babaAdi == babaAdi)&&(identical(other.dogumYeri, dogumYeri) || other.dogumYeri == dogumYeri)&&(identical(other.dogumTarihi, dogumTarihi) || other.dogumTarihi == dogumTarihi)&&(identical(other.girisTarihi, girisTarihi) || other.girisTarihi == girisTarihi)&&(identical(other.cikisTarihi, cikisTarihi) || other.cikisTarihi == cikisTarihi)&&(identical(other.ikametAdresi, ikametAdresi) || other.ikametAdresi == ikametAdresi)&&(identical(other.nufusKayitYeri, nufusKayitYeri) || other.nufusKayitYeri == nufusKayitYeri)&&const DeepCollectionEquality().equals(other.sermayeSatirlari, sermayeSatirlari)&&const DeepCollectionEquality().equals(other.odemeSatirlari, odemeSatirlari));
}


@override
int get hashCode => Object.hash(runtimeType,ortakNo,adSoyad,babaAdi,dogumYeri,dogumTarihi,girisTarihi,cikisTarihi,ikametAdresi,nufusKayitYeri,const DeepCollectionEquality().hash(sermayeSatirlari),const DeepCollectionEquality().hash(odemeSatirlari));

@override
String toString() {
  return 'OcrSonucu(ortakNo: $ortakNo, adSoyad: $adSoyad, babaAdi: $babaAdi, dogumYeri: $dogumYeri, dogumTarihi: $dogumTarihi, girisTarihi: $girisTarihi, cikisTarihi: $cikisTarihi, ikametAdresi: $ikametAdresi, nufusKayitYeri: $nufusKayitYeri, sermayeSatirlari: $sermayeSatirlari, odemeSatirlari: $odemeSatirlari)';
}


}

/// @nodoc
abstract mixin class $OcrSonucuCopyWith<$Res>  {
  factory $OcrSonucuCopyWith(OcrSonucu value, $Res Function(OcrSonucu) _then) = _$OcrSonucuCopyWithImpl;
@useResult
$Res call({
 OcrAlan? ortakNo, OcrAlan? adSoyad, OcrAlan? babaAdi, OcrAlan? dogumYeri, OcrAlan? dogumTarihi, OcrAlan? girisTarihi, OcrAlan? cikisTarihi, OcrAlan? ikametAdresi, OcrAlan? nufusKayitYeri, List<DefterSatiri> sermayeSatirlari, List<DefterSatiri> odemeSatirlari
});


$OcrAlanCopyWith<$Res>? get ortakNo;$OcrAlanCopyWith<$Res>? get adSoyad;$OcrAlanCopyWith<$Res>? get babaAdi;$OcrAlanCopyWith<$Res>? get dogumYeri;$OcrAlanCopyWith<$Res>? get dogumTarihi;$OcrAlanCopyWith<$Res>? get girisTarihi;$OcrAlanCopyWith<$Res>? get cikisTarihi;$OcrAlanCopyWith<$Res>? get ikametAdresi;$OcrAlanCopyWith<$Res>? get nufusKayitYeri;

}
/// @nodoc
class _$OcrSonucuCopyWithImpl<$Res>
    implements $OcrSonucuCopyWith<$Res> {
  _$OcrSonucuCopyWithImpl(this._self, this._then);

  final OcrSonucu _self;
  final $Res Function(OcrSonucu) _then;

/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ortakNo = freezed,Object? adSoyad = freezed,Object? babaAdi = freezed,Object? dogumYeri = freezed,Object? dogumTarihi = freezed,Object? girisTarihi = freezed,Object? cikisTarihi = freezed,Object? ikametAdresi = freezed,Object? nufusKayitYeri = freezed,Object? sermayeSatirlari = null,Object? odemeSatirlari = null,}) {
  return _then(_self.copyWith(
ortakNo: freezed == ortakNo ? _self.ortakNo : ortakNo // ignore: cast_nullable_to_non_nullable
as OcrAlan?,adSoyad: freezed == adSoyad ? _self.adSoyad : adSoyad // ignore: cast_nullable_to_non_nullable
as OcrAlan?,babaAdi: freezed == babaAdi ? _self.babaAdi : babaAdi // ignore: cast_nullable_to_non_nullable
as OcrAlan?,dogumYeri: freezed == dogumYeri ? _self.dogumYeri : dogumYeri // ignore: cast_nullable_to_non_nullable
as OcrAlan?,dogumTarihi: freezed == dogumTarihi ? _self.dogumTarihi : dogumTarihi // ignore: cast_nullable_to_non_nullable
as OcrAlan?,girisTarihi: freezed == girisTarihi ? _self.girisTarihi : girisTarihi // ignore: cast_nullable_to_non_nullable
as OcrAlan?,cikisTarihi: freezed == cikisTarihi ? _self.cikisTarihi : cikisTarihi // ignore: cast_nullable_to_non_nullable
as OcrAlan?,ikametAdresi: freezed == ikametAdresi ? _self.ikametAdresi : ikametAdresi // ignore: cast_nullable_to_non_nullable
as OcrAlan?,nufusKayitYeri: freezed == nufusKayitYeri ? _self.nufusKayitYeri : nufusKayitYeri // ignore: cast_nullable_to_non_nullable
as OcrAlan?,sermayeSatirlari: null == sermayeSatirlari ? _self.sermayeSatirlari : sermayeSatirlari // ignore: cast_nullable_to_non_nullable
as List<DefterSatiri>,odemeSatirlari: null == odemeSatirlari ? _self.odemeSatirlari : odemeSatirlari // ignore: cast_nullable_to_non_nullable
as List<DefterSatiri>,
  ));
}
/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get ortakNo {
    if (_self.ortakNo == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.ortakNo!, (value) {
    return _then(_self.copyWith(ortakNo: value));
  });
}/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get adSoyad {
    if (_self.adSoyad == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.adSoyad!, (value) {
    return _then(_self.copyWith(adSoyad: value));
  });
}/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get babaAdi {
    if (_self.babaAdi == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.babaAdi!, (value) {
    return _then(_self.copyWith(babaAdi: value));
  });
}/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get dogumYeri {
    if (_self.dogumYeri == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.dogumYeri!, (value) {
    return _then(_self.copyWith(dogumYeri: value));
  });
}/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get dogumTarihi {
    if (_self.dogumTarihi == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.dogumTarihi!, (value) {
    return _then(_self.copyWith(dogumTarihi: value));
  });
}/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get girisTarihi {
    if (_self.girisTarihi == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.girisTarihi!, (value) {
    return _then(_self.copyWith(girisTarihi: value));
  });
}/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get cikisTarihi {
    if (_self.cikisTarihi == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.cikisTarihi!, (value) {
    return _then(_self.copyWith(cikisTarihi: value));
  });
}/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get ikametAdresi {
    if (_self.ikametAdresi == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.ikametAdresi!, (value) {
    return _then(_self.copyWith(ikametAdresi: value));
  });
}/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get nufusKayitYeri {
    if (_self.nufusKayitYeri == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.nufusKayitYeri!, (value) {
    return _then(_self.copyWith(nufusKayitYeri: value));
  });
}
}


/// Adds pattern-matching-related methods to [OcrSonucu].
extension OcrSonucuPatterns on OcrSonucu {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OcrSonucu value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OcrSonucu() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OcrSonucu value)  $default,){
final _that = this;
switch (_that) {
case _OcrSonucu():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OcrSonucu value)?  $default,){
final _that = this;
switch (_that) {
case _OcrSonucu() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OcrAlan? ortakNo,  OcrAlan? adSoyad,  OcrAlan? babaAdi,  OcrAlan? dogumYeri,  OcrAlan? dogumTarihi,  OcrAlan? girisTarihi,  OcrAlan? cikisTarihi,  OcrAlan? ikametAdresi,  OcrAlan? nufusKayitYeri,  List<DefterSatiri> sermayeSatirlari,  List<DefterSatiri> odemeSatirlari)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OcrSonucu() when $default != null:
return $default(_that.ortakNo,_that.adSoyad,_that.babaAdi,_that.dogumYeri,_that.dogumTarihi,_that.girisTarihi,_that.cikisTarihi,_that.ikametAdresi,_that.nufusKayitYeri,_that.sermayeSatirlari,_that.odemeSatirlari);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OcrAlan? ortakNo,  OcrAlan? adSoyad,  OcrAlan? babaAdi,  OcrAlan? dogumYeri,  OcrAlan? dogumTarihi,  OcrAlan? girisTarihi,  OcrAlan? cikisTarihi,  OcrAlan? ikametAdresi,  OcrAlan? nufusKayitYeri,  List<DefterSatiri> sermayeSatirlari,  List<DefterSatiri> odemeSatirlari)  $default,) {final _that = this;
switch (_that) {
case _OcrSonucu():
return $default(_that.ortakNo,_that.adSoyad,_that.babaAdi,_that.dogumYeri,_that.dogumTarihi,_that.girisTarihi,_that.cikisTarihi,_that.ikametAdresi,_that.nufusKayitYeri,_that.sermayeSatirlari,_that.odemeSatirlari);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OcrAlan? ortakNo,  OcrAlan? adSoyad,  OcrAlan? babaAdi,  OcrAlan? dogumYeri,  OcrAlan? dogumTarihi,  OcrAlan? girisTarihi,  OcrAlan? cikisTarihi,  OcrAlan? ikametAdresi,  OcrAlan? nufusKayitYeri,  List<DefterSatiri> sermayeSatirlari,  List<DefterSatiri> odemeSatirlari)?  $default,) {final _that = this;
switch (_that) {
case _OcrSonucu() when $default != null:
return $default(_that.ortakNo,_that.adSoyad,_that.babaAdi,_that.dogumYeri,_that.dogumTarihi,_that.girisTarihi,_that.cikisTarihi,_that.ikametAdresi,_that.nufusKayitYeri,_that.sermayeSatirlari,_that.odemeSatirlari);case _:
  return null;

}
}

}

/// @nodoc


class _OcrSonucu implements OcrSonucu {
  const _OcrSonucu({this.ortakNo, this.adSoyad, this.babaAdi, this.dogumYeri, this.dogumTarihi, this.girisTarihi, this.cikisTarihi, this.ikametAdresi, this.nufusKayitYeri, final  List<DefterSatiri> sermayeSatirlari = const <DefterSatiri>[], final  List<DefterSatiri> odemeSatirlari = const <DefterSatiri>[]}): _sermayeSatirlari = sermayeSatirlari,_odemeSatirlari = odemeSatirlari;
  

@override final  OcrAlan? ortakNo;
@override final  OcrAlan? adSoyad;
@override final  OcrAlan? babaAdi;
@override final  OcrAlan? dogumYeri;
@override final  OcrAlan? dogumTarihi;
@override final  OcrAlan? girisTarihi;
@override final  OcrAlan? cikisTarihi;
@override final  OcrAlan? ikametAdresi;
@override final  OcrAlan? nufusKayitYeri;
 final  List<DefterSatiri> _sermayeSatirlari;
@override@JsonKey() List<DefterSatiri> get sermayeSatirlari {
  if (_sermayeSatirlari is EqualUnmodifiableListView) return _sermayeSatirlari;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sermayeSatirlari);
}

 final  List<DefterSatiri> _odemeSatirlari;
@override@JsonKey() List<DefterSatiri> get odemeSatirlari {
  if (_odemeSatirlari is EqualUnmodifiableListView) return _odemeSatirlari;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_odemeSatirlari);
}


/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OcrSonucuCopyWith<_OcrSonucu> get copyWith => __$OcrSonucuCopyWithImpl<_OcrSonucu>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OcrSonucu&&(identical(other.ortakNo, ortakNo) || other.ortakNo == ortakNo)&&(identical(other.adSoyad, adSoyad) || other.adSoyad == adSoyad)&&(identical(other.babaAdi, babaAdi) || other.babaAdi == babaAdi)&&(identical(other.dogumYeri, dogumYeri) || other.dogumYeri == dogumYeri)&&(identical(other.dogumTarihi, dogumTarihi) || other.dogumTarihi == dogumTarihi)&&(identical(other.girisTarihi, girisTarihi) || other.girisTarihi == girisTarihi)&&(identical(other.cikisTarihi, cikisTarihi) || other.cikisTarihi == cikisTarihi)&&(identical(other.ikametAdresi, ikametAdresi) || other.ikametAdresi == ikametAdresi)&&(identical(other.nufusKayitYeri, nufusKayitYeri) || other.nufusKayitYeri == nufusKayitYeri)&&const DeepCollectionEquality().equals(other._sermayeSatirlari, _sermayeSatirlari)&&const DeepCollectionEquality().equals(other._odemeSatirlari, _odemeSatirlari));
}


@override
int get hashCode => Object.hash(runtimeType,ortakNo,adSoyad,babaAdi,dogumYeri,dogumTarihi,girisTarihi,cikisTarihi,ikametAdresi,nufusKayitYeri,const DeepCollectionEquality().hash(_sermayeSatirlari),const DeepCollectionEquality().hash(_odemeSatirlari));

@override
String toString() {
  return 'OcrSonucu(ortakNo: $ortakNo, adSoyad: $adSoyad, babaAdi: $babaAdi, dogumYeri: $dogumYeri, dogumTarihi: $dogumTarihi, girisTarihi: $girisTarihi, cikisTarihi: $cikisTarihi, ikametAdresi: $ikametAdresi, nufusKayitYeri: $nufusKayitYeri, sermayeSatirlari: $sermayeSatirlari, odemeSatirlari: $odemeSatirlari)';
}


}

/// @nodoc
abstract mixin class _$OcrSonucuCopyWith<$Res> implements $OcrSonucuCopyWith<$Res> {
  factory _$OcrSonucuCopyWith(_OcrSonucu value, $Res Function(_OcrSonucu) _then) = __$OcrSonucuCopyWithImpl;
@override @useResult
$Res call({
 OcrAlan? ortakNo, OcrAlan? adSoyad, OcrAlan? babaAdi, OcrAlan? dogumYeri, OcrAlan? dogumTarihi, OcrAlan? girisTarihi, OcrAlan? cikisTarihi, OcrAlan? ikametAdresi, OcrAlan? nufusKayitYeri, List<DefterSatiri> sermayeSatirlari, List<DefterSatiri> odemeSatirlari
});


@override $OcrAlanCopyWith<$Res>? get ortakNo;@override $OcrAlanCopyWith<$Res>? get adSoyad;@override $OcrAlanCopyWith<$Res>? get babaAdi;@override $OcrAlanCopyWith<$Res>? get dogumYeri;@override $OcrAlanCopyWith<$Res>? get dogumTarihi;@override $OcrAlanCopyWith<$Res>? get girisTarihi;@override $OcrAlanCopyWith<$Res>? get cikisTarihi;@override $OcrAlanCopyWith<$Res>? get ikametAdresi;@override $OcrAlanCopyWith<$Res>? get nufusKayitYeri;

}
/// @nodoc
class __$OcrSonucuCopyWithImpl<$Res>
    implements _$OcrSonucuCopyWith<$Res> {
  __$OcrSonucuCopyWithImpl(this._self, this._then);

  final _OcrSonucu _self;
  final $Res Function(_OcrSonucu) _then;

/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ortakNo = freezed,Object? adSoyad = freezed,Object? babaAdi = freezed,Object? dogumYeri = freezed,Object? dogumTarihi = freezed,Object? girisTarihi = freezed,Object? cikisTarihi = freezed,Object? ikametAdresi = freezed,Object? nufusKayitYeri = freezed,Object? sermayeSatirlari = null,Object? odemeSatirlari = null,}) {
  return _then(_OcrSonucu(
ortakNo: freezed == ortakNo ? _self.ortakNo : ortakNo // ignore: cast_nullable_to_non_nullable
as OcrAlan?,adSoyad: freezed == adSoyad ? _self.adSoyad : adSoyad // ignore: cast_nullable_to_non_nullable
as OcrAlan?,babaAdi: freezed == babaAdi ? _self.babaAdi : babaAdi // ignore: cast_nullable_to_non_nullable
as OcrAlan?,dogumYeri: freezed == dogumYeri ? _self.dogumYeri : dogumYeri // ignore: cast_nullable_to_non_nullable
as OcrAlan?,dogumTarihi: freezed == dogumTarihi ? _self.dogumTarihi : dogumTarihi // ignore: cast_nullable_to_non_nullable
as OcrAlan?,girisTarihi: freezed == girisTarihi ? _self.girisTarihi : girisTarihi // ignore: cast_nullable_to_non_nullable
as OcrAlan?,cikisTarihi: freezed == cikisTarihi ? _self.cikisTarihi : cikisTarihi // ignore: cast_nullable_to_non_nullable
as OcrAlan?,ikametAdresi: freezed == ikametAdresi ? _self.ikametAdresi : ikametAdresi // ignore: cast_nullable_to_non_nullable
as OcrAlan?,nufusKayitYeri: freezed == nufusKayitYeri ? _self.nufusKayitYeri : nufusKayitYeri // ignore: cast_nullable_to_non_nullable
as OcrAlan?,sermayeSatirlari: null == sermayeSatirlari ? _self._sermayeSatirlari : sermayeSatirlari // ignore: cast_nullable_to_non_nullable
as List<DefterSatiri>,odemeSatirlari: null == odemeSatirlari ? _self._odemeSatirlari : odemeSatirlari // ignore: cast_nullable_to_non_nullable
as List<DefterSatiri>,
  ));
}

/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get ortakNo {
    if (_self.ortakNo == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.ortakNo!, (value) {
    return _then(_self.copyWith(ortakNo: value));
  });
}/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get adSoyad {
    if (_self.adSoyad == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.adSoyad!, (value) {
    return _then(_self.copyWith(adSoyad: value));
  });
}/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get babaAdi {
    if (_self.babaAdi == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.babaAdi!, (value) {
    return _then(_self.copyWith(babaAdi: value));
  });
}/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get dogumYeri {
    if (_self.dogumYeri == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.dogumYeri!, (value) {
    return _then(_self.copyWith(dogumYeri: value));
  });
}/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get dogumTarihi {
    if (_self.dogumTarihi == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.dogumTarihi!, (value) {
    return _then(_self.copyWith(dogumTarihi: value));
  });
}/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get girisTarihi {
    if (_self.girisTarihi == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.girisTarihi!, (value) {
    return _then(_self.copyWith(girisTarihi: value));
  });
}/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get cikisTarihi {
    if (_self.cikisTarihi == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.cikisTarihi!, (value) {
    return _then(_self.copyWith(cikisTarihi: value));
  });
}/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get ikametAdresi {
    if (_self.ikametAdresi == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.ikametAdresi!, (value) {
    return _then(_self.copyWith(ikametAdresi: value));
  });
}/// Create a copy of OcrSonucu
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OcrAlanCopyWith<$Res>? get nufusKayitYeri {
    if (_self.nufusKayitYeri == null) {
    return null;
  }

  return $OcrAlanCopyWith<$Res>(_self.nufusKayitYeri!, (value) {
    return _then(_self.copyWith(nufusKayitYeri: value));
  });
}
}

// dart format on
