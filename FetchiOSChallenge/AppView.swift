import SwiftUI

// MARK: - AppView
struct AppView: View {
  @ObservedObject var vm: AppViewModel
  
  var body: some View {
    NavigationStack {
      List {
        ForEach(vm.meals, id: \.name) { meal in
          NavigationLink {
            MealView(meal: meal)
          } label: {
            HStack {
              AsyncImage(url: meal.thumbURL) { image in
                image
                  .resizable()
                  .scaledToFit()
              } placeholder: {
                ProgressView()
              }
              .frame(width: 50, height: 50)
              .background(Color(.systemGray6))
              .clipShape(Circle())
              Text(meal.name)
            }

          }
        }
      }
      .taskOnFirstAppear { await vm.task() }
      .navigationTitle("Meals")
      .toolbar {
        ToolbarItemGroup(placement: .bottomBar) {
          Text("\(vm.meals.count) meals")
        }
      }
    }
  }
}

// MARK: - AppViewModel
final class AppViewModel: ObservableObject {
  @Published var meals: [Meal] = []
  let mealClient: MealClient
  
  init(mealClient: MealClient) {
    self.mealClient = mealClient
  }
  
  @MainActor
  func task() async {
    for await meal in mealClient.fetchMeals() {
      let i = meals.firstIndex(where: { meal.name < $0.name }) ?? meals.count
      meals.insert(meal, at: i) // Insert in alphabetical order.
    }
  }
}

// MARK: - AppView Previews
struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(vm: .init(mealClient: .preview))
  }
}
