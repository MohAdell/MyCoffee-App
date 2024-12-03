import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../Coffee/model/Coffee_Model.dart';
import '../model/Order.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;
  bool isExpanded = false;
  CartPage({required this.cartItems});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double serviceCharge = 5.0;
  double deliveryCharge = 10.0;
  bool isExpanded = false;
  List<CartItem> underProcessItems = [];
  List<CartItem> cartItems = [];

  double calculateTotal() {
    double total = widget.cartItems.fold(
        0.0, (sum, item) => sum + (item.coffee.price ?? 0.0) * item.quantity);
    return total + serviceCharge + deliveryCharge;
  }

  void updateQuantity(CartItem item, int change) {
    setState(() {
      item.quantity += change;
      if (item.quantity < 1) item.quantity = 1;
    });
  }
  void moveToUnderProcess(CartItem item) {
    setState(() {
      // Check if the item is already in the In Progress list
      if (!underProcessItems.contains(item)) {
        underProcessItems.add(item);
        widget.cartItems.remove(item);
      } else {
        print("This item is already under process.");
      }
    });
  }
  void addItemToCart(CartItem item) {
    setState(() {
      // Check if the item is already in the cart
      if (!widget.cartItems.contains(item)) {
        widget.cartItems.add(item);
      } else {
        // If the item is already in the cart, just update the quantity
        final existingItem = widget.cartItems.firstWhere((cartItem) => cartItem.coffee.id == item.coffee.id);
        existingItem.quantity += item.quantity;
      }
    });
  }
// A function to save the basket and items in progress
  Future<void> saveCartAndUnderProcessItems(List<CartItem> cartItems, List<CartItem> underProcessItems) async {
    final prefs = await SharedPreferences.getInstance();

    // تحويل السلة و العناصر تحت التنفيذ إلى صيغة JSON
    String cartItemsJson = jsonEncode(cartItems.map((item) => item.toJson()).toList());
    String underProcessItemsJson = jsonEncode(underProcessItems.map((item) => item.toJson()).toList());

    // حفظ البيانات إلى SharedPreferences
    await prefs.setString('cartItems', cartItemsJson);
    await prefs.setString('underProcessItems', underProcessItemsJson);
  }

// A function to retrieve the basket and the items in progress
  Future<Map<String, List<CartItem>>> loadCartAndUnderProcessItems() async {
    final prefs = await SharedPreferences.getInstance();

    // Data retrieval
    String? cartItemsJson = prefs.getString('cartItems');
    String? underProcessItemsJson = prefs.getString('underProcessItems');

    List<CartItem> cartItems = [];
    List<CartItem> underProcessItems = [];

    if (cartItemsJson != null) {
      var cartItemsList = jsonDecode(cartItemsJson) as List;
      cartItems = cartItemsList.map((item) => CartItem.fromJson(item)).toList();
    }

    if (underProcessItemsJson != null) {
      var underProcessItemsList = jsonDecode(underProcessItemsJson) as List;
      underProcessItems = underProcessItemsList.map((item) => CartItem.fromJson(item)).toList();
    }

    return {'cartItems': cartItems, 'underProcessItems': underProcessItems};
  }
  _loadCartAndUnderProcessItems() async {
    var data = await loadCartAndUnderProcessItems();
    setState(() {
      cartItems = data['cartItems']!;
      underProcessItems = data['underProcessItems']!;
    });
  }

@override
  void initState() {
  _loadCartAndUnderProcessItems();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: widget.cartItems.isEmpty && underProcessItems.isEmpty
          ? Center(
        child: Text('Your cart is empty!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.cartItems.isNotEmpty) ...[
          Text('Your Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

        Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = widget.cartItems[index];
                  final coffee = cartItem.coffee;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            coffee.image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                coffee.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Ingredients: ${coffee.ingredients.join(', ')}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove),
                                  onPressed: () => updateQuantity(cartItem, -1),
                                ),
                                Text(
                                  '${cartItem.quantity}',
                                  style: TextStyle(fontSize: 18),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () => updateQuantity(cartItem, 1),
                                ),
                              ],
                            ),
                            Text(
                              '\$${(coffee.price ?? 0.0) * cartItem.quantity}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),],
            SizedBox(height: 20),
            // Show "in progress" items
            if (underProcessItems.isNotEmpty) ...[
              SizedBox(height: 20),
              Text('Under Process', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: underProcessItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = underProcessItems[index];
                    final coffee = cartItem.coffee;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              coffee.image,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coffee.title,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Ingredients: ${coffee.ingredients.join(', ')}',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                'Under Process',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            // If the Basket and In Progress are empty, display the appropriate message
            if (widget.cartItems.isEmpty && underProcessItems.isEmpty)
              Center(child: Text('Your cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            if (underProcessItems.isEmpty && widget.cartItems.isEmpty)
              Center(child: Text('Nothing in progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            SizedBox(height: 20),
            _buildSummarySection(),

          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    double subtotal = widget.cartItems.fold(
      0.0,
          (sum, item) => sum + (item.coffee.price ?? 0.0) * item.quantity,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(thickness: 1),

        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded; // Switch between open and closed
            });
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300), // Slow motion effect when changing
            padding: EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.brown,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, isExpanded ? 2 : 2),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              isExpanded ? 'Hide Price Details' : 'Show Price Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        if (isExpanded)
          Column(
            children: [
              _buildSummaryRow('Subtotal', subtotal),
              _buildSummaryRow('Service Charge', serviceCharge),
              _buildSummaryRow('Delivery Charge', deliveryCharge),
            ],
          ),
        Divider(thickness: 2),
        _buildSummaryRow('Total', calculateTotal(), isTotal: true),
        SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: _showPaymentDialog,

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Checkout',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String title, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.brown : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment(String cardNumber, String expiryDate, String cvv)async {
    if (cardNumber.length == 16 && expiryDate.isNotEmpty && cvv.length == 3) {
      setState(() {
        underProcessItems.addAll(cartItems);
        cartItems.clear();
      });

      // Save basket and items in progress
      await saveCartAndUnderProcessItems(cartItems, underProcessItems);

      // Simulate a successful payment process
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Payment Successful"),
            content: Text("Your payment has been processed successfully."),
            actions: [
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  setState(() {
                    // Move items to “In Progress” and delete them from the basket
                    underProcessItems.addAll(widget.cartItems);
                    widget.cartItems.clear();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Display an error message if the input is incorrect
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Payment Failed"),
            content: Text("Please check your card details."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  void _showPaymentDialog() {
    final _cardNumberController = TextEditingController();
    final _expiryDateController = TextEditingController();
    final _cvvController = TextEditingController();

    bool _showBackCard = false;

    void _checkCardComplete() {
      final cardNumber = _cardNumberController.text;
      final expiryDate = _expiryDateController.text;
      final cvv = _cvvController.text;
      if (cardNumber.length == 16 && expiryDate.length == 5 && cvv.length == 3) {
        setState(() {
          _showBackCard = true;
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Credit Card Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: 300,
                      width: 350,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
                      ),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        child: _showBackCard
                            ? Container(
                          key: ValueKey("backCard"),
                          child: Center(
                            child: Text(
                              'CVV: ${_cvvController.text}',
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        )
                            : Container(
                          key: ValueKey("frontCard"),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: TextField(
                                  controller: _cardNumberController,
                                  decoration: InputDecoration(
                                    hintText: 'XXXXXXXXXXXXXXXX',
                                    labelText: 'Card Number',
                                    labelStyle: TextStyle(color: Colors.white),
                                    hintStyle: TextStyle(color: Colors.white54),
                                  ),
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                  keyboardType: TextInputType.number,
                                  maxLength: 16,
                                  onChanged: (value) {
                                    _checkCardComplete();
                                  },
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: TextField(
                                  controller: _expiryDateController,
                                  decoration: InputDecoration(
                                    hintText: 'MM/YY',
                                    labelText: 'Expiry Date',
                                    labelStyle: TextStyle(color: Colors.white),
                                    hintStyle: TextStyle(color: Colors.white54),
                                  ),
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                  keyboardType: TextInputType.number,
                                  maxLength: 5,
                                  onChanged: (value) {
                                    if (value.length == 2 && !value.contains('/')) {
                                      _expiryDateController.text = value + '/';
                                      _expiryDateController.selection = TextSelection.fromPosition(
                                          TextPosition(offset: _expiryDateController.text.length));
                                    }
                                    _checkCardComplete();
                                  },
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: TextField(
                                  controller: _cvvController,
                                  decoration: InputDecoration(
                                    hintText: 'XXX',
                                    labelText: 'CVV',
                                    labelStyle: TextStyle(color: Colors.white),
                                    hintStyle: TextStyle(color: Colors.white54),
                                  ),
                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                  keyboardType: TextInputType.number,
                                  maxLength: 3,
                                  onChanged: (value) {
                                    _checkCardComplete();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String cardNumber = _cardNumberController.text;
                String expiryDate = _expiryDateController.text;
                String cvv = _cvvController.text;

                if (cardNumber.length == 16 && expiryDate.isNotEmpty && cvv.length == 3) {
                  Navigator.pop(context);
                  _processPayment(cardNumber, expiryDate, cvv);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter valid card details.")),
                  );
                }
              },
              child: Text("Pay Now"),
            ),
          ],
        );
      },
    );
  }

}
