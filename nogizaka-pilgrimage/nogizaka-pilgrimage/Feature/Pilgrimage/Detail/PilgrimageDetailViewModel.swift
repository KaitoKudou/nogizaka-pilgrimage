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

@MainActor
@Observable
final class PilgrimageDetailViewModel {
    @ObservationIgnored
    @Dependency(FavoriteRepository.self) var favoriteRepository
    @ObservationIgnored
    @Dependency(CheckInRepository.self) var checkInRepository
    @ObservationIgnored
    @Dependency(CheckInUseCase.self) var checkInUseCase
    @ObservationIgnored
    @Dependency(NetworkMonitor.self) var networkMonitor
    @ObservationIgnored
    @Dependency(SignInPromotionClient.self) var signInPromotionClient
    @ObservationIgnored
    @Dependency(\.date) var date

    var isLoading = false
    var favorited = false
    var hasCheckedIn = false
    var checkInCompletion: CheckInCompletionInput?
    var showSignInPromotion = false
    private var pendingCheckIn: (pilgrimage: PilgrimageEntity, userCoordinate: CLLocationCoordinate2D)?

    enum AlertType {
        case notNearbyError
        case updateError
        case networkError

        var title: String {
            switch self {
            case .notNearbyError: return String(localized: .alertNotNearby)
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
        if signInPromotionClient.shouldShowOnCheckIn() {
            pendingCheckIn = (pilgrimage, userCoordinate)
            showSignInPromotion = true
            return
        }
        await performCheckIn(pilgrimage: pilgrimage, userCoordinate: userCoordinate)
    }

    func onSignInPromotionCompleted(signedIn: Bool) async {
        showSignInPromotion = false
        if signedIn, let pending = pendingCheckIn {
            pendingCheckIn = nil
            await performCheckIn(pilgrimage: pending.pilgrimage, userCoordinate: pending.userCoordinate)
        } else {
            pendingCheckIn = nil
        }
    }

    private func performCheckIn(pilgrimage: PilgrimageEntity, userCoordinate: CLLocationCoordinate2D) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await checkInUseCase.execute(pilgrimage, userCoordinate)
            hasCheckedIn = true

            let isOnline: Bool
            do {
                try await networkMonitor.monitorNetwork()
                isOnline = true
            } catch {
                isOnline = false
            }

            checkInCompletion = CheckInCompletionInput(
                pilgrimage: pilgrimage,
                checkedInAt: date.now,
                isOnline: isOnline
            )
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
