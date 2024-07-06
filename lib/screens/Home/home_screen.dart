import 'dart:ui';
import 'package:e_commers_app/screens/Favorite/favorites_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../models/category.dart';
import '../Detail/product_details.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class Product {
  final int id;
  final String title;
  final String image;

  Product({required this.id, required this.title, required this.image});
}

class _HomeScreenState extends State<HomeScreen> {
  int currentSlider = 0;
  int selectedIndex = 0;
  List<dynamic> products = [];
  List<int> favoriteProductIds = [];
  bool isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }



  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        products = jsonData.map((item) => Product(
          id: item['id'],
          title: item['title'],
          image: item['image'],
        )).toList();
      });
    }
  }

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products/categories'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => Category(
        title: item,
      )).toList();
    } else {
      throw Exception('Failed to fetch categories');
    }
  }

  Future<void> fetchProductsByCategory(String category) async {
    setState(() {
      isLoadingProducts = true;
    });

    final response = await http.get(Uri.parse('https://fakestoreapi.com/products/category/$category'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        products = jsonData.map((item) => Product(
          id: item['id'],
          title: item['title'],
          image: item['image'],
        )).toList();
        isLoadingProducts = false;
      });
    }
  }



  void toggleFavorite(int productId) {
    setState(() {
      if (favoriteProductIds.contains(productId)) {
        favoriteProductIds.remove(productId);
      } else {
        favoriteProductIds.add(productId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My store',
          style: const TextStyle(
            color: kcontentColor ,
            fontWeight: FontWeight.w800,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.favorite_sharp),
            color: kcontentColor,
            onPressed:  () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesPage(
                      favoriteProductIds: favoriteProductIds),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.orange,
        leading: IconButton(
          onPressed: () {},
          icon: IconButton(
            icon: const Icon(Icons.menu),
            color: kcontentColor,
            onPressed: (){},
          ),
        ),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            )
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              categoryItems(),

              const SizedBox(height: 10),
              if (isLoadingProducts)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(width: 8.0),
                      Text('Loading...',
                        style: TextStyle(
                          color: kprimaryColor,
                          fontWeight: FontWeight.w800,
                        ),

                      ),
                    ],
                  ),
                )
              else
                GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 25,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductItem(
                      product: product,
                      isFavorite: favoriteProductIds.contains(product.id),
                      onFavoriteToggled: () {
                        toggleFavorite(product.id);
                      },

                    );

                  },

                ),


            ],
          ),
        ),
      ),
    );
  }

  SizedBox categoryItems() {
    return SizedBox(
      height: 50,
      child: FutureBuilder<List<Category>>(
        future: fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<Category> categoriesList = [
              Category(title: 'All'),
              ...snapshot.data!
            ];

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categoriesList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      selectedIndex = index;
                    });

                    if (index == 0) {
                      await fetchProducts();
                    } else {
                      await fetchProductsByCategory(categoriesList[index].title);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),

                      color: isLoadingProducts || selectedIndex != index
                          ? Colors.grey[300]
                          : Colors.orange,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          categoriesList[index].title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLoadingProducts || selectedIndex != index
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        if (selectedIndex == index)
                          const SizedBox(width: 4),
                        if (selectedIndex == index)
                          Row(
                            children: const [
                              CircleAvatar(
                                radius: 3,
                                backgroundColor: Colors.orange,
                              ),
                              SizedBox(width: 2),
                              CircleAvatar(
                                radius: 3,
                                backgroundColor: Colors.orange,
                              ),
                              SizedBox(width: 2),
                              CircleAvatar(
                                radius: 3,
                                backgroundColor: Colors.orange,
                              ),

                            ],
                          ),

                      ],
                    ),
                  ),

                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const  Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(width: 8.0),
                  Text('Loading...',
                    style: TextStyle(
                      color: kprimaryColor,
                      fontWeight: FontWeight.w800,
                    ),

                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

}

class ProductItem extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoriteToggled;

  ProductItem({
    required this.product,
    required this.isFavorite,
    required this.onFavoriteToggled,

  }
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(
                  productId: product.id.toString(),
                ),
              ),
            );
          },
          child: Image.network(product.image),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? kprimaryColor : kprimaryColor,
              ),
              onPressed: (){
                onFavoriteToggled();
              }
          ),
        ),
      ],
    );
  }
}
