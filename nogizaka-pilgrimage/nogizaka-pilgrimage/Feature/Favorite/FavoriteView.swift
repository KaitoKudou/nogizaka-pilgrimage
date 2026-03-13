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
    @State private var containerWidth: CGFloat = 0

    var body: some View {
        VStack {
            if viewModel.favoritePilgrimages.isEmpty {
                Text(.favoritesEmpty)
            } else if viewModel.isLoading {
                ProgressView()
                    .controlSize(.large)
                    .frame(alignment: .center)
            } else {
                favoriteScrollView()
            }
        }
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newValue in
            containerWidth = newValue
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
        .navigationTitle(String(localized: .tabbarFavorite))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func favoriteScrollView() -> some View {
        ScrollView {
            ScrollViewReader { proxy in
                LazyVStack(alignment: .leading) {
                    ForEach(viewModel.favoritePilgrimages) { pilgrimage in
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
                            // コンテナ幅の 1/3 を最大高さとして使用
                            .frame(maxHeight: containerWidth / 3)
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
