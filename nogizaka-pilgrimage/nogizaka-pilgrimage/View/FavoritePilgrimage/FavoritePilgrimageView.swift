//
//  FavoritePilgrimageView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/12/04.
//

import ComposableArchitecture
import SwiftUI

struct FavoritePilgrimageView: View {
    let store: StoreOf<PilgrimageDetailFeature>

    var body: some View {
        Group {
            if store.favoriteState.favoritePilgrimages.isEmpty {
                Text(R.string.localizable.favorites_empty())
            } else {
                PilgrimageListNavigationView(
                    pilgrimageList: store.favoriteState.favoritePilgrimages,
                    store: store
                )
            }
        }
        .onAppear {
            store.send(.favoriteAction(.fetchFavorites))
        }
        .onChange(of: store.favoriteState.favoritePilgrimages) { _, _ in
            store.send(.favoriteAction(.fetchFavorites))
        }
        .navigationTitle(R.string.localizable.tabbar_favorite())
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    FavoritePilgrimageView(
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
}
