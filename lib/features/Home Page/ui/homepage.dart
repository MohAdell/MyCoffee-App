import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../core/Service/API/CoffeeService.dart';
import '../../Cart/model/Order.dart';
import '../../Cart/ui/order_page.dart';
import '../../Coffee Details/ui/CoffeeDetails.dart';
import '../../Coffee/Provider/CoffeeProvider.dart';
import '../../Coffee/model/Coffee_Model.dart';

class CoffeeHomePage extends StatefulWidget {
  @override
  _CoffeeHomePageState createState() => _CoffeeHomePageState();
}

class _CoffeeHomePageState extends State<CoffeeHomePage> {
  String selectedCategory = 'Hot'; // Default category
  String location = 'Loading...';
  List<CartItem> cartItems = [];
  List<Coffee> allCoffees = [];
  List<Coffee> filteredCoffees = [];
  TextEditingController _searchController = TextEditingController();
  List<Coffee> hotCoffees = [];
  List<Coffee> icedCoffees = [];

  // Function to add drinks to the basket
  void addToCart(Coffee coffee) {
    setState(() {
      final index = cartItems.indexWhere((item) => item.coffee.title == coffee.title);
      if (index >= 0) {
        cartItems[index].quantity++;
      } else {
        cartItems.add(CartItem(coffee: coffee));
      }
    });
  }

  void updateCategory(String category) {
    setState(() {
      selectedCategory = category;
      allCoffees = selectedCategory == 'Hot' ? hotCoffees : icedCoffees;
      filteredCoffees = allCoffees;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadCoffees();
    _searchController.addListener(_filterCoffees);

  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCoffees);
    super.dispose();
  }

  // Function to get the current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check that location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        location = 'Location services are disabled.';
      });
      return;
    }

    // Check the site access permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          location = 'Location permissions are denied.';
        });
        return;
      }
    }

    // Fetch current location
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

    setState(() {
      location = '${placemarks[0].locality}, ${placemarks[0].country}'; // Current address
    });
  }

  // Function to load drinks using CoffeeService
  Future<void> _loadCoffees() async {
    try {
      final coffeeService = CoffeeService();
      hotCoffees = await coffeeService.fetchCoffees(isHot: true);
      icedCoffees = await coffeeService.fetchCoffees(isHot: false);

      setState(() {
        allCoffees = selectedCategory == 'Hot' ? hotCoffees : icedCoffees;
        filteredCoffees = allCoffees;
      });
    } catch (e) {
      print('Error fetching coffee data: $e');
    }
  }

  // A function to filter drinks according to the entered text
  void _filterCoffees() {
    setState(() {
      String searchTerm = _searchController.text.toLowerCase();
      filteredCoffees = allCoffees
          .where((coffee) =>
      coffee.title.toLowerCase().contains(searchTerm) ||
          coffee.description.toLowerCase().contains(searchTerm))
          .toList();
    });
  }

  // A function to open the drink details page
  void _navigateToCoffeeDetails(Coffee coffee) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: CoffeeDetailsDialog(coffee: coffee, addToCart: addToCart,),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage('https://lh3.googleusercontent.com/a-/AOh14Gj2-'),
          ),
        ),
        actions: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.location_on, color: Colors.black),
                SizedBox(width: 5),
                Text(
                  location,
                  style: TextStyle(color: Colors.black),
                ),
                SizedBox(width: 5),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartPage(cartItems: cartItems),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search box with suggestions
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Coffee...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            // View the list of suggestions
            if (_searchController.text.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: filteredCoffees.length,
                  itemBuilder: (context, index) {
                    final coffee = filteredCoffees[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: GestureDetector(
                        onTap: () => _navigateToCoffeeDetails(coffee),
                        child: Row(
                          children: [
                            // صورة المشروب بشكل دائري
                            ClipOval(
                              child: Image.network(
                                coffee.image,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              coffee.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            SizedBox(height: 20),
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            CategoriesList(
              selectedCategory: selectedCategory,
              onCategorySelected: updateCategory,
            ),
            SizedBox(height: 20),
    Consumer<CoffeeProvider>(
    builder: (context, coffeeProvider, child) {
    // التحقق من حالة التحميل
    if (coffeeProvider.isLoading) {
    return Center(child: CircularProgressIndicator());
    }
            // عرض قائمة المشروبات في الفئة المحددة
            return   Expanded(
              child: CoffeeList(
                coffees: filteredCoffees, // Pass filteredCoffees directly
                addToCart: addToCart,
              ),
            );}
    ),
          ],
        ),
      ),
    );
  }
}

class CategoriesList extends StatelessWidget {
  final List<String> categories = ['Hot', 'Iced'];
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  CategoriesList({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () => onCategorySelected(category),
              child: Chip(
                label: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
                backgroundColor: isSelected ? Colors.brown : Colors.brown[100],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CoffeeList extends StatelessWidget {

  final Function(Coffee) addToCart;
  final List<Coffee> coffees;
  CoffeeList({ required this.addToCart, required this.coffees});

  @override
  Widget build(BuildContext context) {
    final CoffeeService coffeeService = CoffeeService();

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: coffees.length,
      itemBuilder: (context, index) {
        return CoffeeCard(
          coffee: coffees[index],
          addToCart: addToCart,
        );
      },
    );
  }
}

class CoffeeCard extends StatelessWidget {
  final Coffee coffee;
  final Function(Coffee) addToCart;
  CoffeeCard({required this.coffee, required this.addToCart});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: CoffeeDetailsDialog(coffee: coffee, addToCart: addToCart,),
            );
          },
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: coffee.image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180,
                placeholder: (context, url) => CardLoadingWidget(), // Display placeholder
                errorWidget: (context, url, error) => Icon(Icons.error), // Display error icon
              ),
            ),
            SizedBox(height: 10),
            Text(
              coffee.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 5),
                  Text(
                    '\$${coffee.price?.toStringAsFixed(2) ?? '4.50'}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.add_shopping_cart),
                    color: Colors.brown,
                    onPressed: () {
                      addToCart(coffee); // استدعاء الوظيفة لإضافة المشروب للسلة
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${coffee.title} added to cart!')),
                      );

                      print("${coffee.title} added to cart!");
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CardLoading(
      height: 180,
      width: double.infinity,
      borderRadius: BorderRadius.circular(12),
      // loadingColor: Colors.grey,
    );
  }
}



