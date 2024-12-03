
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Coffee/model/Coffee_Model.dart';

class CoffeeDetailsDialog extends StatelessWidget {
  final Coffee coffee;
  final Function(Coffee) addToCart;

  CoffeeDetailsDialog({required this.coffee, required this.addToCart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // عرض الصورة في أعلى البطاقة
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              coffee.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 180,
            ),
          ),
          SizedBox(height: 10),
          // اسم المنتج
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                coffee.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: Icon(Icons.add_circle, size: 30, color: Colors.brown),
                  label: Text(
                    'Order Now',
                    style: TextStyle(fontSize: 18, color: Colors.brown),
                  ),
                  onPressed: () {
                    addToCart(coffee); // استدعاء الوظيفة لإضافة المشروب للسلة
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${coffee.title} added to cart!')),
                    );

                    print("Order placed for ${coffee.title}");
                    Navigator.pop(context); // إغلاق النافذة العائمة
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // عرض المكونات داخل مربع
          Container(
            decoration: BoxDecoration(
              color: Colors.brown[50],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(8),
            child: Text(
              "Ingredients: ${coffee.ingredients.join(', ')}",
              style: TextStyle(fontSize: 16, color: Colors.brown[700]),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 10),
          // وصف المنتج
          Text(
            coffee.description ?? "No description available.",
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          // زر الطلب كأيقونة +
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: IconButton(
          //     icon: Icon(Icons.add_circle, size: 50, color: Colors.brown),
          //     onPressed: () {
          //       print("Order placed for ${coffee.title}");
          //       Navigator.pop(context); // إغلاق النافذة العائمة
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
