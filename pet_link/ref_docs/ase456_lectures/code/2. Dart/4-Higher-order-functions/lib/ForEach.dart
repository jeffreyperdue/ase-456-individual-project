// forEach vs map and Utility Functions
// Examples from "Higher-Order Functions with Lambda Expressions" lecture

void main() {
  print('=== FOREACH VS MAP AND UTILITY FUNCTIONS ===\n');

  forEachExample();
  sideEffectsExample();
  commonMistakesExample();
}

class Product {
  String name;
  double price;
  Product(this.name, this.price);
}

var getProducts = () => [
  Product('Laptop', 999.99),
  Product('Smartphone', 499.99),
  Product('Tablet', 299.99),
];

void forEachExample() {
  List<String> names = ['Alice', 'Bob', 'Charlie'];
  // Print each name
  for (var name in names) {
    print('Hello, $name!');
  }

  List<Product> products = getProducts();
  for (var product in products) {
    print('Product: ${product.name}');
    print('Price: \$${product.price}');
    print('---');
  }
}

void sideEffectsExample() {
  void sendEmail(String student) {
    print('Sending email to $student');
  }

  void updateDatabase(String student) {
    print('Updating database for $student');
  }

  // Wrong usage - trying to collect values
  // Use map instead
  List<int> numbers = [1, 2, 3, 4];
  List<int> doubled = [];
  for (var num in numbers) {
    doubled.add(num * 2); // Side effect
  }
  print(doubled); // [2, 4, 6, 8]

  // Right usage - performing side effects
  List<String> students = ['Alice', 'Bob', 'Charlie'];
  for (var student in students) {
    print('Welcome, $student!'); // Logging
    sendEmail(student); // API call
    updateDatabase(student); // Database update
  }
}

void commonMistakesExample() {
  List<int> numbers = [1, 2, 3];
  var result = numbers.map((num) => num * 2);
  print(result.runtimeType);
  var result2 = numbers.map((num) => num * 2).toList();
  print(result2.runtimeType);

  List<int> doubled = [];
  // Do not use forEach to transform a list
  // This is a common mistake
  // Use map instead
  for (var num in numbers) {
    doubled.add(num * 2);
  } // Awkward
  print(doubled); // [2, 4, 6]
}
