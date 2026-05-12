import 'package:clientsf/theme.dart';
import 'package:flutter/material.dart';

class ProductForm extends StatefulWidget {
  final Function(List<ProductData>) onProductListChanged;

  const ProductForm({super.key, required this.onProductListChanged});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final List<ProductData> products = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final val in products) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'שם מוצר'),
                  onChanged: (value) {
                    setState(() => val.name = value);
                    widget.onProductListChanged(products);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'מחיר עלות'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() =>
                              val.price = double.tryParse(value) ?? 0.0);
                          widget.onProductListChanged(products);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'מחיר ללקוח'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() => val.discountedPrice =
                              double.tryParse(value) ?? 0.0);
                          widget.onProductListChanged(products);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () =>
                setState(() => products.add(ProductData())),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('הוסף מוצר'),
          ),
        ),
      ],
    );
  }
}

class ProductData {
  String? name;
  double? price;
  double? discountedPrice;
  ProductData({
    this.name,
    this.price,
    this.discountedPrice,
  });
  factory ProductData.fromDynamic(dynamic json) {
    return ProductData(
      name: json['name'],
      price: json['price']?.toDouble(),
      discountedPrice: json['discountedPrice']?.toDouble(),
    );
  }
}
