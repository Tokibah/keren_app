import 'package:dio/dio.dart';

class Photo {
  final int id;
  final int view;
  final String link;
  final int popular;

  Photo({
    required this.id,
    required this.view,
    required this.link,
    required this.popular,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      view: json['view'] ?? 0,
      link: json['link'] ?? '',
      popular: json['popular'] ?? 0,
    );
  }
}

const String baseUrl = 'http://10.200.97.106:8080/api/m2/';

Future<int> fetchPageCount(int limit) async {
  try {
    final response = await Dio().get('$baseUrl/getPhotoPagination/$limit');
    if (response.statusCode == 200) {
      return response.data['pages'] as int;
    }
  } catch (e) {
    print('Error fetching page count: $e');
  }
  return 9;
}

Future<List<Photo>> fetchPhotos(int limit, int offset) async {
  try {
    final response = await Dio().get(
      '$baseUrl/getPhotos',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    if (response.statusCode == 200) {
      final photosList = response.data['photos'] as List;
      return photosList.map((json) => Photo.fromJson(json)).toList();
    }
  } catch (e) {
    print('Error fetching photos: $e');
  }
  return [];
}
