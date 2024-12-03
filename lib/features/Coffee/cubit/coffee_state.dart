part of 'coffee_cubit.dart';

@immutable
abstract class CoffeeState {}

class CoffeeInitial extends CoffeeState {}

class CoffeeLoading extends CoffeeState {}

class CoffeeLoaded extends CoffeeState {
  final List<Coffee> coffees;

  CoffeeLoaded(this.coffees);
}

class CoffeeError extends CoffeeState {
  final String error;

  CoffeeError(this.error);
}