import Foundation

struct Meal {
  let name: String
  let thumbURL: URL
  let instructions: [String]
  let ingredients: [Ingredient]
  
  struct Ingredient {
    let name: String
    let measure: String
  }
}

let mockMeals: [Meal] = [
  .init(
    name: "Burger",
    thumbURL: URL(string: "https://www.themealdb.com/images/media/meals/urzj1d1587670726.jpg")!,
    instructions: [
    "Grill the 2 frozen patties",
    "Toast your buns",
    "Assemble burger: bun, patty, cheese, patty, cheese, ketchup, bun",
    "Serve"
  ],
    ingredients: [
    .init(name: "Buns", measure: "1"),
    .init(name: "Cheese", measure: "2 slices"),
    .init(name: "Burger Patty", measure: "2 patties "),
    .init(name: "Ketchup", measure: "2 tbsp "),
  ]),
  .init(
    name: "Tacos",
    thumbURL: URL(string: "https://www.themealdb.com/images/media/meals/ypxvwv1505333929.jpg")!,
    instructions: [
    "Download tacobell app",
    "Order cravings box",
    "Pickup",
    "Feast"
  ],
    ingredients: [
    .init(name: "Taco Bell App", measure: "1 app"),
    .init(name: "Wallet", measure: "$5"),
    .init(name: "Car", measure: "1 car"),
  ]),
  .init(
    name: "Fried Chicken",
    thumbURL: URL(string: "https://www.themealdb.com/images/media/meals/xqusqy1487348868.jpg")!,
    instructions: [
    "Download KFC app",
    "Order 12 piece box combo",
    "Pickup",
    "Feast"
  ],
    ingredients: [
    .init(name: "Taco Bell App", measure: "1 app"),
    .init(name: "KFC App", measure: "$25"),
    .init(name: "Car", measure: "1 car"),
  ])
]
