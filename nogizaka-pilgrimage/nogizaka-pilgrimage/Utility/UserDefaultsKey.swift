//
//  UserDefaultsKey.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/08.
//

import Foundation

enum UserDefaultsKey: String, CaseIterable {
    /// サインイン促進を最後に表示したアプリバージョン
    case lastSignInPromptVersion
    /// お気に入りデータのローカル移行が完了したか
    case hasMigratedFavoritesToLocal
    /// チェックイン記録のリモート→ローカル初回読み込みが完了したか
    case hasLoadedCheckInsOnce
    /// UUID→Firebase Auth IDへのチェックインデータ移行が完了したか
    case hasCompletedCheckInMigration
}
