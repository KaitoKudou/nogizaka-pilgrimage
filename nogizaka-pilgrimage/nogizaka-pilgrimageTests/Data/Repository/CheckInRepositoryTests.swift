//
//  CheckInRepositoryTests.swift
//  nogizaka-pilgrimageTests
//
//  Created by k_kudo on 2026/03/23.
//

import Dependencies
import Foundation
import Testing

@testable import nogizaka_pilgrimage

@Suite(.timeLimit(.minutes(1)))
struct CheckInRepositoryTests {

    private typealias Repository = CheckInRepository

    // MARK: - テスト用データ

    private static let pilgrimage = dummyPilgrimageList[0]
    private static let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
    private static let memo140 = String(repeating: "あ", count: 140)
    private static let memo141 = String(repeating: "あ", count: 141)

    // MARK: - addCheckIn 両DataStore呼び出し

    @Test("addCheckInでRemoteとLocalの両方にデータが保存される")
    func addCheckIn_savesBothStores() async throws {
        let remoteCalled = LockIsolated(false)
        let localCalled = LockIsolated(false)

        try await withDependencies {
            $0[CheckInRemoteDataStore.self].add = { _ in
                remoteCalled.setValue(true)
            }
            $0[CheckInLocalDataStore.self].add = { _, _, _ in
                localCalled.setValue(true)
            }
        } operation: {
            try await Repository.liveValue.addCheckIn(
                pilgrimage: Self.pilgrimage,
                checkedInAt: Self.fixedDate,
                memo: nil
            )
        }

        #expect(remoteCalled.value == true)
        #expect(localCalled.value == true)
    }

    // MARK: - addCheckIn メモバリデーション

    @Test("addCheckInで140文字のメモが保存できる")
    func addCheckIn_memo140_succeeds() async throws {
        let savedMemo = LockIsolated<String?>(nil)

        try await withDependencies {
            $0[CheckInRemoteDataStore.self].add = { _ in }
            $0[CheckInLocalDataStore.self].add = { _, _, memo in
                savedMemo.setValue(memo)
            }
        } operation: {
            try await Repository.liveValue.addCheckIn(
                pilgrimage: Self.pilgrimage,
                checkedInAt: Self.fixedDate,
                memo: Self.memo140
            )
        }

        #expect(savedMemo.value == Self.memo140)
    }

    @Test("addCheckInで141文字のメモはmemoTooLongエラーになる")
    func addCheckIn_memo141_throws() async throws {
        await #expect(throws: CheckInError.memoTooLong) {
            try await withDependencies {
                $0[CheckInRemoteDataStore.self].add = { _ in }
                $0[CheckInLocalDataStore.self].add = { _, _, _ in }
            } operation: {
                try await Repository.liveValue.addCheckIn(
                    pilgrimage: Self.pilgrimage,
                    checkedInAt: Self.fixedDate,
                    memo: Self.memo141
                )
            }
        }
    }

    // MARK: - updateCheckedInAt

    @Test("updateCheckedInAtでRemoteとLocalの両方の日時が更新される")
    func updateCheckedInAt_updatesBothStores() async throws {
        let newDate = Date(timeIntervalSince1970: 1_800_000_000)
        let remoteSavedDate = LockIsolated<Date?>(nil)
        let localSavedDate = LockIsolated<Date?>(nil)

        try await withDependencies {
            $0[CheckInRemoteDataStore.self].updateCheckedInAt = { _, date in
                remoteSavedDate.setValue(date)
            }
            $0[CheckInLocalDataStore.self].updateCheckedInAt = { _, date in
                localSavedDate.setValue(date)
            }
        } operation: {
            try await Repository.liveValue.updateCheckedInAt(
                code: Self.pilgrimage.code,
                newDate: newDate
            )
        }

        #expect(remoteSavedDate.value == newDate)
        #expect(localSavedDate.value == newDate)
    }

    // MARK: - updateMemo メモバリデーション

    @Test("updateMemoで140文字のメモが保存できる")
    func updateMemo_memo140_succeeds() async throws {
        let savedMemo = LockIsolated<String?>(Self.memo141)

        try await withDependencies {
            $0[CheckInRemoteDataStore.self].updateMemo = { _, memo in
                savedMemo.setValue(memo)
            }
            $0[CheckInLocalDataStore.self].updateMemo = { _, _ in }
        } operation: {
            try await Repository.liveValue.updateMemo(
                code: Self.pilgrimage.code,
                memo: Self.memo140
            )
        }

        #expect(savedMemo.value == Self.memo140)
    }

    @Test("updateMemoで141文字のメモはmemoTooLongエラーになる")
    func updateMemo_memo141_throws() async throws {
        await #expect(throws: CheckInError.memoTooLong) {
            try await withDependencies {
                $0[CheckInRemoteDataStore.self].updateMemo = { _, _ in }
                $0[CheckInLocalDataStore.self].updateMemo = { _, _ in }
            } operation: {
                try await Repository.liveValue.updateMemo(
                    code: Self.pilgrimage.code,
                    memo: Self.memo141
                )
            }
        }
    }

    @Test("updateMemoでnilを渡すとメモが削除される")
    func updateMemo_nil_deleteMemo() async throws {
        let savedMemo = LockIsolated<String??>(Self.memo140)

        try await withDependencies {
            $0[CheckInRemoteDataStore.self].updateMemo = { _, memo in
                savedMemo.setValue(memo)
            }
            $0[CheckInLocalDataStore.self].updateMemo = { _, _ in }
        } operation: {
            try await Repository.liveValue.updateMemo(
                code: Self.pilgrimage.code,
                memo: nil
            )
        }

        #expect(savedMemo.value == .some(nil))
    }
}
