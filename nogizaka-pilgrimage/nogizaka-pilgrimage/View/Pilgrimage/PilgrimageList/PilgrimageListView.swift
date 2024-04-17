//
//  PilgrimageListView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/19.
//

import ComposableArchitecture
import SwiftUI

struct PilgrimageListView: View {
    @Environment(\.theme) private var theme
    @State private var searchText = ""
    @State var store = Store(initialState: PilgrimageListFeature.State()) {
        PilgrimageListFeature()
    }
    let pilgrimages: [PilgrimageInformation]

    var body: some View {
        GeometryReader { geometry in
            VStack {
                searchTextField()
                    .padding(.top, theme.margins.spacing_xxs)
                    .padding(.bottom, theme.margins.spacing_m)
                    .padding(.horizontal, theme.margins.spacing_m)
                    .background(R.color.tab_primary()!.color)

                PilgrimageListNavigationView(store: store)
            }
            .onAppear {
                searchText = store.searchText
                store.send(.onAppear(pilgrimages))

                if store.searchText.isEmpty {
                    store.send(.searchPilgrimages(""))
                } else {
                    store.send(.searchPilgrimages(searchText))
                }
            }
        }
        .navigationTitle(R.string.localizable.navbar_pilgrimage_list())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonTextHidden()
    }

    private func searchTextField() -> some View {
        HStack(spacing: .zero) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
                .padding(.leading, theme.margins.spacing_xs)

            TextField(
                R.string.localizable.pilgrimage_list_placeholder(),
                text: $searchText
            )
            .padding(.vertical, theme.margins.spacing_xs)
            .padding(.leading, theme.margins.spacing_xxs)
            .padding(.trailing, theme.margins.spacing_m)
            .submitLabel(.search)
            .onSubmit {
                // キーボードの検索ボタンが押されたときにアクションを送信
                if !searchText.isEmpty {
                    store.send(.searchPilgrimages(searchText))
                } else {
                    store.send(.searchPilgrimages(""))
                }
            }
        }
        .background(.white)
        .border(R.color.tab_primary()!.color, width: 1)
        .cornerRadius(8.0)
    }
}

#Preview {
    PilgrimageListView(
        pilgrimages: dummyPilgrimageList
    )
}
