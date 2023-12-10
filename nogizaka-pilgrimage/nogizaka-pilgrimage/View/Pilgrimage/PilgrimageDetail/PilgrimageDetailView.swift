//
//  PilgrimageDetailView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/02.
//

import ComposableArchitecture
import SwiftUI

struct PilgrimageDetailView: View {
    @Environment(\.theme) private var theme
    @State private var isFavorite = false
    @State private var isShowAlert = false
    @EnvironmentObject private var locationManager: LocationManager
    let pilgrimage: PilgrimageInformation
    let store: StoreOf<FavoriteFeature>

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
                            viewStore.send(.updateFavoriteList(pilgrimage))
                            viewStore.send(.toggleFavorite(pilgrimage))
                            withAnimation {
                                self.isFavorite = viewStore.state.isFavorite
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
                        // TODO: チェックイン処理

                        // 位置情報許可ステータスをチェック
                        let isAuthorized = !locationManager.isLocationPermissionDenied
                        guard isAuthorized else {
                            // 位置情報が許可されなかった場合
                            isShowAlert.toggle()
                            return
                        }
                        print("TODO: チェックイン処理")
                    } label: {
                        Text(R.string.localizable.tabbar_check_in())
                            .frame(height: theme.margins.spacing_xl)
                    }
                    .alert(R.string.localizable.alert_location(), isPresented: $isShowAlert) {
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
                viewStore.send(.toggleFavorite(pilgrimage))
                self.isFavorite = viewStore.state.isFavorite
            }
            .padding(.leading, theme.margins.spacing_m)
            .padding(.trailing, theme.margins.spacing_m)
            .navigationTitle(R.string.localizable.navbar_pilgrimage_detail())
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonTextHidden()
        }
    }
}

#Preview {
    PilgrimageDetailView(
        pilgrimage: dummyPilgrimageList[0],
        store: StoreOf<FavoriteFeature>(initialState: FavoriteFeature.State()) {
            FavoriteFeature()
        }
    )
}
