//
//  CheckInCompletionViewModelTests.swift
//  nogizaka-pilgrimageTests
//
//  Created by k_kudo on 2026/03/31.
//

import Dependencies
import Foundation
import Testing

@testable import nogizaka_pilgrimage

@MainActor
@Suite(.timeLimit(.minutes(1)))
struct CheckInCompletionViewModelTests {

    // MARK: - テスト用データ

    private static let testInput = CheckInCompletionInput(
        pilgrimage: dummyPilgrimageList[0],
        checkedInAt: Date(timeIntervalSince1970: 1_700_000_000),
        isOnline: true
    )

    // MARK: - onAppear: 累計回数

    @Test("onAppearで累計回数が正しく取得される", arguments: [
        (input: 0, expected: 0),
        (input: 1, expected: 1),
        (input: 5, expected: 5),
    ])
    func onAppear_fetchesCumulativeCount(input: Int, expected: Int) async {
        let viewModel = withDependencies {
            $0[CheckInRepository.self].fetchCheckedInPilgrimages = {
                Array(dummyPilgrimageList.prefix(input))
            }
        } operation: {
            CheckInCompletionViewModel(input: Self.testInput)
        }

        await viewModel.onAppear()

        #expect(viewModel.cumulativeCount == expected)
    }

    @Test("onAppearでエラー時はnilのまま")
    func onAppear_errorRemainsNil() async {
        let viewModel = withDependencies {
            $0[CheckInRepository.self].fetchCheckedInPilgrimages = {
                throw APIError.fetchError
            }
        } operation: {
            CheckInCompletionViewModel(input: Self.testInput)
        }

        await viewModel.onAppear()

        #expect(viewModel.cumulativeCount == nil)
    }

    // MARK: - saveMemo: 保存される入力

    @Test("saveMemoでメモが保存される", arguments: [
        (input: "テストメモ", expected: "テストメモ"),
        (input: "  先頭空白", expected: "先頭空白"),
        (input: "末尾改行\n", expected: "末尾改行"),
        (input: " 前後空白 ", expected: "前後空白"),
        (input: String(repeating: "あ", count: 140), expected: String(repeating: "あ", count: 140)),
    ])
    func saveMemo_saves(input: String, expected: String) async throws {
        let savedMemo = LockIsolated<String?>(nil)

        let viewModel = withDependencies {
            $0[CheckInRepository.self].updateMemo = { _, memo in
                savedMemo.setValue(memo)
            }
        } operation: {
            CheckInCompletionViewModel(input: Self.testInput)
        }

        viewModel.memo = input
        try await viewModel.saveMemo()

        #expect(savedMemo.value == expected)
    }

    // MARK: - saveMemo: 保存されない入力

    @Test("saveMemoで空白系のみの場合は保存しない", arguments: [
        "",
        " ",
        "   ",
        "\n",
        " \n ",
        "\t",
    ])
    func saveMemo_whitespaceOnly_skips(input: String) async throws {
        let updateMemoCalled = LockIsolated(false)

        let viewModel = withDependencies {
            $0[CheckInRepository.self].updateMemo = { _, _ in
                updateMemoCalled.setValue(true)
            }
        } operation: {
            CheckInCompletionViewModel(input: Self.testInput)
        }

        viewModel.memo = input
        try await viewModel.saveMemo()

        #expect(updateMemoCalled.value == false)
    }

    // MARK: - isMemoAtLimit

    @Test("isMemoAtLimitが文字数上限で正しく判定される", arguments: [
        (input: "", expected: false),
        (input: "あ", expected: false),
        (input: String(repeating: "あ", count: 139), expected: false),
        (input: String(repeating: "あ", count: 140), expected: true),
    ])
    func isMemoAtLimit(input: String, expected: Bool) {
        let viewModel = CheckInCompletionViewModel(input: Self.testInput)
        viewModel.memo = input
        #expect(viewModel.isMemoAtLimit == expected)
    }

    // MARK: - saveMemo: エラー

    @Test("saveMemoでエラー時はthrowする")
    func saveMemo_error_throws() async {
        let viewModel = withDependencies {
            $0[CheckInRepository.self].updateMemo = { _, _ in
                throw APIError.updateError
            }
        } operation: {
            CheckInCompletionViewModel(input: Self.testInput)
        }

        viewModel.memo = "テストメモ"

        await #expect(throws: APIError.updateError) {
            try await viewModel.saveMemo()
        }
    }
}
