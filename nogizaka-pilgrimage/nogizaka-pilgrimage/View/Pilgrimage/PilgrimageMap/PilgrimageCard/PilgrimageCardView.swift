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
        WithViewStore(store, observe: { $0 }) { viewStore in
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
                            viewStore.send(.favoriteAction(.updateFavoriteList(pilgrimage)))
                        } label: {
                            if viewStore.state.favoriteState.isLoading {
                                // 通信中の場合、インジケータを表示
                                ProgressView()
                            } else if viewStore.state.favoriteState.favoritePilgrimages.contains(pilgrimage) {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.red)
                            } else if !viewStore.state.favoriteState.favoritePilgrimages.contains(pilgrimage) {
                                Image(systemName: "heart")
                                    .foregroundStyle(R.color.tab_primary_off()!.color)
                            }
                        }
                        .disabled(viewStore.state.favoriteState.isLoading ? true : false)
                    }
                    .padding(.bottom, theme.margins.spacing_m)
                    .alert(store: store.scope(state: \.$alert, action: PilgrimageDetailFeature.Action.alertDismissed))

                    Text(pilgrimage.address)
                        .font(theme.fonts.caption)
                    
                    Spacer()
                    
                    HStack(spacing: theme.margins.spacing_xs) {
                        Group {
                            Button {
                                viewStore.send(.routeButtonTapped)
                            } label: {
                                Text(R.string.localizable.common_btn_route_search_text())
                                
                            }
                            .confirmationDialog(
                                store: store.scope(
                                    state: \.$confirmationDialog,
                                    action: PilgrimageDetailFeature.Action.confirmationDialog
                                )
                            )

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
            }
            .onAppear {
                viewStore.send(.favoriteAction(.fetchFavorites))
            }
            .onChange(of: viewStore.state.favoriteState.hasNetworkError) { hasNetworkAlert in
                self.hasNetworkAlert = hasNetworkAlert
            }
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
