import 'package:flutter/material.dart';
import 'package:odifarm/models/category.dart';
import 'package:odifarm/models/product.dart';
import 'package:odifarm/pages/product_page.dart';
import 'package:odifarm/pages/search_page.dart';
import 'package:odifarm/services/auth_service.dart';
import 'package:odifarm/notifiers/cart_notifier.dart';
import 'package:odifarm/services/category_service.dart';
import 'package:odifarm/services/product_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:odifarm/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Categories extends StatefulWidget {
  final dynamic initialcategory;

  const Categories({super.key, this.initialcategory});
  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  String searchQuery = '';
  Category? selectedCategory;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialcategory != null && widget.initialcategory is Category) {
      selectedCategory = widget.initialcategory;
    }
  }

  void updateQuery(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void updateSelectedCategory(Category? category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: const InputDecoration(
                              hintText: "Search for Fruits",
                              border: InputBorder.none,
                            ),
                            onSubmitted: (value) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SearchProductsPage(initialQuery: value),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CategoryDropDown(
                  selectedCategory: selectedCategory,
                  onCategoryChanged: updateSelectedCategory,
                ),
                FetchProducts(category: selectedCategory),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryDropDown extends StatefulWidget {
  final Category? selectedCategory;
  final Function(Category?) onCategoryChanged;

  const CategoryDropDown({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  State<CategoryDropDown> createState() => _CategoryDropDownState();
}

class _CategoryDropDownState extends State<CategoryDropDown> {
  final CategoryService categoryService = CategoryService();
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final result = await categoryService.fetchCategories();
    setState(() {
      categories = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Wait until categories are loaded before showing dropdown
    if (categories.isEmpty) {
      return const SizedBox(height: 36); // or a loader if you prefer
    }
    // If selectedCategory is not in the list, fallback to null
    final validValue = categories.contains(widget.selectedCategory)
        ? widget.selectedCategory
        : null;
    return DropdownButtonHideUnderline(
      child: DropdownButton2<Category>(
        isExpanded: false,
        value: validValue,
        hint: const Text('Select', style: TextStyle(fontSize: 10, height: 1)),
        items: [
          DropdownMenuItem<Category>(
            value: null,
            child: Text(
              'All',
              style: const TextStyle(
                fontSize: 10,
                height: 1,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...categories.map((category) {
            return DropdownMenuItem<Category>(
              value: category,
              child: Text(
                category.name,
                style: const TextStyle(fontSize: 10, height: 1),
              ),
            );
          }),
        ],
        onChanged: widget.onCategoryChanged,
        buttonStyleData: ButtonStyleData(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
            color: Colors.grey[200],
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          offset: const Offset(0, 2),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 26,
          padding: EdgeInsets.symmetric(horizontal: 6),
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 14),
        ),
      ),
    );
  }
}

class FetchProducts extends StatefulWidget {
  final Category? category;

  const FetchProducts({super.key, required this.category});

  @override
  State<FetchProducts> createState() => _FetchProductsState();
}

class _FetchProductsState extends State<FetchProducts> {
  final ProductService productService = ProductService();
  List<Product> products = [];
  bool isLoading = false;
  // ignore: prefer_typing_uninitialized_variables
  var user;
  @override
  void initState() {
    super.initState();
    fetchProducts();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final email = await AuthService().fetchUserByemail();
    final fetchedUser = await UserService().fetchUserData(email);
    user = fetchedUser;
  }

  @override
  void didUpdateWidget(covariant FetchProducts oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always refetch if the category changes, including if the id changes
    if (oldWidget.category?.id != widget.category?.id) {
      fetchProducts();
    }
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
      products = [];
    });

    List<Product> fetchedProducts;

    if (widget.category != null) {
      // Fetch by category id
      fetchedProducts = await productService.fetchProductsByCategory(
        widget.category!.id,
      );
    } else {
      // Fetch all products when no category selected
      fetchedProducts = await productService.fetchProducts();
    }

    setState(() {
      products = fetchedProducts;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
     return Skeletonizer(
      enabled: isLoading,
      child: isLoading
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 4, // Show 4 skeletons while loading
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) => Container(
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : products.isEmpty
          ? const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("No products found."),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7, // Adjust based on design
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  final price = product.productItems.isNotEmpty
                      ? product.productItems[0].price.toString()
                      : 'N/A';

                  return Container(
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: GestureDetector(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: ProductPage(product: product),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              product.image,
                              fit: BoxFit.cover,
                              height: 180,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 50),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  RichText(
                                    maxLines: 2,
                                    text: TextSpan(
                                      text: product.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '₹$price',
                                          style: const TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final cartNotifier =
                                                Provider.of<CartNotifier>(
                                                  context,
                                                  listen: false,
                                                );
                                            await cartNotifier.addToCart(
                                              userId: user.id,
                                              productId: product.id,
                                              quantity: 1,
                                              price:
                                                  product.productItems[0].price,
                                            );
                                            // ignore: use_build_context_synchronously
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Product added to cart successfully!',
                                                ),
                                              ),
                                            );
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                  Colors.green,
                                                ),
                                            padding: WidgetStateProperty.all(
                                              EdgeInsets.zero,
                                            ),
                                            shape: WidgetStateProperty.all(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: const [
                                              Icon(
                                                Icons.shopping_bag_rounded,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                "Add",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
