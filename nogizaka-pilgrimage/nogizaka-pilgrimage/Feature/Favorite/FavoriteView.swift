//
//  FavoriteView.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/02/24.
//

import SwiftUI

struct FavoriteView: View {
    @Environment(\.theme) private var theme
    @State private var viewModel = FavoriteViewModel()

    var body: some View {
        VStack {
            if viewModel.favoritePilgrimages.isEmpty {
                Text(R.string.localizable.favorites_empty())
            } else if viewModel.isLoading {
                ProgressView()
                    .controlSize(.large)
                    .frame(alignment: .center)
            } else {
                GeometryReader { geometry in
                    favoriteScrollView(geometry: geometry)
                }
            }
        }
        .onAppear {
            Task { await viewModel.fetchFavorites() }
        }
        .alert(
            viewModel.alertMessage ?? "",
            isPresented: $viewModel.showAlert
        ) {
            Button("OK") {}
        }
        .navigationTitle(R.string.localizable.tabbar_favorite())
        .navigationBarTitleDisplayMode(.inline)
    }

    private func favoriteScrollView(geometry: GeometryProxy) -> some View {
        ScrollView {
            ScrollViewReader { proxy in
                LazyVStack(alignment: .leading) {
                    ForEach(viewModel.favoritePilgrimages) { pilgrimage in
                        if pilgrimage.id % 5 == 0 {
                            NativeAdvanceView()
                                .frame(height: geometry.size.width / 3)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }

                        NavigationLink(
                            destination: PilgrimageDetailView(pilgrimage: pilgrimage)
                                .onAppear {
                                    viewModel.scrollToIndex = pilgrimage.id
                                }
                        ) {
                            PilgrimageListContentView(
                                pilgrimage: pilgrimage,
                                isLoading: viewModel.isItemLoading(pilgrimage),
                                favorited: true,
                                onFavoriteToggle: {
                                    Task { await viewModel.toggleFavorite(pilgrimage) }
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
                    proxy.scrollTo(viewModel.scrollToIndex, anchor: .center)
                }
            }
        }
    }
}

#Preview {
    FavoriteView()
}
