//
//  PilgrimageDetailViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/26.
//

import AppLogger
import CoreLocation
import Dependencies
import Foundation

@Observable
final class PilgrimageDetailViewModel {
    @ObservationIgnored
    @Dependency(\.networkMonitor) var networkMonitor
    @ObservationIgnored
    @Dependency(FavoriteRepository.self) var favoriteRepository
    @ObservationIgnored
    @Dependency(CheckInRepository.self) var checkInRepository
    @ObservationIgnored
    @Dependency(CheckInUseCase.self) var checkInUseCase

    var isLoading = false
    var favorited = false
    var hasCheckedIn = false

    enum AlertType {
        case notNearbyError
        case updateCheckedInError
        case updateFavoritePilgrimagesError
        case networkError

        var title: String {
            switch self {
            case .notNearbyError: return R.string.localizable.alert_not_nearby()
            case .updateCheckedInError: return APIError.updateCheckedInError.localizedDescription
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
        async let fav: () = verifyFavorited(pilgrimage)
        async let check: () = verifyCheckedIn(pilgrimage)
        _ = await (fav, check)
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

    func checkIn(pilgrimage: PilgrimageInformation, userCoordinate: CLLocationCoordinate2D) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let isNewCheckIn = try await checkInUseCase.execute(pilgrimage, userCoordinate)
            if isNewCheckIn {
                hasCheckedIn = true
            }
        } catch is CheckInError {
            activeAlert = .notNearbyError
        } catch is APIError {
            activeAlert = .updateCheckedInError
        } catch {
            activeAlert = .networkError
        }
    }

    private func verifyFavorited(_ pilgrimage: PilgrimageInformation) async {
        do {
            favorited = try await favoriteRepository.isFavorited(pilgrimage.name)
        } catch {
            #log(.error, "verifyFavorited failed: \(error.localizedDescription)")
        }
    }

    private func verifyCheckedIn(_ pilgrimage: PilgrimageInformation) async {
        do {
            hasCheckedIn = try await checkInRepository.isCheckedIn(pilgrimage.name)
        } catch {
            #log(.error, "verifyCheckedIn failed: \(error.localizedDescription)")
        }
    }
}
