//
//  LocationManager.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/22.
//

import AppLogger
import CoreLocation
import Observation

@Observable
final class LocationManager {
    /// ユーザーの現在地の位置座標
    private(set) var userLocation: CLLocationCoordinate2D?
    /// 位置情報の利用許可状態
    private(set) var isLocationPermissionDenied: Bool = true

    private let delegate: Delegate
    private let clLocationManager = CLLocationManager()

    init() {
        delegate = Delegate()
        delegate.owner = self
    }

    func requestLocation() {
        // initで設定を書くと，アプリ起動時に許可ダイアログが出てしまうためここで設定を行う
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        clLocationManager.distanceFilter = 5
        clLocationManager.delegate = delegate

        if clLocationManager.authorizationStatus == .notDetermined {
            // 位置情報を利用するか未設定の場合に利用許可を求めるアラートを表示
            clLocationManager.requestWhenInUseAuthorization()
        } else {
            switch clLocationManager.authorizationStatus {
            case .restricted, .denied:
                isLocationPermissionDenied = true
            case .authorizedWhenInUse:
                isLocationPermissionDenied = false
            default: break
            }
            clLocationManager.startUpdatingLocation()
        }
    }
}

private extension LocationManager {
    final class Delegate: NSObject, CLLocationManagerDelegate {
        weak var owner: LocationManager?

        /// 許可状態のステータスが変更された際に呼ばれる
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
            case .notDetermined:
                // 位置情報を利用するか未設定の場合に利用許可を求めるアラートを表示
                manager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                // .restricted: 位置情報を利用する権限がない
                // .denied: ユーザが明示的に位置情報の利用を拒否
                owner?.isLocationPermissionDenied = true
            case .authorizedWhenInUse:
                // アプリを使用している間のみ位置情報の利用を許可
                // 位置情報利用が許可がされたらStateに通知
                manager.startUpdatingLocation()
                owner?.isLocationPermissionDenied = false
            case .authorizedAlways:
                // 位置情報の利用を常に許可
                break
            @unknown default:
                break
            }
        }

        /// 位置情報取得成功時に呼ばれる
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else {
                manager.stopUpdatingLocation()
                return
            }
            owner?.userLocation = location.coordinate
        }

        /// 位置情報取得失敗時に呼ばれる
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            #log(.error, "didFailWithError: \(error.localizedDescription)")
        }
    }
}
