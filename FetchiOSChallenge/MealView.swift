import SwiftUI

// MARK: - MealView
struct MealView: View {
  let meal: Meal
  var body: some View {
    Form {
        AsyncImage(url: meal.thumbURL) { image in
          image
            .resizable()
            .scaledToFit()
        } placeholder: {
          ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: 600)
      Section {
        ForEach(meal.ingredients, id: \.name) { ingredient in
          HStack {
            Checkbox()
            Text("\(ingredient.measure) \(ingredient.name)")
          }
        }
      } header : {
        Text("Ingredients")
          .font(.title)
          .fontWeight(.bold)
          .foregroundColor(.black)
      }
      .textCase(nil)
      Section {
        ForEach(meal.instructions, id: \.self) { instruction in
          HStack {
            Checkbox()
            Text(instruction)
          }
        }
      } header : {
        Text("Instructions")
          .font(.title)
          .fontWeight(.bold)
          .foregroundColor(.black)
      }
      .textCase(nil)

    }
    .navigationTitle(meal.name)
  }
}

struct Checkbox: View {
  @State var checked: Bool = false
  var body: some View {
    Button {
      checked.toggle()
    } label: {
      Image(systemName: checked ? "checkmark.square" : "square")
        .foregroundColor(.black)
    }
  }
}

// MARK: - MealView Previews
struct MealView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      MealView(meal: mockMeals.first!)
    }
  }
}
