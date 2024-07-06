import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants.dart';

class FavoritesPage extends StatefulWidget {
  final List<int> favoriteProductIds;

  const FavoritesPage({Key? key, required this.favoriteProductIds})
      : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<dynamic> products = [];
  bool isLoadingProducts = false;
  @override
  void initState() {
    super.initState();
    fetchFavoriteProducts();
  }

  Future<void> fetchFavoriteProducts() async {
    setState(() {
      products = [];
      isLoadingProducts = true;
    });
    for (int productId in widget.favoriteProductIds) {
      final response =
      await http.get(Uri.parse('https://fakestoreapi.com/products/$productId'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          products.add(jsonData);
          isLoadingProducts = false;
        });
      }
    }
  }

  void removeFavorite(int productId) {
    setState(() {
      widget.favoriteProductIds.remove(productId);
    });
    fetchFavoriteProducts();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites',
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
      body: products.isEmpty
          ? const Center(
        child: Text('...'),
      )
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            leading: Image.network(product['image']),
            title: Text(product['title']),
            subtitle: Text('\$${product['price']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete,
                color: kprimaryColor,),
              onPressed: () => removeFavorite(product['id']),
            ),
          );
        },
      ),
    );
  }
}