import '../../domain/entities/product_entity.dart';

class ProductModel {
  int id;
  String createdById;
  String name;
  String imageUrl;
  int stock;
  int sold;
  int price;
  String? description;
  String? specifications;
  int? installmentMonths;
  String? barcode;
  String? createdAt;
  String? updatedAt;

  ProductModel({
    required this.id,
    required this.createdById,
    required this.name,
    required this.imageUrl,
    required this.stock,
    required this.sold,
    required this.price,
    this.description,
    this.specifications,
    this.installmentMonths,
    this.barcode,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      createdById: json['createdById'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      stock: json['stock'],
      sold: json['sold'],
      price: json['price'],
      description: json['description'],
      specifications: json['specifications'],
      installmentMonths: json['installmentMonths'],
      barcode: json['barcode'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdById': createdById,
      'name': name,
      'imageUrl': imageUrl,
      'stock': stock,
      'sold': sold,
      'price': price,
      'description': description,
      'specifications': specifications,
      'installmentMonths': installmentMonths,
      'barcode': barcode,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id ?? DateTime.now().millisecondsSinceEpoch,
      createdById: entity.createdById,
      name: entity.name,
      imageUrl: entity.imageUrl,
      stock: entity.stock,
      sold: entity.sold ?? 0,
      price: entity.price,
      description: entity.description,
      specifications: entity.specifications,
      installmentMonths: entity.installmentMonths,
      barcode: entity.barcode,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      createdById: createdById,
      name: name,
      imageUrl: imageUrl,
      stock: stock,
      sold: sold,
      price: price,
      description: description,
      specifications: specifications,
      installmentMonths: installmentMonths,
      barcode: barcode,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
