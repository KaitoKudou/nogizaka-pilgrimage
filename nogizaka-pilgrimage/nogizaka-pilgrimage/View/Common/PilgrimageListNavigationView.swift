//
//  PilgrimageListNavigationView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/12/04.
//

import ComposableArchitecture
import SwiftUI

struct PilgrimageListNavigationView: View {
    @Bindable var store: StoreOf<PilgrimageListFeature>

    init(store: StoreOf<PilgrimageListFeature>) {
        self.store = store
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ScrollView {
                    ScrollViewReader { proxy in
                        LazyVStack(alignment: .leading) {
                            ForEachStore(
                                store.scope(
                                    state: \.pilgrimageSearchResults,
                                    action: \.pilgrimageRows
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
}

#Preview {
    PilgrimageListNavigationView(
        store: .init(
            initialState:
                PilgrimageListFeature.State()
        ) {
            PilgrimageListFeature()
        }
    )
}
