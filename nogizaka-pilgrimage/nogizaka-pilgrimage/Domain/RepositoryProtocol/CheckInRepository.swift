//
//  CheckInRepository.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/03.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct CheckInRepository {
    /// チェックイン済みの聖地一覧を取得する
    var fetchCheckedInPilgrimages: @Sendable () async throws -> [PilgrimageEntity]
    /// 指定コードの聖地がチェックイン済みか判定する
    var isCheckedIn: @Sendable (_ code: String) async throws -> Bool
    /// 新規チェックイン記録を追加する
    var addCheckIn: @Sendable (_ pilgrimage: PilgrimageEntity, _ checkedInAt: Date, _ memo: String?) async throws -> Void
    /// 指定コードの訪問日時を更新する
    var updateCheckedInAt: @Sendable (_ code: String, _ newDate: Date) async throws -> Void
    /// 指定コードのメモを更新する（nilで削除）
    var updateMemo: @Sendable (_ code: String, _ memo: String?) async throws -> Void
}
