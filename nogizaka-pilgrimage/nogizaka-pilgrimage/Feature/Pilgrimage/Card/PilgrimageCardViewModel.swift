//
//  PilgrimageCardViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/26.
//

import AppLogger
import Dependencies
import Foundation

@Observable
final class PilgrimageCardViewModel {
    @ObservationIgnored
    @Dependency(\.networkMonitor) var networkMonitor
    @ObservationIgnored
    @Dependency(\.routeActionClient) var routeActionClient
    @ObservationIgnored
    @Dependency(FavoriteRepository.self) var favoriteRepository

    var isLoading = false
    var favorited = false

    var isConfirmationDialogPresented = false
    private(set) var routeLatitude = ""
    private(set) var routeLongitude = ""

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

    func onAppear(pilgrimage: PilgrimageInformation) async {
        do {
            favorited = try await favoriteRepository.isFavorited(pilgrimage.name)
        } catch {
            #log(.error, "verifyFavorited failed: \(error.localizedDescription)")
        }
    }

    func toggleFavorite(_ pilgrimage: PilgrimageInformation) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await networkMonitor.monitorNetwork()

            let exists = try await favoriteRepository.isFavorited(pilgrimage.name)
            if exists {
                try await favoriteRepository.removeFavorite(pilgrimage)
                favorited = false
            } else {
                try await favoriteRepository.addFavorite(pilgrimage)
                favorited = true
            }
        } catch is APIError {
            activeAlert = .updateFavoritePilgrimagesError
        } catch {
            activeAlert = .networkError
        }
    }

    func showRouteDialog(latitude: String, longitude: String) {
        routeLatitude = latitude
        routeLongitude = longitude
        isConfirmationDialogPresented = true
    }

    func openAppleMaps() async {
        await routeActionClient.viewOnMap(routeLatitude, routeLongitude)
    }

    func openGoogleMaps() async {
        await routeActionClient.viewOnGoogleMaps(routeLatitude, routeLongitude)
    }
}
