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
                        favoritePilgrimageScrollView(geometry: geometry)
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

    private func favoritePilgrimageScrollView(geometry: GeometryProxy) -> some View {
        NavigationStack {
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack(alignment: .leading) {
                        ForEachStore(
                            store.scope(
                                state: \.favoritePilgrimageRows,
                                action: \.favoritePilgrimageRows
                            )
                        ) { itemStore in

                            if itemStore.id % 5 == 0 {
                                NativeAdvanceView()
                                    .frame(height: geometry.size.width / 3)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                            }

                            NavigationLink(
                                destination: PilgrimageDetailView(pilgrimage: itemStore.pilgrimage)
                                    .onAppear {
                                        store.send(
                                            .updateScrollToIndex(scrollToIndex: itemStore.pilgrimage.id)
                                        )
                                    }
                            ) {
                                PilgrimageListContentView(
                                    pilgrimage: itemStore.pilgrimage,
                                    store: itemStore
                                )
                                .frame(maxHeight: geometry.size.width / 3)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .id(itemStore.pilgrimage.id)
                            }
                        }
                    }
                    .onAppear {
                        proxy.scrollTo(
                            store.scrollToIndex, anchor: .center
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    FavoritePilgrimageView()
}
