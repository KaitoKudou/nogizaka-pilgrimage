//
//  IconLicenseView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/05/01.
//

import SwiftUI

struct IconLicenseView: View {
    @Environment(\.theme) private var theme
    @State private var safariURL: URL?

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text(.iconsBy)

                    Button {
                        safariURL = URL(string: "https://icons8.com")!
                    } label: {
                        Text(.icons8)
                            .underline()
                    }
                }
            }
            .foregroundStyle(.gray)
            .padding(.top, theme.margins.spacing_xl)
        }
        .fullScreenCover(item: $safariURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
        .navigationTitle(String(localized: .menuIconLicense))
    }
}

#Preview {
    IconLicenseView()
}
