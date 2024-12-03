import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../features/Coffee/model/Coffee_Model.dart';

class CoffeeService {
  Future<List<Coffee>> fetchCoffees({required bool isHot}) async {
    final url = isHot
        ? 'https://api.sampleapis.com/coffee/hot'
        : 'https://api.sampleapis.com/coffee/iced';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Coffee.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load coffee data');
    }
  }

}
