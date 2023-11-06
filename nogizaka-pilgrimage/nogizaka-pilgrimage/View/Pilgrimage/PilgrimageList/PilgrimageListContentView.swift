//
//  PilgrimageListContentView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/06.
//

import SwiftUI

struct PilgrimageListContentView: View {
    @Environment(\.theme) private var theme
    let pilgrimage: PilgrimageInformation

    var body: some View {
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
                        // TODO: お気に入り登録
                        print("TODO: お気に入り登録")
                    } label: {
                        Image(systemName: "heart")
                            .foregroundStyle(R.color.tab_primar_off()!.color)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.bottom, theme.margins.spacing_m)

                Text(pilgrimage.address)
                    .font(theme.fonts.caption)
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
        PilgrimageListContentView(pilgrimage: dummyPilgrimageList[0])
            .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.width / 3)
            .previewLayout(.sizeThatFits)
    }
}
