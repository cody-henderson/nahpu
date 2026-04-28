import 'package:nahpu/services/database/database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:io';

part 'database.g.dart';

@Riverpod(keepAlive: true)
Database database(Ref ref) {
  final db = Database();
  ref.onDispose(() {
    db.close();
  });
  return db;
}

@Riverpod(keepAlive: true)
Database databaseFromPath(Ref ref, {required File dbFile}) {
  final db = Database.forMerging(dbFile);
  ref.onDispose(() {
    db.close();
  });
  return db;
}
