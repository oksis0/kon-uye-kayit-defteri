// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'defter_satiri_dao.dart';

// ignore_for_file: type=lint
mixin _$DefterSatiriDaoMixin on DatabaseAccessor<AppVeritabani> {
  $OrtaklarTable get ortaklar => attachedDatabase.ortaklar;
  $DefterSatirlariTable get defterSatirlari => attachedDatabase.defterSatirlari;
  DefterSatiriDaoManager get managers => DefterSatiriDaoManager(this);
}

class DefterSatiriDaoManager {
  final _$DefterSatiriDaoMixin _db;
  DefterSatiriDaoManager(this._db);
  $$OrtaklarTableTableManager get ortaklar =>
      $$OrtaklarTableTableManager(_db.attachedDatabase, _db.ortaklar);
  $$DefterSatirlariTableTableManager get defterSatirlari =>
      $$DefterSatirlariTableTableManager(
        _db.attachedDatabase,
        _db.defterSatirlari,
      );
}
