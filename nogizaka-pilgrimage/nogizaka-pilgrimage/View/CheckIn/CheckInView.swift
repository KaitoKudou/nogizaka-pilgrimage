//
//  CheckInView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/01/04.
//

import ComposableArchitecture
import SwiftUI

struct CheckInView: View {
    @Environment(\.theme) private var theme
    let store: StoreOf<PilgrimageDetailFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: geometry.size.width / 4))], spacing: theme.margins.spacing_s) {
                        ForEach(viewStore.state.checkInState.checkedInPilgrimages, id: \.self) { pilgrimage in
                            CheckInContentView(pilgrimageName: pilgrimage.name)
                        }
                    }
                    .padding(.top, theme.margins.spacing_xs)
                }
            }
            .onAppear {
                viewStore.send(.checkInAction(.fetchCheckedInList))
            }
            .navigationTitle(R.string.localizable.tabbar_check_in())
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CheckInView_Previews: PreviewProvider {
    static var previews: some View {
        CheckInView(
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
}
