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
    @State private var isFavorite = false
    let pilgrimage: PilgrimageInformation
    let store: StoreOf<PilgrimageDetailFeature>


    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(alignment: .top, spacing: theme.margins.spacing_m) {
                VStack {
                    AsyncImage(url: nil) { image in
                        // TODO: 聖地の画像を表示
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
                            viewStore.send(.favoriteAction(.toggleFavorite(pilgrimage)))
//                            viewStore.send(.updateFavoriteList(pilgrimage))
//                            viewStore.send(.toggleFavorite(pilgrimage))
                            withAnimation {
                                self.isFavorite = viewStore.state.favoriteState.isFavorite
                                //self.isFavorite = viewStore.state.isFavorite
                            }
                        } label: {
                            if isFavorite {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.red)
                            } else {
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
                viewStore.send(.favoriteAction(.toggleFavorite(pilgrimage)))
                viewStore.send(.favoriteAction(.fetchFavorites))
                self.isFavorite = viewStore.state.favoriteState.isFavorite
                //viewStore.send(.toggleFavorite(pilgrimage))
                //viewStore.send(.fetchFavorites)
                //self.isFavorite = viewStore.state.isFavorite
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
