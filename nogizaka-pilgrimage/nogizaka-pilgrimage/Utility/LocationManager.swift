//
//  LocationManager.swift
//  nogizaka-pilgrimage
//
//  Created by 工藤 海斗 on 2023/11/22.
//

import CoreLocation

final class LocationManager: NSObject, ObservableObject {
    /// ユーザーの現在地の位置座標
    @Published private(set) var userLocation: CLLocationCoordinate2D?
    /// 位置情報の利用許可状態
    @Published private(set) var isLocationPermissionDenied: Bool = true

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
    }

    func requestLocation() {
        // initで設定を書くと，アプリ起動時に許可ダイアログが出てしまうためここ設定を行う
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000
        locationManager.delegate = self

        if locationManager.authorizationStatus == .notDetermined {
            // 位置情報を利用するか未設定の場合に利用許可を求めるアラートを表示
            locationManager.requestWhenInUseAuthorization()
        } else {
            switch locationManager.authorizationStatus {
            case .restricted, .denied:
                isLocationPermissionDenied = true
            case .authorizedWhenInUse:
                isLocationPermissionDenied = false
            default: break
            }
            // ユーザーの現在地の配信を１回だけ要求する
            locationManager.startUpdatingLocation()
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    /// 許可状態のステータスが変更された際に呼ばれる
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            // 位置情報を利用するか未設定の場合に利用許可を求めるアラートを表示
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // .restricted: 位置情報を利用する権限がない
            // .denied: ユーザが明示的に位置情報の利用を拒否
            isLocationPermissionDenied = true
        case .authorizedWhenInUse:
            // アプリを使用している間のみ位置情報の利用を許可
            // 位置情報利用が許可がされたらStateに通知
            locationManager.startUpdatingLocation()
            isLocationPermissionDenied = false
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
            locationManager.stopUpdatingLocation()
            return
        }
        userLocation = location.coordinate
    }

    /// 位置情報取得失敗時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError error=\(error.localizedDescription)")
    }
}
