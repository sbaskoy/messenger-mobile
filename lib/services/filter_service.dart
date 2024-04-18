import 'package:dio/dio.dart';
import 'package:planner_messenger/models/filter/filter_response.dart';

import 'messenger_service.dart';

class FilterService {
  final MessengerService service;

  FilterService({required this.service});

  CancelToken searchRequestCancelToken = CancelToken();

  Future<FilterResponse?> search(String searchTerm) async {
    if (!searchRequestCancelToken.isCancelled) {
      searchRequestCancelToken.cancel();
      searchRequestCancelToken = CancelToken();
    }
    var response = await service.dio.get(
      "/filter/search",
      queryParameters: {
        "searchTerm": searchTerm,
      },
      cancelToken: searchRequestCancelToken,
    );
    var jsonResponse = response.data;
    if (jsonResponse is Map) {
      return FilterResponse.fromJson(jsonResponse);
    }
    return null;
  }
}
