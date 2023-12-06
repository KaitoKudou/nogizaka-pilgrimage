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
    @State private var searchWord = ""
    @State var store = Store(initialState: SearchCandidateFeature.State()) {
        SearchCandidateFeature()
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                VStack {
                    searchTextField(viewStore: viewStore)
                        .padding(.top, theme.margins.spacing_xxs)
                        .padding(.bottom, theme.margins.spacing_m)
                        .padding(.horizontal, theme.margins.spacing_m)
                        .background(R.color.tab_primary()!.color)

                    PilgrimageListNavigationView(
                        pilgrimageList: viewStore.allSearchCandidatePilgrimages
                    )
                }
                .onAppear {
                    viewStore.send(.resetPilgrimages)
                }
                .onChange(of: viewStore.isLoading) { newIsLoading in
                    if newIsLoading {
                    }
                }
            }
        }
        .navigationTitle(R.string.localizable.navbar_pilgrimage_list())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonTextHidden()
    }

    private func searchTextField(
        viewStore: ViewStore<SearchCandidateFeature.State, SearchCandidateFeature.Action>
    ) -> some View {
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
                // キーボードの検索ボタンが押されたときにアクションを送信
                if !searchWord.isEmpty {
                    viewStore.send(.searchPilgrimages(searchWord))
                } else {
                    viewStore.send(.resetPilgrimages)
                }
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
