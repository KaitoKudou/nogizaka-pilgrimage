//
//  MenuView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/07.
//

import SwiftUI

struct MenuView: View {
    @Environment(\.theme) private var theme
    let menuList = ["ログイン・新規登録", "お問い合わせ", "利用規約",
                    "プライバシーポリシー", "アプリバージョン：1.0.0"]

    var body: some View {
        List {
            ForEach(menuList, id: \.self) { menuItem in
                Text(menuItem)
            }
        }
        .listStyle(.plain)
        .navigationTitle(R.string.localizable.tabbar_menu())
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MenuView()
}
