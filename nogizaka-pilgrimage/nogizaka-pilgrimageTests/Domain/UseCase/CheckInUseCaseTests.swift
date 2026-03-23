//
//  CheckInUseCaseTests.swift
//  nogizaka-pilgrimageTests
//
//  Created by k_kudo on 2026/03/23.
//

import CoreLocation
import Dependencies
import Foundation
import Testing

@testable import nogizaka_pilgrimage

@Suite(.timeLimit(.minutes(1)))
struct CheckInUseCaseTests {
    
    private typealias UseCase = CheckInUseCase

    // MARK: - テスト用データ

    /// 乃木坂駅（チェックイン範囲内の座標で使用）
    private static let nogizakaStation = dummyPilgrimageList[0]

    /// 乃木坂駅の座標（200m以内）
    private static let nearNogizaka = CLLocationCoordinate2D(latitude: 35.666827, longitude: 139.726497)

    /// 乃木坂駅から200m以上離れた座標
    private static let farFromNogizaka = CLLocationCoordinate2D(latitude: 35.68, longitude: 139.75)

    /// テスト用の固定日時
    private static let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)

    // MARK: - チェックイン成功

    @Test("チェックイン成功時にcheckedInAtが自動保存される")
    func execute_savesCheckedInAt() async throws {
        let savedDate = LockIsolated<Date?>(nil)

        let result = try await withDependencies {
            $0[CheckInRepository.self].isCheckedIn = { _ in false }
            $0[CheckInRepository.self].addCheckIn = { _, checkedInAt, _ in
                savedDate.setValue(checkedInAt)
            }
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try await UseCase.liveValue.execute(
                pilgrimage: Self.nogizakaStation,
                userCoordinate: Self.nearNogizaka
            )
        }

        #expect(result == true)
        #expect(savedDate.value == Self.fixedDate)
    }

    @Test("チェックイン成功時にmemoがnilで保存される")
    func execute_savesNilMemo() async throws {
        let savedMemo = LockIsolated<String??>(nil) // Optional<Optional<String>> で「呼ばれたか」と「値」を区別

        _ = try await withDependencies {
            $0[CheckInRepository.self].isCheckedIn = { _ in false }
            $0[CheckInRepository.self].addCheckIn = { _, _, memo in
                savedMemo.setValue(memo)
            }
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try await UseCase.liveValue.execute(
                pilgrimage: Self.nogizakaStation,
                userCoordinate: Self.nearNogizaka
            )
        }

        #expect(savedMemo.value == .some(nil))
    }

    // MARK: - 距離バリデーション

    @Test("200m圏外ではCheckInError.notNearbyがスローされる")
    func execute_notNearby_throws() async throws {
        await #expect(throws: CheckInError.notNearby) {
            try await withDependencies {
                $0[CheckInRepository.self].isCheckedIn = { _ in false }
                $0[CheckInRepository.self].addCheckIn = { _, _, _ in }
                $0.date = .constant(Self.fixedDate)
            } operation: {
                try await UseCase.liveValue.execute(
                    pilgrimage: Self.nogizakaStation,
                    userCoordinate: Self.farFromNogizaka
                )
            }
        }
    }

    // MARK: - 重複チェック

    @Test("既にチェックイン済みの場合falseを返す")
    func execute_alreadyCheckedIn_returnsFalse() async throws {
        let addCheckInCalled = LockIsolated(false)

        let result = try await withDependencies {
            $0[CheckInRepository.self].isCheckedIn = { _ in true }
            $0[CheckInRepository.self].addCheckIn = { _, _, _ in
                addCheckInCalled.setValue(true)
            }
            $0.date = .constant(Self.fixedDate)
        } operation: {
            try await UseCase.liveValue.execute(
                pilgrimage: Self.nogizakaStation,
                userCoordinate: Self.nearNogizaka
            )
        }

        #expect(result == false)
        #expect(addCheckInCalled.value == false)
    }
}
