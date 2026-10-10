import SwiftUI

/// Composition root: the only place that knows the concrete types.
/// It builds the object graph and creates every screen's view model with its dependencies injected.
/// Views receive it through the SwiftUI environment.
@MainActor @Observable
final class AppContainer {
    private let userService: UserServicing
    private let weatherService: WeatherServicing
    private let favorites: FavoritesRepository
    private let imageLoader: ImageDataLoading

    init() {
        let client = APIClient()
        let imageLoader = ImageLoader(client: client)
        self.imageLoader = imageLoader
        self.userService = UserService(client: client)
        self.weatherService = WeatherService(client: client)
        self.favorites = FavoritesStore(container: PersistenceController().container, imageLoader: imageLoader)
    }

    func makeUsersListViewModel() -> UsersListViewModel {
        UsersListViewModel(userService: userService, favorites: favorites)
    }

    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(favorites: favorites)
    }

    func makeUserDetailViewModel(user: User) -> UserDetailViewModel {
        UserDetailViewModel(user: user, favorites: favorites, imageLoader: imageLoader)
    }

    func makeWeatherViewModel(user: User) -> WeatherViewModel {
        WeatherViewModel(user: user, weatherService: weatherService, favorites: favorites)
    }
}
