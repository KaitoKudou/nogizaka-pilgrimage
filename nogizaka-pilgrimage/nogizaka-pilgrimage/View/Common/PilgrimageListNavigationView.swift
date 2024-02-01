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
    @State var store = Store(initialState: FavoriteFeature.State()) {
        FavoriteFeature()
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                List {
                    ForEach(pilgrimageList, id: \.code) { pilgrimage in
                        ZStack {
                            NavigationLink(
                                destination:
                                    PilgrimageDetailView(
                                        pilgrimage: pilgrimage,
                                        store: store
                                    )
                                    .environmentObject(LocationManager())
                            ) {
                                EmptyView()
                            }
                            .opacity(0)

                            PilgrimageListContentView(pilgrimage: pilgrimage, store: store)
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
        store: StoreOf<FavoriteFeature>(initialState: FavoriteFeature.State()) {
            FavoriteFeature()
        }
    )
}
