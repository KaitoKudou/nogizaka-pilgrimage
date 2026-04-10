//
//  PilgrimageDetailViewModelTests.swift
//  nogizaka-pilgrimageTests
//
//  Created by k_kudo on 2026/04/07.
//

import CoreLocation
import Dependencies
import Foundation
import Testing

@testable import nogizaka_pilgrimage

private let testPilgrimage = dummyPilgrimageList[0]
private let testCoordinate = CLLocationCoordinate2D(
    latitude: testPilgrimage.coordinate.latitude,
    longitude: testPilgrimage.coordinate.longitude
)

@MainActor
@Suite(.timeLimit(.minutes(1)))
struct PilgrimageDetailViewModelTests {

    // MARK: - チェックイン認証ゲート

    @Test("サインイン済みでcheckInすると直接チェックインが実行される")
    func checkIn_signedIn_performsDirectly() async {
        let checkInCalled = LockIsolated(false)

        let viewModel = withDependencies {
            $0[CheckInUseCase.self].execute = { _, _ in
                checkInCalled.setValue(true)
            }
            $0[NetworkMonitor.self].monitorNetwork = {}
            $0.date = .constant(Date(timeIntervalSince1970: 1_700_000_000))
        } operation: {
            PilgrimageDetailViewModel()
        }

        await viewModel.checkIn(pilgrimage: testPilgrimage, userCoordinate: testCoordinate)

        #expect(checkInCalled.value == true)
        #expect(viewModel.showSignInPromotion == false)
    }

    @Test("UseCaseがsignInRequiredをスローするとサインイン促進が表示される")
    func checkIn_signInRequired_showsPromotion() async {
        let viewModel = withDependencies {
            $0[CheckInUseCase.self].execute = { _, _ in
                throw CheckInError.signInRequired
            }
        } operation: {
            PilgrimageDetailViewModel()
        }

        await viewModel.checkIn(pilgrimage: testPilgrimage, userCoordinate: testCoordinate)

        #expect(viewModel.showSignInPromotion == true)
    }

    // MARK: - サインイン促進完了後

    @Test("サインイン成功後にpendingCheckInが実行される")
    func onPromotionCompleted_signedIn_resumesCheckIn() async {
        let checkInCalled = LockIsolated(false)
        let callCount = LockIsolated(0)

        let viewModel = withDependencies {
            $0[CheckInUseCase.self].execute = { _, _ in
                let count = callCount.withValue { $0 += 1; return $0 }
                if count == 1 {
                    throw CheckInError.signInRequired
                }
                checkInCalled.setValue(true)
            }
            $0[CheckInMigrationClient.self].migrateIfNeeded = {}
            $0[NetworkMonitor.self].monitorNetwork = {}
            $0.date = .constant(Date(timeIntervalSince1970: 1_700_000_000))
        } operation: {
            PilgrimageDetailViewModel()
        }

        // チェックイン試行 → signInRequired → 促進画面表示
        await viewModel.checkIn(pilgrimage: testPilgrimage, userCoordinate: testCoordinate)
        #expect(viewModel.showSignInPromotion == true)

        // サインイン成功で促進画面を閉じる → pendingCheckInが実行される
        await viewModel.onSignInPromotionCompleted(signedIn: true)

        #expect(viewModel.showSignInPromotion == false)
        #expect(checkInCalled.value == true)
    }

    @Test("サインイン成功後にマイグレーションがチェックインより先に実行される")
    func onPromotionCompleted_signedIn_migratesBeforeCheckIn() async {
        let callOrder = LockIsolated<[String]>([])
        let callCount = LockIsolated(0)

        let viewModel = withDependencies {
            $0[CheckInMigrationClient.self].migrateIfNeeded = {
                callOrder.withValue { $0.append("migration") }
            }
            $0[CheckInUseCase.self].execute = { _, _ in
                let count = callCount.withValue { $0 += 1; return $0 }
                if count == 1 {
                    throw CheckInError.signInRequired
                }
                callOrder.withValue { $0.append("checkIn") }
            }
            $0[NetworkMonitor.self].monitorNetwork = {}
            $0.date = .constant(Date(timeIntervalSince1970: 1_700_000_000))
        } operation: {
            PilgrimageDetailViewModel()
        }

        await viewModel.checkIn(pilgrimage: testPilgrimage, userCoordinate: testCoordinate)
        await viewModel.onSignInPromotionCompleted(signedIn: true)

        #expect(callOrder.value == ["migration", "checkIn"])
    }

    @Test("サインイン失敗後はpendingCheckInがクリアされる")
    func onPromotionCompleted_notSignedIn_clearsPending() async {
        let checkInCalled = LockIsolated(false)

        let viewModel = withDependencies {
            $0[CheckInUseCase.self].execute = { _, _ in
                throw CheckInError.signInRequired
            }
        } operation: {
            PilgrimageDetailViewModel()
        }

        // チェックイン試行 → 促進画面表示
        await viewModel.checkIn(pilgrimage: testPilgrimage, userCoordinate: testCoordinate)

        // サインインせずに閉じる
        await viewModel.onSignInPromotionCompleted(signedIn: false)

        #expect(viewModel.showSignInPromotion == false)
        #expect(checkInCalled.value == false)
    }
}
