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
    @State private var pilgrimageListType: PilgrimageListType = .all
    @State private var searchWord = ""
    @State var store = Store(initialState: FavoriteFeature.State()) {
        FavoriteFeature()
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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

                    switch(pilgrimageListType) {
                    case .all:
                        pilgrimageListNavigationView(
                            geometry: geometry,
                            pilgrimageList: dummyPilgrimageList
                        )
                    case.favorite:
                        pilgrimageListNavigationView(
                            geometry: geometry,
                            pilgrimageList: viewStore.state.favoritePilgrimages
                        )
                    }
                }
                .onChange(of: viewStore.state.favoritePilgrimages) { _ in
                    viewStore.send(.fetchFavorites)
                }
            }
        }
        .navigationTitle(R.string.localizable.navbar_pilgrimage_list())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonTextHidden()
    }

    private func pilgrimageListNavigationView(geometry: GeometryProxy, pilgrimageList: [PilgrimageInformation]) -> some View {
        NavigationView {
            List {
                ForEach(pilgrimageList, id: \.code) { pilgrimage in
                    ZStack {
                        NavigationLink(
                            destination: PilgrimageDetailView(
                                pilgrimage: pilgrimage,
                                store: store
                            )
                        ) {
                            EmptyView()
                        }
                        .opacity(0)

                        PilgrimageListContentView(pilgrimage: pilgrimage, store: store)
                            .frame(maxHeight: geometry.size.width / 3)
                    }
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
