//
//  RemoteConfigClient.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/10.
//

import Dependencies
import DependenciesMacros
@preconcurrency import FirebaseRemoteConfig

@DependencyClient
struct RemoteConfigClient {
    /// Remote Config の値をサーバーからフェッチ・アクティベートする
    var fetchAndActivate: @Sendable () async -> Void
    /// サインイン促進をスキップ可能か
    var canDismissSignInPrompt: @Sendable () -> Bool = { true }
    /// UUID ベースの Firestore 読み取りが有効か
    var isUUIDAccessEnabled: @Sendable () -> Bool = { true }
}

extension RemoteConfigClient: DependencyKey {
    static let liveValue: Self = {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0
        #else
        settings.minimumFetchInterval = 3600
        #endif
        remoteConfig.configSettings = settings
        return .init(
            fetchAndActivate: {
                do {
                    _ = try await remoteConfig.fetchAndActivate()
                } catch {
                    // フェッチ失敗時はデフォルト値で動作
                }
            },
            canDismissSignInPrompt: {
                remoteConfig[.canDismissSignInPrompt] ?? true
            },
            isUUIDAccessEnabled: {
                remoteConfig[.isUUIDAccessEnabled] ?? true
            }
        )
    }()
}
