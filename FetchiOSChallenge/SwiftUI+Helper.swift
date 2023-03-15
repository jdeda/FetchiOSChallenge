import SwiftUI

// MARK: - TaskOnFirstAppear View Modifier
// Essentially an overload of existing `.task` view modifier, but executes logic only once!
// Uses virtually identical signature.
public extension View {
  func taskOnFirstAppear(
    priority: TaskPriority = .userInitiated,
    _ action: @escaping @Sendable () async -> Void
  ) -> some View {
    modifier(TaskOnFirstAppear(action: action))
  }
}

private struct TaskOnFirstAppear: ViewModifier {
  let action: @Sendable () async -> Void
  
  @State private var hasAppeared = false
  
  init(action: @escaping @Sendable () async -> Void) {
    self.action = action
  }
  
  func body(content: Content) -> some View {
    content.task {
      guard !hasAppeared else { return }
      hasAppeared = true
      await action()
    }
  }
}

