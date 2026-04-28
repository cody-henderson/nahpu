import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu_data/nahpu_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/merge_db_services.dart';

class MergeTestStruct {
  MergeTestStruct({
    required this.dataset,
    required this.container,
  });
  final NahpuDataSet dataset;
  final ProviderContainer container;

  late Database db;
  late File dbFile;
  late List<ProjectData> projects;
  late Directory tempDir;
  late File tempDbFile;
  late List<ProjectData> dbProjects;

  NahpuDataSet get dataSet => dataset;

  Future<void> oneTimeSetup() async {
    dbFile = File(await getDatabasePath(dataset));
    final projectsStr = await getProjects(dataSet);

    projects = (jsonDecode(projectsStr) as List)
        .map((e) => ProjectData.fromJson(e))
        .toList();
  }

  Future<void> testSetup() async {
    tempDir = await Directory.systemTemp.createTemp('test_db_');
    tempDbFile = File('${tempDir.path}/testDb.sqlite3');
    await dbFile.copy(tempDbFile.path);
    db = container.read(databaseFromPathProvider(dbFile: tempDbFile));
    dbProjects = await ProjectQuery(db).getAllProjects();
  }

  Future<void> refreshData() async {
    dbProjects = await ProjectQuery(db).getAllProjects();
  }

  Future<void> tearDown() async {
    await db.close();
    container.invalidate(databaseFromPathProvider(dbFile: tempDbFile));

    // Wait a few milliseconds for OS to release the tempDbFile
    sleep(Duration(milliseconds: 10));
    try {
      if (tempDbFile.existsSync()) {
        tempDbFile.deleteSync();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Notice: Skipped deleting locked temp files: ${tempDbFile.path}');
      }
    }
  }

  Future<void> validateDB(int expectedProjects) async {
    expect(dbProjects.first, projects.first);
    expect(dbProjects.length, expectedProjects);
  }
}

void main() {
  final ProviderContainer container = ProviderContainer();

  final listEquals = UnorderedIterableEquality();

  final MergeTestStruct structA =
      MergeTestStruct(dataset: NahpuDataSet.mergeTestA, container: container);
  final MergeTestStruct structB =
      MergeTestStruct(dataset: NahpuDataSet.mergeTestB, container: container);

  setUpAll(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

    await structA.oneTimeSetup();
    await structB.oneTimeSetup();
  });

  setUp(() async {
    await structA.testSetup();
    await structB.testSetup();
  });

  test('validate initial database structure', () async {
    await structA.validateDB(1);
    await structB.validateDB(1);
  });

  test('merge DBs, keep all projects', () async {
    final projectMap = {structB.projects.first.uuid: 'NEW'};
    final combinedProjects = structA.projects + structB.projects;

    await MergeDbServices().mergeProjects(structA.db, structB.db, projectMap);
    await structA.refreshData();
    expect(structA.dbProjects.length, combinedProjects.length);
    expect(listEquals.equals(structA.dbProjects, combinedProjects), true);
  });

  test('merge DBs, skip incoming projects', () async {
    final projectMap = {structB.projects.first.uuid: 'SKIP'};

    await MergeDbServices().mergeProjects(structA.db, structB.db, projectMap);
    await structA.refreshData();
    expect(structA.dbProjects.length, structA.projects.length);
    expect(listEquals.equals(structA.dbProjects, structA.projects), true);
  });

  test('merge DBs, incoming project maps to current', () async {
    final projectMap = {
      structB.projects.first.uuid: structA.projects.first.uuid
    };

    await MergeDbServices().mergeProjects(structA.db, structB.db, projectMap);
    await structA.refreshData();
    expect(structA.dbProjects.length, structA.projects.length);
    expect(listEquals.equals(structA.dbProjects, structA.projects), true);
  });

  tearDown(() async {
    // Clean up the database connection and temporary file after the test
    await structA.tearDown();
    await structB.tearDown();
  });

  tearDownAll(() {
    container.dispose();
  });
}
