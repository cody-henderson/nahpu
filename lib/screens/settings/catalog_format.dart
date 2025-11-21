import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/services/types/specimens.dart';

class CatalogFmtSelection extends ConsumerStatefulWidget {
  const CatalogFmtSelection({super.key, required this.selectedFmt});
  final String selectedFmt;
  @override
  CatalogFmtSelectionState createState() => CatalogFmtSelectionState();
}

class CatalogFmtSelectionState extends ConsumerState<CatalogFmtSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog Format'),
      ),
      body: CommonSettingList(
        sections: [
          CommonSettingSection(
              title: 'Catalog Format',
              isDivided: true,
              children: CatalogFmt.values.map((catalogFmt) {
                String catalogFmtStr = matchCatFmtToTaxonGroup(catalogFmt);
                return CommonSettingTile(
                    title: catalogFmtStr,
                    icon: matchCatFmtToPartIcon(catalogFmt),
                    trailing: widget.selectedFmt == catalogFmtStr
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () {
                      ref
                          .read(catalogFmtNotifierProvider.notifier)
                          .set(catalogFmt);
                      Navigator.pop(context);
                    });
              }).toList())
        ],
      ),
    );
  }
}
