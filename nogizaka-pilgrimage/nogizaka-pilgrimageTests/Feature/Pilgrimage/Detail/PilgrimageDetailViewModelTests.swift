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
            $0[SignInPromotionClient.self].shouldShowOnCheckIn = { false }
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

    @Test("未サインインでcheckInするとサインイン促進が表示される")
    func checkIn_notSignedIn_showsPromotion() async {
        let checkInCalled = LockIsolated(false)

        let viewModel = withDependencies {
            $0[SignInPromotionClient.self].shouldShowOnCheckIn = { true }
            $0[CheckInUseCase.self].execute = { _, _ in
                checkInCalled.setValue(true)
            }
        } operation: {
            PilgrimageDetailViewModel()
        }

        await viewModel.checkIn(pilgrimage: testPilgrimage, userCoordinate: testCoordinate)

        #expect(viewModel.showSignInPromotion == true)
        #expect(checkInCalled.value == false)
    }

    // MARK: - サインイン促進完了後

    @Test("サインイン成功後にpendingCheckInが実行される")
    func onPromotionCompleted_signedIn_resumesCheckIn() async {
        let checkInCalled = LockIsolated(false)

        let viewModel = withDependencies {
            $0[SignInPromotionClient.self].shouldShowOnCheckIn = { true }
            $0[CheckInUseCase.self].execute = { _, _ in
                checkInCalled.setValue(true)
            }
            $0[NetworkMonitor.self].monitorNetwork = {}
            $0.date = .constant(Date(timeIntervalSince1970: 1_700_000_000))
        } operation: {
            PilgrimageDetailViewModel()
        }

        // チェックイン試行 → 促進画面表示
        await viewModel.checkIn(pilgrimage: testPilgrimage, userCoordinate: testCoordinate)
        #expect(viewModel.showSignInPromotion == true)

        // サインイン成功で促進画面を閉じる
        viewModel.onSignInPromotionCompleted(signedIn: true)

        // pendingCheckInが実行されるまで待つ
        try? await Task.sleep(for: .milliseconds(100))

        #expect(viewModel.showSignInPromotion == false)
        #expect(checkInCalled.value == true)
    }

    @Test("サインイン失敗後はpendingCheckInがクリアされる")
    func onPromotionCompleted_notSignedIn_clearsPending() async {
        let checkInCalled = LockIsolated(false)

        let viewModel = withDependencies {
            $0[SignInPromotionClient.self].shouldShowOnCheckIn = { true }
            $0[CheckInUseCase.self].execute = { _, _ in
                checkInCalled.setValue(true)
            }
        } operation: {
            PilgrimageDetailViewModel()
        }

        // チェックイン試行 → 促進画面表示
        await viewModel.checkIn(pilgrimage: testPilgrimage, userCoordinate: testCoordinate)

        // サインインせずに閉じる
        viewModel.onSignInPromotionCompleted(signedIn: false)

        #expect(viewModel.showSignInPromotion == false)
        #expect(checkInCalled.value == false)
    }
}
