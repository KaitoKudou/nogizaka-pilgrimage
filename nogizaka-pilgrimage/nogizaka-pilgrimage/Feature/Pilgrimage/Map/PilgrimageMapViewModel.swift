//
//  PilgrimageMapViewModel.swift
//  nogizaka-pilgrimage
//
//  Created by k_kudo on 2026/03/22.
//

import CoreLocation
import Foundation

@MainActor
@Observable
final class PilgrimageMapViewModel {
    var selectedIndex: Int
    private var hasSetInitialLocation = false

    let pilgrimages: [PilgrimageEntity]

    private static let nogizakaStationCode = "130001"

    init(pilgrimages: [PilgrimageEntity], userLocation: CLLocationCoordinate2D? = nil) {
        self.pilgrimages = pilgrimages
        if let userLocation {
            self.selectedIndex = Self.nearestIndex(for: pilgrimages, from: userLocation)
            self.hasSetInitialLocation = true
        } else {
            self.selectedIndex = Self.defaultIndex(for: pilgrimages)
        }
    }

    /// 指定された聖地リストから乃木坂駅のインデックスを返す。見つからなければ 0。
    static func defaultIndex(for pilgrimages: [PilgrimageEntity]) -> Int {
        pilgrimages.firstIndex(where: { $0.code == nogizakaStationCode }) ?? 0
    }

    /// ユーザー位置から最も近い聖地のインデックスを返す。
    func nearestPilgrimageIndex(from userLocation: CLLocationCoordinate2D) -> Int {
        Self.nearestIndex(for: pilgrimages, from: userLocation)
    }

    /// 指定位置から最も近い聖地のインデックスを返す。
    static func nearestIndex(for pilgrimages: [PilgrimageEntity], from userLocation: CLLocationCoordinate2D) -> Int {
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

    /// 初回のみ、ユーザーの現在地から最も近い聖地を選択する。
    @discardableResult
    func selectNearestPilgrimageIfNeeded(userLocation: CLLocationCoordinate2D?) -> Bool {
        guard !hasSetInitialLocation,
              let userLocation else { return false }
        hasSetInitialLocation = true
        let nearestIndex = nearestPilgrimageIndex(from: userLocation)
        if nearestIndex != selectedIndex {
            selectedIndex = nearestIndex
            return true
        }
        return false
    }
}
