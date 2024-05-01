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
    @State var store = Store(
        initialState: PilgrimageCardFeature.State()
    ) {
        PilgrimageCardFeature()
    }
    let pilgrimage: PilgrimageInformation

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
                        store.send(.favoriteButtonTapped(pilgrimage))
                    } label: {
                        if store.isLoading {
                            // 通信中の場合、インジケータを表示
                            ProgressView()
                        } else if store.favorited {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                        } else if !store.favorited {
                            Image(systemName: "heart")
                                .foregroundStyle(R.color.tab_primary_off()!.color)
                        }
                    }
                    .disabled(store.isLoading ? true : false)
                }
                .padding(.bottom, theme.margins.spacing_m)

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
                                PilgrimageDetailView(pilgrimage: pilgrimage)
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
                store.send(.onAppear(pilgrimage))
            }
            .alert(
                $store.scope(
                    state: \.destination?.alert,
                    action: \.destination.alert
                )
            )
            .confirmationDialog(
                $store.scope(
                    state: \.destination?.confirmationDialog,
                    action: \.destination.confirmationDialog
                )
            )
        }
        .padding(.all)
        .background(.white)
    }
}

struct PilgrimageCardView_Previews: PreviewProvider {
    static var previews: some View {
        PilgrimageCardView(
            pilgrimage: dummyPilgrimageList[0]
        )
        .frame(width: UIScreen.main.bounds.width - 64, height: UIScreen.main.bounds.width / 2 - 32)
        .previewLayout(.sizeThatFits)
    }
}
