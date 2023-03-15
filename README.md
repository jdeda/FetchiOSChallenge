# 🍩 Fetch iOS Challenge
This repo demonstrates fetching data from [TheMealDB](https://www.themealdb.com/).

# Table of Contents
- [Table of Contents](#table-of-contents)
- [The Challenge](#the-challenge)
- [Solution Part 1: Data](#solution-part-1-data)
- [Solution Part 2: View](#solution-part-2-view)
- [Solution Part 3: API Client](#solution-part-3-api-client)
- [Parting Thoughts](#parting-thoughts)

# The Challenge
1. Display a list of meals, specifically just all the desserts from the API
2. When clicking on one of these meals, navigate to a new screen that displays the meals name, instructions, and ingredients/measurements.
3. Ignore any empty or null data from the API

It is worth nothing that I added the thumbnails. I did this just because they really make things look so much better and it really isn't much work to add them.

# Solution Part 1: Data
The first thing I did was look at the two API endpoints [here](https://themealdb.com/api/json/v1/1/filter.php?c=Dessert) and [here](https://themealdb.com/api/json/v1/1/lookup.php?i=MEAL_ID). Based off the JSON, I stubbed out some codable types and created some mock data so I could get to writing out some view code.

# Solution Part 2: View
After my mock data was written, I immediately wrote out the view code to get things going. The view and state management are written via vanilla SwiftUI and MVVM. Once the view was in place, it was time to actually start writing the client to handle streaming the data from the API. 

# Solution Part 3: API Client
This where the meat of this app really is. I decided to delegate all the logic for streaming data from the API into a single dedicated type:
```swift
struct MealClient {
  let fetchMeals: @Sendable () -> AsyncStream<Meal>
}
```
I simply implemented two `static let` versions, one for preview using mock data and emulating fetch time, the other for live production. Once this was in place, the app was ready to go!

# Parting Thoughts
For more information about implementation, please refer to the repo.
