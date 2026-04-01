//
//  CheckInCompletionViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/31.
//

import Dependencies
import Foundation

@MainActor
@Observable
final class CheckInCompletionViewModel {
    @ObservationIgnored
    @Dependency(CheckInRepository.self) var checkInRepository

    let input: CheckInCompletionInput
    var cumulativeCount: Int?
    var memo: String = ""

    var isMemoAtLimit: Bool {
        memo.count >= Constants.memoMaxLength
    }

    init(input: CheckInCompletionInput) {
        self.input = input
    }

    func onAppear() async {
        do {
            let pilgrimages = try await checkInRepository.fetchCheckedInPilgrimages()
            cumulativeCount = pilgrimages.count
        } catch {}
    }

    func saveMemo() async throws {
        let trimmed = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        try await checkInRepository.updateMemo(code: input.pilgrimage.code, memo: trimmed)
    }
}
