//
//  PilgrimageCardView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/30.
//

import NukeUI
import SwiftUI

struct PilgrimageCardView: View {
    @Environment(\.theme) private var theme
    @State private var viewModel = PilgrimageCardViewModel()
    let pilgrimage: PilgrimageEntity

    var body: some View {
        HStack(spacing: theme.margins.spacing_m) {
            VStack {
                LazyImage(url: pilgrimage.imageURL) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        // 画像取得中のプレースホルダー表示
                        Image(.placeholder)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                }

                if let copyright = pilgrimage.copyright {
                    Text(copyright)
                        .font(theme.fonts.captionSmall)
                }
            }

            VStack(alignment: .leading, spacing: .zero) {
                HStack {
                    Text(pilgrimage.name)
                        .font(theme.fonts.bodyMedium)

                    Spacer()

                    Button {
                        Task { await viewModel.toggleFavorite(pilgrimage) }
                    } label: {
                        if viewModel.isLoading {
                            // 通信中の場合、インジケータを表示
                            ProgressView()
                        } else if viewModel.favorited {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                        } else {
                            Image(systemName: "heart")
                                .foregroundStyle(Color(.tabPrimaryOff))
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
                .padding(.bottom, theme.margins.spacing_m)

                Text(pilgrimage.address)
                    .font(theme.fonts.caption)

                Spacer()

                HStack(spacing: theme.margins.spacing_xs) {
                    Group {
                        Button {
                            viewModel.showRouteDialog(
                                latitude: pilgrimage.latitude,
                                longitude: pilgrimage.longitude
                            )
                        } label: {
                            Text(.commonBtnRouteSearchText)
                        }

                        NavigationLink(
                            destination:
                                PilgrimageDetailView(pilgrimage: pilgrimage)
                        ) {
                            Text(.commonBtnDetailText)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 26)
                    .background(Color(.textSecondary))
                    .foregroundStyle(.white)
                    .font(theme.fonts.caption)
                }
            }
            .onAppear {
                Task { await viewModel.onAppear(pilgrimage: pilgrimage) }
            }
            .alert(
                viewModel.activeAlert?.title ?? "",
                isPresented: $viewModel.isAlertPresented
            ) {}
            .confirmationDialog(
                "",
                isPresented: $viewModel.isConfirmationDialogPresented
            ) {
                Button(String(localized: .confirmationDialogAppleMap)) {
                    Task { await viewModel.openAppleMaps() }
                }
                Button(String(localized: .confirmationDialogGoogleMaps)) {
                    Task { await viewModel.openGoogleMaps() }
                }
                Button(String(localized: .confirmationDialogCancel), role: .cancel) {}
            }
        }
        .padding(.all)
        .background(.white)
    }
}

// iPhone 15基準（幅393pt）でカードサイズを算出: 393 - 64 = 329, 393 / 2 - 32 ≈ 164
#Preview(traits: .fixedLayout(width: 329, height: 164)) {
    PilgrimageCardView(
        pilgrimage: dummyPilgrimageList[0]
    )
}
