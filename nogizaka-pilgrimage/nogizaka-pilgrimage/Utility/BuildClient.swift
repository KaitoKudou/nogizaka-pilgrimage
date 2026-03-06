//
//  BuildClient.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/05/01.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct BuildClient {
    var appVersion: @Sendable () -> String = { "" }
}

extension BuildClient: DependencyKey {
    static let liveValue = Self(
        appVersion: {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        }
    )
}
