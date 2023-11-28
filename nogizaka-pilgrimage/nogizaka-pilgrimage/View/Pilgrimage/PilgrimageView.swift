//
//  PilgrimageView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/01/04.
//

import ComposableArchitecture
import SwiftUI

struct PilgrimageView: View {
    @Environment(\.theme) private var theme
    @State private var store = Store(initialState: UserLocationFeature.State()) {
        UserLocationFeature()
    }

    var body: some View {
        ZStack {
            PilgrimageMapView(userLocationFeature: store)
        }
        .navigationTitle(R.string.localizable.tabbar_pilgrimage())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            pilgrimageListToolBarItem
        }
    }
}

// MARK: Extension PilgrimageView
extension PilgrimageView {
    /// NavigationBarの聖地一覧遷移ボタン
    private var pilgrimageListToolBarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink(destination: PilgrimageListView()) {
                Image(systemName: "list.bullet")
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    PilgrimageView()
}
