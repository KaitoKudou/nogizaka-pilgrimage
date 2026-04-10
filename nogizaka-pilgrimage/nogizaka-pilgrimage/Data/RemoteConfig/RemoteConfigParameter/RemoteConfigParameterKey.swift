//
//  RemoteConfigParameterKey.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/04/10.
//

import FirebaseRemoteConfig

// MARK: - RemoteConfigParameterKey

struct RemoteConfigParameterKey<T> {
    let key: String

    init(_ key: String) {
        self.key = key
    }
}

extension RemoteConfigParameterKey {
    static var canDismissSignInPrompt: RemoteConfigParameterKey<Bool> { .init("can_dismiss_signin_prompt") }
    static var isUUIDAccessEnabled: RemoteConfigParameterKey<Bool> { .init("is_uuid_access_enabled") }
}

// MARK: - RemoteConfig Extension

extension RemoteConfig {
    func remoteBoolValue(forKey key: String) -> Bool? {
        let value = configValue(forKey: key)
        return value.source == .remote ? value.boolValue : nil
    }

    subscript(key: RemoteConfigParameterKey<Bool>) -> Bool? {
        remoteBoolValue(forKey: key.key)
    }
}
