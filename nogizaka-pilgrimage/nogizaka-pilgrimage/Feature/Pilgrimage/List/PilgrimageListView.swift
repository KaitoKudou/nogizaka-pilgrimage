//
//  PilgrimageListView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/19.
//

import SwiftUI

struct PilgrimageListView: View {
    @Environment(\.theme) private var theme
    @State private var searchText = ""
    @State private var viewModel = PilgrimageListViewModel()
    let pilgrimages: [PilgrimageEntity]

    var body: some View {
        GeometryReader { geometry in
            VStack {
                searchTextField()
                    .padding(.top, theme.margins.spacing_xxs)
                    .padding(.bottom, theme.margins.spacing_m)
                    .padding(.horizontal, theme.margins.spacing_m)
                    .background(R.color.tab_primary()!.color)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .controlSize(.large)
                    Spacer()
                } else {
                    pilgrimageListScrollView(geometry: geometry)
                }
            }
            .onAppear {
                searchText = viewModel.searchText
                viewModel.onAppear(pilgrimages: pilgrimages)
            }
            .task {
                await viewModel.loadFavoriteStatuses()
            }
            .alert(
                viewModel.activeAlert?.title ?? "",
                isPresented: $viewModel.isAlertPresented
            ) {}
        }
        .navigationTitle(R.string.localizable.navbar_pilgrimage_list())
        .navigationBarTitleDisplayMode(.inline)
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
                viewModel.searchPilgrimages(searchText)
            }
        }
        .background(.white)
        .border(R.color.tab_primary()!.color, width: 1)
        .cornerRadius(8.0)
    }

    private func pilgrimageListScrollView(geometry: GeometryProxy) -> some View {
        NavigationStack {
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVStack(alignment: .leading) {
                        ForEach(viewModel.searchResults) { pilgrimage in
                            if pilgrimage.id % 5 == 0 {
                                NativeAdvanceView()
                                    .frame(height: geometry.size.width / 3)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                            }

                            NavigationLink(
                                destination: PilgrimageDetailView(pilgrimage: pilgrimage)
                                    .onAppear {
                                        viewModel.updateScrollToIndex(pilgrimage.id)
                                    }
                            ) {
                                PilgrimageListContentView(
                                    pilgrimage: pilgrimage,
                                    isLoading: viewModel.isItemLoading(pilgrimage),
                                    favorited: viewModel.isFavorited(pilgrimage),
                                    onFavoriteToggle: {
                                        Task { await viewModel.toggleFavorite(pilgrimage: pilgrimage) }
                                    }
                                )
                                .frame(maxHeight: geometry.size.width / 3)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .id(pilgrimage.id)
                            }
                        }
                    }
                    .onAppear {
                        proxy.scrollTo(
                            viewModel.scrollToIndex, anchor: .center
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    PilgrimageListView(
        pilgrimages: dummyPilgrimageList
    )
}
