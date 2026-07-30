import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_config.dart';
import '../models/sale.dart';

class SaleApiService {
  const SaleApiService();

  Future<List<Sale>> fetchSales() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/api/sales'));
    if (response.statusCode != 200) {
      throw StateError('판매 목록 조회 실패: ${response.statusCode}');
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>? ?? const {};
    final sales = data['sales'];
    if (sales is! List) return const [];
    return sales.whereType<Map<String, dynamic>>().map(Sale.fromJson).toList();
  }

  Future<Sale> create({
    required String title,
    required String description,
    required String medium,
    required String size,
    required int? year,
    required int buyNowPrice,
    required bool auctionEnabled,
    int? auctionStartPrice,
    String? auctionEndDate,
    String? imageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/sales'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'medium': medium,
        'size': size,
        'year': year,
        'buyNowPrice': buyNowPrice,
        'auctionEnabled': auctionEnabled,
        'auctionStartPrice': auctionStartPrice,
        'auctionEndDate': auctionEndDate,
        'imageUrl': imageUrl,
      }),
    );
    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw StateError(body['message'] as String? ?? '판매 등록 실패: ${response.statusCode}');
    }
    return Sale.fromJson(body['data'] as Map<String, dynamic>);
  }
}
