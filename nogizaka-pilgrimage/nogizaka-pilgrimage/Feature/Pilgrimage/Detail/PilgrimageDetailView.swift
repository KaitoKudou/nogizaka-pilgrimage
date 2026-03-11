//
//  PilgrimageDetailView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/02.
//

import CoreLocation
import NukeUI
import SwiftUI

struct PilgrimageDetailView: View {
    @Environment(\.theme) private var theme
    @State private var isShowAuthorizationAlert = false
    @Environment(LocationManager.self) private var locationManager
    @State private var viewModel = PilgrimageDetailViewModel()
    let pilgrimage: PilgrimageEntity

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
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
                                    .foregroundStyle(Color(.tabPrimaryOff))
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
                             String(localized: .hasCheckIn) :
                                String(localized: .checkInButton)
                        )
                        .frame(height: theme.margins.spacing_xl)
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.hasCheckedIn)
                    .alert(
                        viewModel.activeAlert?.title ?? "",
                        isPresented: $viewModel.isAlertPresented
                    ) {}
                    .alert(String(localized: .alertLocation), isPresented: $isShowAuthorizationAlert) {
                    } message: {
                        EmptyView()
                    }
                    .frame(maxWidth: .infinity)
                    .background(viewModel.hasCheckedIn ?
                                Color(.tabPrimaryOff) :
                                    Color(.textSecondary)
                    )
                    .foregroundStyle(.white)
                    .font(theme.fonts.caption)
                    .padding(.bottom, theme.margins.spacing_xl)

                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundStyle(Color(.textSecondary))
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
        }
        .onAppear {
            Task { await viewModel.onAppear(pilgrimage: pilgrimage) }
        }
        .padding(.leading, theme.margins.spacing_m)
        .padding(.trailing, theme.margins.spacing_m)
        .navigationTitle(String(localized: .navbarPilgrimageDetail))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PilgrimageDetailView(
        pilgrimage: dummyPilgrimageList[0]
    )
    .environment(LocationManager())
}
