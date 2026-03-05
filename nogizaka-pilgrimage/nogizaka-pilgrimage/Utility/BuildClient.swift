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
    var appVersion: () -> String = { "" }
}

extension BuildClient: DependencyKey {
    static var liveValue = Self(
        appVersion: {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        }
    )
}
