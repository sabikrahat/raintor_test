import 'dart:developer';

import '../model/post.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<PostModel>> fetchPosts() async {
  var request = http.Request('GET', Uri.parse('https://jsonplaceholder.typicode.com/posts/'));

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    String responseBody = await response.stream.bytesToString();
    List<dynamic> jsonData = jsonDecode(responseBody);
    return jsonData.map((post) => PostModel.fromJson(post)).toList();
  } else {
    log(response.reasonPhrase ?? 'Unknown error', name: 'fetchPosts');
    throw Exception('Failed to load posts: ${response.reasonPhrase}');
  }
}
