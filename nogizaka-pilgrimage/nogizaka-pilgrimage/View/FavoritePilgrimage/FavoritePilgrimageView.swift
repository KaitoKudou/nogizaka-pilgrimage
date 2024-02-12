//
//  FavoritePilgrimageView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/12/04.
//

import ComposableArchitecture
import SwiftUI

struct FavoritePilgrimageView: View {
    @State var store = Store(
        initialState: PilgrimageDetailFeature.State(
            favoriteState: FavoriteFeature.State(),
            checkInState: CheckInFeature.State()
        )
    ) {
        PilgrimageDetailFeature()
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.state.favoriteState.favoritePilgrimages.isEmpty {
                    Text("お気に入り聖地はありません")
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
    FavoritePilgrimageView()
}
