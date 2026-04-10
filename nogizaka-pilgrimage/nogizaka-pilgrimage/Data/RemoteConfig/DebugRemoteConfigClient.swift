//
//  DebugRemoteConfigClient.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/10.
//

#if DEBUG
import Dependencies
import DependenciesMacros
@preconcurrency import FirebaseRemoteConfig

@DependencyClient
struct DebugRemoteConfigClient {
    var lastFetchTime: @Sendable () -> Date?
    var allConfig: @Sendable () -> [String: String] = { [:] }
}

extension DebugRemoteConfigClient: DependencyKey {
    static let liveValue: Self = {
        let remoteConfig = RemoteConfig.remoteConfig()

        return .init(
            lastFetchTime: {
                remoteConfig.lastFetchTime
            },
            allConfig: {
                let pairs = remoteConfig.allKeys(from: .remote)
                    .map { key in
                        (key, remoteConfig.configValue(forKey: key).stringValue ?? "(nil)")
                    }
                return Dictionary(uniqueKeysWithValues: pairs)
            }
        )
    }()
}
#endif
