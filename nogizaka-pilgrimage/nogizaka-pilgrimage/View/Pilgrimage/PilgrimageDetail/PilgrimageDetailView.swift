//
//  PilgrimageDetailView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/02.
//

import ComposableArchitecture
import SwiftUI
import CoreLocation

struct PilgrimageDetailView: View {
    @Environment(\.theme) private var theme
    @State private var isShowAuthorizationAlert = false
    @State private var isShowUpdatedCheckedInAlert = false
    @State private var hasNetworkAlert = false
    @EnvironmentObject private var locationManager: LocationManager
    let pilgrimage: PilgrimageInformation
    let store: StoreOf<PilgrimageDetailFeature>
    private let distanceThreshold: Double = 100.0
    private let adSize = BannerView.getAdSize(width: UIScreen.main.bounds.width)

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
                                viewStore.send(.favoriteAction(.updateFavoriteList(pilgrimage)))
                            } label: {
                                if viewStore.state.favoriteState.isLoading {
                                    // 通信中の場合、インジケータを表示
                                    ProgressView()
                                } else if viewStore.state.favoriteState.favoritePilgrimages.contains(pilgrimage) {
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

                            viewStore.send(
                                .checkInAction(
                                    .calculateDistance(
                                        userCoordinate: locationManager.userLocation!,
                                        pilgrimageCoordinate: pilgrimage.coordinate
                                    )
                                )
                            )

                            if viewStore.state.checkInState.distance <= distanceThreshold {
                                viewStore.send(.checkInAction(.addCheckedInList(pilgrimage: pilgrimage)))
                            } else {
                                // 100m以内に聖地がない場合
                                viewStore.send(.showNotNearbyAlert)
                            }
                        } label: {
                            Text(viewStore.state.checkInState.hasCheckedIn ?
                                 R.string.localizable.has_check_in() :
                                    R.string.localizable.tabbar_check_in()
                            )
                            .frame(height: theme.margins.spacing_xl)
                        }
                        .disabled(viewStore.state.checkInState.hasCheckedIn)
                        .alert(store: store.scope(state: \.$alert, action: PilgrimageDetailFeature.Action.alertDismissed))
                        .alert(R.string.localizable.alert_location(), isPresented: $isShowAuthorizationAlert) {
                        } message: {
                            EmptyView()
                        }
                        .frame(maxWidth: .infinity)
                        .background(viewStore.state.checkInState.hasCheckedIn ?
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

                BannerView(adUnitID: .pilgrimageDetail)
                    .frame(
                        width: adSize.size.width,
                        height: adSize.size.height
                    )
            }
            .onAppear {
                viewStore.send(.checkInAction(.verifyCheckedIn(pilgrimage: pilgrimage)))
            }
            .onChange(of: viewStore.state.checkInState.hasError) { hasError in
                isShowUpdatedCheckedInAlert = hasError
            }
            .onChange(of: viewStore.state.favoriteState.hasNetworkError) { hasNetworkAlert in
                self.hasNetworkAlert = hasNetworkAlert
            }
            .alert(R.string.localizable.alert_network(), isPresented: $hasNetworkAlert) {
            } message: {
                EmptyView()
            }
            .alert(viewStore.state.checkInState.errorMessage, isPresented: $isShowUpdatedCheckedInAlert) {
            } message: {
                EmptyView()
            }
            .padding(.leading, theme.margins.spacing_m)
            .padding(.trailing, theme.margins.spacing_m)
            .navigationTitle(R.string.localizable.navbar_pilgrimage_detail())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonTextHidden()
        }
    }

    func calculateDistance(userCoordinate: CLLocationCoordinate2D, pilgrimageCoordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let pilgrimageLocation = CLLocation(latitude: pilgrimageCoordinate.latitude, longitude: pilgrimageCoordinate.longitude)

        return userLocation.distance(from: pilgrimageLocation)
    }
}

#Preview {
    PilgrimageDetailView(
        pilgrimage: dummyPilgrimageList[0],
        store: StoreOf<PilgrimageDetailFeature>(
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
