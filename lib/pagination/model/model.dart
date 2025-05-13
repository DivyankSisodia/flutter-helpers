class Product {
  int? id;
  String? title;
  double? price;

  Product({
    this.id,
    this.title,
    this.price,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    price = json['price'] is int 
        ? (json['price'] as int).toDouble() 
        : json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['price'] = price;
    return data;
  }
}