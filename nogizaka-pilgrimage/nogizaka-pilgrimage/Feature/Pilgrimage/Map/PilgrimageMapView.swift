//
//  PilgrimageMapView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/11.
//

import MapKit
import SwiftUI

struct PilgrimageMapView: View {
    @Environment(\.theme) private var theme
    @State private var viewModel: PilgrimageMapViewModel
    @State private var centerCommand: MapCameraCommand?
    @State private var isShowAlert = false
    @State private var containerWidth: CGFloat = 0
    @Environment(LocationManager.self) private var locationManager

    init(pilgrimages: [PilgrimageEntity]) {
        viewModel = .init(pilgrimages: pilgrimages)
    }

    var body: some View {
        mapView
            .ignoresSafeArea(edges: [.bottom])
            .overlay(alignment: .topTrailing) {
                CurrentLocationButton {
                    let isAuthorized = !locationManager.isLocationPermissionDenied
                    guard isAuthorized else {
                        // 位置情報が許可されなかった場合
                        isShowAlert.toggle()
                        return
                    }
                    guard let location = locationManager.userLocation else {
                        return
                    }
                    withAnimation {
                        centerCommand = .init(
                            target: location,
                            yOffset: cardYOffset(),
                            animated: true
                        )
                    }
                }
                .alert(String(localized: .alertLocation), isPresented: $isShowAlert) {
                } message: {
                    EmptyView()
                }

            }
            .overlay(alignment: .bottom) {
                pilgrimageCardsView()
                    .padding(.bottom, theme.margins.spacing_xl)
            }
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.width
            } action: { newValue in
                containerWidth = newValue
            }
            .onAppear {
                locationManager.requestLocation()
                viewModel.selectNearestPilgrimageIfNeeded(userLocation: locationManager.userLocation)
            }
            .onChange(of: locationManager.userLocation?.latitude) { _, _ in
                viewModel.selectNearestPilgrimageIfNeeded(userLocation: locationManager.userLocation)
            }
            .onChange(of: viewModel.selectedIndex) { _, newIndex in
                withAnimation(.easeInOut(duration: 0.3)) {
                    centerCommand = .init(
                        target: viewModel.pilgrimages[newIndex].coordinate,
                        yOffset: cardYOffset(),
                        animated: true
                    )
                }
            }
    }

    private var mapView: some View {
        ClusterMapView(
            selectedIndex: $viewModel.selectedIndex,
            centerCommand: $centerCommand,
            initialRegion: PilgrimageMapConstant.initialRegion,
            initialYOffset: cardYOffset(),
            mapWidth: containerWidth,
            pilgrimages: viewModel.pilgrimages,
            showsUserLocation: true,
            onAnnotationSelected: { index in
                withAnimation {
                    viewModel.selectedIndex = index
                }
            }
        )
    }

    private func pilgrimageCardsView() -> some View {
        TabView(selection: $viewModel.selectedIndex) {
            ForEach(Array(viewModel.pilgrimages.enumerated()), id: \.element.id) { index, pilgrimage in
                PilgrimageCardView(pilgrimage: pilgrimage)
                .tag(index)
                .frame(
                    width: max(0, containerWidth - theme.margins.spacing_l * 2)
                )
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: cardsHeight())
    }

    // コンテナ幅の 1/2 からマージンを引いた値をカード高さとして使用
    private func cardsHeight() -> CGFloat {
        return max(0, containerWidth / 2 - theme.margins.spacing_m)
    }

    // カード高さの半分をマップの Y オフセットとして使用
    private func cardYOffset() -> CGFloat {
        cardsHeight() / 2
    }
}

#Preview {
    PilgrimageMapView(
        pilgrimages: dummyPilgrimageList
    )
    .environment(LocationManager())
}
