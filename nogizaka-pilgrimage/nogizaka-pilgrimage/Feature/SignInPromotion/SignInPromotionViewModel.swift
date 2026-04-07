//
//  SignInPromotionViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/07.
//

import Dependencies
import Foundation

@MainActor
@Observable
final class SignInPromotionViewModel {
    @ObservationIgnored
    @Dependency(SignInUseCase.self) private var signInUseCase

    let context: SignInPromotionContext
    var isSigningIn = false
    var isCompleted = false
    var isSignedIn = false

    enum AlertType: Equatable {
        case signInError

        var title: String {
            switch self {
            case .signInError: return String(localized: .alertSignInError)
            }
        }
    }
    var activeAlert: AlertType?

    init(context: SignInPromotionContext) {
        self.context = context
    }

    func signInWithApple() async {
        isSigningIn = true
        defer { isSigningIn = false }
        do {
            _ = try await signInUseCase.execute()
            isSignedIn = true
            isCompleted = true
        } catch AuthError.cancelled {
            // ユーザーがキャンセルした場合は何もしない
        } catch {
            activeAlert = .signInError
        }
    }

    func skip() {
        isCompleted = true
    }

    func close() {
        isCompleted = true
    }
}
