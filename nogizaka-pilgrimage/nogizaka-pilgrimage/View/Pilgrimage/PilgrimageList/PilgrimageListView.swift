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
    @State var searchCandidateStore = Store(initialState: SearchCandidateFeature.State()) {
        SearchCandidateFeature()
    }
    let pilgrimages: [PilgrimageInformation]
    let pilgrimageDetailStore: StoreOf<PilgrimageDetailFeature>

    var body: some View {
        GeometryReader { geometry in
            VStack {
                searchTextField()
                    .padding(.top, theme.margins.spacing_xxs)
                    .padding(.bottom, theme.margins.spacing_m)
                    .padding(.horizontal, theme.margins.spacing_m)
                    .background(R.color.tab_primary()!.color)

                PilgrimageListNavigationView(
                    pilgrimageList: searchCandidateStore.allSearchCandidatePilgrimages,
                    store: pilgrimageDetailStore
                )
            }
            .onAppear {
                searchWord = searchCandidateStore.searchText
                if searchCandidateStore.allSearchCandidatePilgrimages.isEmpty {
                    searchCandidateStore.send(.resetPilgrimages(pilgrimages: pilgrimages))
                } else {
                    searchCandidateStore.send(.resetPilgrimages(pilgrimages: searchCandidateStore.allSearchCandidatePilgrimages))
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
                text: $searchWord
            )
            .padding(.vertical, theme.margins.spacing_xs)
            .padding(.leading, theme.margins.spacing_xxs)
            .padding(.trailing, theme.margins.spacing_m)
            .submitLabel(.search)
            .onSubmit {
                // キーボードの検索ボタンが押されたときにアクションを送信
                if !searchWord.isEmpty {
                    searchCandidateStore.send(.resetPilgrimages(pilgrimages: pilgrimages))
                    searchCandidateStore.send(.searchPilgrimages(searchWord))
                } else {
                    searchCandidateStore.send(.resetPilgrimages(pilgrimages: pilgrimages))
                    searchCandidateStore.send(.resetSearchText)
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
        pilgrimages: dummyPilgrimageList,
        pilgrimageDetailStore: StoreOf<PilgrimageDetailFeature>(
            initialState:
                PilgrimageDetailFeature.State(
                    favoriteState: FavoriteFeature.State(),
                    checkInState: CheckInFeature.State()
                )
        ) {
            PilgrimageDetailFeature()
        }
    )
}
