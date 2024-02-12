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
    @State private var isFavorite = false
    @State private var isShowAuthorizationAlert = false
    @State private var isNotNearbyAlert = false
    @EnvironmentObject private var locationManager: LocationManager
    let pilgrimage: PilgrimageInformation
    let store: StoreOf<PilgrimageDetailFeature>
    let distanceThreshold: Double = 100.0

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack(alignment: .leading) {
                    AsyncImage(url: pilgrimage.imageURL) { image in
                        // TODO: 聖地の画像を表示
                    } placeholder: {
                        // 画像取得中のプレースホルダー表示
                        Image(R.image.no_image.name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .padding(.bottom, theme.margins.spacing_m)

                    HStack {
                        Text(pilgrimage.name)
                            .font(theme.fonts.title)

                        Spacer()

                        Button {
                            viewStore.send(.favoriteAction(.updateFavoriteList(pilgrimage)))
                            viewStore.send(.favoriteAction(.toggleFavorite(pilgrimage)))
                            withAnimation {
                                self.isFavorite = viewStore.state.favoriteState.isFavorite
                            }
                        } label: {
                            if isFavorite {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.red)
                            } else {
                                Image(systemName: "heart")
                                    .foregroundStyle(R.color.tab_primar_off()!.color)
                            }
                        }
                    }
                    .padding(.bottom, theme.margins.spacing_xs)

                    Button {
                        // 位置情報許可ステータスをチェック
                        let isAuthorized = !locationManager.isLocationPermissionDenied
                        guard isAuthorized else {
                            // 位置情報が許可されなかった場合
                            isShowAuthorizationAlert.toggle()
                            return
                        }
                        let distance = calculateDistance(userCoordinate: locationManager.userLocation!, pilgrimageCoordinate: pilgrimage.coordinate)
                        print("現在位置から\(pilgrimage.name)までの距離：\(distance)")
                        if distance <= distanceThreshold {
                            // TODO: チェックイン処理
                            print("TODO: チェックイン処理")
                        } else {
                            // 50m以内に聖地がない場合
                            isNotNearbyAlert.toggle()
                        }
                    } label: {
                        Text(R.string.localizable.tabbar_check_in())
                            .frame(height: theme.margins.spacing_xl)
                    }
                    .alert(R.string.localizable.alert_location(), isPresented: $isShowAuthorizationAlert) {
                    } message: {
                        EmptyView()
                    }
                    .alert(R.string.localizable.alert_not_nearby(),
                           isPresented: $isNotNearbyAlert) {
                    } message: {
                        EmptyView()
                    }
                    .frame(maxWidth: .infinity)
                    .background(R.color.text_secondary()!.color)
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
            .onAppear {
                viewStore.send(.favoriteAction(.toggleFavorite(pilgrimage)))
                self.isFavorite = viewStore.state.favoriteState.isFavorite
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
