//
//  IconLicenseView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2024/05/01.
//

import ComposableArchitecture
import SwiftUI

struct IconLicenseView: View {
    @Environment(\.theme) private var theme
    let store: StoreOf<IconLicenseFeature>

    init(store: StoreOf<IconLicenseFeature>) {
        self.store = store
    }

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text(R.string.localizable.icons_by())

                    Button {
                        store.send(.icons8LinkTapped)
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
    IconLicenseView(
        store: .init(
            initialState: IconLicenseFeature.State()
        ) {
            IconLicenseFeature()
        }
    )
}
