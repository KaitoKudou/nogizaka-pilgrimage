//
//  PilgrimageListContentView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/06.
//

import NukeUI
import SwiftUI

struct PilgrimageListContentView: View {
    @Environment(\.theme) private var theme
    let pilgrimage: PilgrimageEntity
    let isLoading: Bool
    let favorited: Bool
    let onFavoriteToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: theme.margins.spacing_m) {
            VStack {
                LazyImage(url: pilgrimage.imageURL) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        // 画像取得中のプレースホルダー表示
                        Image(.placeholder)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }

                if let copyright = pilgrimage.copyright {
                    Text(copyright)
                        .font(theme.fonts.captionSmall)
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                }
            }

            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text(pilgrimage.name)
                        .font(theme.fonts.bodyMedium)
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Button {
                        onFavoriteToggle()
                    } label: {
                        if isLoading {
                            // 通信中の場合、インジケータを表示
                            ProgressView()
                        } else if favorited {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                        } else {
                            Image(systemName: "heart")
                                .foregroundStyle(Color(.tabPrimaryOff))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.bottom, theme.margins.spacing_m)

                Text(pilgrimage.address)
                    .font(theme.fonts.caption)
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .clipped()
        .shadow(color: Color.gray.opacity(0.8), radius: 4, x: 0, y: 4)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    PilgrimageListContentView(
        pilgrimage: dummyPilgrimageList[0],
        isLoading: false,
        favorited: true,
        onFavoriteToggle: {}
    )
    .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.width / 3)
}
