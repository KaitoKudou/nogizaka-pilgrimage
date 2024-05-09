//
//  UIApplicationClient.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/05/06.
//

import Dependencies
import UIKit

public struct UIApplicationClient {
    public var open: @Sendable (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool = {
        _, _ in false
    }
}

extension UIApplicationClient: DependencyKey {
    public static let liveValue = Self(
        open: { @MainActor in await UIApplication.shared.open($0, options: $1) }
    )
}

extension UIApplicationClient: TestDependencyKey {
    public static let previewValue = Self(
        open: { _, _ in false }
    )
}

extension DependencyValues {
  public var applicationClient: UIApplicationClient {
    get { self[UIApplicationClient.self] }
    set { self[UIApplicationClient.self] = newValue }
  }
}
