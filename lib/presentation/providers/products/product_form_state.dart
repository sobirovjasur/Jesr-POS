import 'dart:io';

class ProductFormState {
  final File? imageFile;
  final String? imageUrl;
  final String? name;
  final int? price;
  final int? stock;
  final String? description;
  final String? specifications;
  final int? installmentMonths;
  final String? barcode;
  final bool isLoaded;

  const ProductFormState({
    this.imageFile,
    this.imageUrl,
    this.name,
    this.price,
    this.stock,
    this.description,
    this.specifications,
    this.installmentMonths,
    this.barcode,
    this.isLoaded = false,
  });

  ProductFormState copyWith({
    File? imageFile,
    String? imageUrl,
    String? name,
    int? price,
    int? stock,
    String? description,
    String? specifications,
    int? installmentMonths,
    String? barcode,
    bool? isLoaded,
  }) {
    return ProductFormState(
      imageFile: imageFile ?? this.imageFile,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      specifications: specifications ?? this.specifications,
      installmentMonths: installmentMonths ?? this.installmentMonths,
      barcode: barcode ?? this.barcode,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}
