//
//  PilgrimageCardView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/30.
//

import SwiftUI

struct PilgrimageCardView: View {
    @Environment(\.theme) private var theme
    @State private var viewModel = PilgrimageCardViewModel()
    let pilgrimage: PilgrimageEntity

    var body: some View {
        HStack(spacing: theme.margins.spacing_m) {
            VStack {
                AsyncImage(url: pilgrimage.imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)

                } placeholder: {
                    // 画像取得中のプレースホルダー表示
                    Image(R.image.no_image.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
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
                                .foregroundStyle(R.color.tab_primary_off()!.color)
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
                            Text(R.string.localizable.common_btn_route_search_text())
                        }

                        NavigationLink(
                            destination:
                                PilgrimageDetailView(pilgrimage: pilgrimage)
                        ) {
                            Text(R.string.localizable.common_btn_detail_text())
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 26)
                    .background(R.color.text_secondary()!.color)
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
                Button(R.string.localizable.confirmation_dialog_apple_map()) {
                    Task { await viewModel.openAppleMaps() }
                }
                Button(R.string.localizable.confirmation_dialog_google_maps()) {
                    Task { await viewModel.openGoogleMaps() }
                }
                Button(R.string.localizable.confirmation_dialog_cancel(), role: .cancel) {}
            }
        }
        .padding(.all)
        .background(.white)
    }
}

struct PilgrimageCardView_Previews: PreviewProvider {
    static var previews: some View {
        PilgrimageCardView(
            pilgrimage: dummyPilgrimageList[0]
        )
        .frame(width: UIScreen.main.bounds.width - 64, height: UIScreen.main.bounds.width / 2 - 32)
        .previewLayout(.sizeThatFits)
    }
}
