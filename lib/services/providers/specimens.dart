import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/database/media_queries.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/utility_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'specimens.g.dart';

const String specimenTypePrefKey = 'specimenTypes';
const String specimenTypeFmtPrefKey = 'specimenTypeFmt';
const String treatmentPrefKey = 'specimenTreatment';
const String treatmentFmtPrefKey = 'treatmentFmt';
const String catalogFmtPrefKey = 'catalogFmt';

@riverpod
class CatalogFmtNotifier extends _$CatalogFmtNotifier {
  Future<CatalogFmt> _fetchSetting() async {
    final prefs = ref.watch(settingProvider);
    final savedFmt = prefs.getString(catalogFmtPrefKey);

    // Set to default general mammals if no setting is found
    final CatalogFmt currentFmt = matchTaxonGroupToCatFmt(savedFmt);
    if (savedFmt == null) {
      await prefs.setString(
          catalogFmtPrefKey, matchCatFmtToTaxonGroup(currentFmt));
    }

    return currentFmt;
  }

  @override
  FutureOr<CatalogFmt> build() async {
    return await _fetchSetting();
  }

  Future<void> set(CatalogFmt fmt) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      final value = prefs.getString(catalogFmtPrefKey);
      final setFmt = matchTaxonGroupToCatFmt(value);
      if (setFmt == fmt) return fmt;
      await prefs.setString(catalogFmtPrefKey, matchCatFmtToTaxonGroup(fmt));
      ref.invalidate(catalogFmtProvider);
      return fmt;
    });
  }
}

final catalogFmtProvider = Provider<CatalogFmt>((ref) {
  final prefs = ref.watch(settingProvider);
  return matchTaxonGroupToCatFmt(prefs.getString(catalogFmtPrefKey));
});

class FossilAwareStruct {
  const FossilAwareStruct({required this.isFossils});

  final bool isFossils;

  static const _fossilAwareValues = <bool, Map<String, Map<String, String>>>{
    false: {
      'siteName': {'singular': 'site', 'plural': 'sites'}
    },
    true: {
      'siteName': {'singular': 'locality', 'plural': 'localities'}
    }
  };

  String get siteName {
    return _fossilAwareValues[isFossils]!['siteName']!['singular']!;
  }

  String get siteNamePlural {
    return _fossilAwareValues[isFossils]!['siteName']!['plural']!;
  }
}

final fossilAwareProvider = Provider<FossilAwareStruct>((ref) {
  final fmt = ref.watch(catalogFmtProvider);
  return FossilAwareStruct(isFossils: fmt == CatalogFmt.fossils);
});

mixin FossilAware {
  WidgetRef get ref;
  FossilAwareStruct get struct => ref.watch(fossilAwareProvider);

  String get siteName => struct.siteName;
  String get siteNamePlural => struct.siteNamePlural;
}

@riverpod
class SpecimenEntry extends _$SpecimenEntry {
  Future<List<SpecimenData>> _fetchSpecimenEntry() async {
    final projectUuid = ref.watch(projectUuidProvider);

    final specimenEntries = await SpecimenQuery(ref.read(databaseProvider))
        .getAllSpecimens(projectUuid);

    return specimenEntries;
  }

  @override
  FutureOr<List<SpecimenData>> build() async {
    return await _fetchSpecimenEntry();
  }
}

final partBySpecimenProvider = FutureProvider.family
    .autoDispose<List<SpecimenPartData>, String>((ref, specimenUuid) =>
        SpecimenPartQuery(ref.read(databaseProvider))
            .getSpecimenParts(specimenUuid));

@riverpod
Future<List<AssociatedDataData>> associatedData(Ref ref,
    {required String specimenUuid}) async {
  final associatedDataEntries =
      await AssociatedDataQuery(ref.read(databaseProvider))
          .getAllAssociatedData(specimenUuid);

  return associatedDataEntries;
}

@riverpod
Future<List<MediaData>> specimenMedia(Ref ref,
    {required String specimenUuid}) async {
  List<SpecimenMediaData> mediaList =
      await SpecimenQuery(ref.read(databaseProvider))
          .getSpecimenMedia(specimenUuid);
  List<MediaData> mediaDataList = [];
  for (SpecimenMediaData media in mediaList) {
    if (media.mediaId != null) {
      mediaDataList.add(
        await MediaDbQuery(ref.read(databaseProvider)).getMedia(media.mediaId!),
      );
    }
  }
  return mediaDataList;
}

@riverpod
class SpecimenTypes extends _$SpecimenTypes {
  Future<List<String>> _fetchSettings() async {
    final prefs = ref.watch(settingProvider);
    final typeList = prefs.getStringList(specimenTypePrefKey);

    List<String> currentTypes = typeList ?? defaultSpecimenType;

    if (typeList == null) {
      await prefs.setStringList(specimenTypePrefKey, currentTypes);
    }

    return currentTypes;
  }

  @override
  FutureOr<List<String>> build() async {
    return await _fetchSettings();
  }

  Future<void> add(String type) async {
    if (type.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      final typeList = prefs.getStringList(specimenTypePrefKey);
      if (typeList != null && isListContains(typeList, type)) {
        return typeList;
      }

      List<String> newList = [...typeList ?? [], type];
      await prefs.setStringList(specimenTypePrefKey, newList);
      return newList;
    });
  }

  Future<void> replaceAll(List<String> newSpecimenTypes) async {
    if (newSpecimenTypes.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      await prefs.setStringList(specimenTypePrefKey, newSpecimenTypes);
      return newSpecimenTypes;
    });
  }

  Future<void> remove(String type) async {
    if (type.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      final typeList = prefs.getStringList(specimenTypePrefKey);
      if (typeList == null || typeList.isEmpty) return [];

      if (!isListContains(typeList, type)) {
        return typeList;
      }

      List<String> newList = [...typeList]..remove(type);
      await prefs.setStringList(specimenTypePrefKey, newList);
      return newList;
    });
  }

  Future<void> clear() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      await prefs.remove(specimenTypePrefKey);
      return [];
    });
  }
}

@riverpod
class TreatmentOptions extends _$TreatmentOptions {
  Future<List<String>> _fetchSettings() async {
    final prefs = ref.watch(settingProvider);
    final treatmentList = prefs.getStringList(treatmentPrefKey);

    List<String> currentTreatments = treatmentList ?? defaultTreatment;

    if (treatmentList == null) {
      await prefs.setStringList(treatmentPrefKey, currentTreatments);
    }

    return currentTreatments;
  }

  @override
  FutureOr<List<String>> build() async {
    return await _fetchSettings();
  }

  Future<void> add(String treatment) async {
    if (treatment.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      final treatmentList = prefs.getStringList(treatmentPrefKey);
      if (treatmentList != null && isListContains(treatmentList, treatment)) {
        return treatmentList;
      }

      List<String> newList = [...treatmentList ?? [], treatment];
      await prefs.setStringList(treatmentPrefKey, newList);
      return newList;
    });
  }

  Future<void> replaceAll(List<String> newTreatments) async {
    if (newTreatments.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      await prefs.setStringList(treatmentPrefKey, newTreatments);
      return newTreatments;
    });
  }

  Future<void> remove(String treatment) async {
    if (treatment.isEmpty) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      final treatmentList = prefs.getStringList(treatmentPrefKey);

      // We don't need to delete if the list is null
      // or doesn't contain the item
      if (treatmentList == null || treatmentList.isEmpty) return [];

      if (!isListContains(treatmentList, treatment)) {
        return treatmentList;
      }

      List<String> newList = [...treatmentList]..remove(treatment);
      await prefs.setStringList(treatmentPrefKey, newList);
      return newList;
    });
  }

  Future<void> clear() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final prefs = ref.watch(settingProvider);
      await prefs.remove(treatmentPrefKey);
      return [];
    });
  }
}
