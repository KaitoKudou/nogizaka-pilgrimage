//
//  FavoriteViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/24.
//

import Dependencies
import Foundation

@Observable
final class FavoriteViewModel {
    @ObservationIgnored
    @Dependency(\.networkMonitor) var networkMonitor
    @ObservationIgnored
    @Dependency(FavoriteRepository.self) var favoriteRepository

    var favoritePilgrimages: [PilgrimageInformation] = []
    var isLoading = false
    var alertMessage: String?
    var showAlert = false
    var scrollToIndex = 0

    private var loadingItems: Set<Int> = []

    func isItemLoading(_ pilgrimage: PilgrimageInformation) -> Bool {
        loadingItems.contains(pilgrimage.id)
    }

    func fetchFavorites() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await networkMonitor.monitorNetwork()
            favoritePilgrimages = try await favoriteRepository.fetchFavorites()
        } catch let error as APIError {
            alertMessage = error.localizedDescription
            showAlert = true
        } catch {
            alertMessage = APIError.unknownError.localizedDescription
            showAlert = true
        }
    }

    func toggleFavorite(_ pilgrimage: PilgrimageInformation) async {
        loadingItems.insert(pilgrimage.id)
        defer { loadingItems.remove(pilgrimage.id) }

        do {
            try await networkMonitor.monitorNetwork()

            let exists = try await favoriteRepository.isFavorited(pilgrimage.name)
            if exists {
                try await favoriteRepository.removeFavorite(pilgrimage)
                favoritePilgrimages.removeAll { $0.id == pilgrimage.id }
            } else {
                try await favoriteRepository.addFavorite(pilgrimage)
                favoritePilgrimages.append(pilgrimage)
            }
        } catch let error as APIError {
            alertMessage = error.localizedDescription
            showAlert = true
        } catch {
            alertMessage = APIError.unknownError.localizedDescription
            showAlert = true
        }
    }
}
