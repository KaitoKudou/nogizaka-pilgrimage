//
//  PilgrimageCardViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/26.
//

import AppLogger
import Dependencies
import Foundation

@MainActor
@Observable
final class PilgrimageCardViewModel {
    @ObservationIgnored
    @Dependency(RouteActionClient.self) var routeActionClient
    @ObservationIgnored
    @Dependency(FavoriteRepository.self) var favoriteRepository

    var isLoading = false
    var favorited = false

    var isConfirmationDialogPresented = false
    private(set) var routeLatitude = ""
    private(set) var routeLongitude = ""

    enum AlertType {
        case updateError
        case networkError

        var title: String {
            switch self {
            case .updateError: return APIError.updateError.localizedDescription
            case .networkError: return APIError.networkError.localizedDescription
            }
        }
    }
    var activeAlert: AlertType?
    var isAlertPresented: Bool {
        get { activeAlert != nil }
        set { if !newValue { activeAlert = nil } }
    }

    func onAppear(pilgrimage: PilgrimageEntity) async {
        do {
            favorited = try await favoriteRepository.isFavorited(pilgrimage.code)
        } catch {
            #log(.error, "verifyFavorited failed: \(error.localizedDescription)")
        }
    }

    func toggleFavorite(_ pilgrimage: PilgrimageEntity) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let exists = try await favoriteRepository.isFavorited(pilgrimage.code)
            if exists {
                try await favoriteRepository.removeFavorite(pilgrimage)
                favorited = false
            } else {
                try await favoriteRepository.addFavorite(pilgrimage)
                favorited = true
            }
        } catch is APIError {
            activeAlert = .updateError
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
