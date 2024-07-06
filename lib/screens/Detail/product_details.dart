import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../../constants.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
  });
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  Future<Product> getProductDetailsFromApi(String productId) async {
    final url = Uri.https('fakestoreapi.com', '/products/$productId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Product(
        id: jsonData['id'].toString(),
        name: jsonData['title'],
        price: jsonData['price'].toDouble(),
        imageUrl: jsonData['image'],
        description: jsonData['description'],
      );
    } else {
      throw Exception('Error');
    }
  }

  Future<void> fetchProductDetails() async {
    try {
      final productDetails = await getProductDetailsFromApi(widget.productId);
      setState(() {
        _product = productDetails;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ERROR $e')),
      );
    }
  }

  Product? _product;

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details',
          style: const TextStyle(
            color: kcontentColor ,
            fontWeight: FontWeight.w800,
            fontSize: 25,
          ),
        ),

        backgroundColor: kprimaryColor,
        leading:  IconButton(
          color: kcontentColor,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),

        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            )
        ),
      ),
      body: _product == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              _product!.imageUrl,
              width: 200,
              height: 200,
            ),
            Text(_product!.name,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 25,
              ),
            ),
            Row(
              children: [
                Text('${_product!.price}',style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 25,
                ),
                ),
                const Text('\$',
                    style: TextStyle(color: kprimaryColor , fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kprimaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Description",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16),
                  ),
                ),
              ],
            ),
            Text(_product!.description,
                style: const TextStyle(
                    fontSize: 16,
                    color:  Colors.black)),
          ],
        ),
      ),
    );
  }
}