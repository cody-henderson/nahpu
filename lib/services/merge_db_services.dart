import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/project_queries.dart';

class MergeDbServices {
  const MergeDbServices();

  Future<void> mergeProjects(Database currentDB, Database incomingDb,
      Map<String, String> projectMap) async {
    final incomingProjects = await ProjectQuery(incomingDb).getAllProjects();

    for (ProjectData project in incomingProjects) {
      final action = projectMap[project.uuid];
      if (action == 'NEW') {
        ProjectQuery(currentDB).createProject(project.toCompanion(false));
      } else {
        continue;
      }
    }
  }
}
