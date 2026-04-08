//
//  MenuViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/19.
//

import Dependencies
import Foundation

enum MenuDestination: Hashable {
    case openSourceLicense
    case iconLicense
}

enum MenuItem: Hashable {
    case aboutDeveloper
    case contact
    case termsOfUse
    case openSourceLicense
    case iconLicense
    case privacyPolicy
    case appVersion(String)

    var title: String {
        switch self {
        case .aboutDeveloper: return String(localized: .menuAboutDeveloper)
        case .contact: return String(localized: .menuContact)
        case .termsOfUse: return String(localized: .menuTerms)
        case .openSourceLicense: return String(localized: .menuOpenSourceLicense)
        case .iconLicense: return String(localized: .menuIconLicense)
        case .privacyPolicy: return String(localized: .menuPrivacyPolicy)
        case .appVersion(let version): return String(format: String(localized: .menuAppVersion), version)
        }
    }
}

@MainActor
@Observable
final class MenuViewModel {
    enum Action {
        case navigate(MenuDestination)
        case openURL(URL)
    }

    enum AlertType: Equatable {
        case signInError
        case signOutError
        case signOutConfirmation

        var title: String {
            switch self {
            case .signInError: return String(localized: .alertSignInError)
            case .signOutError: return String(localized: .alertSignOutError)
            case .signOutConfirmation: return String(localized: .alertSignOutConfirmation)
            }
        }
    }

    @ObservationIgnored
    @Dependency(BuildClient.self) private var buildClient
    @ObservationIgnored
    @Dependency(AuthRepository.self) private var authRepository
    @ObservationIgnored
    @Dependency(SignInUseCase.self) private var signInUseCase
    @ObservationIgnored
    @Dependency(SignOutUseCase.self) private var signOutUseCase
    @ObservationIgnored
    @Dependency(CheckInMigrationClient.self) private var checkInMigration

    var appVersion: String {
        buildClient.appVersion()
    }

    var authState: AuthState = .unknown
    var activeAlert: AlertType?
    var isSigningIn = false

    func observeAuthState() async {
        for await state in authRepository.observeAuthState() {
            self.authState = state
        }
    }

    func signInWithApple() async {
        isSigningIn = true
        defer { isSigningIn = false }
        do {
            _ = try await signInUseCase.execute()
            await checkInMigration.migrateIfNeeded()
        } catch AuthError.cancelled {
            // ユーザーがキャンセルした場合は何もしない
        } catch {
            activeAlert = .signInError
        }
    }

    func confirmSignOut() {
        activeAlert = .signOutConfirmation
    }

    func signOut() {
        do {
            try signOutUseCase.execute()
        } catch {
            activeAlert = .signOutError
        }
    }

    func action(for item: MenuItem) -> Action? {
        switch item {
        case .aboutDeveloper:
            return .openURL(URL(string: "https://twitter.com/kudokai00")!)
        case .contact:
            return .openURL(URL(string: "https://forms.gle/dVsUCgo6GkoLUqxA7")!)
        case .termsOfUse:
            return .openURL(URL(string: "https://sites.google.com/view/nogi-jyunrei/terms")!)
        case .openSourceLicense:
            return .navigate(.openSourceLicense)
        case .iconLicense:
            return .navigate(.iconLicense)
        case .privacyPolicy:
            return .openURL(URL(string: "https://sites.google.com/view/nogi-jyunrei/privacy-policy")!)
        case .appVersion:
            return nil
        }
    }
}
