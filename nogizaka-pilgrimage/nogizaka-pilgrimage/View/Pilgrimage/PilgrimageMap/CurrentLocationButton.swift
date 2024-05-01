//
//  CurrentLocationButton.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/18.
//

import SwiftUI

/// 現在地ボタン
struct CurrentLocationButton: View {
    @Environment(\.theme) private var theme
    let didTap: () -> Void

    var body: some View {
        Button {
            didTap()
        } label: {
            Image(systemName: "location")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.all, theme.margins.spacing_xs)
                .foregroundStyle(.gray)
                .background(.white)
                .clipShape(Circle())
                .frame(
                    width: theme.margins.spacing_xxl,
                    height: theme.margins.spacing_xxl
                )
                .padding(.all, theme.margins.spacing_m)
                .shadow(
                    color: .black.opacity(0.25),
                    radius: 4.0, x: .zero, y: 1.0
                )
        }
    }
}

#Preview {
    CurrentLocationButton(didTap: {})
        .previewLayout(.sizeThatFits)
}
