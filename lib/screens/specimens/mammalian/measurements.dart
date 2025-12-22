import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/screens/specimens/shared/measurements.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/specimen_services.dart';
import 'package:nahpu/services/types/mammals.dart';
import 'package:drift/drift.dart' as db;

class MammalMeasurementForms extends ConsumerStatefulWidget {
  const MammalMeasurementForms({
    super.key,
    required this.useHorizontalLayout,
    required this.specimenUuid,
  });

  final bool useHorizontalLayout;
  final String specimenUuid;

  @override
  MammalMeasurementFormsState createState() => MammalMeasurementFormsState();
}

class MammalMeasurementFormsState
    extends ConsumerState<MammalMeasurementForms> {
  MammalMeasurementCtrModel ctr = MammalMeasurementCtrModel.empty();
  TextEditingController headBodyLengthCtr = TextEditingController();
  TextEditingController tailHeadBodyPercentCtr = TextEditingController();
  String? _hblErrorText;
  bool _showBatFields = false;
  bool _showEcholocateFields = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCtr(widget.specimenUuid);
    });
  }

  @override
  void dispose() {
    ctr.dispose();
    headBodyLengthCtr.dispose();
    tailHeadBodyPercentCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MeasurementForm(
      children: [
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            CommonNumField(
              controller: ctr.totalLengthCtr,
              labelText: 'Total length (mm)',
              hintText: 'Enter TTL',
              isLastField: false,
              isDouble: true,
              errorText: _hblErrorText,
              onChanged: (String? value) {
                setState(() {
                  _getHBTailPercent();
                  updateMeasurement(widget.specimenUuid, ref, #totalLength,
                      double, value, true);
                });
              },
            ),
            CommonNumField(
              controller: ctr.tailLengthCtr,
              labelText: 'Tail length (mm)',
              hintText: 'Enter TL',
              isDouble: true,
              isLastField: false,
              errorText: _hblErrorText,
              onChanged: (String? value) {
                setState(() {
                  _getHBTailPercent();
                  updateMeasurement(widget.specimenUuid, ref, #tailLength,
                      double, value, true);
                });
              },
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            Tooltip(
              message: 'Automatically calculated',
              child: CommonNumField(
                controller: headBodyLengthCtr,
                labelText: 'Head and body length (mm)',
                hintText: 'Enter HBL',
                enabled: false,
                isDouble: true,
                isLastField: false,
                onChanged: null,
              ),
            ),
            Tooltip(
              message: 'Automatically calculated',
              child: CommonNumField(
                controller: tailHeadBodyPercentCtr,
                labelText: 'Tail/HB length',
                hintText: 'Enter TL/HBL',
                enabled: false,
                isDouble: true,
                isLastField: false,
                onChanged: null,
              ),
            ),
          ],
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            CommonNumField(
              controller: ctr.hindFootCtr,
              labelText: 'Hind foot length (mm)',
              hintText: 'Enter HF length',
              isDouble: true,
              isLastField: false,
              onChanged: (String? value) {
                if (value != null && value.isNotEmpty) {
                  setState(() {
                    updateMeasurement(widget.specimenUuid, ref, #hindFootLength,
                        double, value);
                  });
                }
              },
            ),
            CommonNumField(
              controller: ctr.earCtr,
              labelText: 'Ear length (mm)',
              hintText: 'Enter ER length',
              isLastField: false,
              isDouble: true,
              onChanged: (String? value) {
                if (value != null && value.isNotEmpty) {
                  setState(() {
                    updateMeasurement(
                        widget.specimenUuid, ref, #earLength, double, value);
                  });
                }
              },
            ),
          ],
        ),
        AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              CommonNumField(
                controller: ctr.weightCtr,
                labelText: 'Weight (grams)',
                hintText: 'Enter specimen weight',
                isDouble: true,
                isLastField: false,
                onChanged: (value) {
                  if (value != null && value.isNotEmpty) {
                    setState(() {
                      updateMeasurement(
                          widget.specimenUuid, ref, #weight, double, value);
                    });
                  }
                },
              ),
            ]),
        Padding(
            padding: const EdgeInsets.all(5),
            child: SwitchField(
                label: 'Show bat fields',
                value: _showBatFields,
                // Disable the button when bat fields are
                // always shown based on app-wide setting
                disabled: isBatFieldsAlwaysShown,
                onPressed: (value) {
                  setState(() {
                    _showBatFields = value;
                    updateMeasurement(
                        widget.specimenUuid, ref, #showBatFields, bool, value);
                  });
                })),
        Visibility(
            visible: _showBatFields,
            child: AdaptiveLayout(
                useHorizontalLayout: widget.useHorizontalLayout,
                children: [
                  CommonNumField(
                    controller: ctr.forearmCtr,
                    labelText: 'Forearm Length (mm)',
                    hintText: 'Enter FL length',
                    isLastField: true,
                    isDouble: true,
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        setState(() {
                          updateMeasurement(widget.specimenUuid, ref, #forearm,
                              double, value);
                        });
                      }
                    },
                  ),
                  CommonNumField(
                    controller: ctr.forearmCtr,
                    labelText: 'Forearm Length (mm)',
                    hintText: 'Enter FL length',
                    isLastField: true,
                    isDouble: true,
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        setState(() {
                          updateMeasurement(widget.specimenUuid, ref, #forearm,
                              double, value);
                        });
                      }
                    },
                  ),
                ])),
        Padding(
            padding: const EdgeInsets.all(5),
            child: SwitchField(
                label: 'Echolocate?',
                value: _showEcholocateFields,
                onPressed: (value) {
                  setState(() {
                    _showEcholocateFields = value;
                  });
                })),
        Padding(
          padding: const EdgeInsets.all(5),
          child: DropdownButtonFormField(
              initialValue: ctr.accuracyCtr,
              decoration: const InputDecoration(
                labelText: 'Accuracy',
                hintText: 'Select measurement accuracy',
              ),
              items: accuracyList
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: CommonDropdownText(text: e),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                ctr.accuracyCtr = newValue;
                updateMeasurement(
                    widget.specimenUuid, ref, #accuracy, String, newValue);
              }),
        ),
        AdaptiveLayout(
          useHorizontalLayout: widget.useHorizontalLayout,
          children: [
            DropdownButtonFormField<SpecimenSex>(
                initialValue: getSpecimenSex(ctr.sexCtr),
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Sex',
                  hintText: 'Select specimen sex',
                ),
                items: specimenSexList
                    .map((e) => DropdownMenuItem(
                          value: SpecimenSex.values[specimenSexList.indexOf(e)],
                          child: CommonDropdownText(text: e),
                        ))
                    .toList(),
                onChanged: (SpecimenSex? newValue) {
                  if (newValue != null) {
                    setState(() {
                      ctr.sexCtr = newValue.index;
                      updateMeasurement(
                          widget.specimenUuid, ref, #sex, int, newValue.index);
                    });
                  }
                }),
            DropdownButtonFormField<SpecimenAge>(
              initialValue: getSpecimenAge(ctr.ageCtr),
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Age',
                hintText: 'Select specimen age',
              ),
              items: specimenAgeList
                  .map((e) => DropdownMenuItem(
                        value: SpecimenAge.values[specimenAgeList.indexOf(e)],
                        child: CommonDropdownText(text: e),
                      ))
                  .toList(),
              onChanged: (SpecimenAge? newValue) {
                if (newValue != null) {
                  setState(
                    () {
                      ctr.ageCtr = newValue.index;
                      updateMeasurement(
                          widget.specimenUuid, ref, #age, int, newValue.index);
                    },
                  );
                }
              },
            ),
          ],
        ),
        MaleGonadForm(
          specimenUuid: widget.specimenUuid,
          specimenSex: getSpecimenSex(ctr.sexCtr),
          useHorizontalLayout: widget.useHorizontalLayout,
          ctr: ctr,
        ),
        OvaryOpeningField(
          specimenUuid: widget.specimenUuid,
          specimenSex: getSpecimenSex(ctr.sexCtr),
          specimenAge: getSpecimenAge(ctr.ageCtr),
          useHorizontalLayout: widget.useHorizontalLayout,
          ctr: ctr,
        ),
        FemaleGonadForm(
          specimenUuid: widget.specimenUuid,
          specimenSex: getSpecimenSex(ctr.sexCtr),
          specimenAge: getSpecimenAge(ctr.ageCtr),
          useHorizontalLayout: widget.useHorizontalLayout,
          ctr: ctr,
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: CommonTextField(
            controller: ctr.remarksCtr,
            maxLines: 5,
            labelText: 'Remarks',
            hintText: 'Write notes about the measurements (optional)',
            isLastField: true,
            onChanged: (value) {
              updateMeasurement(
                  widget.specimenUuid, ref, #remark, String, value);
            },
          ),
        ),
      ],
    );
  }

  bool get isBatFieldsAlwaysShown {
    return SpecimenSettingServices(ref: ref)
        .getSpecimenSettingField(batFieldsKey);
  }

  Future<void> _updateCtr(String specimenUuid) async {
    MammalMeasurementData data =
        await SpecimenServices(ref: ref).getMammalMeasurementData(specimenUuid);

    setState(() {
      ctr = MammalMeasurementCtrModel.fromData(data);
      _getHBTailPercent();
      _showBatFields =
          isBatFieldsAlwaysShown || (ctr.showBatFieldsCtr ?? false);
    });
  }

  void _getHBTailPercent() {
    MammalMeasurementServices service = MammalMeasurementServices(
      totalLengthText: ctr.totalLengthCtr.text,
      tailLengthText: ctr.tailLengthCtr.text,
    );

    ({
      String headAndBodyText,
      String percentTailText,
      String errorText
    })? results = service.getHBandTailPercentage();

    headBodyLengthCtr.text = results?.headAndBodyText ?? '';
    tailHeadBodyPercentCtr.text = results?.percentTailText ?? '';
    _hblErrorText = results?.errorText ?? '';
  }
}

void updateMeasurement(
    String specimenUuid, WidgetRef ref, Symbol field, Type type, dynamic value,
    [bool forceZero = false]) {
  if (value != null) {
    Map<Symbol, dynamic> args = {};

    switch (type) {
      case const (double):
        args[field] = db.Value<double?>(forceZero
            ? double.tryParse(value ?? '') ?? 0
            : double.tryParse(value));
        break;
      case const (int):
        if (value is int) {
          args[field] = db.Value<int?>(value);
        } else {
          args[field] = db.Value<int?>(int.tryParse(value));
        }
        break;
      case const (bool):
        args[field] = db.Value<int?>(value ? 1 : 0);
        break;
      case const (String):
        args[field] = db.Value<String?>(value);
        break;
    }

    SpecimenServices(ref: ref).updateMammalMeasurement(
        specimenUuid, Function.apply(MammalMeasurementCompanion.new, [], args));
  }
}

class MaleGonadForm extends ConsumerStatefulWidget {
  const MaleGonadForm({
    super.key,
    required this.specimenUuid,
    required this.specimenSex,
    required this.useHorizontalLayout,
    required this.ctr,
  });

  final String specimenUuid;
  final SpecimenSex? specimenSex;
  final bool useHorizontalLayout;
  final MammalMeasurementCtrModel ctr;

  @override
  MaleGonadFormState createState() => MaleGonadFormState();
}

class MaleGonadFormState extends ConsumerState<MaleGonadForm> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.specimenSex == SpecimenSex.male,
      child: Column(
        children: [
          const CommonDivider(),
          Text('Testes', style: Theme.of(context).textTheme.titleLarge),
          Padding(
            padding: const EdgeInsets.all(5),
            child: DropdownButtonFormField<TestisPosition>(
              initialValue: getTestisPosition(widget.ctr.testisPosCtr),
              decoration: const InputDecoration(
                labelText: 'Position',
                hintText: 'Select testis position',
              ),
              items: testisPositionList
                  .map((e) => DropdownMenuItem(
                        value: TestisPosition
                            .values[testisPositionList.indexOf(e)],
                        child: CommonDropdownText(text: e),
                      ))
                  .toList(),
              onChanged: (TestisPosition? newValue) {
                if (newValue != null) {
                  setState(
                    () {
                      widget.ctr.testisPosCtr = newValue.index;
                      updateMeasurement(widget.specimenUuid, ref,
                          #testisPosition, int, newValue.index);
                    },
                  );
                }
              },
            ),
          ),
          ScrotalMaleForm(
            specimenUuid: widget.specimenUuid,
            visible: getTestisPosition(widget.ctr.testisPosCtr) ==
                TestisPosition.scrotal,
            useHorizontalLayout: widget.useHorizontalLayout,
            ctr: widget.ctr,
          ),
        ],
      ),
    );
  }
}

class ScrotalMaleForm extends ConsumerStatefulWidget {
  const ScrotalMaleForm({
    super.key,
    required this.specimenUuid,
    required this.visible,
    required this.useHorizontalLayout,
    required this.ctr,
  });

  final String specimenUuid;
  final bool visible;
  final bool useHorizontalLayout;
  final MammalMeasurementCtrModel ctr;

  @override
  ScrotalMaleFormState createState() => ScrotalMaleFormState();
}

class ScrotalMaleFormState extends ConsumerState<ScrotalMaleForm> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visible,
      child: Column(
        children: [
          AdaptiveLayout(
            useHorizontalLayout: widget.useHorizontalLayout,
            children: [
              CommonNumField(
                controller: widget.ctr.testisLengthCtr,
                labelText: 'Length (mm)',
                hintText: 'Enter the length of the right testes ',
                isLastField: false,
                isDouble: true,
                onChanged: (String? value) {
                  updateMeasurement(
                      widget.specimenUuid, ref, #testisLength, double, value);
                },
              ),
              CommonNumField(
                controller: widget.ctr.testisWidthCtr,
                labelText: 'Width (mm)',
                hintText: 'Enter the width of the right testes ',
                isLastField: true,
                isDouble: true,
                onChanged: (String? value) {
                  updateMeasurement(
                      widget.specimenUuid, ref, #testisWidth, double, value);
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: DropdownButtonFormField<EpididymisAppearance>(
              initialValue: _getEpididymisAppearance(),
              decoration: const InputDecoration(
                labelText: 'Epididymis',
                hintText: 'Select epididymis appearance',
              ),
              items: epididymisAppearanceList
                  .map((e) => DropdownMenuItem(
                        value: EpididymisAppearance
                            .values[epididymisAppearanceList.indexOf(e)],
                        child: CommonDropdownText(text: e),
                      ))
                  .toList(),
              onChanged: (value) {
                updateMeasurement(widget.specimenUuid, ref,
                    #epididymisAppearance, int, value?.index);
              },
            ),
          ),
        ],
      ),
    );
  }

  EpididymisAppearance? _getEpididymisAppearance() {
    if (widget.ctr.epididymisCtr != null) {
      return EpididymisAppearance.values[widget.ctr.epididymisCtr!];
    }
    return null;
  }
}

class OvaryOpeningField extends ConsumerWidget {
  const OvaryOpeningField({
    super.key,
    required this.specimenUuid,
    required this.specimenSex,
    required this.specimenAge,
    required this.useHorizontalLayout,
    required this.ctr,
  });

  final String specimenUuid;
  final SpecimenSex? specimenSex;
  final SpecimenAge? specimenAge;
  final bool useHorizontalLayout;
  final MammalMeasurementCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveLayout(
      useHorizontalLayout: useHorizontalLayout,
      children: [
        Visibility(
          visible: specimenSex == SpecimenSex.female,
          child: DropdownButtonFormField<VaginaOpening>(
            initialValue: _getVaginaOpening(),
            decoration: const InputDecoration(
              labelText: 'Vagina opening',
              hintText: 'Select vagina opening',
            ),
            items: vaginaOpeningList
                .map((e) => DropdownMenuItem(
                      value: VaginaOpening.values[vaginaOpeningList.indexOf(e)],
                      child: CommonDropdownText(text: e),
                    ))
                .toList(),
            onChanged: (VaginaOpening? newValue) {
              updateMeasurement(
                  specimenUuid, ref, #vaginaOpening, int, newValue?.index);
            },
          ),
        ),
        Visibility(
          visible: specimenSex == SpecimenSex.female &&
              specimenAge == SpecimenAge.adult,
          child: DropdownButtonFormField<PubicSymphysis>(
            initialValue: _getPubicSymphysis(),
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Pubic symphysis',
              hintText: 'Select pubic symphysis condition',
            ),
            items: pubicSymphysisList
                .map((e) => DropdownMenuItem(
                      value:
                          PubicSymphysis.values[pubicSymphysisList.indexOf(e)],
                      child: CommonDropdownText(text: e),
                    ))
                .toList(),
            onChanged: (PubicSymphysis? newValue) {
              updateMeasurement(
                  specimenUuid, ref, #pubicSymphysis, int, newValue?.index);
            },
          ),
        ),
      ],
    );
  }

  VaginaOpening? _getVaginaOpening() {
    if (ctr.vaginaOpeningCtr != null) {
      return VaginaOpening.values[ctr.vaginaOpeningCtr!];
    }
    return null;
  }

  PubicSymphysis? _getPubicSymphysis() {
    if (ctr.pubicSymphysisCtr != null) {
      return PubicSymphysis.values[ctr.pubicSymphysisCtr!];
    }
    return null;
  }
}

class FemaleGonadForm extends ConsumerWidget {
  const FemaleGonadForm({
    super.key,
    required this.specimenUuid,
    required this.specimenSex,
    required this.specimenAge,
    required this.useHorizontalLayout,
    required this.ctr,
  });

  final String specimenUuid;
  final SpecimenSex? specimenSex;
  final SpecimenAge? specimenAge;
  final bool useHorizontalLayout;
  final MammalMeasurementCtrModel ctr;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
      visible:
          specimenSex == SpecimenSex.female && specimenAge == SpecimenAge.adult,
      child: Column(
        children: [
          const CommonDivider(),
          Padding(
            padding: const EdgeInsets.all(5),
            child: DropdownButtonFormField<ReproductiveStage>(
              initialValue: _getReproductiveStage(),
              decoration: const InputDecoration(
                labelText: 'Reproductive stage',
                hintText: 'Select reproductive stage',
              ),
              items: reproductiveStageList
                  .map((e) => DropdownMenuItem(
                        value: ReproductiveStage
                            .values[reproductiveStageList.indexOf(e)],
                        child: CommonDropdownText(text: e),
                      ))
                  .toList(),
              onChanged: (ReproductiveStage? newValue) {
                updateMeasurement(specimenUuid, ref, #reproductiveStage, int,
                    newValue?.index);
              },
            ),
          ),
          const CommonDivider(),
          Text('Mammae Counts (pairs)',
              style: Theme.of(context).textTheme.titleLarge),
          MammaeForm(
            useHorizontalLayout: useHorizontalLayout,
            specimenUuid: specimenUuid,
            ctr: ctr,
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: DropdownButtonFormField<MammaeCondition>(
              initialValue: _getMammaeCondition(),
              decoration: const InputDecoration(
                labelText: 'Mammae condition',
                hintText: 'Select mammae condition',
              ),
              items: mammaeConditionList
                  .map((e) => DropdownMenuItem(
                        value: MammaeCondition
                            .values[mammaeConditionList.indexOf(e)],
                        child: CommonDropdownText(text: e),
                      ))
                  .toList(),
              onChanged: (MammaeCondition? newValue) {
                updateMeasurement(
                    specimenUuid, ref, #mammaeCondition, int, newValue?.index);
              },
            ),
          ),
          const CommonDivider(),
          Text(
            'Embryo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          EmbryoForm(
            useHorizontalLayout: useHorizontalLayout,
            specimenUuid: specimenUuid,
            ctr: ctr,
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: CommonNumField(
              controller: ctr.embryoCRCtr,
              labelText: 'CR length (mm)',
              hintText: 'Enter crown-rump length',
              isLastField: true,
              onChanged: (String? value) {
                updateMeasurement(specimenUuid, ref, #embryoCR, int, value);
              },
            ),
          ),
          const CommonDivider(),
          Text('Placental Scars',
              style: Theme.of(context).textTheme.titleLarge),
          PlacentalScarForm(
            useHorizontalLayout: useHorizontalLayout,
            specimenUuid: specimenUuid,
            ctr: ctr,
          ),
        ],
      ),
    );
  }

  ReproductiveStage? _getReproductiveStage() {
    if (ctr.reproductiveStageCtr != null) {
      return ReproductiveStage.values[ctr.reproductiveStageCtr!];
    }
    return null;
  }

  MammaeCondition? _getMammaeCondition() {
    if (ctr.mammaeConditionCtr != null) {
      return MammaeCondition.values[ctr.mammaeConditionCtr!];
    }
    return null;
  }
}

class MammaeForm extends ConsumerWidget {
  const MammaeForm({
    super.key,
    required this.useHorizontalLayout,
    required this.specimenUuid,
    required this.ctr,
  });

  final bool useHorizontalLayout;
  final String specimenUuid;
  final MammalMeasurementCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveLayout(useHorizontalLayout: useHorizontalLayout, children: [
      CommonNumField(
        controller: ctr.mammaeAxCtr,
        labelText: 'Axillary',
        hintText: 'Enter the axillary pair number',
        isLastField: false,
        onChanged: (String? value) {
          updateMeasurement(
              specimenUuid, ref, #mammaeAxillaryCount, int, value);
        },
      ),
      CommonNumField(
        controller: ctr.mammaeAbdCtr,
        labelText: 'Abdominal',
        hintText: 'Enter the abdominal pair number',
        isLastField: false,
        onChanged: (String? value) {
          updateMeasurement(
              specimenUuid, ref, #mammaeAbdominalCount, int, value);
        },
      ),
      CommonNumField(
        controller: ctr.mammaeIngCtr,
        labelText: 'Inguinal',
        hintText: 'Enter the inguinal pair number',
        isLastField: false,
        onChanged: (String? value) {
          updateMeasurement(
              specimenUuid, ref, #mammaeInguinalCount, int, value);
        },
      ),
    ]);
  }
}

class EmbryoForm extends ConsumerWidget {
  const EmbryoForm({
    super.key,
    required this.useHorizontalLayout,
    required this.ctr,
    required this.specimenUuid,
  });

  final bool useHorizontalLayout;
  final String? specimenUuid;
  final MammalMeasurementCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveLayout(useHorizontalLayout: useHorizontalLayout, children: [
      CommonNumField(
        controller: ctr.embryoLeftCtr,
        labelText: 'Left',
        hintText: 'Left',
        isLastField: false,
        onChanged: (String? value) {
          updateMeasurement(specimenUuid!, ref, #embryoLeftCount, int, value);
        },
      ),
      CommonNumField(
        controller: ctr.embryoRightCtr,
        labelText: 'Right',
        hintText: 'Right',
        isLastField: true,
        onChanged: (String? value) {
          updateMeasurement(specimenUuid!, ref, #embryoRightCount, int, value);
        },
      ),
    ]);
  }
}

class MeasurementField {
  const MeasurementField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.field,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final Symbol field;
}

class PlacentalScarForm extends ConsumerWidget {
  const PlacentalScarForm({
    super.key,
    required this.useHorizontalLayout,
    required this.ctr,
    required this.specimenUuid,
  });

  final bool useHorizontalLayout;
  final String specimenUuid;
  final MammalMeasurementCtrModel ctr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveLayout(useHorizontalLayout: useHorizontalLayout, children: [
      CommonNumField(
        controller: ctr.leftPlacentaCtr,
        labelText: 'Left',
        hintText: 'Left',
        isLastField: false,
        onChanged: (String? value) {
          updateMeasurement(specimenUuid, ref, #leftPlacentalScars, int, value);
        },
      ),
      CommonNumField(
        controller: ctr.rightPlacentaCtr,
        labelText: 'Right',
        hintText: 'Right',
        isLastField: true,
        onChanged: (String? value) {
          updateMeasurement(
              specimenUuid, ref, #rightPlacentalScars, int, value);
        },
      ),
    ]);
  }
}
