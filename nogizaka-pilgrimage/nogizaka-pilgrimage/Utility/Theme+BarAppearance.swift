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
    @MainActor func styleNavigationBarGlobalAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor(resource: .tabPrimary)
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(resource: .navText),
            .font: uiFonts.navigationTitle
        ]
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.shadowColor = nil

        // 戻るボタンのテキストを非表示で統一
        let backItemAppearance = UIBarButtonItemAppearance()
        backItemAppearance.normal.titleTextAttributes = [.foregroundColor : UIColor.clear]
        navigationBarAppearance.backButtonAppearance = backItemAppearance

        // 戻るボタンのアイコンを統一
        let imageConfig = UIImage.SymbolConfiguration(weight: .regular)
        let image = UIImage(systemName: "chevron.backward", withConfiguration: imageConfig)?
            .withTintColor(.white ,renderingMode: .alwaysOriginal)
        navigationBarAppearance.setBackIndicatorImage(image, transitionMaskImage: image)

        // 用意した `UINavigationBarAppearance` を設定
        UINavigationBar.appearance().tintColor = UIColor(resource: .tabPrimary)
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
}

// MARK: TabBarの設定
extension Theme {
    /// アプリ全体のTabBarの外見を設定する
    @MainActor func styleTabBarGlobalAppearance() {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(resource: .bgPrimary)
        tabAppearance.selectionIndicatorTintColor = UIColor(resource: .tabPrimary)

        let tabBarItemAppearance = tabBarItemAppearanceConfiguration()
        tabAppearance.compactInlineLayoutAppearance = tabBarItemAppearance
        tabAppearance.inlineLayoutAppearance = tabBarItemAppearance
        tabAppearance.stackedLayoutAppearance = tabBarItemAppearance

        // 用意した `UITabBarAppearance` を設定
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }

    @MainActor private func tabBarItemAppearanceConfiguration() -> UITabBarItemAppearance {
        let itemAppearance = UITabBarItemAppearance()
        let normalColor = UIColor(resource: .tabPrimaryOff)
        let selectedColor = UIColor(resource: .tabPrimary)

        // 通常状態
        itemAppearance.normal.iconColor = normalColor
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: normalColor,
            .font: uiFonts.caption,
        ]
        itemAppearance.normal.titlePositionAdjustment = UIOffset(
            horizontal: Theme.system.margins.zero,
            vertical: Theme.system.margins.spacing_xxs
        )
        
        // 選択状態
        itemAppearance.selected.iconColor = selectedColor
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor,
            .font: uiFonts.caption,
        ]
        itemAppearance.selected.titlePositionAdjustment = UIOffset(
            horizontal: Theme.system.margins.zero,
            vertical: Theme.system.margins.spacing_xxs
        )

        return itemAppearance
    }
}
