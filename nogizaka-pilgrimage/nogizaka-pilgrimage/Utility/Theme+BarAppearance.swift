//
//  Theme+BarAppearance.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/10.
//

import Foundation
import UIKit

// MARK: NavigationBarの設定
extension Theme {
    /// 通常のNavigationBarの外見を設定する
    func styleNavigationBarGlobalAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = R.color.tab_primary()!
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: R.color.nav_text()!,
            .font: uiFonts.navigationTitle
        ]
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.shadowColor = nil

        // 用意した `UINavigationBarAppearance` を設定
        UINavigationBar.appearance().tintColor = R.color.tab_primary()!
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
}

// MARK: TabBarの設定
extension Theme {
    /// アプリ全体のTabBarの外見を設定する
    func styleTabBarGlobalAppearance() {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = R.color.bg_primary()!
        tabAppearance.selectionIndicatorTintColor = R.color.tab_primary()!

        let tabBarItemAppearance = tabBarItemAppearanceConfiguration()
        tabAppearance.compactInlineLayoutAppearance = tabBarItemAppearance
        tabAppearance.inlineLayoutAppearance = tabBarItemAppearance
        tabAppearance.stackedLayoutAppearance = tabBarItemAppearance

        // 用意した `UITabBarAppearance` を設定
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }

    private func tabBarItemAppearanceConfiguration() -> UITabBarItemAppearance {
        let itemAppearance = UITabBarItemAppearance()
        let normalColor = R.color.tab_primary_off()!
        let selectedColor = R.color.tab_primary()!

        // 通常状態
        itemAppearance.normal.iconColor = normalColor
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: normalColor,
            .font: uiFonts.caption,
        ]

        // 選択状態
        itemAppearance.selected.iconColor = selectedColor
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor,
            .font: uiFonts.caption,
        ]

        return itemAppearance
    }
}
