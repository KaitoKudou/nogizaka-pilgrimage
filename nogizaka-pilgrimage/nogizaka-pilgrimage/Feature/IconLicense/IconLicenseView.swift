//
//  IconLicenseView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/05/01.
//

import Dependencies
import SwiftUI

struct IconLicenseView: View {
    @Environment(\.theme) private var theme
    @Dependency(\.safari) private var safari

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text(R.string.localizable.icons_by())

                    Button {
                        Task {
                            await safari(URL(string: "https://icons8.com")!)
                        }
                    } label: {
                        Text(R.string.localizable.icons8())
                            .underline()
                    }
                }
            }
            .foregroundStyle(.gray)
            .padding(.top, theme.margins.spacing_xl)
        }
        .navigationTitle(R.string.localizable.menu_icon_license())
    }
}

#Preview {
    IconLicenseView()
}
