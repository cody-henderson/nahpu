import 'package:drift/drift.dart';
import 'package:nahpu/services/database/collevent_queries.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/database/narrative_queries.dart';
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

String convertTimeString(String inputTimeString) {
  DateTime? parsedTime = DateFormat('h:m a').tryParse(inputTimeString) ??
      DateFormat('H:m').tryParse(inputTimeString);
  if (parsedTime == null) return inputTimeString;
  return DateFormat.Hms().format(parsedTime);
}

Future<void> migrateProjectDateTimeFormat(Migrator m) async {
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

Future<void> migrateSpecimenDateTimeFormat(Migrator m) async {
  final db = m.database as Database;

  final specimenDateFields = ['prepDate', 'collectionDate', 'captureDate'];
  final specimenTimeFields = ['prepTime', 'collectionTime', 'captureTime'];
  final projects = await ProjectQuery(db).getAllProjects();

  for (final projectData in projects) {
    final specimens = await SpecimenQuery(db).getAllSpecimens(projectData.uuid);

    for (final specimenData in specimens) {
      // Specimen general records and capture records update
      bool doSpecimenUpdate = false;
      final specimenJson = specimenData.toJson();

      for (final field in specimenDateFields) {
        final dateString = specimenJson[field];

        if (dateString != null && dateString.isNotEmpty) {
          final updatedDateString = convertDateString(dateString);

          if (updatedDateString != dateString) {
            doSpecimenUpdate = true;
            specimenJson[field] = updatedDateString;
          }
        }
      }

      for (final field in specimenTimeFields) {
        final timeString = specimenJson[field];

        if (timeString != null && timeString.isNotEmpty) {
          final updatedTimeString = convertTimeString(timeString);

          if (updatedTimeString != timeString) {
            doSpecimenUpdate = true;
            specimenJson[field] = updatedTimeString;
          }
        }
      }

      if (doSpecimenUpdate) {
        final updatedSpecimenData = SpecimenData.fromJson(specimenJson);
        SpecimenQuery(db).updateSpecimenEntry(
            updatedSpecimenData.uuid, updatedSpecimenData.toCompanion(false));
      }

      // Specimen part update
      final specimenParts =
          await SpecimenPartQuery(db).getSpecimenParts(specimenData.uuid);

      for (final specimenPartData in specimenParts) {
        bool doSpecimenPartUpdate = false;
        final specimenPartJson = specimenPartData.toJson();

        final dateString = specimenPartJson['dateTaken'];
        if (dateString != null && dateString.isNotEmpty) {
          final updatedDateString = convertDateString(dateString);

          if (updatedDateString != dateString) {
            doSpecimenPartUpdate = true;
            specimenPartJson['dateTaken'] = updatedDateString;
          }
        }

        final timeString = specimenPartJson['timeTaken'];
        if (timeString != null && timeString.isNotEmpty) {
          final updatedTimeString = convertTimeString(timeString);

          if (updatedTimeString != timeString) {
            doSpecimenPartUpdate = true;
            specimenPartJson['timeTaken'] = updatedTimeString;
          }
        }

        if (doSpecimenPartUpdate) {
          final updatedSpecimenPartData =
              SpecimenPartData.fromJson(specimenPartJson);
          SpecimenPartQuery(db).updateSpecimenPart(
              updatedSpecimenPartData.id as int,
              updatedSpecimenPartData.toCompanion(false));
        }
      }

      // Associated data update
      final associatedDataList =
          await AssociatedDataQuery(db).getAllAssociatedData(specimenData.uuid);

      for (final associatedDatum in associatedDataList) {
        final associatedDatumJson = associatedDatum.toJson();
        final dateString = associatedDatumJson['date'];

        if (dateString != null && dateString.isNotEmpty) {
          final updatedDateString = convertDateString(dateString);

          if (updatedDateString != dateString) {
            associatedDatumJson['date'] = updatedDateString;
            final updatedAssociatedDatum =
                AssociatedDataData.fromJson(associatedDatumJson);
            AssociatedDataQuery(db).updateAssociatedData(
                updatedAssociatedDatum.primaryId as int,
                updatedAssociatedDatum.toCompanion(false));
          }
        }
      }
    }
  }
}

Future<void> migrateNarrativeDateTimeFormat(Migrator m) async {
  final db = m.database as Database;
  final projects = await ProjectQuery(db).getAllProjects();

  for (final projectData in projects) {
    final narrativeList =
        await NarrativeQuery(db).getAllNarrative(projectData.uuid);

    for (final narrativeData in narrativeList) {
      final narrativeJson = narrativeData.toJson();
      final dateString = narrativeJson['date'];

      if (dateString != null && dateString.isNotEmpty) {
        final updatedDateString = convertDateString(dateString);

        if (updatedDateString != dateString) {
          narrativeJson['date'] = updatedDateString;
          final updatedNarrativeData = NarrativeData.fromJson(narrativeJson);
          NarrativeQuery(db).updateNarrativeEntry(
              updatedNarrativeData.id, updatedNarrativeData.toCompanion(false));
        }
      }
    }
  }
}

Future<void> migrateCollEventDateTimeFormat(Migrator m) async {
  final db = m.database as Database;
  final projects = await ProjectQuery(db).getAllProjects();

  final collEventDateFields = ['startDate', 'endDate'];
  final collEventTimeFields = ['startTime', 'endTime'];

  for (final projectData in projects) {
    final eventList =
        await CollEventQuery(db).getAllCollEvents(projectData.uuid);

    for (final eventData in eventList) {
      bool doUpdate = false;
      final eventJson = eventData.toJson();

      for (final field in collEventDateFields) {
        final dateString = eventJson[field];

        if (dateString != null && dateString.isNotEmpty) {
          final updatedDateString = convertDateString(dateString);

          if (updatedDateString != dateString) {
            doUpdate = true;
            eventJson[field] = updatedDateString;
          }
        }
      }

      for (final field in collEventTimeFields) {
        final timeString = eventJson[field];

        if (timeString != null && timeString.isNotEmpty) {
          final updatedTimeString = convertTimeString(timeString);

          if (updatedTimeString != timeString) {
            doUpdate = true;
            eventJson[field] = updatedTimeString;
          }
        }
      }

      if (doUpdate) {
        final updatedEventData = CollEventData.fromJson(eventJson);
        CollEventQuery(db).updateCollEventEntry(
            updatedEventData.id, updatedEventData.toCompanion(false));
      }
    }
  }
}
