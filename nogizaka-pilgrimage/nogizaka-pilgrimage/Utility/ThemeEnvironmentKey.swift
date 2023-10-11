//
//  ThemeEnvironmentKey.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/10.
//

import SwiftUI

private struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: Theme = .system
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}
