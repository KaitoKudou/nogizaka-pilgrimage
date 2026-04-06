//
//  AuthRepository.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/02.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct AuthRepository {
    /// 現在の認証状態を非同期ストリームで監視する
    var observeAuthState: @Sendable () -> AsyncStream<AuthState> = { .finished }
    /// Firebase Auth にサインインする
    var signIn: @Sendable (_ idToken: String, _ nonce: String, _ fullName: PersonNameComponents?) async throws -> AuthUser
    /// サインアウトする
    var signOut: @Sendable () throws -> Void
    /// 現在の認証済みユーザーを取得する（未認証なら nil）
    var currentUser: @Sendable () -> AuthUser? = { nil }
}
