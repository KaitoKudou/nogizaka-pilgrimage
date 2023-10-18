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
    }
}

#Preview {
    PilgrimageMapView()
}
