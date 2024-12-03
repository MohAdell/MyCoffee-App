import 'package:flutter/material.dart';

import '../../../core/Service/API/CoffeeService.dart';
import '../model/Coffee_Model.dart';

class CoffeeProvider extends ChangeNotifier {
  List<Coffee> _coffees = [];
  bool _isLoading = false;

  List<Coffee> get coffees => _coffees;
  bool get isLoading => _isLoading;

  // A function to download data from the API and store it in memory
  Future<void> fetchCoffees(bool isHot) async {
    if (_coffees.isNotEmpty) return; // If the data is already downloaded, we do not re-download it.

    _isLoading = true;
    notifyListeners();

    try {
      _coffees = await CoffeeService().fetchCoffees(isHot: isHot);
    } catch (e) {
      print("Error fetching data: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
