//
//  MapCameraCommand.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/22.
//

import CoreLocation
import Foundation

/// マップカメラの移動を指示するコマンド。
/// 指定した座標にカメラを移動し、カード領域を考慮した Y オフセットで表示位置を調整する。
struct MapCameraCommand: Identifiable, Equatable {
    static func == (lhs: MapCameraCommand, rhs: MapCameraCommand) -> Bool {
        return lhs.id == rhs.id
    }

    init(id: UUID = UUID(),
         target: CLLocationCoordinate2D,
         yOffset: CGFloat,
         animated: Bool
    ) {
        self.id = id
        self.target = target
        self.yOffset = yOffset
        self.animated = animated
    }

    var id = UUID()
    let target: CLLocationCoordinate2D
    let yOffset: CGFloat
    let animated: Bool
}
