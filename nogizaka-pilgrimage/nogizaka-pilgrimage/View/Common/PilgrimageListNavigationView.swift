//
//  PilgrimageListNavigationView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/12/04.
//

import ComposableArchitecture
import SwiftUI

struct PilgrimageListNavigationView: View {
    let pilgrimageList: [PilgrimageInformation]
    let store: StoreOf<PilgrimageDetailFeature>

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                List {
                    ForEach(Array(pilgrimageList.enumerated()), id: \.element.id) { index, pilgrimage in
                        ZStack {
                            NavigationLink(
                                destination:
                                    PilgrimageDetailView(
                                        pilgrimage: pilgrimage,
                                        store: store
                                    )
                            ) {
                                EmptyView()
                            }
                            .opacity(0)

                            PilgrimageListContentView(
                                pilgrimage: pilgrimage,
                                store: store.scope(
                                    state: \.favoriteState,
                                    action: \.favoriteAction
                                )
                            )
                            .frame(maxHeight: geometry.size.width / 3)
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}


#Preview {
    PilgrimageListNavigationView(
        pilgrimageList: dummyPilgrimageList,
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
