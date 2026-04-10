//
//  SignInPromotionContext.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/07.
//

import Foundation

enum SignInPromotionContext: Equatable, Sendable {
    /// アプリ起動時のサインイン促進
    case launch
    /// チェックイン時のサインイン促進
    case checkIn
}
