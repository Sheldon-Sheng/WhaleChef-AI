// lib/utils/dish_count.dart

/// 根据总菜数与荤菜数推导荤素配比：素菜 = 总菜数 − 荤菜数，荤菜夹在 [0, 总数]
({int meat, int veggie}) computeDishBreakdown(int dishesCount, int meatDishes) {
  final meat = meatDishes.clamp(0, dishesCount);
  return (meat: meat, veggie: dishesCount - meat);
}
