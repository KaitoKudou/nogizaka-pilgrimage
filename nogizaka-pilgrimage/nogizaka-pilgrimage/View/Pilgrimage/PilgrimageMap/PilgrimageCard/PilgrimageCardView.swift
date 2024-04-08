//
//  PilgrimageCardView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/30.
//

import ComposableArchitecture
import SwiftUI

struct PilgrimageCardView: View {
    @Environment(\.theme) private var theme
    @State private var isFavorite = false
    @State private var isShowUpdateFavoriteAlert = false
    @State private var hasNetworkAlert = false
    let pilgrimage: PilgrimageInformation
    let store: StoreOf<PilgrimageDetailFeature>

    var body: some View {
        HStack(spacing: theme.margins.spacing_m) {
            VStack {
                AsyncImage(url: pilgrimage.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)

                } placeholder: {
                    // 画像取得中のプレースホルダー表示
                    Image(R.image.no_image.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }

                if let copyright = pilgrimage.copyright {
                    Text(copyright)
                        .font(theme.fonts.captionSmall)
                }
            }

            VStack(alignment: .leading, spacing: .zero) {
                HStack {
                    Text(pilgrimage.name)
                        .font(theme.fonts.bodyMedium)

                    Spacer()

                    Button {
                        store.send(.favoriteAction(.updateFavoriteList(pilgrimage)))
                    } label: {
                        if store.favoriteState.isLoading {
                            // 通信中の場合、インジケータを表示
                            ProgressView()
                        } else if store.favoriteState.favoritePilgrimages.contains(pilgrimage) {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                        } else if !store.favoriteState.favoritePilgrimages.contains(pilgrimage) {
                            Image(systemName: "heart")
                                .foregroundStyle(R.color.tab_primary_off()!.color)
                        }
                    }
                    .disabled(store.favoriteState.isLoading ? true : false)
                }
                .padding(.bottom, theme.margins.spacing_m)
                .alert(store: store.scope(state: \.$alert, action: \.alertDismissed))

                Text(pilgrimage.address)
                    .font(theme.fonts.caption)

                Spacer()

                HStack(spacing: theme.margins.spacing_xs) {
                    Group {
                        Button {
                            store.send(
                                .routeButtonTapped(
                                    latitude: pilgrimage.latitude,
                                    longitude: pilgrimage.longitude
                                )
                            )
                        } label: {
                            Text(R.string.localizable.common_btn_route_search_text())
                        }

                        NavigationLink(
                            destination:
                                PilgrimageDetailView(
                                    pilgrimage: pilgrimage, store: store
                                )
                        ) {
                            Text(R.string.localizable.common_btn_detail_text())
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 26)
                    .background(R.color.text_secondary()!.color)
                    .foregroundStyle(.white)
                    .font(theme.fonts.caption)
                }
            }
            .onAppear {
                store.send(.favoriteAction(.fetchFavorites))
            }
            .onChange(of: store.favoriteState.hasNetworkError) { _, _ in
                self.hasNetworkAlert = hasNetworkAlert
            }
            .confirmationDialog(
                store: store.scope(
                    state: \.$confirmationDialog,
                    action: \.confirmationDialog
                )
            )
            .alert(R.string.localizable.alert_network(), isPresented: $hasNetworkAlert) {
            } message: {
                EmptyView()
            }
        }
        .padding(.all)
        .background(.white)
    }
}

struct PilgrimageCardView_Previews: PreviewProvider {
    static var previews: some View {
        PilgrimageCardView(
            pilgrimage: dummyPilgrimageList[0],
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
        .frame(width: UIScreen.main.bounds.width - 64, height: UIScreen.main.bounds.width / 2 - 32)
        .previewLayout(.sizeThatFits)
    }
}
