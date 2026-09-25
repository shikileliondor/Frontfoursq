import '../domain/models/church.dart';
import 'church_api_data_source.dart';
import 'churches.dart';

class ChurchRepository {
  ChurchRepository({ChurchApiDataSource? apiDataSource})
    : _apiDataSource = apiDataSource ?? ChurchApiDataSource();

  final ChurchApiDataSource _apiDataSource;

  Future<List<Church>> getChurches({String search = ''}) async {
    try {
      final remoteChurches = await _apiDataSource.fetchChurches(search: search);
      if (remoteChurches.isNotEmpty) return remoteChurches;
    } catch (_) {
      // Local data keeps the screen usable offline and during API maintenance.
    }

    return churches.where((church) => church.matches(search)).toList();
  }
}
