//
//  PilgrimageMapView.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/11.
//

import ComposableArchitecture
import MapKit
import SwiftUI

struct PilgrimageMapView: View {
    @Environment(\.theme) private var theme
    @State private var selectedIndex: Int = 0
    @State private var centerCommand: ClusterMapView.CenterCommand?
    @State private var isShowAlert = false
    @EnvironmentObject private var locationManager: LocationManager
    let pilgrimages: [PilgrimageInformation]

    var body: some View {
        GeometryReader { geometry in
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
                                yOffset: cardsHeight(geometry: geometry) / 2,
                                animated: true
                            )
                        }
                    }
                    .alert(R.string.localizable.alert_location(), isPresented: $isShowAlert) {
                    } message: {
                        EmptyView()
                    }

                }
                .overlay(alignment: .bottom) {
                    pilgrimageCardsView(geometry: geometry)
                        .padding(.bottom, theme.margins.spacing_xl)
                }
                .onAppear {
                    locationManager.requestLocation()
                }
                .onChange(of: selectedIndex) { _, newIndex in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        centerCommand = .init(
                            target: pilgrimages[newIndex].coordinate,
                            yOffset: cardsHeight(geometry: geometry) / 2,
                            animated: true
                        )
                    }
                }
        }
    }

    private var mapView: some View {
        GeometryReader { geometry in
            ClusterMapView(
                selectedIndex: $selectedIndex,
                centerCommand: $centerCommand,
                initialRegion: PilgrimageMapConstant.initialRegion,
                pilgrimages: pilgrimages,
                showsUserLocation: true,
                onAnnotationSelected: { index in
                    withAnimation {
                        selectedIndex = index
                    }
                }
            )
        }
    }

    private func pilgrimageCardsView(geometry: GeometryProxy) -> some View {
        TabView(selection: $selectedIndex) {
            ForEach(Array(pilgrimages.enumerated()), id: \.element.id) { index, pilgrimage in
                PilgrimageCardView(pilgrimage: pilgrimage)
                .tag(index)
                .frame(
                    width: max(0, geometry.size.width - theme.margins.spacing_l * 2)
                )
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: cardsHeight(geometry: geometry))
    }

    private func cardsHeight(geometry: GeometryProxy) -> CGFloat {
        return max(0, geometry.size.width / 2 - theme.margins.spacing_m)
    }
}

#Preview {
    PilgrimageMapView(
        pilgrimages: dummyPilgrimageList
    )
    .environmentObject(LocationManager())
}
