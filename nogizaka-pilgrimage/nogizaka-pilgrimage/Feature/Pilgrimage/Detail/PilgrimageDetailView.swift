//
//  PilgrimageDetailView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/02.
//

import SwiftUI
import CoreLocation

struct PilgrimageDetailView: View {
    @Environment(\.theme) private var theme
    @State private var isShowAuthorizationAlert = false
    @Environment(LocationManager.self) private var locationManager
    @State private var viewModel = PilgrimageDetailViewModel()
    private let adSize = BannerViewContainer.getAdSize(width: UIScreen.main.bounds.width)
    let pilgrimage: PilgrimageEntity

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
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
                    .padding(.vertical, theme.margins.spacing_m)

                    HStack {
                        Text(pilgrimage.name)
                            .font(theme.fonts.title)

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
                    }
                    .padding(.bottom, theme.margins.spacing_xs)

                    Button {
                        let isAuthorized = !locationManager.isLocationPermissionDenied
                        guard isAuthorized else {
                            // 位置情報が許可されなかった場合
                            isShowAuthorizationAlert.toggle()
                            return
                        }

                        Task {
                            await viewModel.checkIn(
                                pilgrimage: pilgrimage,
                                userCoordinate: locationManager.userLocation!
                            )
                        }
                    } label: {
                        Text(viewModel.hasCheckedIn ?
                             R.string.localizable.has_check_in() :
                                R.string.localizable.check_in_button()
                        )
                        .frame(height: theme.margins.spacing_xl)
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.hasCheckedIn)
                    .alert(
                        viewModel.activeAlert?.title ?? "",
                        isPresented: $viewModel.isAlertPresented
                    ) {}
                    .alert(R.string.localizable.alert_location(), isPresented: $isShowAuthorizationAlert) {
                    } message: {
                        EmptyView()
                    }
                    .frame(maxWidth: .infinity)
                    .background(viewModel.hasCheckedIn ?
                                R.color.tab_primary_off()!.color :
                                    R.color.text_secondary()!.color
                    )
                    .foregroundStyle(.white)
                    .font(theme.fonts.caption)
                    .padding(.bottom, theme.margins.spacing_xl)

                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(R.color.text_secondary()!.color)
                        Text(pilgrimage.address)
                            .font(theme.fonts.bodyLarge)
                    }
                    .padding(.bottom, theme.margins.spacing_xl)

                    Text(pilgrimage.description)
                        .font(theme.fonts.bodyLarge)
                        .padding(.bottom, theme.margins.spacing_xxl)
                }
            }
            .readableContentGuide()

            BannerViewContainer(adUnitID: .pilgrimageDetail)
                .frame(width: adSize.size.width, height: adSize.size.height)
        }
        .onAppear {
            Task { await viewModel.onAppear(pilgrimage: pilgrimage) }
        }
        .padding(.leading, theme.margins.spacing_m)
        .padding(.trailing, theme.margins.spacing_m)
        .navigationTitle(R.string.localizable.navbar_pilgrimage_detail())
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PilgrimageDetailView(
        pilgrimage: dummyPilgrimageList[0]
    )
    .environment(LocationManager())
}
