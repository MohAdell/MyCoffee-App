import 'dart:convert';
import 'package:coffee_shop/features/Cart/model/Order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedHelper {

  Future<void> saveCartAndUnderProcessItems(List<CartItem> cartItems, List<CartItem> underProcessItems) async {
    final prefs = await SharedPreferences.getInstance();

    // تحويل السلة و العناصر تحت التنفيذ إلى صيغة JSON
    String cartItemsJson = jsonEncode(cartItems.map((item) => item.toJson()).toList());
    String underProcessItemsJson = jsonEncode(underProcessItems.map((item) => item.toJson()).toList());

    // حفظ البيانات إلى SharedPreferences
    await prefs.setString('cartItems', cartItemsJson);
    await prefs.setString('underProcessItems', underProcessItemsJson);
  }

  Future<Map<String, List<CartItem>>> loadCartAndUnderProcessItems() async {
    final prefs = await SharedPreferences.getInstance();

    // استرجاع البيانات
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

}