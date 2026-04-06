//
//  SignInUseCase.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/02.
//

import AuthenticationServices
import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct SignInUseCase {
    /// Sign in with Apple でサインインする
    var execute: @Sendable () async throws -> AuthUser
}

extension SignInUseCase: DependencyKey {
    static let liveValue: Self = {
        @Dependency(AuthRepository.self) var authRepository

        return .init(
            execute: {
                do {
                    let helper = await AppleSignInHelper()
                    let appleCredential = try await helper.performSignIn()
                    return try await authRepository.signIn(
                        idToken: appleCredential.idToken,
                        nonce: appleCredential.nonce,
                        fullName: appleCredential.fullName
                    )
                } catch let error as ASAuthorizationError where error.code == .canceled {
                    throw AuthError.cancelled
                }
            }
        )
    }()
}
