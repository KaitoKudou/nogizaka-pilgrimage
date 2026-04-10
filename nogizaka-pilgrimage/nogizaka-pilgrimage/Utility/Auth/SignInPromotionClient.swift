//
//  SignInPromotionClient.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/07.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct SignInPromotionClient {
    /// 起動時にサインイン促進を表示すべきか判定する
    var shouldShowOnLaunch: @Sendable () -> Bool = { false }
    /// サインイン促進を表示済みとしてマークする
    var markPromptShown: @Sendable () -> Void
}

extension SignInPromotionClient: DependencyKey {
    static let liveValue: Self = {
        @Dependency(AuthRepository.self) var authRepository
        @Dependency(BuildClient.self) var buildClient
        @Dependency(RemoteConfigClient.self) var remoteConfigClient

        return .init(
            shouldShowOnLaunch: {
                guard authRepository.currentUser() == nil else { return false }
                if !remoteConfigClient.canDismissSignInPrompt() {
                    return true
                }
                let lastVersion = UserDefaults.standard.string(forKey: UserDefaultsKey.lastSignInPromptVersion.rawValue)
                return lastVersion != buildClient.appVersion()
            },
            markPromptShown: {
                let version = buildClient.appVersion()
                UserDefaults.standard.set(version, forKey: UserDefaultsKey.lastSignInPromptVersion.rawValue)
            }
        )
    }()
}
