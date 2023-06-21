import 'package:flutter/material.dart';

class ProductForm extends StatefulWidget {
  final Function(List<ProductData>) onProductListChanged;

  const ProductForm({required this.onProductListChanged});


  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  List<ProductData> products = [];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
       ListTile(
              onTap: () {
                setState(() {
                  products.add(ProductData());
                });
              },
              leading: Icon(Icons.add),
              title: Text('Add Product'),
            ),
          
      for(var val in products)
             ListTile(
            title: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                    ),
                    onChanged: (value) {
                         setState(() {
                        val.name = value;
                      });
                       widget.onProductListChanged(products);
                    },
                    
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Price',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                          setState(() {
                       val.price = double.tryParse(value) ?? 0.0;
                      });
                      widget.onProductListChanged(products);
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Discounted Price',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
         setState(() {
                        val.discountedPrice =
                            double.tryParse(value) ?? 0.0;
                      });
                      widget.onProductListChanged(products);
                    },
                  ),
                ),
              ],
            ),
          )
      
    ],);
    // return Expanded(
    //   child: ListView.builder(
    //     shrinkWrap: true,
    //     itemCount: products.length + 1,
    //     itemBuilder: (context, index) {
    //       if (index == products.length) {
    //         return ListTile(
    //           onTap: () {
    //             setState(() {
    //               products.add(ProductData());
    //             });
    //           },
    //           leading: Icon(Icons.add),
    //           title: Text('Add Product'),
    //         );
    //       }
    //       return ListTile(
    //         title: Row(
    //           children: [
    //             Expanded(
    //               child: TextFormField(
    //                 decoration: InputDecoration(
    //                   labelText: 'Product Name',
    //                 ),
    //                 onChanged: (value) {
    //                      setState(() {
    //                     products[index].name = value;
    //                   });
    //                    widget.onProductListChanged(products);
    //                 },
                    
    //               ),
    //             ),
    //             SizedBox(width: 10),
    //             Expanded(
    //               child: TextFormField(
    //                 decoration: InputDecoration(
    //                   labelText: 'Price',
    //                 ),
    //                 keyboardType: TextInputType.number,
    //                 onChanged: (value) {
    //                       setState(() {
    //                     products[index].price = double.tryParse(value) ?? 0.0;
    //                   });
    //                   widget.onProductListChanged(products);
    //                 },
    //               ),
    //             ),
    //             SizedBox(width: 10),
    //             Expanded(
    //               child: TextFormField(
    //                 decoration: InputDecoration(
    //                   labelText: 'Discounted Price',
    //                 ),
    //                 keyboardType: TextInputType.number,
    //                 onChanged: (value) {
    //      setState(() {
    //                     products[index].discountedPrice =
    //                         double.tryParse(value) ?? 0.0;
    //                   });
    //                   widget.onProductListChanged(products);
    //                 },
    //               ),
    //             ),
    //           ],
    //         ),
    //       );
    //     },
    //   ),
    // );
  
  }
}

class ProductData {
  late String name;
  late double price;
  late double discountedPrice;
}
