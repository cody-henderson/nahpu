import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/projects/personnel/new_personnel.dart';
import 'package:nahpu/services/project_services.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/providers/projects.dart';
import 'package:nahpu/services/providers/taxa.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:flutter/material.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:drift/drift.dart' as db;
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/screens/specimens/shared/taxa.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/personnel_services.dart';
import 'package:nahpu/services/specimen_services.dart';

class GeneralRecordField extends ConsumerStatefulWidget {
  const GeneralRecordField({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
    required this.useHorizontalLayout,
  });

  final SpecimenFormCtrModel specimenCtr;
  final String specimenUuid;
  final bool useHorizontalLayout;

  @override
  GeneralRecordFieldState createState() => GeneralRecordFieldState();
}

class GeneralRecordFieldState extends ConsumerState<GeneralRecordField> {
  List<PersonnelData> personnelList = [];

  bool _showMore = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final personnelEntry = ref.watch(projectPersonnelProvider);
    personnelEntry.whenData(
      (personnelEntry) => personnelList = personnelEntry,
    );
    return FormCard(
      title: 'General Records',
      isPrimary: true,
      infoContent: const CollRecordInfoContent(),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      child: Column(
        children: [
          PersonnelRecords(
            specimenUuid: widget.specimenUuid,
            specimenCtr: widget.specimenCtr,
            showMore: _showMore,
          ),
          SpeciesFieldCtr(
            specimenUuid: widget.specimenUuid,
            speciesCtr: widget.specimenCtr.speciesCtr,
          ),
          IDConfidence(
            specimenUuid: widget.specimenUuid,
            specimenCtr: widget.specimenCtr,
          ),
          Visibility(
            visible:
                _showMore || widget.specimenCtr.idMethodCtr.text.isNotEmpty,
            child: IDMethod(
                specimenUuid: widget.specimenUuid,
                specimenCtr: widget.specimenCtr),
          ),
          SpecimenConditionField(
            specimenCtr: widget.specimenCtr,
            specimenUuid: widget.specimenUuid,
          ),
          AdaptiveLayout(
              useHorizontalLayout: widget.useHorizontalLayout,
              children: [
                SpecimenCollectionDateField(
                  specimenCtr: widget.specimenCtr,
                  specimenUuid: widget.specimenUuid,
                ),
                SpecimenCollectionTimeField(
                  specimenCtr: widget.specimenCtr,
                  specimenUuid: widget.specimenUuid,
                ),
              ]),
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              PrepDateField(
                specimenCtr: widget.specimenCtr,
                specimenUuid: widget.specimenUuid,
              ),
              PrepTimeField(
                specimenCtr: widget.specimenCtr,
                specimenUuid: widget.specimenUuid,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextButton(
              onPressed: () {
                setState(
                  () {
                    _showMore = !_showMore;
                  },
                );
              },
              child: Text(_showMore ? 'Show less' : 'Show more'),
            ),
          ),
        ],
      ),
    );
  }
}

class SpeciesFieldCtr extends ConsumerWidget {
  const SpeciesFieldCtr({
    super.key,
    required this.specimenUuid,
    required this.speciesCtr,
  });

  final String specimenUuid;
  final int? speciesCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(taxonProvider).when(
          data: (taxa) {
            if (taxa.isEmpty) {
              return const DisabledSpeciesField();
            }
            return SpeciesInputField(
              specimenUuid: specimenUuid,
              speciesCtr: speciesCtr,
              taxonList: taxa,
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => const Text('Error loading taxa'),
        );
  }
}

class IDConfidence extends ConsumerWidget {
  const IDConfidence({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonPadding(
        child: DropdownButtonFormField<int?>(
      initialValue: specimenCtr.idConfidenceCtr,
      onChanged: (int? value) {
        SpecimenServices(ref: ref).updateSpecimen(
          specimenUuid,
          SpecimenCompanion(iDConfidence: db.Value(value)),
        );
      },
      decoration: const InputDecoration(
        labelText: 'ID Confidence',
        hintText: 'Choose a confidence level',
      ),
      items: idConfidenceList.reversed
          .map((e) => DropdownMenuItem<int?>(
              value: idConfidenceList.indexOf(e),
              child: CommonDropdownText(text: e)))
          .toList(),
    ));
  }
}

class IDMethod extends ConsumerWidget {
  const IDMethod({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = SpecimenServices(ref: ref);
    return CommonPadding(
        child: TextField(
      controller: specimenCtr.idMethodCtr,
      decoration: const InputDecoration(
        labelText: 'ID Method',
        hintText: 'Enter ID method',
      ),
      onChanged: (value) {
        if (value.isNotEmpty) {
          service.updateSpecimenSkipInvalidation(
            specimenUuid,
            SpecimenCompanion(iDMethod: db.Value(value)),
          );
        }
      },
      onSubmitted: (_) => service.invalidateSpecimenList(),
    ));
  }
}

class SpecimenCollectionDateField extends ConsumerWidget {
  const SpecimenCollectionDateField({
    super.key,
    required this.specimenCtr,
    required this.specimenUuid,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonDateField(
        controller: specimenCtr.collDateCtr,
        labelText: 'Collection date',
        hintText: 'Enter date',
        initialDate: DateTime.now(),
        lastDate: DateTime.now(),
        onTap: () {
          SpecimenServices(ref: ref).updateSpecimen(
            specimenUuid,
            SpecimenCompanion(
                collectionDate: db.Value(
              specimenCtr.collDateCtr.date,
            )),
          );
        },
        onClear: () {
          SpecimenServices(ref: ref).updateSpecimen(
            specimenUuid,
            SpecimenCompanion(collectionDate: db.Value(null)),
          );
        });
  }
}

class SpecimenCollectionTimeField extends ConsumerWidget {
  const SpecimenCollectionTimeField({
    super.key,
    required this.specimenCtr,
    required this.specimenUuid,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonTimeField(
        controller: specimenCtr.collTimeCtr,
        labelText: 'Collection time',
        hintText: 'Enter time',
        initialTime: TimeOfDay.now(),
        onTap: () {
          SpecimenServices(ref: ref).updateSpecimen(
            specimenUuid,
            SpecimenCompanion(
                collectionTime: db.Value(
              specimenCtr.collTimeCtr.time,
            )),
          );
        },
        onClear: () {
          SpecimenServices(ref: ref).updateSpecimen(
              specimenUuid, SpecimenCompanion(collectionTime: db.Value(null)));
        });
  }
}

class SpecimenConditionField extends ConsumerWidget {
  const SpecimenConditionField({
    super.key,
    required this.specimenCtr,
    required this.specimenUuid,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonPadding(
        child: DropdownButtonFormField(
      initialValue: specimenCtr.conditionCtr,
      onChanged: (String? value) {
        SpecimenServices(ref: ref).updateSpecimen(
          specimenUuid,
          SpecimenCompanion(condition: db.Value(value)),
        );
      },
      decoration: const InputDecoration(
        labelText: 'Condition',
        hintText: 'Choose a condition',
      ),
      items: conditionList
          .map((String condition) => DropdownMenuItem(
                value: condition,
                child: CommonDropdownText(text: condition),
              ))
          .toList(),
    ));
  }
}

class PrepDateField extends ConsumerWidget {
  const PrepDateField({
    super.key,
    required this.specimenCtr,
    required this.specimenUuid,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonDateField(
        controller: specimenCtr.prepDateCtr,
        labelText: 'Prep. date',
        hintText: 'Enter date',
        initialDate: DateTime.now(),
        lastDate: DateTime.now(),
        onTap: () {
          SpecimenServices(ref: ref).updateSpecimen(
            specimenUuid,
            SpecimenCompanion(
              prepDate: db.Value(specimenCtr.prepDateCtr.date),
            ),
          );
        },
        onClear: () {
          SpecimenServices(ref: ref).updateSpecimen(
            specimenUuid,
            SpecimenCompanion(prepDate: db.Value(null)),
          );
        });
  }
}

class PrepTimeField extends ConsumerWidget {
  const PrepTimeField({
    super.key,
    required this.specimenCtr,
    required this.specimenUuid,
  });

  final String specimenUuid;
  final SpecimenFormCtrModel specimenCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonTimeField(
        controller: specimenCtr.prepTimeCtr,
        labelText: 'Prep. time',
        hintText: 'Enter time',
        initialTime: TimeOfDay.now(),
        onTap: () {
          SpecimenServices(ref: ref).updateSpecimen(
            specimenUuid,
            SpecimenCompanion(
              prepTime: db.Value(specimenCtr.prepTimeCtr.time),
            ),
          );
        },
        onClear: () {
          SpecimenServices(ref: ref).updateSpecimen(
              specimenUuid, SpecimenCompanion(prepTime: db.Value(null)));
        });
  }
}

class PersonnelRecords extends ConsumerStatefulWidget {
  const PersonnelRecords({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
    required this.showMore,
  });

  final SpecimenFormCtrModel specimenCtr;
  final String specimenUuid;
  final bool showMore;

  @override
  PersonnelRecordsState createState() => PersonnelRecordsState();
}

class PersonnelRecordsState extends ConsumerState<PersonnelRecords> {
  final Set<String> _selectedPersonnel = {};

  @override
  Widget build(BuildContext context) {
    final projectInfo = ref.watch(currProjInfoProvider);

    return projectInfo.when(
        data: (project) {
          final usePersonalNumber = project.usePersonalNumber ?? true;
          final useProjectNumber = project.useProjectNumber ?? false;
          return CommonPadding(
            child: Column(
              children: [
                (usePersonalNumber ||
                        useProjectNumber ||
                        widget.showMore ||
                        widget.specimenCtr.museumIDCtr.text.isNotEmpty)
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: IdTile(
                          specimenUuid: widget.specimenUuid,
                          specimenCtr: widget.specimenCtr,
                          catalogerUuid: widget.specimenCtr.catalogerCtr ?? '',
                          showMore: widget.showMore,
                          usePersonalNumber: usePersonalNumber,
                          useProjectNumber: useProjectNumber,
                        ))
                    : const SizedBox.shrink(),
                DropdownButtonFormField<String>(
                    initialValue: widget.specimenCtr.catalogerCtr,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Cataloger',
                      hintText: 'Choose a cataloger',
                      hintStyle: TextStyle(overflow: TextOverflow.ellipsis),
                    ),
                    items: ref.watch(projectPersonnelProvider).when(
                          data: (data) => data
                              .where((element) => element.role == 'Cataloger')
                              .map((e) => DropdownMenuItem(
                                    value: e.uuid,
                                    child:
                                        CommonDropdownText(text: e.name ?? ''),
                                  ))
                              .toList(),
                          loading: () => const [],
                          error: (e, s) => const [],
                        ),
                    onChanged: (String? personnelUuid) async {
                      _setPersonalFieldNumber(personnelUuid, usePersonalNumber);
                    }),
                DropdownButtonFormField<String>(
                  initialValue: widget.specimenCtr.preparatorCtr,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Preparator',
                    hintText: 'Choose a preparator (default is cataloger)',
                    hintStyle: TextStyle(overflow: TextOverflow.ellipsis),
                  ),
                  items: ref.watch(projectPersonnelProvider).when(
                        data: (data) => data
                            .where((element) =>
                                element.role == 'Cataloger' ||
                                element.role == 'Preparator only')
                            .map((e) => DropdownMenuItem(
                                  value: e.uuid,
                                  child: CommonDropdownText(text: e.name ?? ''),
                                ))
                            .toList(),
                        loading: () => const [],
                        error: (e, s) => const [],
                      ),
                  onChanged: (String? uuid) {
                    SpecimenServices(ref: ref).updateSpecimen(
                      widget.specimenUuid,
                      SpecimenCompanion(preparatorID: db.Value(uuid)),
                    );
                  },
                )
              ],
            ),
          );
        },
        loading: () => const Text('Loading...'),
        error: (error, stack) => Text('Error: $error'));
  }

  Future<void> _setPersonalFieldNumber(
      String? personnelUuid, bool usePersonalNumber) async {
    if (personnelUuid != null && usePersonalNumber) {
      final personnelData =
          await PersonnelServices(ref: ref).getPersonnelByUuid(personnelUuid);
      int personalFieldNumber = await _getCurrentCollectorNumber(personnelUuid);
      setState(() {
        bool hasSelected = _selectedPersonnel.contains(personnelUuid);
        int? currentFieldNumber = personnelData.isRegisterField
            ? (hasSelected ? personalFieldNumber - 1 : personalFieldNumber)
            : null;
        widget.specimenCtr.catalogerCtr = personnelUuid;
        widget.specimenCtr.preparatorCtr = personnelUuid;
        widget.specimenCtr.persFieldNumberCtr.text =
            currentFieldNumber.toString();

        if (!hasSelected) {
          PersonnelServices(ref: ref).updatePersonnelEntry(
              personnelUuid,
              PersonnelCompanion(
                  currentFieldNumber: db.Value(personalFieldNumber + 1)));
          _selectedPersonnel.add(personnelUuid);
        }
        SpecimenServices(ref: ref).updateSpecimen(
          widget.specimenUuid,
          SpecimenCompanion(
            catalogerID: db.Value(personnelUuid),
            fieldNumber: db.Value(
              currentFieldNumber,
            ),
            preparatorID: db.Value(personnelUuid),
          ),
        );
      });
    }
  }

  Future<int> _getCurrentCollectorNumber(String personnelUuid) async {
    int fieldNumber = await SpecimenServices(ref: ref).getSpecimenFieldNumber(
      personnelUuid,
    );

    return fieldNumber;
  }
}

class IdTile extends ConsumerWidget {
  const IdTile({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
    required this.catalogerUuid,
    required this.showMore,
    required this.usePersonalNumber,
    required this.useProjectNumber,
  });

  final SpecimenFormCtrModel specimenCtr;
  final bool showMore;
  final String specimenUuid;
  final String catalogerUuid;
  final bool usePersonalNumber;
  final bool useProjectNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible: useProjectNumber ||
          (usePersonalNumber && catalogerUuid != '') ||
          showMore ||
          specimenCtr.museumIDCtr.text.isNotEmpty,
      child: CommonIDForm(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Visibility(
                visible: showMore || specimenCtr.museumIDCtr.text.isNotEmpty,
                child: CommonTextField(
                  controller: specimenCtr.museumIDCtr,
                  labelText: 'Museum ID',
                  hintText: 'Enter museum ID (if applicable)',
                  isLastField: true,
                  onChanged: (String? value) {
                    if (value != null) {
                      SpecimenServices(ref: ref).updateSpecimenSkipInvalidation(
                        specimenUuid,
                        SpecimenCompanion(
                          museumID: db.Value(value),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            SpecimenIdTile(
              specimenUuid: specimenUuid,
              specimenCtr: specimenCtr,
              catalogerUuid: catalogerUuid,
              usePersonalNumber: usePersonalNumber,
              useProjectNumber: useProjectNumber,
            ),
          ],
        ),
      ),
    );
  }
}

class SpecimenIdTile extends ConsumerWidget {
  const SpecimenIdTile({
    super.key,
    required this.specimenUuid,
    required this.specimenCtr,
    required this.catalogerUuid,
    required this.usePersonalNumber,
    required this.useProjectNumber,
  });

  final SpecimenFormCtrModel specimenCtr;
  final String specimenUuid;
  final String catalogerUuid;
  final bool usePersonalNumber;
  final bool useProjectNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personnelInfo = ref.watch(personnelNameProvider(catalogerUuid));
    return Column(children: [
      Visibility(
        visible: (usePersonalNumber && catalogerUuid != ''),
        child: personnelInfo.when(
            data: (personnelInfo) => ListTile(
                  title: Text(_fieldIdString(
                      personnelInfo, specimenCtr.persFieldNumberCtr.text)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Visibility(
                      visible: !personnelInfo.isRegisterField,
                      child: IconButton(
                        icon: Icon(
                          Icons.person,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditPersonnelForm(
                                        personnelData: personnelInfo,
                                      )));
                        },
                      ),
                    ),
                    Visibility(
                      visible: personnelInfo.isRegisterField,
                      child: IconButton(
                        icon: Icon(
                          Icons.edit_outlined,
                          color: Theme.of(context).disabledColor,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Edit field number'),
                                content: TextField(
                                  controller: specimenCtr.persFieldNumberCtr,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Field number',
                                    hintText: 'Enter field number',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      int fieldNumber = int.parse(
                                          specimenCtr.persFieldNumberCtr.text);
                                      int nextFieldNumber = fieldNumber + 1;
                                      await PersonnelServices(ref: ref)
                                          .updatePersonnelEntry(
                                              catalogerUuid,
                                              PersonnelCompanion(
                                                  currentFieldNumber: db.Value(
                                                      nextFieldNumber)));
                                      await SpecimenServices(ref: ref)
                                          .updateSpecimen(
                                        specimenUuid,
                                        SpecimenCompanion(
                                          fieldNumber: db.Value(
                                            fieldNumber,
                                          ),
                                        ),
                                      );

                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    )
                  ]),
                ),
            loading: () => const Text('Loading...'),
            error: (error, stack) => Text('Error: $error')),
      ),
      Visibility(
        visible: useProjectNumber,
        child: ListTile(
          title: Text(
            'Project ID: ${specimenCtr.projFieldNumberCtr.text}',
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: Theme.of(context).disabledColor,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Edit project number'),
                    content: TextField(
                      controller: specimenCtr.projFieldNumberCtr,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Project number',
                        hintText: 'Enter project number',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          int projectNumber =
                              int.parse(specimenCtr.projFieldNumberCtr.text);
                          int nextProjectNumber = projectNumber + 1;
                          ProjectServices(ref: ref).updateProject(
                              await ref.read(projectUuidProvider),
                              ProjectCompanion(
                                  currentFieldNumber:
                                      db.Value(nextProjectNumber)));
                          await SpecimenServices(ref: ref).updateSpecimen(
                            specimenUuid,
                            SpecimenCompanion(
                              projectFieldNumber: db.Value(
                                projectNumber,
                              ),
                            ),
                          );

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      )
    ]);
  }

  String _fieldIdString(PersonnelData personnelInfo, String currentFieldNum) {
    if (personnelInfo.isRegisterField) {
      return 'Field ID: ${personnelInfo.initial}$currentFieldNum';
    } else {
      return 'Field ID: (cataloger not setup for field numbers)';
    }
  }
}

class CollRecordInfoContent extends StatelessWidget {
  const CollRecordInfoContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoContainer(content: [
      InfoContent(
        header: 'Overview',
        content: 'General record of the specimen. '
            'Field ID is auto-generated based on the'
            ' cataloger\'s current field number.'
            ' Use the edit button to override the field number.',
      ),
      InfoContent(
        header: 'Cataloger and preparator fields',
        content: 'By default, the cataloger is the preparator.'
            ' If the preparator is different, '
            'select the preparator from the dropdown.',
      ),
      InfoContent(
        header: 'Species field',
        content: 'Type the species name to search for it in the taxon registry.'
            ' You can start by typing the epithet to simplify the search.'
            'The species field will be disabled if no'
            ' taxa are registered in the project.'
            ' You can add a taxon in the taxon registry section in the project dashboard.',
      ),
      InfoContent(
          header: 'Condition field',
          content:
              'The condition field is a qualitative measure of the freshness'
              ' of the specimen at time of prep.'
              ' Condition can depend on factors including time since death,'
              ' temperature, sun exposure (especially for salvage specimens), etc.'
              ' If the collection time (i.e., time of death) and prep times are known,'
              ' these can also be added for a more quantitative'
              ' measure of condition at time of prep.'),
    ]);
  }
}
