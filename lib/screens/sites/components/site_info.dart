import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as db;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/fields.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/screens/shared/forms.dart';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/site_services.dart';
import 'package:nahpu/services/utility_services.dart';

const List<String> siteTypeList = [
  'City',
  'Town',
  'Hotel',
  'Village',
  'Camp',
  'Trail',
  'Trapline',
  'Netline',
  'Cave',
  'Other',
];

class SiteInfo extends ConsumerStatefulWidget {
  const SiteInfo({
    super.key,
    required this.id,
    required this.useHorizontalLayout,
    required this.siteFormCtr,
  });

  final int id;
  final bool useHorizontalLayout;
  final SiteFormCtrModel siteFormCtr;

  @override
  SiteInfoState createState() => SiteInfoState();
}

class SiteInfoState extends ConsumerState<SiteInfo> with FossilAware {
  @override
  Widget build(BuildContext context) {
    List<PersonnelData> personnelList = [];
    final personnelEntry = ref.watch(projectPersonnelProvider);
    personnelEntry.whenData(
      (personnelEntry) => personnelList = personnelEntry,
    );

    return FormCard(
      isPrimary: true,
      title: '${siteName.toTitleCase()} Info',
      infoContent: SiteInfoContent(ref: ref),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      child: AdaptiveLayout(
        useHorizontalLayout: widget.useHorizontalLayout,
        children: [
          TextField(
            controller: widget.siteFormCtr.siteIDCtr,
            inputFormatters: [
              LengthLimitingTextInputFormatter(40),
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9-_]+'))
            ],
            decoration: InputDecoration(
              labelText: '${siteName.toTitleCase()} ID',
              hintText:
                  'Enter a $siteName ID (max. 40 chars), e.g. "CAMP-01", "LINE-1"',
            ),
            onChanged: (value) {
              widget.siteFormCtr.siteIDCtr.value = TextEditingValue(
                text: value.toUpperCase(),
                selection: widget.siteFormCtr.siteIDCtr.selection,
              );
              SiteServices(ref: ref).updateSite(
                widget.id,
                SiteCompanion(
                    siteID: db.Value(widget.siteFormCtr.siteIDCtr.text)),
              );
            },
          ),
          DropdownButtonFormField(
            initialValue: widget.siteFormCtr.leadStaffCtr,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: '${siteName.toTitleCase()} Leader',
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
            onChanged: (String? uuid) {
              SiteServices(ref: ref).updateSite(
                widget.id,
                SiteCompanion(leadStaffId: db.Value(uuid)),
              );
            },
          ),
          DropdownButtonFormField<String?>(
            initialValue: widget.siteFormCtr.siteTypeCtr,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: '${siteName.toTitleCase()} Type',
              hintText: 'Choose a $siteName type',
            ),
            items: siteTypeList
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: CommonDropdownText(text: e),
                  ),
                )
                .toList(),
            onChanged: (String? value) {
              if (value != null) {
                SiteServices(ref: ref).updateSite(
                  widget.id,
                  SiteCompanion(siteType: db.Value(value)),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class SiteInfoContent extends StatelessWidget with FossilAware {
  const SiteInfoContent({super.key, required this.ref});

  @override
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return InfoContainer(
      content: [
        InfoContent(
          header: 'Overview',
          content: 'Basic information about the $siteName.'
              ' We recommend developing a naming convention for your $siteNamePlural.'
              ' For example, "CAMP-01" for the first campsite, '
              '"L1" for the first line. You could prefix the $siteName ID with the'
              ' project ID or location ID to make it unique.',
        ),
        InfoContent(
            content:
                'To avoid inputting the same information when creating a new $siteName,'
                ' you can duplicate a $siteName using the menu button in the top right corner.'
                ' It will create a new $siteName with the same information as the current $siteName,'
                ' except that the $siteName ID and coordinates will be empty.'),
      ],
    );
  }
}
