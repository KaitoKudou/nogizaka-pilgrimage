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
    @State private var region = PilgrimageMapConstant.initialRegion
    let pilgrimage = dummyPilgrimageList

    var body: some View {
        GeometryReader { geometry in
            Map(
                coordinateRegion: $region,
                annotationItems: dummyPilgrimageList,
                annotationContent: { item in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: item.coordinate.latitude,
                        longitude: item.coordinate.longitude
                    )) {
                        Image(uiImage: R.image.map_pin()!)
                    }
                }
            )
            .edgesIgnoringSafeArea(.all)
            .overlay(alignment: .bottom) {
                pilgrimageCardsView(geometry: geometry)
                    .padding(.bottom, theme.margins.spacing_xl)
            }
        }
    }

    private func pilgrimageCardsView(geometry: GeometryProxy) -> some View {

        TabView {
            ForEach(Array(dummyPilgrimageList.enumerated()), id: \.element.id) { index, pilgrimage in
                PilgrimageCardView(pilgrimage: pilgrimage)
                    .frame(
                        width: max(0, geometry.size.width - theme.margins.spacing_l * 2)
                    )
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(
            height: max(0, geometry.size.width / 2 - theme.margins.spacing_m)
        )
    }
}

#Preview {
    PilgrimageMapView()
}
