import 'dart:convert';
import 'package:kitchen_alchemy/models/barcode_product.dart';
import 'package:http/http.dart' as http;

class BarcodeService {
  final String baseUrl = 'https://kitchenalchemy-backend.onrender.com';


  Future<BarcodeProduct> getProductByBarcode(String code) async {
    final response = await http.get(
      Uri.parse('$baseUrl/barcode/$code'),
    );
    if (response.statusCode == 200) {
      return BarcodeProduct.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load Product');
    }
  }

}
