//
//  PilgrimageMapConstant.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/10/18.
//

import Foundation
import MapKit

// MARK: 聖地マップで使用する定数
enum PilgrimageMapConstant {
    /// 中心点から東西軸に沿った境界までの距離として指定される、領域の東西方向の長さ (メートル単位)
    static let initialLatitudinalMeters: CLLocationDistance = 1000
    /// 中心点から南北軸に沿った境界までの距離として指定される、領域の南北方向の長さ (メートル単位)
    static let initialLongitudinalMeters: CLLocationDistance = 1000

    /// マップのリージョンの初期値
    /// 乃木坂駅を指定。
    static let initialRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 35.666827 - 0.0029,
            longitude: 139.726497
        ),
        latitudinalMeters: initialLatitudinalMeters,
        longitudinalMeters: initialLongitudinalMeters
    )
}
