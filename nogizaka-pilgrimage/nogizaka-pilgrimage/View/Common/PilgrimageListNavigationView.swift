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
                List {
                    ForEachStore(
                        store.scope(
                        state: \.pilgrimageSearchResults,
                        action: \.pilgrimageRows
                        )
                    ) { itemStore in
                        if itemStore.id % 5 == 0 {
                            NativeAdvanceView()
                                .frame(height: geometry.size.width / 3)
                        } else {
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
                }
                .listStyle(.plain)
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
