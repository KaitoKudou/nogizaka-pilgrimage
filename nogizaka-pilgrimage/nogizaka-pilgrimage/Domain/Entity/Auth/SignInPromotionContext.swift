//
//  SignInPromotionContext.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/07.
//

import Foundation

enum SignInPromotionContext: Equatable, Sendable {
    /// アプリ起動時（スキップ可）
    case launch
    /// チェックイン時（スキップ不可）
    case checkIn

    var isDismissible: Bool {
        switch self {
        case .launch: return true
        case .checkIn: return false
        }
    }
}
