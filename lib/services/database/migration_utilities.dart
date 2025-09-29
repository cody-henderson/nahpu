import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:intl/intl.dart';

Future<void> castMammalType(Migrator m) async {
  final mammalMeasurement = (m.database as Database).mammalMeasurement;

  await m.alterTable(TableMigration(mammalMeasurement, columnTransformer: {
    mammalMeasurement.totalLength: mammalMeasurement.totalLength.cast<double>(),
    mammalMeasurement.tailLength: mammalMeasurement.tailLength.cast<double>(),
    mammalMeasurement.hindFootLength:
        mammalMeasurement.hindFootLength.cast<double>(),
    mammalMeasurement.earLength: mammalMeasurement.earLength.cast<double>(),
    mammalMeasurement.forearm: mammalMeasurement.forearm.cast<double>(),
    mammalMeasurement.testisLength:
        mammalMeasurement.testisLength.cast<double>(),
    mammalMeasurement.testisWidth: mammalMeasurement.testisWidth.cast<double>(),
  }));
}

String convertDateString(String inputDateString) {
  DateTime? parsedDate = DateFormat.yMMMd().tryParse(inputDateString);
  if (parsedDate == null) return inputDateString;
  return DateFormat('yyyy-MM-dd').format(parsedDate);
}

Future<void> migrateProjectDatesFormat(Migrator m) async {
  final db = m.database as Database;

  final fieldsToUpdate = ['startDate', 'endDate'];
  final projects = await ProjectQuery(db).getAllProjects();

  for (final projectData in projects) {
    bool doUpdate = false;
    final projectJson = projectData.toJson();

    for (final field in fieldsToUpdate) {
      final dateString = projectJson[field];

      if (dateString != null && dateString.isNotEmpty) {
        final updatedDateString = convertDateString(dateString);

        if (updatedDateString != dateString) {
          doUpdate = true;
          projectJson[field] = updatedDateString;
        }
      }
    }

    if (doUpdate) {
      final updatedProjectData = ProjectData.fromJson(projectJson);
      ProjectQuery(db).updateProjectEntry(
          updatedProjectData.uuid, updatedProjectData.toCompanion(false));
    }
  }
}
