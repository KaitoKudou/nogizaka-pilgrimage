//
//  AuthRepository+Live.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/02.
//

import Dependencies
// Firebase SDK が Sendable 未対応のため
@preconcurrency import FirebaseAuth
import Foundation

extension AuthRepository: DependencyKey {
    static let liveValue: Self = {
        return .init(
            observeAuthState: {
                AsyncStream { continuation in
                    let handle = Auth.auth().addStateDidChangeListener { _, user in
                        if let user {
                            continuation.yield(.signedIn(user.toDomain()))
                        } else {
                            continuation.yield(.signedOut)
                        }
                    }
                    continuation.onTermination = { _ in
                        Auth.auth().removeStateDidChangeListener(handle)
                    }
                }
            },
            signIn: { idToken, nonce, fullName in
                let credential = OAuthProvider.appleCredential(
                    withIDToken: idToken,
                    rawNonce: nonce,
                    fullName: fullName
                )
                let result = try await Auth.auth().signIn(with: credential)
                return result.user.toDomain()
            },
            signOut: {
                try Auth.auth().signOut()
            },
            currentUser: {
                Auth.auth().currentUser?.toDomain()
            }
        )
    }()
}

private extension FirebaseAuth.User {
    func toDomain() -> AuthUser {
        AuthUser(uid: uid, email: email, displayName: displayName)
    }
}
