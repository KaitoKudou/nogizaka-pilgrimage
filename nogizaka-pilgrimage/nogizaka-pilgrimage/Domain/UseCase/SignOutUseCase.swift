//
//  SignOutUseCase.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/02.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct SignOutUseCase {
    /// サインアウトする
    var execute: @Sendable () throws -> Void
}

extension SignOutUseCase: DependencyKey {
    static let liveValue: Self = {
        @Dependency(AuthRepository.self) var authRepository

        return .init(
            execute: {
                try authRepository.signOut()
            }
        )
    }()
}
