//
//  PilgrimageListViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/26.
//

import AppLogger
import Dependencies
import Foundation

@Observable
final class PilgrimageListViewModel {
    @ObservationIgnored
    @Dependency(\.networkMonitor) var networkMonitor
    @ObservationIgnored
    @Dependency(FavoriteRepository.self) var favoriteRepository

    var pilgrimages: [PilgrimageInformation] = []
    var searchResults: [PilgrimageInformation] = []
    var searchText = ""
    var isLoading = false
    var scrollToIndex = 0

    private var favoritedIds: Set<Int> = []
    private var loadingItems: Set<Int> = []

    enum AlertType {
        case updateFavoritePilgrimagesError
        case networkError

        var title: String {
            switch self {
            case .updateFavoritePilgrimagesError: return APIError.updateFavoritePilgrimagesError.localizedDescription
            case .networkError: return APIError.networkError.localizedDescription
            }
        }
    }
    var activeAlert: AlertType?
    var isAlertPresented: Bool {
        get { activeAlert != nil }
        set { if !newValue { activeAlert = nil } }
    }

    func isFavorited(_ pilgrimage: PilgrimageInformation) -> Bool {
        favoritedIds.contains(pilgrimage.id)
    }

    func isItemLoading(_ pilgrimage: PilgrimageInformation) -> Bool {
        loadingItems.contains(pilgrimage.id)
    }

    func onAppear(pilgrimages: [PilgrimageInformation]) {
        self.pilgrimages = pilgrimages
        searchPilgrimages(searchText)
    }

    func loadFavoriteStatuses() async {
        do {
            let favorites = try await favoriteRepository.fetchFavorites()
            favoritedIds = Set(favorites.map(\.id))
        } catch {
            #log(.error, "loadFavoriteStatuses failed: \(error.localizedDescription)")
        }
    }

    func searchPilgrimages(_ text: String) {
        isLoading = true
        defer { isLoading = false }

        if searchText != text {
            scrollToIndex = 0
        }
        searchText = text

        if text.isEmpty {
            searchResults = pilgrimages
        } else {
            let normalizedSearchText = text.normalizedString
            searchResults = pilgrimages.filter { pilgrimage in
                let normalizedSearchCandidates = pilgrimage.searchCandidateList.map { $0.normalizedString }
                return normalizedSearchCandidates.contains { candidate in
                    candidate.range(of: normalizedSearchText, options: .caseInsensitive) != nil
                }
            }
        }
    }

    func updateScrollToIndex(_ index: Int) {
        scrollToIndex = index
    }

    func toggleFavorite(pilgrimage: PilgrimageInformation) async {
        loadingItems.insert(pilgrimage.id)
        defer { loadingItems.remove(pilgrimage.id) }

        do {
            try await networkMonitor.monitorNetwork()

            if favoritedIds.contains(pilgrimage.id) {
                try await favoriteRepository.removeFavorite(pilgrimage)
                favoritedIds.remove(pilgrimage.id)
            } else {
                try await favoriteRepository.addFavorite(pilgrimage)
                favoritedIds.insert(pilgrimage.id)
            }
        } catch is APIError {
            activeAlert = .updateFavoritePilgrimagesError
        } catch {
            activeAlert = .networkError
        }
    }
}

extension String {
    var normalizedString: String {
        return folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }
}
