//
//  FavoritePilgrimageView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/12/04.
//

import ComposableArchitecture
import SwiftUI

struct FavoritePilgrimageView: View {
    @State var store = Store(initialState: FavoriteFeature.State()) {
        FavoriteFeature()
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.favoritePilgrimages.isEmpty {
                    Text("お気に入り聖地はありません")
                } else {
                    PilgrimageListNavigationView(
                        pilgrimageList: viewStore.favoritePilgrimages,
                        store: store
                    )
                }
            }
            .onAppear {
                viewStore.send(.fetchFavorites)
            }
            .onChange(of: viewStore.favoritePilgrimages) { _ in
                viewStore.send(.fetchFavorites)
            }
        }
        .navigationTitle(R.string.localizable.tabbar_favorite())
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    FavoritePilgrimageView()
}
