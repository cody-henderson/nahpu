import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/providers/specimens.dart';
import 'package:nahpu/screens/settings/common.dart';
import 'package:nahpu/screens/shared/common.dart';
import 'package:nahpu/services/types/specimens.dart';
import 'package:nahpu/services/types/taxonomy.dart';

class TaxonomySelection extends ConsumerStatefulWidget {
  const TaxonomySelection({super.key});
  @override
  TaxonomySelectionState createState() => TaxonomySelectionState();
}

class TaxonomySelectionState extends ConsumerState<TaxonomySelection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(catalogFmtNotifierProvider).when(
        data: (selectedFmt) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Taxonomy'),
            ),
            body: CommonSettingList(
              sections: [
                CommonSettingSection(
                    title: 'Taxonomy',
                    isDivided: true,
                    children: TaxonomicRanks.values.map((rank) {
                      return CommonSettingTile(
                          title: taxonRankMap[rank]!,
                          icon: matchCatFmtToPartIcon(CatalogFmt.birds),
                          onTap: () {});
                    }).toList()),
              ],
            ),
          );
        },
        loading: () => const CommonProgressIndicator(),
        error: (e, __) => Text(e.toString()));
  }
}
