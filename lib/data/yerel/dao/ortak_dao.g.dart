// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ortak_dao.dart';

// ignore_for_file: type=lint
mixin _$OrtakDaoMixin on DatabaseAccessor<AppVeritabani> {
  $OrtaklarTable get ortaklar => attachedDatabase.ortaklar;
  OrtakDaoManager get managers => OrtakDaoManager(this);
}

class OrtakDaoManager {
  final _$OrtakDaoMixin _db;
  OrtakDaoManager(this._db);
  $$OrtaklarTableTableManager get ortaklar =>
      $$OrtaklarTableTableManager(_db.attachedDatabase, _db.ortaklar);
}
