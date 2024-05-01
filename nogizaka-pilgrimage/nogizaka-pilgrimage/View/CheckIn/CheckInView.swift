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
    private let adSize = BannerView.getAdSize(width: UIScreen.main.bounds.width)

    init(store: StoreOf<CheckInFeature>) {
        self.store = store
    }

    var body: some View {
        GeometryReader { geometry in
            switch (store.isLoading, store.checkedInPilgrimages.isEmpty) {
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

                    BannerView(adUnitID: .checkIn)
                        .frame(
                            width: adSize.size.width,
                            height: adSize.size.height
                        )
                }
            case (false, false):
                VStack {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: geometry.size.width / 4))], spacing: theme.margins.spacing_s) {
                            ForEach(store.checkedInPilgrimages, id: \.self) { pilgrimage in
                                CheckInContentView(pilgrimageName: pilgrimage.name)
                            }
                        }
                        .padding(.top, theme.margins.spacing_xs)
                    }

                    BannerView(adUnitID: .checkIn)
                        .frame(
                            width: adSize.size.width,
                            height: adSize.size.height
                        )
                }
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
