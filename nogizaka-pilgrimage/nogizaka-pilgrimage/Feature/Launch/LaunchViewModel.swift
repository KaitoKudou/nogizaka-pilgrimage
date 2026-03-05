//
//  LaunchViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/25.
//

import Dependencies
import Foundation

@Observable
final class LaunchViewModel {
    @ObservationIgnored
    @Dependency(\.buildClient) var buildClient
    @ObservationIgnored
    @Dependency(\.networkMonitor) var networkMonitor
    @ObservationIgnored
    @Dependency(PilgrimageRepository.self) var pilgrimageRepository
    @ObservationIgnored
    @Dependency(AppConfigRepository.self) var appConfigRepository
    @ObservationIgnored
    @Dependency(FavoriteMigrationClient.self) var favoriteMigration

    var pilgrimages: [PilgrimageEntity] = []
    var isLoading = true
    var pendingUpdate: AppUpdateInformation?

    enum AlertType {
        case updatePromotion(AppUpdateInformation)
        case fetchError
        case networkError

        var title: String {
            switch self {
            case .updatePromotion(let info): return info.title
            case .fetchError: return APIError.fetchError.localizedDescription
            case .networkError: return APIError.networkError.localizedDescription
            }
        }
    }
    var activeAlert: AlertType?
    var isAlertPresented: Bool {
        get { activeAlert != nil }
        set { if !newValue { activeAlert = nil } }
    }

    var isReady: Bool {
        !isLoading && !pilgrimages.isEmpty && pendingUpdate == nil
    }

    func initialize() async {
        await checkForUpdate()
        await favoriteMigration.migrateIfNeeded()
        await fetchAllPilgrimages()
    }

    func fetchAllPilgrimages() async {
        isLoading = true
        defer { isLoading = false }

        do {
            pilgrimages = try await pilgrimageRepository.fetchAllPilgrimages()
                .sorted { $0.code < $1.code }
        } catch is APIError {
            activeAlert = .fetchError
        } catch {
            activeAlert = .networkError
        }
    }

    func dismissUpdate() {
        pendingUpdate = nil
    }

    private func checkForUpdate() async {
        do {
            try await networkMonitor.monitorNetwork()
            let appUpdateInfo = try await appConfigRepository.fetchUpdateInfo()

            if appUpdateInfo.targetVersion.compare(buildClient.appVersion()) == .orderedDescending {
                pendingUpdate = appUpdateInfo
                activeAlert = .updatePromotion(appUpdateInfo)
            }
        } catch {
            activeAlert = .networkError
        }
    }
}
