//
//  PilgrimageMapView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/11.
//

import CoreLocation
import MapKit
import SwiftUI

struct PilgrimageMapView: View {
    @Environment(\.theme) private var theme
    @State private var selectedIndex: Int
    @State private var centerCommand: ClusterMapView.CenterCommand?
    @State private var isShowAlert = false
    @State private var containerWidth: CGFloat = 0
    @State private var hasSetInitialLocation = false
    @Environment(LocationManager.self) private var locationManager
    let pilgrimages: [PilgrimageEntity]

    private static let nogizakaStationCode = "130001"

    init(pilgrimages: [PilgrimageEntity]) {
        self.pilgrimages = pilgrimages
        self.selectedIndex = pilgrimages.firstIndex(where: { $0.code == Self.nogizakaStationCode }) ?? 0
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
                selectNearestPilgrimageIfNeeded()
            }
            .onChange(of: locationManager.userLocation?.latitude) { _, _ in
                selectNearestPilgrimageIfNeeded()
            }
            .onChange(of: selectedIndex) { _, newIndex in
                withAnimation(.easeInOut(duration: 0.3)) {
                    centerCommand = .init(
                        target: pilgrimages[newIndex].coordinate,
                        yOffset: cardYOffset(),
                        animated: true
                    )
                }
            }
    }

    private var mapView: some View {
        ClusterMapView(
            selectedIndex: $selectedIndex,
            centerCommand: $centerCommand,
            initialRegion: PilgrimageMapConstant.initialRegion,
            initialYOffset: cardYOffset(),
            mapWidth: containerWidth,
            pilgrimages: pilgrimages,
            showsUserLocation: true,
            onAnnotationSelected: { index in
                withAnimation {
                    selectedIndex = index
                }
            }
        )
    }

    private func pilgrimageCardsView() -> some View {
        TabView(selection: $selectedIndex) {
            ForEach(Array(pilgrimages.enumerated()), id: \.element.id) { index, pilgrimage in
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

    /// ユーザーの現在地から最も近い聖地を選択する（初回のみ）
    private func selectNearestPilgrimageIfNeeded() {
        guard !hasSetInitialLocation,
              let userLocation = locationManager.userLocation else { return }
        hasSetInitialLocation = true
        let nearestIndex = nearestPilgrimageIndex(from: userLocation)
        if nearestIndex != selectedIndex {
            selectedIndex = nearestIndex
        }
    }

    /// ユーザーの現在地から最も近い聖地のインデックスを返す
    private func nearestPilgrimageIndex(from userLocation: CLLocationCoordinate2D) -> Int {
        guard !pilgrimages.isEmpty else { return 0 }
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        var nearestIndex = 0
        var nearestDistance = Double.greatestFiniteMagnitude
        for (index, pilgrimage) in pilgrimages.enumerated() {
            let distance = userCLLocation.distance(
                from: CLLocation(latitude: pilgrimage.coordinate.latitude, longitude: pilgrimage.coordinate.longitude)
            )
            if distance < nearestDistance {
                nearestDistance = distance
                nearestIndex = index
            }
        }
        return nearestIndex
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
