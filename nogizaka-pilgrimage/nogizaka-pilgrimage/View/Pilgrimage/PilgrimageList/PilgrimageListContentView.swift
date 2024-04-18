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
    let pilgrimage: PilgrimageInformation
    @Bindable var store: StoreOf<PilgrimageRowFeature>

    init(pilgrimage: PilgrimageInformation, store: StoreOf<PilgrimageRowFeature>) {
        self.pilgrimage = pilgrimage
        self.store = store
    }

    var body: some View {
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
                        store.send(.updateFavorite(pilgrimage))
                    } label: {
                        if store.isLoading {
                            // 通信中の場合、インジケータを表示
                            ProgressView()
                        } else if store.favorited {
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
            .onAppear {
                store.send(.onAppear(pilgrimage))
            }
            .alert(
                $store.scope(
                    state: \.destination?.alert,
                    action: \.destination.alert
                )
            )
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
            store: .init(
                initialState: PilgrimageRowFeature.State(
                    pilgrimage: dummyPilgrimageList[0]
                )
            ) {
                PilgrimageRowFeature()
            }
        )
        .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.width / 3)
        .previewLayout(.sizeThatFits)
    }
}
