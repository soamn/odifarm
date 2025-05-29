import 'package:flutter/material.dart';
import 'package:odifarm/models/category.dart';
import 'package:odifarm/models/product.dart';
import 'package:odifarm/pages/categories.dart';
import 'package:odifarm/pages/login.dart';
import 'package:odifarm/pages/product_page.dart';
import 'package:odifarm/pages/search_page.dart';
import 'package:odifarm/services/auth_service.dart';
import 'package:odifarm/services/category_service.dart';
import 'package:odifarm/services/product_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          surfaceTintColor: const Color.fromARGB(255, 255, 255, 255),
          actionsPadding: EdgeInsets.all(12),
          leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
          centerTitle: true,
          title: Text(
            "Odi Farm",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                await authService.signout();
                Navigator.pushReplacement(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  Card.filled(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.black12),
                    ),
                    child: Padding(
                      padding: EdgeInsetsGeometry.fromLTRB(8, 2, 8, 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              autofocus: false,
                              decoration: const InputDecoration(
                                hintText: "Search for Fruits",
                                border: InputBorder.none,
                              ),
                              onSubmitted: (value) => (
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SearchProductsPage(initialQuery: value),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Featured Products",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2),
                    child: FeaturedProducts(),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Seasonal Offers",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  Padding(padding: EdgeInsets.all(2), child: SeasonalOffers()),
                  SizedBox(height: 12),
                  Text(
                    "Categories",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2),
                    child: FeaturedCategories(),
                  ),
                  SizedBox(height: 12),
                  SizedBox(height: 20, child: Card(color: Colors.red)),
                  SizedBox(
                    child: FetchProducts(
                      category: null, // Show all products on home
                    ),
                  ),
                  Footer(
                    title: "Odi Farm",
                    links: ["About Us", "Contact", "Privacy Policy", "Website"],
                    onLinkTap: (link) {
                      // print("Clicked on $link");
                      // Navigate or do something with the link here
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Footer extends StatelessWidget {
  final String title;
  final List<String> links;
  final void Function(String)? onLinkTap;

  const Footer({
    super.key,
    required this.title,
    required this.links,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: links.map((link) {
              return GestureDetector(
                onTap: () {
                  if (onLinkTap != null) {
                    onLinkTap!(link);
                  }
                },
                child: Text(
                  link,
                  style: const TextStyle(decoration: TextDecoration.underline),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class FeaturedProducts extends StatelessWidget {
  final ProductService productService = ProductService();
  FeaturedProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: productService.fetchProducts(),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final products =
            snapshot.data ??
            List.generate(
              5,
              (index) => Product(
                id: "1",
                name: 'Loading...',
                description: 'Loading...',
                image: '', // Will not be shown during skeleton loading
                productItems: [],
                isFeatured: true,
                category: Category(id: "1", name: "q", image: ''),
              ),
            );

        return SizedBox(
          height: 260,
          child: Skeletonizer(
            enabled: isLoading,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor:
                        Colors.transparent, // Let rounded container be visible
                    builder: (context) => SizedBox(
                      height:
                          MediaQuery.of(context).size.height *
                          0.5, // almost full screen
                      child: ProductPage(product: product),
                    ),
                  ),
                  child: Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AspectRatio(
                              aspectRatio: 1.5,
                              child: product.image.isEmpty
                                  ? Container(
                                      color: Colors.grey[300],
                                    ) // during loading
                                  : Image.network(
                                      product.image,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            product.description,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 166, 120, 123),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class SeasonalOffers extends StatelessWidget {
  final ProductService productService = ProductService();
  SeasonalOffers({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: productService.fetchProducts(),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final products =
            snapshot.data ??
            List.generate(
              5,
              (index) => Product(
                id: "1",
                name: 'Loading...',
                description: 'Loading...',
                image: '', // Will not be shown during skeleton loading
                productItems: [],
                isFeatured: true,
                category: Category(id: "1", name: "q", image: ''),
              ),
            );

        return SizedBox(
          height: 390,
          child: Skeletonizer(
            enabled: isLoading,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor:
                        Colors.transparent, // Let rounded container be visible
                    builder: (context) => SizedBox(
                      height:
                          MediaQuery.of(context).size.height *
                          0.5, // almost full screen
                      child: ProductPage(product: product),
                    ),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AspectRatio(
                              aspectRatio: 1.5,
                              child: product.image.isEmpty
                                  ? Container(
                                      color: Colors.grey[300],
                                    ) // during loading
                                  : Image.network(
                                      product.image,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            product.description,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 166, 120, 123),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class FeaturedCategories extends StatelessWidget {
  final CategoryService categoryService = CategoryService();
  FeaturedCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: categoryService.fetchCategories(),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final categories =
            snapshot.data ??
            List.generate(
              4,
              (index) => Category(id: "$index", name: "Loading...", image: ''),
            );

        return Skeletonizer(
          enabled: isLoading,
          child: GridView.count(
            physics:
                NeverScrollableScrollPhysics(), // Prevent internal scrolling
            shrinkWrap: true, // Fit only the necessary height
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4, // Adjust to match your desired shape
            children: categories.map((category) {
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Categories(initialcategory: category),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: category.image.isNotEmpty ? null : Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: category.image.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  category.image,
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 60,
                                        width: 60,
                                        color: Colors.green[50],
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.green[200],
                                          size: 32,
                                        ),
                                      ),
                                ),
                              )
                            : Container(
                                height: 60,
                                width: 60,
                                color: Colors.green[50],
                                child: Icon(
                                  Icons.category,
                                  color: Colors.green[200],
                                  size: 32,
                                ),
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
