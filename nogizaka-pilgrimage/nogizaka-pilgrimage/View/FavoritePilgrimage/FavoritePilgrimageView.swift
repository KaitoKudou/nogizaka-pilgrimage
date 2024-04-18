//
//  FavoritePilgrimageView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/12/04.
//

import ComposableArchitecture
import SwiftUI

struct FavoritePilgrimageView: View {
    let store: StoreOf<FavoriteFeature>

    init(store: StoreOf<FavoriteFeature>) {
        self.store = store
    }

    var body: some View {
        Group {
            VStack {
                if store.favoritePilgrimageRows.isEmpty {
                    Text(R.string.localizable.favorites_empty())
                } else if store.isLoading {
                    ProgressView()
                        .controlSize(.large)
                        .frame(alignment: .center)
                } else {
                    GeometryReader { geometry in
                        NavigationStack {
                            List {
                                ForEachStore(store.scope(
                                    state: \.favoritePilgrimageRows,
                                    action: \.favoritePilgrimageRows
                                )) { itemStore in
                                    ZStack {
                                        NavigationLink(
                                            destination: PilgrimageDetailView(pilgrimage: itemStore.pilgrimage)
                                        ) {
                                            EmptyView()
                                        }
                                        .opacity(0)

                                        PilgrimageListContentView(
                                            pilgrimage: itemStore.pilgrimage, 
                                            store: itemStore
                                        )
                                        .frame(maxHeight: geometry.size.width / 3)
                                    }
                                    .listRowSeparator(.hidden)
                                }
                            }
                            .listStyle(.plain)
                        }
                    }
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .navigationTitle(R.string.localizable.tabbar_favorite())
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    FavoritePilgrimageView(
        store: .init(
            initialState: FavoriteFeature.State()
        ) {
            FavoriteFeature()
        }
    )
}
