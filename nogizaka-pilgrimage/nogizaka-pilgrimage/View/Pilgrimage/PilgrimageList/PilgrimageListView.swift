//
//  PilgrimageListView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/19.
//

import SwiftUI

struct PilgrimageListView: View {
    @Environment(\.theme) private var theme
    @State private var pilgrimageListType: PilgrimageListType = .all
    @State private var searchWord = ""

    var body: some View {
        GeometryReader { geometry in
            VStack {
                searchTextField
                    .padding(.top, theme.margins.spacing_xxs)
                    .padding(.bottom, theme.margins.spacing_m)
                    .padding(.horizontal, theme.margins.spacing_m)
                    .background(R.color.tab_primary()!.color)

                PilgrimageListTypeSelectView(
                    type: $pilgrimageListType,
                    screenWidth: geometry.size.width
                )
            }
        }
        .navigationTitle(R.string.localizable.navbar_pilgrimage_list())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonTextHidden()
    }

    private var searchTextField: some View {
        HStack(spacing: .zero) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
                .padding(.leading, theme.margins.spacing_xs)

            TextField(
                R.string.localizable.pilgrimage_list_placeholder(),
                text: $searchWord
            )
            .padding(.vertical, theme.margins.spacing_xs)
            .padding(.leading, theme.margins.spacing_xxs)
            .padding(.trailing, theme.margins.spacing_m)
            .submitLabel(.search)
            .onSubmit {
                // TODO: 検索
                print("検索予定ワード: \(searchWord)")
            }
        }
        .background(.white)
        .border(R.color.tab_primary()!.color, width: 1)
        .cornerRadius(8.0)
    }
}

#Preview {
    PilgrimageListView()
}
