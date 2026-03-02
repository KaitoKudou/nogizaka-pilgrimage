//
//  BuildClient.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/05/01.
//

import Dependencies
import Foundation

public struct BuildClient {
    public var appVersion: () -> String
}

extension BuildClient: DependencyKey {
    public static var liveValue = Self(
        appVersion: {
            Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        }
    )
}

extension BuildClient: TestDependencyKey {
    public static let previewValue = Self(
        appVersion: { "0.0.0" }
    )
}

extension DependencyValues {
  public var buildClient: BuildClient {
    get { self[BuildClient.self] }
    set { self[BuildClient.self] = newValue }
  }
}
