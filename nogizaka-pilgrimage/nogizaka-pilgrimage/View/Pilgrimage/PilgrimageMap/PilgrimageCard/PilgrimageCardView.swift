//
//  PilgrimageCardView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/30.
//

import SwiftUI

struct PilgrimageCardView: View {
    @Environment(\.theme) private var theme
    let pilgrimage: PilgrimageInformation

    var body: some View {
        HStack(spacing: theme.margins.spacing_m) {
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

            VStack(alignment: .leading, spacing: .zero) {
                HStack {
                    Text(pilgrimage.name)
                        .font(theme.fonts.bodyMedium)

                    Spacer()

                    Button {
                        // TODO: お気に入り登録
                        print("TODO: お気に入り登録")
                    } label: {
                        Image(systemName: "heart")
                            .foregroundStyle(R.color.tab_primar_off()!.color)
                    }
                }
                .padding(.bottom, theme.margins.spacing_m)

                Text(pilgrimage.address)
                    .font(theme.fonts.caption)

                Spacer()
                
                HStack(spacing: theme.margins.spacing_xs) {
                    Group {
                        Button {
                            // TODO: Google Map or Apple Mapを開く
                            print("TODO: 経路")
                        } label: {
                            Text(R.string.localizable.common_btn_route_search_text())

                        }

                        NavigationLink(destination: PilgrimageDetailView(pilgrimage: pilgrimage)) {
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
        .padding(.all)
        .background(.white)
    }
}

struct PilgrimageCardView_Previews: PreviewProvider {
    static var previews: some View {
        PilgrimageCardView(pilgrimage: dummyPilgrimageList[0])
            .frame(width: UIScreen.main.bounds.width - 64, height: UIScreen.main.bounds.width / 2 - 32)
            .previewLayout(.sizeThatFits)
    }
}
