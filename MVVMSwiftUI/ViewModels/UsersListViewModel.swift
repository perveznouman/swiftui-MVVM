import Foundation
import Observation

/// VIEW MODEL (MVVM): owns the state of the Users screen. `@Observable` makes every property trackable,
/// so the view controller can react to changes without any publisher plumbing.
/// It imports no UIKit, so it can be unit-tested with fakes.
@MainActor @Observable
final class UsersListViewModel {
    private(set) var state: ScreenState = .loading

    let title = "Users"

    private let userService: UserServicing
    private let favorites: FavoritesRepository
    private var users: [User] = []

    init(userService: UserServicing, favorites: FavoritesRepository) {
        self.userService = userService
        self.favorites = favorites
    }

    /// Derived on demand. Reading `favorites.revision` makes observers re-run when a favourite changes.
    var rows: [UserRowViewModel] {
        _ = favorites.revision
        return users.map { UserRowViewModel(user: $0, isFavorite: favorites.isFavorite($0.id)) }
    }

    /// For `.task`: SwiftUI runs it every time the view appears, so only fetch when we have nothing yet.
    func loadIfNeeded() async {
        guard users.isEmpty else { return }
        await load()
    }

    func load() async {
        if users.isEmpty { state = .loading }
        do {
            users = try await userService.fetchUsers()
            state = users.isEmpty ? .empty(message: "No users found.") : .content
        } catch {
            // Keep showing stale rows on a refresh failure; only show the error when there is nothing to show.
            if users.isEmpty {
                state = .error(message: "Couldn't load users.\n\(error.localizedDescription)\n\nFavourites are still available offline.")
            }
        }
    }

    func toggleFavorite(id: Int) {
        guard let user = users.first(where: { $0.id == id }) else { return }
        favorites.toggle(user)
    }
}
