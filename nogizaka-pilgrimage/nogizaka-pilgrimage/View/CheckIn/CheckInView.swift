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
    @Bindable var store: StoreOf<CheckInFeature>
    private let adSize = BannerViewContainer.getAdSize(width: UIScreen.main.bounds.width)

    init(store: StoreOf<CheckInFeature>) {
        self.store = store
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if store.checkedInPilgrimages.isEmpty {
                    emptyCheckInView()
                } else {
                    filledCheckInView(geometry: geometry)
                }

                Spacer()

                BannerViewContainer(adUnitID: .checkIn)
                    .frame(width: adSize.size.width, height: adSize.size.height)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .alert(
            $store.scope(
                state: \.destination?.alert,
                action: \.destination.alert
            )
        )
        .navigationTitle(R.string.localizable.tabbar_check_in())
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func filledCheckInView(geometry: GeometryProxy) -> some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: geometry.size.width / 4))], spacing: theme.margins.spacing_s) {
                    ForEach(store.checkedInPilgrimages, id: \.self) { pilgrimage in
                        CheckInContentView(pilgrimageName: pilgrimage.name)
                    }
                }
                .padding(.top, theme.margins.spacing_xs)
            }
        }
    }

    @ViewBuilder
    private func emptyCheckInView() -> some View {
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
    }
}

struct CheckInView_Previews: PreviewProvider {
    static var previews: some View {
        CheckInView(
            store: .init(
                initialState: CheckInFeature.State()
            ) {
                CheckInFeature()
            }
        )
    }
}
