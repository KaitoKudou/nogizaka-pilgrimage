//
//  LaunchViewModelTests.swift
//  nogizaka-pilgrimageTests
//
//  Created by k_kudo on 2026/04/08.
//

import Dependencies
import Foundation
import Testing

@testable import nogizaka_pilgrimage

@MainActor
@Suite(.timeLimit(.minutes(1)))
struct LaunchViewModelTests {

    // MARK: - マイグレーション

    @Test("initialize()でチェックインマイグレーションが実行される")
    func initialize_callsCheckInMigration() async {
        let migrationCalled = LockIsolated(false)

        let viewModel = withDependencies {
            $0[RemoteConfigClient.self].fetchAndActivate = {}
            $0[BuildClient.self].appVersion = { "1.0.0" }
            $0[FavoriteMigrationClient.self].migrateIfNeeded = {}
            $0[CheckInMigrationClient.self].migrateIfNeeded = {
                migrationCalled.setValue(true)
            }
            $0[NetworkMonitor.self].monitorNetwork = {}
            $0[AppConfigRepository.self].fetchUpdateInfo = {
                AppUpdateInfoDTO(
                    targetVersion: "1.0.0",
                    isForce: false,
                    title: "",
                    message: "",
                    appStoreURL: ""
                )
            }
            $0[PilgrimageRepository.self].fetchAllPilgrimages = { dummyPilgrimageList }
            $0[SignInPromotionClient.self].shouldShowOnLaunch = { false }
        } operation: {
            LaunchViewModel()
        }

        await viewModel.initialize()

        #expect(migrationCalled.value == true)
    }

    @Test("dismissSignInPromotion()でチェックインマイグレーションが実行される")
    func dismissSignInPromotion_callsCheckInMigration() async {
        let migrationCalled = LockIsolated(false)

        let viewModel = withDependencies {
            $0[CheckInMigrationClient.self].migrateIfNeeded = {
                migrationCalled.setValue(true)
            }
            $0[SignInPromotionClient.self].markPromptShown = {}
        } operation: {
            LaunchViewModel()
        }

        await viewModel.dismissSignInPromotion()

        #expect(migrationCalled.value == true)
    }
}
