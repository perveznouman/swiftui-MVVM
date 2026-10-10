import Foundation
import Observation

@MainActor @Observable
final class FavoritesViewModel {
    let title = "Favourites"

    private let favorites: FavoritesRepository

    init(favorites: FavoritesRepository) {
        self.favorites = favorites
    }

    private var users: [User] {
        _ = favorites.revision // re-evaluate observers whenever favourites change
        return favorites.allFavorites()
    }

    var rows: [UserRowViewModel] {
        users.map { UserRowViewModel(user: $0, isFavorite: true) }
    }

    var state: ScreenState {
        users.isEmpty
            ? .empty(message: "No favourites yet.\nOpen a user and tap the star to save them for offline use.")
            : .content
    }

    func remove(id: Int) {
        guard let user = users.first(where: { $0.id == id }) else { return }
        favorites.toggle(user)
    }
}
