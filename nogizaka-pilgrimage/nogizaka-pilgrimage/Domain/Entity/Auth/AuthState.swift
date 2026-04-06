//
//  AuthState.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/02.
//

import Foundation

enum AuthState: Equatable, Sendable {
    /// 起動直後、Firebaseがキャッシュ済みトークンを確認する前
    case unknown
    case signedIn(AuthUser)
    case signedOut
}
