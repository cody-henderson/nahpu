import 'package:drift/drift.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';
import 'package:nahpu/services/database/site_queries.dart';

class MergeDbServices {
  const MergeDbServices();

  Future<void> mergeProjects(Database currentDB, Database incomingDb,
      Map<String, String> projectMap) async {
    final incomingProjects = await ProjectQuery(incomingDb).getAllProjects();

    for (ProjectData project in incomingProjects) {
      final action = projectMap[project.uuid];

      final incomingSites =
          await SiteQuery(incomingDb).getAllSites(project.uuid);

      if (action != 'SKIP') {
        if (action == 'NEW') {
          await ProjectQuery(currentDB)
              .createProject(project.toCompanion(true));

          for (SiteData site in incomingSites) {
            final siteCompanion = site.toCompanion(true);
            await SiteQuery(currentDB)
                .createSite(siteCompanion.copyWith(id: Value.absent()));
          }
        } else {
          // MERGE
          for (SiteData site in incomingSites) {
            final siteCompanion = site.toCompanion(true);
            await SiteQuery(currentDB).createSite(siteCompanion.copyWith(
                id: Value.absent(), projectUuid: Value(action)));
          }
        }
      }
    }
  }
}
