class BarcodeProduct {
  final String code;
  final String productName;
  final String brands;


  BarcodeProduct({
    required this.code,
    required this.productName,
    required this.brands,});


  factory BarcodeProduct.fromJson(Map<String, dynamic> json) {
    return BarcodeProduct(
      code: json['code']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      brands: json['brands']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'product_name': productName,
      'brands': brands,
    };
  }

  @override
  String toString() {
    return 'Item($productName, brand: $brands)';
  }

}