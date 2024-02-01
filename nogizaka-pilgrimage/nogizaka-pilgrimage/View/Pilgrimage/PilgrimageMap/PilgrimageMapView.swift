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
    @State private var region = PilgrimageMapConstant.initialRegion
    @State private var selectedIndex: Int = 0
    @State var store = Store(initialState: FavoriteFeature.State()) {
        FavoriteFeature()
    }
    @State private var isShowAlert = false
    @EnvironmentObject private var locationManager: LocationManager

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
                            self.region.center = offsetAppliedCenter(to: location, geometry: geometry)
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
                .onChange(of: selectedIndex) { _ in
                    withAnimation {
                        region.center = offsetAppliedCenter(
                            to: dummyPilgrimageList[selectedIndex].coordinate,
                            geometry: geometry
                        )
                    }
                }
        }
    }

    private var mapView: some View {
        Map(
            coordinateRegion: $region,
            showsUserLocation: true,
            annotationItems: dummyPilgrimageList,
            annotationContent: { item in
                let coordinate = CLLocationCoordinate2D(
                    latitude: item.coordinate.latitude,
                    longitude: item.coordinate.longitude
                )
                let index = dummyPilgrimageList.firstIndex(where: { $0.code == item.code }) ?? 0

                return MapAnnotation(coordinate: coordinate) {
                    Image(uiImage: R.image.map_pin()!)
                        .onTapGesture {
                            selectedIndex = index
                        }
                }
            }
        )
    }

    private func pilgrimageCardsView(geometry: GeometryProxy) -> some View {
        TabView(selection: $selectedIndex) {
            ForEach(Array(dummyPilgrimageList.enumerated()), id: \.element.id) { index, pilgrimage in
                PilgrimageCardView(pilgrimage: pilgrimage, store: store)
                    .tag(index)
                    .frame(
                        width: max(0, geometry.size.width - theme.margins.spacing_l * 2)
                    )
                    .environmentObject(locationManager)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: cardsHeight(geometry: geometry))
    }

    private func cardsHeight(geometry: GeometryProxy) -> CGFloat {
        return max(0, geometry.size.width / 2 - theme.margins.spacing_m)
    }

    private func offsetAppliedCenter(to center: CLLocationCoordinate2D, geometry: GeometryProxy) -> CLLocationCoordinate2D {
        let ratio = (cardsHeight(geometry: geometry) / 2) / geometry.size.height
        let latitudeOffset = ratio * region.span.latitudeDelta
        let coordinate = CLLocationCoordinate2D(
            latitude: center.latitude - latitudeOffset,
            longitude: center.longitude
        )
        return coordinate
    }
}

#Preview {
    PilgrimageMapView()
        .environmentObject(LocationManager())
}
