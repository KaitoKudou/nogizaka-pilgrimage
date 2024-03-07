//
//  PilgrimageView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/01/04.
//

import ComposableArchitecture
import SwiftUI

struct PilgrimageView: View {
    let pilgrimages: [PilgrimageInformation]
    let store: StoreOf<PilgrimageDetailFeature>

    var body: some View {
        ZStack {
            PilgrimageMapView(pilgrimages: pilgrimages, store: store)
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
            NavigationLink(
                destination: 
                    PilgrimageListView(pilgrimages: pilgrimages, pilgrimageDetailStore: store)
            ) {
                Image(systemName: "list.bullet")
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    PilgrimageView(
        pilgrimages: dummyPilgrimageList,
        store: StoreOf<PilgrimageDetailFeature>(
            initialState:
                PilgrimageDetailFeature.State(
                    favoriteState: FavoriteFeature.State(),
                    checkInState: CheckInFeature.State()
                )
        ) {
            PilgrimageDetailFeature()
        }
    )
    .environmentObject(LocationManager())
}
