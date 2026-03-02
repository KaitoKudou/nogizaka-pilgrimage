//
//  PilgrimageAnnotation.swift
//  nogizaka-pilgrimage
//
//  Created on 2025/08/06.
//

import MapKit

final class PilgrimageAnnotation: NSObject, MKAnnotation {
    let pilgrimage: PilgrimageInformation
    let coordinate: CLLocationCoordinate2D
    let index: Int
    var title: String? { return pilgrimage.name }
    
    init(pilgrimage: PilgrimageInformation, index: Int) {
        self.pilgrimage = pilgrimage
        self.coordinate = pilgrimage.coordinate
        self.index = index
    }
}
