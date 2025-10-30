import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/screens/shared/features.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/services/narrative_services.dart';

class SiteForm extends ConsumerWidget {
  const SiteForm({
    super.key,
    required this.narrativeId,
    required this.narrativeCtr,
  });

  final int narrativeId;
  final NarrativeFormCtrModel narrativeCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<SiteData> data = [];
    final siteEntry = ref.watch(siteEntryProvider);
    siteEntry.whenData(
      (siteEntry) => data = siteEntry,
    );
    return SiteIdField(
      value: narrativeCtr.siteCtr,
      siteData: data,
      onChanges: (int? value) {
        NarrativeServices(ref: ref).updateNarrative(
          narrativeId,
          NarrativeCompanion(siteID: db.Value(value)),
        );
      },
    );
  }
}

class DateForm extends ConsumerWidget {
  const DateForm({
    super.key,
    required this.narrativeId,
    required this.narrativeCtr,
  });

  final int narrativeId;
  final NarrativeFormCtrModel narrativeCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonDateField(
      labelText: 'Date',
      hintText: 'Enter date',
      initialDate: DateTime.now(),
      lastDate: DateTime.now(),
      controller: narrativeCtr.dateCtr,
      onTap: () {
        // If time is set, combine date and time into a single datetime string
        String? dateStd = narrativeCtr.dateCtr.date;
        String? timeStd = narrativeCtr.timeCtr.time;
        String? combined;
        if (dateStd != null && dateStd.isNotEmpty && timeStd != null && timeStd.isNotEmpty) {
          combined = '\$dateStd \$timeStd';
        } else {
          combined = dateStd;
        }
        NarrativeServices(ref: ref).updateNarrative(
          narrativeId,
          NarrativeCompanion(date: db.Value(combined)),
        );
      },
      onClear: () {
        // Clearing date should remove the stored date (and time)
        narrativeCtr.timeCtr.time = null;
        NarrativeServices(ref: ref).updateNarrative(
          narrativeId,
          NarrativeCompanion(date: db.Value(null)),
        );
      }
    );
  }
}

class TimeForm extends ConsumerWidget {
  const TimeForm({
    super.key,
    required this.narrativeId,
    required this.narrativeCtr,
  });

  final int narrativeId;
  final NarrativeFormCtrModel narrativeCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonTimeField(
      labelText: 'Time',
      hintText: 'Enter time',
      initialTime: TimeOfDay.now(),
      controller: narrativeCtr.timeCtr,
      onTap: () {
        // Combine with date if available
        String? dateStd = narrativeCtr.dateCtr.date;
        String? timeStd = narrativeCtr.timeCtr.time;
        String? combined;
        if (dateStd != null && dateStd.isNotEmpty && timeStd != null && timeStd.isNotEmpty) {
          combined = '$dateStd $timeStd';
        } else if (timeStd != null && timeStd.isNotEmpty) {
          // If only time set, store as today with time
          final today = DateTime.now();
          final dateOnly = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
          combined = '$dateOnly $timeStd';
        }
        NarrativeServices(ref: ref).updateNarrative(
          narrativeId,
          NarrativeCompanion(date: db.Value(combined)),
        );
      },
      onClear: () {
        // Clearing time keeps date only
        NarrativeServices(ref: ref).updateNarrative(
          narrativeId,
          NarrativeCompanion(date: db.Value(narrativeCtr.dateCtr.date)),
        );
      },
    );
  }
}

class WriterForm extends ConsumerWidget {
  const WriterForm({
    super.key,
    required this.narrativeId,
    required this.narrativeCtr,
  });

  final int narrativeId;
  final NarrativeFormCtrModel narrativeCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<PersonnelData> personnelList = [];
    final personnelEntry = ref.watch(projectPersonnelProvider);
    personnelEntry.whenData(
      (personnelEntry) => personnelList = personnelEntry,
    );

    return DropdownButtonFormField<String?>(
      initialValue: narrativeCtr.writerCtr,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Writer',
        hintText: 'Choose a person name',
      ),
      items: personnelList
          .map(
            (e) => DropdownMenuItem(
              value: e.uuid,
              child: CommonDropdownText(text: e.name ?? ''),
            ),
          )
          .toList(),
      onChanged: (String? uuid) async {
        narrativeCtr.writerCtr = uuid;
        await NarrativeServices(ref: ref).updateNarrativeWriter(narrativeId, uuid);
      },
    );
  }
}