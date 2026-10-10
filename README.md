# MVVM in SwiftUI: Users, Favourites & Weather (Observation + Core Data)

Same app and features as the UIKit MVVM and MVC samples, rebuilt with SwiftUI.
Open `MVVMSwiftUI.xcodeproj`, run on an iPhone simulator (iOS 17+). Run tests with Cmd+U.

## What stays the same as UIKit MVVM
Models, services, Core Data persistence and the four `@Observable` view models are carried over almost unchanged. They never import UIKit or SwiftUI views, which is exactly why they port cleanly.

## What changes with SwiftUI
| Concern | UIKit MVVM | SwiftUI MVVM |
|---|---|---|
| Binding VM to view | `bind(_:apply:)` helper over `withObservationTracking`, re-armed by hand | Automatic: `body` reads `@Observable` properties and SwiftUI re-renders |
| View | `UIViewController` + `UITableView` + manual cell config | `struct ...View` (`List`, `NavigationLink`, `.task`, `.refreshable`) |
| Holding the VM | stored property | `@State private var viewModel` (keeps it alive across `body` re-evaluations) |
| Dependency wiring | `AppContainer` passed to view controllers via `ScreenFactory` | `AppContainer` injected with `.environment(container)`; views ask it for view models |
| Navigation | view controller pushes the next one | value-based `NavigationStack` with a `Route` enum (`Route.swift`) and `navigationDestination(for:)` |
| Loading/empty/error UI | custom `StateView` | `ContentUnavailableView` + `ProgressView` |

## Layers
- **Model**: `Models/`, `Services/` (protocols + implementations), `Persistence/` (Core Data, `FavoritesStore`)
- **ViewModel**: `ViewModels/` (display-ready strings, state enums, no UI imports)
- **View**: `Views/` (pure SwiftUI, no logic)
- **Composition root**: `App/AppContainer.swift`

## Tests
28 unit tests in `MVVMSwiftUITests/` cover the view models with fakes, including that they are observable.

## Notes
- `AppContainer` is itself `@Observable` only so it can live in the SwiftUI environment; it has no observed state.
- Because navigation is data (`Route`), deep links and state restoration become a matter of appending routes to a path.
