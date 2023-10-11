//
//  nogizaka_pilgrimageApp.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2022/12/27.
//

import SwiftUI

@main
struct nogizaka_pilgrimageApp: App {
    @Environment(\.theme) private var theme
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.theme, .system)
        }
    }
}
