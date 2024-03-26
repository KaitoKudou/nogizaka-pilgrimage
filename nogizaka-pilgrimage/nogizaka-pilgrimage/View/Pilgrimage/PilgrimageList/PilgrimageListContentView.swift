//
//  PilgrimageListContentView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/06.
//

import ComposableArchitecture
import SwiftUI

struct PilgrimageListContentView: View {
    @Environment(\.theme) private var theme
    @State private var hasNetworkAlert = false
    let pilgrimage: PilgrimageInformation
    let store: StoreOf<PilgrimageDetailFeature>


    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(alignment: .top, spacing: theme.margins.spacing_m) {
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

                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
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
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.bottom, theme.margins.spacing_m)

                    Text(pilgrimage.address)
                        .font(theme.fonts.caption)
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
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .clipped()
        .shadow(color: Color.gray.opacity(0.8), radius: 4, x: 0, y: 4)
    }
}

struct PilgrimageListContentView_Previews: PreviewProvider {
    static var previews: some View {
        PilgrimageListContentView(
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
        .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.width / 3)
        .previewLayout(.sizeThatFits)
    }
}
