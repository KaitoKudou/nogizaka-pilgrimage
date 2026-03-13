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
    @State private var containerWidth: CGFloat = 0
    let pilgrimages: [PilgrimageEntity]

    var body: some View {
        VStack {
            searchTextField()
                .padding(.top, theme.margins.spacing_xxs)
                .padding(.bottom, theme.margins.spacing_m)
                .padding(.horizontal, theme.margins.spacing_m)
                .background(Color(.tabPrimary))

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .controlSize(.large)
                Spacer()
            } else {
                pilgrimageListScrollView()
            }
        }
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newValue in
            containerWidth = newValue
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
        .navigationTitle(String(localized: .navbarPilgrimageList))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func searchTextField() -> some View {
        HStack(spacing: .zero) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
                .padding(.leading, theme.margins.spacing_xs)

            TextField(
                String(localized: .pilgrimageListPlaceholder),
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
        .border(Color(.tabPrimary), width: 1)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
    }

    private func pilgrimageListScrollView() -> some View {
        ScrollView {
            ScrollViewReader { proxy in
                LazyVStack(alignment: .leading) {
                    ForEach(viewModel.searchResults) { pilgrimage in
                        if pilgrimage.id % 5 == 0 {
                            NativeAdvanceView()
                                // コンテナ幅の 1/3 を高さとして使用
                                .frame(height: containerWidth / 3)
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
                            // コンテナ幅の 1/3 を最大高さとして使用
                            .frame(maxHeight: containerWidth / 3)
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

#Preview {
    PilgrimageListView(
        pilgrimages: dummyPilgrimageList
    )
}
