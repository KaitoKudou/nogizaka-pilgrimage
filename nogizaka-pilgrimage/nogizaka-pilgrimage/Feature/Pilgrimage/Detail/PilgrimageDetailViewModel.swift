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
        case updateError
        case networkError

        var title: String {
            switch self {
            case .notNearbyError: return R.string.localizable.alert_not_nearby()
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
        async let fav: () = verifyFavorited(pilgrimage)
        async let check: () = verifyCheckedIn(pilgrimage)
        _ = await (fav, check)
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

    func checkIn(pilgrimage: PilgrimageEntity, userCoordinate: CLLocationCoordinate2D) async {
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
            activeAlert = .updateError
        } catch {
            activeAlert = .networkError
        }
    }

    private func verifyFavorited(_ pilgrimage: PilgrimageEntity) async {
        do {
            favorited = try await favoriteRepository.isFavorited(pilgrimage.code)
        } catch {
            #log(.error, "verifyFavorited failed: \(error.localizedDescription)")
        }
    }

    private func verifyCheckedIn(_ pilgrimage: PilgrimageEntity) async {
        do {
            hasCheckedIn = try await checkInRepository.isCheckedIn(pilgrimage.code)
        } catch {
            #log(.error, "verifyCheckedIn failed: \(error.localizedDescription)")
        }
    }
}
