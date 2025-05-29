import 'package:flutter/material.dart';
import 'package:odifarm/models/product.dart';
import 'package:odifarm/services/product_service.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:odifarm/pages/product_page.dart';

class SearchProductsPage extends StatefulWidget {
  final String initialQuery;

  const SearchProductsPage({super.key, required this.initialQuery});

  @override
  State<SearchProductsPage> createState() => _SearchProductsPageState();
}

class _SearchProductsPageState extends State<SearchProductsPage> {
  final TextEditingController searchController = TextEditingController();
  final ProductService productService = ProductService();

  List<Product> products = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    searchController.text = widget.initialQuery;
    if (widget.initialQuery.isNotEmpty) {
      performSearch(widget.initialQuery);
    }
  }

  void performSearch(String query) async {
    setState(() => loading = true);
    final result = await productService.fetchProductsBySearch(query);
    setState(() {
      products = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: performSearch,
            ),
            const SizedBox(height: 16),
            if (products.isEmpty)
              const Text('No products found.')
            else
              Expanded(
                child: Skeletonizer(
                  enabled: loading,
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (_, index) {
                      final product = products[index];
                      return ListTile(
                        leading: product.image.isNotEmpty
                            ? Image.network(
                                product.image,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                              )
                            : const Icon(Icons.image_not_supported),
                        title: Text(product.name),
                        subtitle: Text('₹${product.productItems.isNotEmpty ? product.productItems[0].price.toString() : "N/A"}'),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: ProductPage(product: product),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
