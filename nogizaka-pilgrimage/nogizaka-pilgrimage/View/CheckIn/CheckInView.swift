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
    @State private var isShowFetchCheckedInAlert = false
    @State private var hasNetworkAlert = false
    let store: StoreOf<PilgrimageDetailFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                switch (viewStore.state.checkInState.isLoading, viewStore.state.checkInState.checkedInPilgrimages.isEmpty) {
                case (true, _):
                    VStack(alignment: .center) {
                        Spacer()

                        HStack {
                            Spacer()
                            ProgressView()
                                .controlSize(.large)
                                .frame(alignment: .center)
                            Spacer()
                        }

                        Spacer()
                    }
                case (false, true):
                    VStack(alignment: .center) {
                        Spacer()

                        HStack {
                            Spacer()
                            Text(R.string.localizable.checked_in_empty())
                                .multilineTextAlignment(.center)
                            Spacer()
                        }

                        Spacer()
                    }
                case (false, false):
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: geometry.size.width / 4))], spacing: theme.margins.spacing_s) {
                            ForEach(viewStore.state.checkInState.checkedInPilgrimages, id: \.self) { pilgrimage in
                                CheckInContentView(pilgrimageName: pilgrimage.name)
                            }
                        }
                        .padding(.top, theme.margins.spacing_xs)
                    }
                }
            }
            .onAppear {
                viewStore.send(.checkInAction(.fetchCheckedInList))
            }
            .onChange(of: viewStore.state.checkInState.hasError) { hasError in
                isShowFetchCheckedInAlert = hasError
            }
            .onChange(of: viewStore.state.favoriteState.hasNetworkError) { hasNetworkAlert in
                self.hasNetworkAlert = hasNetworkAlert
            }
            .alert(R.string.localizable.alert_network(), isPresented: $hasNetworkAlert) {
            } message: {
                EmptyView()
            }
            .alert(viewStore.state.checkInState.errorMessage, isPresented: $isShowFetchCheckedInAlert) {
            } message: {
                EmptyView()
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
