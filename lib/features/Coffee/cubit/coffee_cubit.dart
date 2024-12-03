import 'package:coffee_shop/core/Service/API/CoffeeService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../model/Coffee_Model.dart';

part 'coffee_state.dart';

class CoffeeCubit extends Cubit<CoffeeState> {
  CoffeeCubit(CoffeeService coffeeService) : super(CoffeeInitial());
  final _coffeeService = CoffeeService();
  List<Coffee> _coffees = []; // Store coffees in memory

  Future<void> loadCoffees({required bool isHot}) async {
    emit(CoffeeLoading());
    try {
      // 1. Try loading from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(isHot ? 'hotCoffees' : 'icedCoffees');

      if (cachedData != null) {
        _coffees = (jsonDecode(cachedData) as List)
            .map((json) => Coffee.fromJson(json))
            .toList();
        emit(CoffeeLoaded(_coffees));
      } else {
        // 2. If not in SharedPreferences, fetch from API
        _coffees = (await _coffeeService.fetchCoffees(isHot: isHot)).cast<Coffee>();
        // 3. Store fetched data in SharedPreferences
        prefs.setString(
          isHot ? 'hotCoffees' : 'icedCoffees',
          jsonEncode(_coffees.map((coffee) => coffee.toJson()).toList()),
        );
        emit(CoffeeLoaded(_coffees));
      }
    } catch (e) {
      emit(CoffeeError('Failed to load coffees.'));
    }
  }

  // Method to get coffees from memory (no reloading)
  List<Coffee> getCoffees({required bool isHot}) {
    return _coffees;
  }

  // Method to add an item to the cart (without reloading)
  void addToCart(Coffee coffee) {
    // ... (your logic to add to cart)
    emit(CoffeeLoaded(_coffees)); // Update state to reflect cart changes
  }

// ... (other methods)
}