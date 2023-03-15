import Foundation

// MARK: - MealClient
struct MealClient {
  let fetchMeals: @Sendable () -> AsyncStream<Meal>
}

// MARK: - MealClient Preview
// Implementation of the client specifically for Xcode previews.
// Streams mock data with emulated fetch await times.
extension MealClient {
  static let preview = Self { .init { continuation in
    let task = Task {
      for meal in mockMeals {
        guard !Task.isCancelled else { return }
        _ = try? await Task.sleep(nanoseconds: NSEC_PER_SEC)
        continuation.yield(meal)
      }
      continuation.finish()
    }
    continuation.onTermination = { _ in
      task.cancel()
    }
  }}
}

// MARK: - MealClient Live
// Implementation of the client for production use.
// Streams real data from the TheMealDB: https://www.themealdb.com/
extension MealClient {
  static let live = Self { .init { continuation in
    let task = Task {
      
      let rootURL = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert")!
      guard let (data, response) = try? await URLSession.shared.data(from: rootURL),
            let responseHTTP = response as? HTTPURLResponse, responseHTTP.statusCode == 200,
            let dessertsResponse = try? JSONDecoder().decode(FetchDessertsResponse.self, from: data)
      else {
        continuation.finish()
        return
      }
      
      await withTaskGroup(of: Void.self) { group in
        let ids = dessertsResponse.meals.map(\.idMeal)
        for id in ids {
          group.addTask {
            let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(id)")!
            guard let (data, response) = try? await URLSession.shared.data(from: url)
            else { return }
            guard
              let responseHTTP = response as? HTTPURLResponse, responseHTTP.statusCode == 200,
              let mealByIdResponse = try? JSONDecoder().decode(FetchMealByIdResponse.self, from: data),
              let meal = FetchMealByIdResponse.convertToMeal(mealByIdResponse)
            else { return }
            continuation.yield(meal)
          }
        }
      }
      continuation.finish()
    }
    continuation.onTermination = { _ in
      task.cancel()
    }
  }}
}

// MARK: - Intermediary types for parsing JSON.
private struct FetchDessertsResponse: Codable {
  let meals: [EachResult]
  struct EachResult: Codable {
    let strMeal: String
    let strMealThumb: String
    let idMeal: String
  }
}

private struct FetchMealByIdResponse: Codable {
  let meals: [[String: String?]]
}

extension FetchMealByIdResponse {
  static func convertToMeal(_ response: Self) -> Meal? {
    // Get the first meal, ignore the rest.
    // Assume that by fetching a meal by ID, you'd get a single meal.
    let data = response.meals.map { $0.compactMapValues { $0 } }.first!
    
    // Get the name.
    guard let name = data["strMeal"]
    else { return nil }
    
    // Get the instructions.
    guard let strInstructionsRaw = data["strInstructions"]
    else { return nil }
    let instructions = strInstructionsRaw.split(whereSeparator: \.isNewline).map { String($0) }
    
    // Collect all ingredients where we start with "strIngredient"
    // immediatelly followed and ended with a number (i.e. "strIngredient42")
    let ingredientKeys: [String] = data.keys
      .filter {
        guard let r = $0.range(of: "strIngredient"),
              r.lowerBound == $0.startIndex,
              Int(String($0[r.upperBound..<$0.endIndex])) != nil
        else { return false }
        return true
      }
      .sorted(using: KeyPathComparator(\.self))
    
    // Get the measures.
    // Collect all measures where we start with "strMeasure"
    // immediatelly followed and ended with a number (i.e. "strMeasure42")
    let measureKeys: [String] = data.keys
      .filter {
        guard let r = $0.range(of: "strMeasure"),
              r.lowerBound == $0.startIndex,
              Int(String($0[r.upperBound..<$0.endIndex])) != nil
        else { return false }
        return true
      }
      .sorted(using: KeyPathComparator(\.self))
    
    // Zip the ingredients and measures and ignore any with empty properties.
    let mealIngredients: [Meal.Ingredient] = zip(ingredientKeys, measureKeys)
      .map { .init(name: data[$0]!, measure: data[$1]!) }
      .filter { !$0.measure.isEmpty && !$0.name.isEmpty }
    
    // Get the thumbnail.
    guard let strMealThumb = data["strMealThumb"]
    else { return nil }
    let thumb = URL(string: strMealThumb)!
    
    // Return the result.
    return .init(name: name, thumbURL: thumb, instructions: instructions, ingredients: mealIngredients)
  }
}
