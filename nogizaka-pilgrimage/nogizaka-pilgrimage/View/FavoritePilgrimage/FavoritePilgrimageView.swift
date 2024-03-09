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
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.state.favoriteState.favoritePilgrimages.isEmpty {
                    Text(R.string.localizable.favorites_empty())
                } else {
                    PilgrimageListNavigationView(
                        pilgrimageList: viewStore.state.favoriteState.favoritePilgrimages,
                        store: store
                    )
                }
            }
            .onAppear {
                viewStore.send(.favoriteAction(.fetchFavorites))
            }
            .onChange(of: viewStore.state.favoriteState.favoritePilgrimages) { _ in
                viewStore.send(.favoriteAction(.fetchFavorites))
            }
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
