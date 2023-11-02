//
//  PilgrimageDetailView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/02.
//

import SwiftUI

struct PilgrimageDetailView: View {
    @Environment(\.theme) private var theme
    let pilgrimage: PilgrimageInformation

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AsyncImage(url: pilgrimage.imageURL) { image in
                    // TODO: 聖地の画像を表示
                } placeholder: {
                    // 画像取得中のプレースホルダー表示
                    Image(R.image.no_image.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .padding(.bottom, theme.margins.spacing_m)

                HStack {
                    Text(pilgrimage.name)
                        .font(theme.fonts.title)

                    Spacer()

                    Button {
                        // TODO: お気に入り登録
                        print("TODO: お気に入り登録")
                    } label: {
                        Image(systemName: "heart")
                            .foregroundStyle(R.color.tab_primar_off()!.color)
                    }
                }
                .padding(.bottom, theme.margins.spacing_xs)

                Button {
                    // TODO: チェックイン処理
                    print("TODO: チェックイン処理")
                } label: {
                    Text(R.string.localizable.tabbar_check_in())
                        .frame(height: theme.margins.spacing_xl)
                }
                .frame(maxWidth: .infinity)
                .background(R.color.text_secondary()!.color)
                .foregroundStyle(.white)
                .font(theme.fonts.caption)
                .padding(.bottom, theme.margins.spacing_xl)

                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundStyle(R.color.text_secondary()!.color)
                    Text(pilgrimage.address)
                        .font(theme.fonts.bodyLarge)
                }
                .padding(.bottom, theme.margins.spacing_xl)

                Text(pilgrimage.description)
                    .font(theme.fonts.bodyLarge)
                    .padding(.bottom, theme.margins.spacing_xxl)
            }
        }
        .padding(.leading, theme.margins.spacing_m)
        .padding(.trailing, theme.margins.spacing_m)
        .navigationTitle(R.string.localizable.navbar_pilgrimage_detail())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonTextHidden()
    }
}

#Preview {
    PilgrimageDetailView(pilgrimage: dummyPilgrimageList[0])
}
